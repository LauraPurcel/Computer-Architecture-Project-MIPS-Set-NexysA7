library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity UC is
    Port ( Instr : in STD_LOGIC_VECTOR (5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           BranchGEZ : out STD_LOGIC; -- Branch on Greater than or Equal to Zero
           BranchGTZ : out STD_LOGIC; -- Branch on Greater than Zero
           Jump : out STD_LOGIC;
           ALUOp : out std_logic_vector(1 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end UC;

architecture Behavioral of UC is
begin       
 
 main_control: process(Instr)
            begin
           RegDst <= '0';
           ExtOp <= '0';
           ALUSrc <= '0';
           Branch <= '0';
           BranchGTZ <= '0';
           BranchGEZ <= '0';
           Jump <= '0';
           ALUOp <= "00";
           MemWrite <= '0';
           MemtoReg <= '0';
           RegWrite <= '0';
            
                case(Instr) is
                    when "000000" => RegDst <= '1'; --operatie aritmetica
                                      RegWrite <= '1';
                                      ALUOp <= "10";
                    when "001000" => ExtOp <= '1'; --addi
                                      ALUSrc <= '1';
                                      ALUOp <= "00";
                                      RegWrite <= '1';
                    when "100011" =>  ExtOp <= '1'; --lw
                                      ALUSrc <= '1';
                                      ALUOp <= "00";
                                      RegWrite <= '1';
                                      MemToReg <= '1';
                    when "101011" => ExtOp <= '1';--sw
                                      ALUSrc <= '1';
                                      ALUOp <= "00";
                                      MemWrite <= '1';
                    when "000100" => ExtOp <= '1';--beq
                                      Branch <= '1';
                                      ALUOp <= "01";
                    when "000101" => ExtOp <= '1';--bne
                                      Branch <= '1';
                                      ALUOp <= "01";
                    when "000111" => ExtOp <= '1';--bgtz
                                      BranchGTZ <= '1';
                                      ALUOp <= "01";
                    when "000001" => ExtOp <= '1';--bgez
                                      BranchGEZ <= '1';
                                      ALUOp <= "01";
                    when "000010" => Jump <= '1';
                                     
                    when others => RegDst <= '0';
                            ExtOp <= '0';
                            ALUSrc <= '0';
                            Branch <= '0';
                            BranchGTZ <= '0';
                            BranchGEZ <= '0';
                            Jump <= '0';
                            ALUOp <= "00";
                            MemWrite <= '0';
                            MemtoReg <= '0';
                            RegWrite <= '0';                    
                 end case;                     
            end process;

end Behavioral;
