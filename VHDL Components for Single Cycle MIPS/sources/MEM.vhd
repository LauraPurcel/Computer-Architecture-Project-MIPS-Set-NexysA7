 library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
 
entity MEM is  
port ( clk : in std_logic; 
        MemWrite : in std_logic; 
        enable : in std_logic; 
        addr : in std_logic_vector(5 downto 0); 
        WriteData : in std_logic_vector(31 downto 0); 
        ReadData : out std_logic_vector(31 downto 0)); 
end MEM ; 
 
architecture Behavioral of MEM is 
 
type ram_type is array (0 to 63) of std_logic_vector(31 downto 0); 
signal ram : ram_type := ( 
    X"00000003", --adresa 0 -> X
    X"00000008", --adresa 4 -> Y
    X"0000000A", --adresa 8 -> N
    X"00000000", --adresa 12 -> se va scrie rezultatul 
    X"00000007", --adresa 16 -> incep valorile sirului a[0]
    X"00000002", --adresa 20 -> a[1]
    X"00000004", --a[2]
    X"00000001",
    X"00000005",
    X"00000006",
    X"00000003",
    X"00000008",
    X"00000009",
    X"0000000A", --a[9]
 others => X"00000000"); 
 
begin 
 
 process(clk) 
 begin 
    if rising_edge(clk) then 
        if MemWrite = '1' and enable = '1' then 
            ram(conv_integer(addr)) <= WriteData; 
            ReadData <= WriteData; 
         end if; 
   end if; 
   ReadData <= ram(conv_integer(addr));  
 end process; 
 
end Behavioral;