library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

   component MPG is
        Port( btn : in STD_LOGIC;
              clk : in STD_LOGIC;
              enable : out STD_LOGIC);
    end component;
    
    component SSD is
      Port ( clk : in STD_LOGIC;
             an : out STD_LOGIC_VECTOR (7 downto 0);
             cat : out STD_LOGIC_VECTOR (6 downto 0);
             digits : in STD_LOGIC_VECTOR (31 downto 0));
    end component;

  component IFetch is
    Port ( Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           clk : in STD_LOGIC;
           PC4 : out STD_LOGIC_VECTOR (31 downto 0);
           BranchAddress : in STD_LOGIC_VECTOR (31 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR (31 downto 0);
           Instruction : out STD_LOGIC_VECTOR (31 downto 0);
           btn_control : in STD_LOGIC;
           reset : in STD_LOGIC);
    end component;

component ID is
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
end component;

component UC is
    Port ( Instr : in STD_LOGIC_VECTOR (5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           BranchGEZ : out STD_LOGIC; -- Branch on Greater than or Equal to Zero
           BranchGTZ : out STD_LOGIC; -- Branch on Greater than Zero
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(1 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;


component MEM is  
    port ( clk : in std_logic; 
        MemWrite : in std_logic; 
        enable : in std_logic; 
        addr : in std_logic_vector(5 downto 0); 
        WriteData : in std_logic_vector(31 downto 0); 
        ReadData : out std_logic_vector(31 downto 0)); 
end component; 
 
 
component EX is
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
end component;

signal en, regwr, jump, pcSrc, zero, branch, BranchGEZ, BranchGTZ, greater : std_logic := '0';
signal rd1, rd2, do, digits, instr, pc4, resMUXmem : std_logic_vector(31 downto 0);
signal jumpAddress : std_logic_vector(31 downto 0);-- := X"00000000";
signal branchAddress : std_logic_vector(31 downto 0);-- := X"00000010";
signal regDst, extOp, memWrite, memtoReg : std_logic;
signal  wd, ext_Imm, aluResult : std_logic_vector(31 downto 0);
signal funct : std_logic_vector(5 downto 0);
signal shift_amount : std_logic_vector(4 downto 0);
signal aluOp : std_logic_vector(1 downto 0);
signal aluSrc : std_logic;

begin

    debouncer_btn0 : MPG
                port map(clk => clk,
                btn => btn(0),
                enable => en);
                           
    afisor : SSD
             Port map(clk => clk,
                        an => an,
                        cat => cat,
                        digits => digits);
    process(sw(7))
    begin
      case(sw(7 downto 0)) is
        when "00000000" => digits <= instr;
        when "00000001" => digits <= pc4;
        when "00000010" => digits <= rd1;
        when "00000011" => digits <= rd2;
        when "00000100" => digits <= Ext_Imm;
        when "00000101" => digits <= AluResult;
        when "00000110" => digits <= wd;  --memData
        when "00000111" => digits <= resMUXmem;      --wd de la instruction decode  -> write data pentru registru
        when others => digits <= X"00000000";
      end case;
    end process;
    
    led(0) <= regDst;
    led(1) <= regWr;
    led(2) <= extOp;
    led(3) <= pcSrc; 
    led(4) <= jump;
    led(5) <= memWrite;
    led(6) <= memtoReg;
    led(7) <= aluSrc;
    led(8) <= branch;
    led(9) <= BranchGEZ;
    led(10) <= BranchGTZ;
    led(11) <= zero;
    
    Instruction_FETCH : IFetch
            Port map(Jump => jump,
               PCSrc => pcSrc,
               clk => clk,
               PC4 => pc4,
               BranchAddress => branchAddress,
               JumpAddress => jumpAddress,
               Instruction => instr,
               btn_control => en,
               reset => btn(1));
               
    Unitate_Main_Control: UC
  Port map(Instr => instr(31 downto 26),
           RegDst => regDst,
           ExtOp => extOp,
           ALUSrc => aluSrc,
           Branch => branch,
           BranchGEZ => BranchGEZ,
           BranchGTZ => BranchGTZ,
           Jump => jump, 
           ALUOp => aluOp,
           MemWrite => memWrite,
           MemtoReg => memtoReg,
           RegWrite => regWr);
    
    Instruction_Decode : ID
Port map ( RegWr => regWr,
           RegDst => regDst,
           ExtOp => extOP, 
           clk => clk,
           en => en,
           Instr => instr(25 downto 0), 
           WD => resMUXmem,
           RD1 => rd1,
           RD2 => rd2, 
           Ext_Imm => ext_Imm,
           funct => funct,
           sa => shift_amount);
       
     Unitate_Executie: EX
   Port map(RD1 => rd1,
           RD2 => rd2, 
           Ext_Imm => ext_imm,
           ALUSrc => aluSrc,
           sa => shift_amount,
           func => funct, -- instr(5 downto 0),
           ALUOp => aluOp,
           PC4 => pc4,
           Zero => zero,
           Greater => greater,
           ALURes => aluResult,
           BranchAddress => branchAddress);
           
     Unitate_Memorie : MEM
            Port map(clk => clk,                       
                     MemWrite =>  memWrite,                    
                     enable => en,                       
                     addr =>  aluResult(5 downto 0),     
                     WriteData => rd2,
                     ReadData => wd);
           
     mux_mem_to_reg: resMUXmem <= aluResult when MemtoReg = '0' else wd;       --Unitatea de scriere a rezultatului WB (Write-Back)  
     --wd este memData     
        
     pcSrc <= (branch and zero) or (BranchGTZ and greater) or (BranchGEZ and (zero or greater)); 
     JumpAddress <= pc4(31 downto 28) & "00" & instr(25 downto 0);                
                
end Behavioral;




