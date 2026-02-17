library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity ID is
    Port ( RegWr : in STD_LOGIC;
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           clk : in std_logic;
           en : in std_logic;
           Instr : in STD_LOGIC_VECTOR (25 downto 0);
           WD : in STD_LOGIC_VECTOR (31 downto 0);
           RD1 : out STD_LOGIC_VECTOR (31 downto 0);
           RD2 : out STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR (31 downto 0);
           funct : out STD_LOGIC_VECTOR (5 downto 0);
           sa : out STD_LOGIC_VECTOR (4 downto 0));
end ID;

architecture Behavioral of ID is

component reg_file is 
    port ( clk : in std_logic; 
        ra1 : in std_logic_vector(4 downto 0); 
        ra2 : in std_logic_vector(4 downto 0); 
        wa : in std_logic_vector(4 downto 0); 
        wd : in std_logic_vector(31 downto 0); 
        regwr : in std_logic; 
        en : in std_logic; 
        rd1 : out std_logic_vector(31 downto 0); 
        rd2 : out std_logic_vector(31 downto 0)); 
end component; 
   
signal WriteAddress : std_logic_vector(4 downto 0);

begin

mux_reg_dst: process(RegDst)
    begin
    if RegDst = '0' then
        WriteAddress <= Instr(20 downto 16);
    else 
        WriteAddress <= Instr(15 downto 11);
    end if;
    end process;  
    
    Ext_Imm(15 downto 0) <= Instr(15 downto 0);
    Ext_Imm(31 downto 16) <= (others => Instr(15)) when ExtOp = '1' else (others => '0');
    
    funct <= Instr(5 downto 0);
    sa <= Instr(10 downto 6);
  
reg_process : reg_file
        Port map(clk => clk,
                    ra1 => Instr(25 downto 21),
                    ra2 => Instr(20 downto 16),
                    wa => WriteAddress,
                    rd1 => RD1,
                    rd2 => RD2,
                    regwr => RegWr,
                    en => en,
                    wd => WD);

end Behavioral;
