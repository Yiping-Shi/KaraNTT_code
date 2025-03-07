def generate_bram_init_files():
    """
    Generate BRAM initialization files:
    - 65536 numbers. (Values 0-65535)
    - Split into 16 Banks, each with 4096 numbers, each number 30-bit wide
    - Allocation rule:
        1. Value = 0xABCD
        2. Bank = (A+B+C+D) % 16
        3. Addr = 0xABC
    """
    # Initialize 16 Banks to store
    banks = [[-1 for _ in range(4096)] for _ in range(16)]
    
    # Process all possible values (0-65535)
    for value in range(65536):
        # Convert to hex string, ensure 4 digits
        hex_value = f"{value:04x}"
        
        # Calculate Bank index: (A+B+C+D) % 16
        bank_index = 0
        for digit in hex_value:
            # Convert hex character to integer
            bank_index += int(digit, 16)
        bank_index %= 16
        
        # Calculate Address: Extract ABC from hex_value
        if len(hex_value) >= 3:
            addr = int(hex_value[0:3], 16)
        else:
            addr = int(hex_value, 16)
        
        # Ensure address is within valid range
        if addr < 4096:
            # Store value (30-bit wide, ensure value does not exceed 30-bit)
            banks[bank_index][addr] = value & 0x3FFFFFFF
    
    # Generate files
    for bank_id in range(16):
        # Create .coe file (for synthesis)
        with open(f"BRAM_coe_files/bank_{bank_id}.coe", "w") as coe_file:
            coe_file.write("memory_initialization_radix=16;\n")
            coe_file.write("memory_initialization_vector=\n")
            
            for i, value in enumerate(banks[bank_id]):
                if value != -1:
                    # Convert to 30-bit hex
                    hex_val = f"{value & 0x3FFFFFFF:07x}"
                    if i < 4095:  # Not last value
                        coe_file.write(f"{hex_val},\n")
                    else:
                        coe_file.write(f"{hex_val};\n")
                else:
                    # Unassigned address, set to 0
                    if i < 4095:
                        coe_file.write("0000000,\n")
                    else:
                        coe_file.write("0000000;\n")
        
        # Create .mem file (for simulation)
        with open(f"BRAM_mem_files/bank_{bank_id}.mem", "w") as mem_file:
            for value in banks[bank_id]:
                if value != -1:
                    # Convert to 30-bit hex
                    hex_val = f"{value & 0x3FFFFFFF:07x}"
                    mem_file.write(f"{hex_val}\n")
                else:
                    # Unassigned address, set to 0
                    mem_file.write("0000000\n")
    
    # Print statistics
    total_assigned = sum(sum(1 for val in bank if val != -1) for bank in banks)
    print(f"Total assigned values: {total_assigned} (out of 65536)")
    
    # Print bank statistics
    for bank_id, bank in enumerate(banks):
        assigned = sum(1 for val in bank if val != -1)
        print(f"Bank {bank_id}: Assigned {assigned} values, utilization {assigned/4096*100:.2f}%")

# Run the function
if __name__ == "__main__":
    generate_bram_init_files()
    print("Initialization files generated successfully!")