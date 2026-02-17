
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity MPG is
    Port ( btn : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : out STD_LOGIC);
end MPG;

architecture Behavioral of MPG is

signal cnt : std_logic_vector(15 downto 0) := X"0000";
signal Q1, Q2, Q3, en : std_logic;

begin
    
    en <= '1' when cnt = X"FFFF" else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            cnt <= cnt + 1;
        end if;    
    end process;

    process(clk)
    begin
        if rising_edge (clk) then 
            if en = '1' then 
                Q1 <= btn;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge (clk) then
            Q2 <= Q1;
            Q3 <= Q2;
        end if;
    end process;

    enable <= not Q3 and Q2;

end Behavioral;
