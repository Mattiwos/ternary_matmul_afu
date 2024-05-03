import numpy as np
import regex as re
import sys

D = 4

# TMPU Registers
vector_registers = {f"v{i}": np.zeros(D) for i in range(4)}
ternary_matrix_registers = {f"tm{i}": np.zeros((D,D)) for i in range(1)}

# Memory
memory = {
    "X": np.random.rand(D),
    "WK": np.random.choice([-1, 0, 1], size=(D, D)),
    "WV": np.random.choice([-1, 0, 1], size=(D, D)),
    "WQ": np.random.choice([-1, 0, 1], size=(D, D)),
    "eM": np.random.rand(D),
    "eNW": np.random.rand(D),
    "A": np.random.rand(D),
    "B": np.random.rand(D),
    "O": np.random.rand(D),
}

def nop(v_destination):
    pass

def add(v_destination, v_a, v_b):
    vector_registers[v_destination] = vector_registers[v_a] + vector_registers[v_b]

def div(v_destination, v_a, v_b):
    vector_registers[v_destination] = vector_registers[v_a] / vector_registers[v_b]

def mul(v_destination, v_a, v_b):
    vector_registers[v_destination] = vector_registers[v_a] * vector_registers[v_b]

def exp(v_destination, v_a):
    vector_registers[v_destination] = np.exp(vector_registers[v_a])

def sig(v_destination, v_a):
    vector_registers[v_destination] = np.exp(vector_registers[v_a]) / (1 + np.exp(vector_registers[v_a]))

def norm(v_target):
    norm = np.sqrt(np.average(vector_registers[v_target] ** 2))
    vector_registers[v_target] /= norm

def tmatmul(v_destination, v_a, address):
    vector_registers[v_destination] = np.matmul(vector_registers[v_a], memory[address])

def ldv(v_destination, address):
    vector_registers[v_destination] = memory[address]

def sv(v_source, address):
    memory[address] = vector_registers[v_source]


# Parsing TMI File
def parse_tmi_file(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()
    instructions = []
    for line in lines:
        line = line.split(';')[0] # Remove comments
        line = line.strip() # Remove spaces
        if line:
            instruction = re.split(r'[\s,]+', line)
            instructions.append(instruction)
    return instructions


# Execute Instructions
def execute_instructions(instructions):
    instruction_map = {
        'nop': nop,
        'add': add,
        'div': div,
        'mul': mul,
        'exp': exp,
        'sig': sig,
        'norm': norm,
        'tmatmul': tmatmul,
        'ldv': ldv,
        'sv': sv
    }
    for instruction in instructions:
        opcode = instruction[0]
        args = instruction[1:]
        if opcode not in instruction_map:
            raise ValueError(f"Unknown instruction: {opcode}")
        instruction_map[opcode](*args)


def main():
    if len(sys.argv) != 2:
        print(f"Usage: python3 {sys.argv[0]} <tmi_file>")
        sys.exit(1)

    tmi_filename = sys.argv[1]
    instructions = parse_tmi_file(tmi_filename)
    execute_instructions(instructions)

    # Dump core
    print("Registers:")
    for reg_name, reg_value in vector_registers.items():
        print(f"{reg_name}: {reg_value}")
    for reg_name, reg_value in ternary_matrix_registers.items():
        print(f"{reg_name}: {reg_value}")

    print("\nMemory:")
    for mem_name, mem_value in memory.items():
        print(f"{mem_name}: {mem_value}")

if __name__ == "__main__":
    main()
