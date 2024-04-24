
from random import randrange
import math


class FixedPoint:
    def __init__(self, precision, exponent):
        self.precision = precision
        self.exponent = exponent

    def decodedMin(self):
        return -(2 ** (self.precision-1)) * (2 ** self.exponent)

    def decodedMax(self):
        return ((2 ** (self.precision-1)) - 1) * (2 ** self.exponent)

    def decode(self, x):
        sign = x & (1 << (self.precision-1))
        neg = x - (2 ** self.precision)
        x = x if not sign else neg
        x *= (2.0 ** self.exponent)
        return x

    def encode(self, x):
        x = min(x, self.decodedMax())
        x = max(x, self.decodedMin())
        x /= (2.0 ** self.exponent)
        sign = (x < 0)
        if (sign):
            x += (2 ** self.precision)
        x = int(round(x))
        return x

    def run_test():
        for _ in range(10000):
            test = FixedPoint(precision=randrange(1, 16), exponent=randrange(-16, 16))
            for i in range(2 ** test.precision):
                decoded = test.decode(i)
                encoded = test.encode(decoded)
                if (i != encoded):
                    print(f"Test Failed: precision={test.precision}, exponent={test.exponent}, {hex(i)}->{decoded}->{hex(encoded)}")
                    exit(1)


class UnaryOperationLut:
    def __init__(self, operation, in_precision, in_exponent, out_precision, out_exponent):
        self.operation = operation
        self.fpin = FixedPoint(in_precision, in_exponent)
        self.fpout = FixedPoint(out_precision, out_exponent)

    def tableSize(self):
        return (2 ** self.fpin.precision)

    def sqt(x):
        if (x < 0):
            return 0
        return math.sqrt(x)
    def sqa(x):
        return (x ** 2)
    def exp(x):
        return math.exp(x)
    def sig(x):
        return math.exp(x) / (1 + math.exp(x))

    def write_header(self, file):
        file.write(f"// {self.operation.__name__} LUT\n")
        file.write(f"// in_precision={self.fpin.precision} in_exponent={self.fpin.exponent}\n")
        file.write(f"// out_precision={self.fpout.precision} out_exponent={self.fpout.exponent}\n")
        file.write(f"// average clipping={self.average_clipping():.2f}\n")
        file.write(f"\n")

    def exportDecodedTable(self, filename):
        with open(filename, 'w') as file:
            self.write_header(file)
            for i in range(self.tableSize()):
                decoded_in = self.fpin.decode(i)
                result = self.fpout.decode(self.fpout.encode(self.operation(decoded_in)))
                file.write(str(result) + '\n')

    def exportEncodedTable(self, filename):
        with open(filename, 'w') as file:
            self.write_header(file)
            for i in range(self.tableSize()):
                decoded_in = self.fpin.decode(i)
                result = self.fpout.encode(self.operation(decoded_in))
                file.write(str(result) + '\n')

    def exportEncodedTableHex(self, filename):
        with open(filename, 'w') as file:
            self.write_header(file)
            for i in range(self.tableSize()):
                decoded_in = self.fpin.decode(i)
                result = self.fpout.encode(self.operation(decoded_in))
                padding = math.ceil(self.fpout.precision / 4)
                hex_result = f"{result:0{padding}x}"
                file.write(str(hex_result) + '\n')

    def average_clipping(self):
        sum_of_clipping = 0
        for i in range(self.tableSize()):
            decoded_in = self.fpin.decode(i)
            clipped_result = self.fpout.decode(self.fpout.encode(self.operation(decoded_in)))
            unclipped_result = self.operation(decoded_in)
            sum_of_clipping += abs(clipped_result - unclipped_result)
        return sum_of_clipping / self.tableSize()


if __name__ == "__main__":
    UnaryOperationLut(
        operation=UnaryOperationLut.exp,
        in_precision=8,
        in_exponent=-3,
        out_precision=8,
        out_exponent=-3
    ).exportEncodedTableHex("exp_lut.mem")
    UnaryOperationLut(
        operation=UnaryOperationLut.sig,
        in_precision=8,
        in_exponent=-3,
        out_precision=8,
        out_exponent=-3
    ).exportEncodedTableHex("sig_lut.mem")
    UnaryOperationLut(
        operation=UnaryOperationLut.sqa,
        in_precision=8,
        in_exponent=-3,
        out_precision=9,
        out_exponent=0
    ).exportEncodedTableHex("rms_sqa_lut.mem")
    UnaryOperationLut(
        operation=UnaryOperationLut.sqt,
        in_precision=9,
        in_exponent=0,
        out_precision=8,
        out_exponent=-3
    ).exportEncodedTableHex("rms_sqt_lut.mem")
