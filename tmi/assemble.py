
from sim import parse_tmi_file
import sys

def encode(instruction):
    fus = {
        'ldv':'001',
        'sv':'001',

        'add':'010',
        'sub':'010',
        'mul':'010',
        'div':'010',
        'exp':'010',
        'sig':'010',

        'tmatmul':'011',

        'norm':'100',
    }
    operations = {
        'add':'000',
        'sub':'001',
        'mul':'010',
        'div':'011',
        'exp':'100',
        'sig':'101'
    }
    vector_registers = {
        'v0': '00',
        'v1': '01',
        'v2': '10',
        'v3': '11'
    }
    load_store_operations = {
        'ldv' : '00',
        'sv'  : '01'
    }
    ddr_addresses = {
        'X'  :'0000000000000000',
        'WK' :'0000000000000000',
        'WQ' :'0000000000000000',
        'WV' :'0000000000000000',
        'eM' :'0000000000000000',
        'eNW':'0000000000000000',
        'A'  :'0000000000000000',
        'B'  :'0000000000000000',
        'O'  :'0000000000000000'
    }
    out = ''
    if instruction[0] == 'ldv':
        out += fus[instruction[0]] + '_'
        out += '000_00_00_'
        out += vector_registers[instruction[1]] + '_'
        out += load_store_operations[instruction[0]] + '_'
        out += ddr_addresses[instruction[2]]
        out += ' // ' + ' '.join(instruction)
    if instruction[0] == 'sv':
        out += fus[instruction[0]] + '_'
        out += '000_'
        out += vector_registers[instruction[1]] + '_'
        out += '00_00_'
        out += load_store_operations[instruction[0]] + '_'
        out += ddr_addresses[instruction[2]]
        out += ' // ' + ' '.join(instruction)
    if instruction[0] in ['add', 'sub', 'mul', 'div']:
        out += fus[instruction[0]] + '_'
        out += operations[instruction[0]] + '_'
        out += vector_registers[instruction[2]] + '_'
        out += vector_registers[instruction[3]] + '_'
        out += vector_registers[instruction[1]] + '_'
        out += '00_0000000000000000'
        out += ' // ' + ' '.join(instruction)
    if instruction[0] in ['exp', 'sig']:
        out += fus[instruction[0]] + '_'
        out += operations[instruction[0]] + '_'
        out += vector_registers[instruction[2]] + '_'
        out += '00_'
        out += vector_registers[instruction[1]] + '_'
        out += '00_0000000000000000'
        out += ' // ' + ' '.join(instruction)
    if instruction[0] == 'tmatmul':
        out += fus[instruction[0]] + '_'
        out += '000_'
        out += vector_registers[instruction[2]] + '_'
        out += '00_'
        out += vector_registers[instruction[1]] + '_'
        out += '00_'
        out += ddr_addresses[instruction[3]]
        out += ' // ' + ' '.join(instruction)
    if instruction[0] in ['norm']:
        out += fus[instruction[0]] + '_'
        out += '000_'
        out += vector_registers[instruction[1]] + '_'
        out += '00_'
        out += vector_registers[instruction[1]] + '_'
        out += '00_0000000000000000'
        out += ' // ' + ' '.join(instruction)

    return out


def main():
    if len(sys.argv) != 3:
        print(f"Usage: python3 {sys.argv[0]} <tmi_file> <output>")
        sys.exit(1)

    tmi_filename = sys.argv[1]
    mem_filename = sys.argv[2]
    instructions = parse_tmi_file(tmi_filename)
    with open(mem_filename, 'w') as file:
        for instruction in instructions:
            file.write(encode(instruction))
            file.write('\n')

if __name__ == "__main__":
    main()
