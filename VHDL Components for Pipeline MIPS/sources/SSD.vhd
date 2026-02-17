library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity SSD is
    Port ( clk : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           digits : in STD_LOGIC_VECTOR (31 downto 0));
end SSD;

architecture Behavioral of SSD is

signal cnt : std_logic_vector(16 downto 0) := (others => '0');
signal digit_hex : std_logic_vector(3 downto 0);

begin

process (clk)
begin
    if (rising_edge(clk)) then
        cnt <= cnt + 1;
    end if;
end process;

mux_anozi : process(cnt)
            begin
                case cnt(16 downto 14) is
                    when "000" => an <= "11111110";
                    when "001" => an <= "11111101";
                    when "010" => an <= "11111011";
                    when "011" => an <= "11110111";
                    when "100" => an <= "11101111";
                    when "101" => an <= "11011111";
                    when "110" => an <= "10111111";
                    when others => an <= "01111111";
                end case;
            end process;
            
mux_cat : process(cnt)
          begin
            case cnt(16 downto 14) is
                              when "000" => digit_hex <= digits(3 downto 0);
                              when "001" => digit_hex <= digits(7 downto 4);
                              when "010" => digit_hex <= digits(11 downto 8);
                              when "011" => digit_hex <= digits(15 downto 12);
                              when "100" => digit_hex <= digits(19 downto 16);
                              when "101" => digit_hex <= digits(23 downto 20);
                              when "110" => digit_hex <= digits(27 downto 24);
                              when others => digit_hex <= digits(31 downto 28);
                          end case;
          end process;
               --HEX-to-seven-segment decoder
                    --   HEX:   in    STD_LOGIC_VECTOR (3 downto 0);
                    --   LED:   out   STD_LOGIC_VECTOR (6 downto 0);
                    --
                    -- segment encoinputg
                    --      0
                    --     ---
                    --  5 |   | 1
                    --     ---   <- 6
                    --  4 |   | 2
                    --     ---
                    --      3
          
hex_to_7_seg : process(digit_hex)
               begin
                    case digit_hex is
                        when X"1" => cat <= "1111001";
                        when X"2" => cat <= "0100100";
                        when X"3" => cat <= "0110000";
                        when X"4" => cat <= "0011001";                                
                        when X"5" => cat <= "0010010";
                        when X"6" => cat <= "0000010";
                        when X"7" => cat <= "1111000";
                        when X"8" => cat <= "0000000";
                        when X"9" => cat <= "0010000";
                        when X"A" => cat <= "0001000";
                        when X"B" => cat <= "0000011";
                        when X"C" => cat <= "1000110";
                        when X"D" => cat <= "0100001";
                        when X"E" => cat <= "0000110";
                        when X"F" => cat <= "0001110";
                        when others => cat <= "1000000";
                    end case;
               end process; 
end Behavioral;