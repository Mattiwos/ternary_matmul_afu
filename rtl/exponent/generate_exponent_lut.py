
class ExponentLut:
    def __init__(self, base, integer_precision, fractional_precision):
        self.base = base
        self.integer_precision = integer_precision
        self.fractional_precision = fractional_precision

    def getPrecision(self):
        return self.integer_precision + self.fractional_precision

    def getSize(self):
        return 2 ** self.getPrecision()

    def encodedMin(self):
        return 0

    def encodedMax(self):
        return (2 ** self.getPrecision()) - 1

    def decodedMin(self):
        return -(2 ** (self.integer_precision - 1))

    def decodedMax(self):
        integer_part_max = (2 ** (self.integer_precision - 1)) - 1
        fractional_part_max = ((2 ** self.fractional_precision) - 1) / (2.0 ** self.fractional_precision)
        return integer_part_max + fractional_part_max

    def decode(self, x):
        x = min(x, self.encodedMax())
        x = max(x, self.encodedMin())
        sign = x & (1 << (self.getPrecision()-1))
        x = x if not sign else (x - self.getSize())
        x /= (2.0 ** self.fractional_precision)
        return x

    def encode(self, x):
        x = min(x, self.decodedMax())
        x = max(x, self.decodedMin())
        x *= (2 ** self.fractional_precision)
        x = int(round(x))
        x &= (2 ** self.getPrecision()) - 1
        return x

    def exportDecodedTable(self, filename):
        with open(filename, 'w') as file:
            for i in range(self.getSize()):
                exponent = self.decode(i)
                result = self.decode(self.encode(self.base ** exponent))
                file.write(str(result) + '\n')

    def exportEncodedTable(self, filename):
        with open(filename, 'w') as file:
            for i in range(self.getSize()):
                exponent = self.decode(i)
                result = self.encode(self.base ** exponent)
                file.write(str(result) + '\n')

    def exportEncodedTableHex(self, filename):
        with open(filename, 'w') as file:
            for i in range(self.getSize()):
                exponent = self.decode(i)
                result = self.encode(self.base ** exponent)
                hex_result = hex(result)[2:]  # Convert to hexadecimal and remove '0x' prefix
                file.write(hex_result + '\n')

# Example usage:
if __name__ == "__main__":
    # Create an instance of ExponentLut
    lut = ExponentLut(base=1.19, integer_precision=5, fractional_precision=3)

    # Export lookup table to a file
    lut.exportEncodedTableHex("exponent_table.mem")
    lut.exportDecodedTable("decoded_exponent_table.txt")
    lut.exportEncodedTable("encoded_exponent_table.txt")
