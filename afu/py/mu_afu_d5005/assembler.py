import sys
sys.path.append('../../tmi')
from sim import parse_tmi_file

class TMIAssembler():
    
    def __init__(
        self,
        ddr_addresses_str,
        ddr_addr_bits
    ):
        self.ddr_addresses_str=ddr_addresses_str
        self.ddr_addr_bits=ddr_addr_bits
        
    def __encode__(self, instruction):
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
            'v0': '000',
            'v1': '001',
            'v2': '010',
            'v3': '011',
            'v4': '100',
            'v5': '101',
            'v6': '110',
            'v7': '111'
        }
        load_store_operations = {
            'ldv' : '00',
            'sv'  : '01'
        }

        out = ''
        if instruction[0] == 'ldv':
            out += fus[instruction[0]] + '_'
            out += '000_000_000_'
            out += vector_registers[instruction[1]] + '_'
            out += load_store_operations[instruction[0]] + '_'
            out += self.ddr_addresses_str[instruction[2]]
            out += ' // ' + ' '.join(instruction)
        if instruction[0] == 'sv':
            out += fus[instruction[0]] + '_'
            out += '000_'
            out += vector_registers[instruction[1]] + '_'
            out += '000_000_'
            out += load_store_operations[instruction[0]] + '_'
            out += self.ddr_addresses_str[instruction[2]]
            out += ' // ' + ' '.join(instruction)
        if instruction[0] in ['add', 'sub', 'mul', 'div']:
            out += fus[instruction[0]] + '_'
            out += operations[instruction[0]] + '_'
            out += vector_registers[instruction[2]] + '_'
            out += vector_registers[instruction[3]] + '_'
            out += vector_registers[instruction[1]] + '_'
            out += '00_' + self.ddr_addr_bits*'0'
            out += ' // ' + ' '.join(instruction)
        if instruction[0] in ['exp', 'sig']:
            out += fus[instruction[0]] + '_'
            out += operations[instruction[0]] + '_'
            out += vector_registers[instruction[2]] + '_'
            out += '000_'
            out += vector_registers[instruction[1]] + '_'
            out += '00_' + self.ddr_addr_bits*'0'
            out += ' // ' + ' '.join(instruction)
        if instruction[0] == 'tmatmul':
            out += fus[instruction[0]] + '_'
            out += '000_'
            out += vector_registers[instruction[2]] + '_'
            out += '000_'
            out += vector_registers[instruction[1]] + '_'
            out += '00_'
            out += self.ddr_addresses_str[instruction[3]]
            out += ' // ' + ' '.join(instruction)
        if instruction[0] in ['norm']:
            out += fus[instruction[0]] + '_'
            out += '000_'
            out += vector_registers[instruction[1]] + '_'
            out += '000_'
            out += vector_registers[instruction[1]] + '_'
            out += '00_' + self.ddr_addr_bits*'0'
            out += ' // ' + ' '.join(instruction)

        return out

    def assemble(self, tmi_filename, mem_filename):
        instructions = parse_tmi_file(tmi_filename)
        with open(mem_filename, 'w') as file:
            for instruction in instructions:
                file.write(self.__encode__(instruction))
                file.write('\n')
