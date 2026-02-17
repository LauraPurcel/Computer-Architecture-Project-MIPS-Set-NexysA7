library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity IFetch is
    Port ( Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           clk : in STD_LOGIC;
           PC4 : out STD_LOGIC_VECTOR (31 downto 0);
           BranchAddress : in STD_LOGIC_VECTOR (31 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR (31 downto 0);
           Instruction : out STD_LOGIC_VECTOR (31 downto 0);
           btn_control : in STD_LOGIC;
           reset : in STD_LOGIC);
end IFetch;

architecture Behavioral of IFetch is

   component MPG is
        Port( btn : in STD_LOGIC;
              clk : in STD_LOGIC;
              enable : out STD_LOGIC);
    end component;

type ROM_TYPE is array (0 to 31) of std_logic_vector(31 downto 0);
signal ROM : ROM_TYPE := (
            B"100011_00000_00010_0000000000000000",     --lw $2, 0($0)      --0  --X  --adresa 0 
            --aluSrc = 1, regWr = 1, regDst = 0
            B"100011_00000_00100_0000000000000001",     --lw $4, 1($0)      --1  --Y  --adresa 1 
            B"100011_00000_00011_0000000000000010",     --lw $3, 2($0)      --2  --N  --adresa 2
            B"000000_00101_00101_00101_00000_100110",   --xor $5, $5, $5    --3  
            B"000000_00110_00110_00110_00000_100110",   --xor $6, $6, $6    --4  --rez
            B"000100_00011_00000_0000000000001010",     --beq $3, $0, 10    --5  --salt la final, la adresa 16
            B"100011_00101_00001_0000000000000100",    --lw $1, 4($5)      --6  --elementele incep de la adresa 4
            B"000000_00010_00001_00111_00000_100010",   --sub $7, $2, $1    --7
            B"000111_00111_00000_0000000000000100",     --bgtz $7, 4        --8  --salt la instr 13 
            B"000000_00001_00100_00111_00000_100010",   --sub $7, $1, $4    --9
            B"000111_00111_00000_0000000000000010",     --bgtz $7, 2        --10   --salt la instr 13
            B"000000_00110_00001_00110_00000_100000",   --add $6, $6, $1    --11   --adaug elementul la SUMA
            B"101011_00000_00110_0000000000000011",     --sw $6, 3($0)      --12   --pun suma partiala in memorie la adresa 3
            B"001000_00101_00101_0000000000000001",     --addi $5, $5, 1    --13   --adaug 1 la adresa curenta, adica trec la urmatoarea adresa
            B"001000_00011_00011_1111111111111111",     --addi $3, $3, -1   --14
            B"000111_00011_00000_1111111111110110",     --bgtz $3, -10      --15  --salt la instr 6, daca N nu e zero, adica daca mai sunt elemente in sir
            others => X"00000000");                                         --16

signal PC_4, PC, PC_S, PC_S1: std_logic_vector(31 downto 0) := X"00000000";

begin

 PC_reg: process(clk)
    begin
        if rising_edge(clk) then
            if btn_control = '1' then
                PC <= PC_S1;
            end if;
        end if;
        
        if reset = '1' then
            PC <= X"00000000";
        end if;        
    end process;   
                
    PC_4 <= PC + 1;
    PC4 <= PC_4;
    
    mux_BranchAddress : process(PCSrc, branchAddress)
    begin
    if PCSrc = '1' then 
        PC_S <= branchAddress;
    else 
        PC_S <= PC_4;
    end if;
    end process;
    
     mux_JumpAddress : process(jump, jumpAddress)
       begin
           if jump = '1' then 
               PC_S1 <= jumpAddress;
           else 
               PC_S1 <= PC_S;
           end if;             
       end process;
    
    Instruction <= ROM(conv_integer(PC(4 downto 0)));
end Behavioral;
    
