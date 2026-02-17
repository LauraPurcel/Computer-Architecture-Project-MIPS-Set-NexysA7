library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned .ALL;
use IEEE.std_logic_arith.ALL;
entity EX is
    Port ( RD1 : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);
           ALUSrc : in STD_LOGIC;
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           func : in STD_LOGIC_VECTOR (5 downto 0);
           ALUOp : in STD_LOGIC_VECTOR (1 downto 0);
           PC4 : in STD_LOGIC_VECTOR (31 downto 0);
           Zero : out STD_LOGIC;
           Greater : out STD_LOGIC;
           ALURes : out STD_LOGIC_VECTOR (31 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR (31 downto 0));
end EX;

architecture Behavioral of EX is
signal ALUCtrl : std_logic_vector (2 downto 0);
signal res, RD, z : std_logic_vector (31 downto 0);
begin

ALU_Control : process(func, ALUOp)
                    begin                   
                        case(ALUOp) is
                            when "11" => ALUCtrl <= "010"; --sau
                            when "01" => ALUCtrl <= "100"; --sub
                            when "00" => ALUCtrl <= "000"; --add
                            when others => case(func) is -- "10" tip R
                                            when "100000" =>  ALUCtrl <= "000";--add
                                            when "100010" =>  ALUCtrl <= "100";--sub
                                            when "100101" =>  ALUCtrl <= "010";--or
                                            when "100100" =>  ALUCtrl <= "001";--and
                                            when "100110" =>  ALUCtrl <= "011";--xor
                                            when "000000" =>  ALUCtrl <= "110";--sll
                                            when "000010" =>  ALUCtrl <= "111";--srl;    
                                            when others =>  ALUCtrl <= "111";                                      
                                         end case;
                        end case;                        
                    end process;
                    
ALU_EXECUTE: process(ALUCtrl)
                begin
                     case(ALUCtrl) is
                            when "000" => res <= RD1 + RD;       --add
                            when "100" => res <= RD1 - RD;       --sub
                            when "010" => res <= RD1 or RD;      --or
                            when "001" => res <= RD1 and RD;     --and
                            when "011" => res <= RD1 xor RD2;    --xor
                            when "110" => res <= to_stdlogicvector(to_bitvector(RD1) sll conv_integer(sa));--sll
                            when "111" => res <= to_stdlogicvector(to_bitvector(RD1) srl conv_integer(sa));--srl
                            when others => res <= X"00000000";
                       end case;
                end process;
    MUX_ALU_src : RD <= RD2 when ALUSrc = '0' else Ext_Imm;   
    z <= X"00000000";
    Zero <= '1' when res = X"00000000" else '0';
    
    process(res)
    begin
        if(signed(res) > signed(z)) then
            Greater <= '1';
        else
            Greater <= '0';
        end if;
    end process;
    
  --  Greater <= '1' when (signed(res) > signed(X"00000000")) else '0';
  
    BranchAddress <= PC4 + Ext_Imm;
    ALURes <= res;
end Behavioral;
