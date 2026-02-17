# MIPS Processor: Single-Cycle & Pipeline Architecture

### Project Overview
This project implements a fully functional **MIPS Processor** designed to demonstrate the evolution from a simple **Single-Cycle** execution model to a high-performance **5-Stage Pipeline** architecture. The design was developed using **VHDL** and verified on a **Nexys A7 FPGA** development board.

---

### Components
* **Instruction Fetch (IFetch)**: Fetches the instruction from memory at the beginning of each cycle using the Program Counter (PC).
* **Instruction Decode (ID)**: Decodes the 32-bit instruction, accesses the Register File, and prepares data for execution.
* **Execution (EX)**: Performs arithmetic/logical operations and calculates branch addresses using the ALU.
* **Memory (MEM)**: Handles data memory operations, such as loading and storing data (LW/SW).
* **Write-Back (WB)**: Writes the results of computations back to the registers to complete the cycle.
* **Control Unit (CU)**: The "brain" of the processor that activates the correct signals for each instruction.
* **Monostable Pulse Generator (MPG)**: Generates a single-cycle pulse to synchronize manual button presses with the clock, allowing step-by-step execution.
* **Seven Segment Display (SSD)**: Displays real-time results, PC status, or instruction codes for hardware debugging.

---

### Implemented Instructions
The processor supports a diverse set of MIPS instructions, including standard operations and custom extensions found in the VHDL logic:

#### Standard Instructions
* **Memory & Arithmetic**: LW (Load Word), SW (Store Word), ADDI (Add Immediate), and standard R-Type operations.
* **Control Flow**: BEQ (Branch on Equal), BNE (Branch on Not Equal), and J (Jump).

#### Extended & Custom Instructions
* **SRA & XOR**: Shift Right Arithmetic and bitwise Exclusive OR operations.
* **ORI**: Logical OR with an immediate value for bit manipulation.
* **BGEZ & BGTZ**: Specialized branches (**Branch on Greater than or Equal to Zero** and **Branch on Greater than Zero**). These use a custom **Greater** flag in the EX stage to handle advanced conditional logic.

---

### Functionalities Implemented

#### 1. Single-Cycle Execution
In this model, each instruction is executed in a single clock cycle. All stages occur in parallel for one instruction, ensuring a straightforward but slower processing manner.

#### 2. Pipeline Execution
The advanced version implements a **5-stage pipeline** (IF, ID, EX, MEM, WB) to allow instruction-level parallelism. While one instruction is being decoded, the previous one is already in the execution stage, greatly improving throughput.
* **Hazard Handling**: The system manages data flow between stages using dedicated pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB).
* **Branch Logic**: Optimized `pcSrc` logic: `pcSrc <= (branch and zero) or (BranchGTZ and Greater) or (BranchGEZ and (zero or greater))`.

---

### How to Use
1. **Setup**: Open the project files in Xilinx Vivado or a similar VHDL simulator.
2. **Compilation**: Compile the design and check the RTL diagrams for both Single-Cycle and Pipeline versions.
3. **Hardware Test**: Connect the Nexys A7 board and load the bitstream.
4. **Execution**: Use the buttons (synced via MPG) to step through instructions and observe the output on the Seven Segment Display (SSD).
