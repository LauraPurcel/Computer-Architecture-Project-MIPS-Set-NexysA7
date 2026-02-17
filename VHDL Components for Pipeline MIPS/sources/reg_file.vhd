 
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
 
entity reg_file is 
port ( clk : in std_logic; 
    ra1 : in std_logic_vector(4 downto 0); 
    ra2 : in std_logic_vector(4 downto 0); 
    wa : in std_logic_vector(4 downto 0); 
    wd : in std_logic_vector(31 downto 0); 
    regwr : in std_logic; 
    en : in std_logic; 
    rd1 : out std_logic_vector(31 downto 0); 
    rd2 : out std_logic_vector(31 downto 0)); 
end reg_file; 
 
architecture Behavioral of reg_file is 
 
type reg_array is array(0 to 31) of std_logic_vector(31 downto 0); 
signal reg_file : reg_array := (others => X"00000000"); 
 
begin 
 
 process(clk) 
 begin 
    if falling_edge(clk) then 
        if regwr = '1' and en = '1' then 
            reg_file(conv_integer(wa)) <= wd; 
        end if; 
    end if; 
 end process; 
 
 rd1 <= reg_file(conv_integer(ra1)); 
 rd2 <= reg_file(conv_integer(ra2)); 
 
end Behavioral;