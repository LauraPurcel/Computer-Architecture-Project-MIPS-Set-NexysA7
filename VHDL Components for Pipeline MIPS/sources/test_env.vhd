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
           ExtOp : in STD_LOGIC;
           clk : in std_logic;
           en : in std_logic;
           Instr : in STD_LOGIC_VECTOR (25 downto 0);
           WD : in STD_LOGIC_VECTOR (31 downto 0);
           RD1 : out STD_LOGIC_VECTOR (31 downto 0);
           RD2 : out STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR (31 downto 0);
           WriteAddress : in std_logic_vector(4 downto 0);
           funct : out STD_LOGIC_VECTOR (5 downto 0);
           sa : out STD_LOGIC_VECTOR (4 downto 0);
           rt : out STD_LOGIC_VECTOR (4 downto 0);
           rd : out STD_LOGIC_VECTOR (4 downto 0));
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
           BranchAddress : out STD_LOGIC_VECTOR (31 downto 0);
           RegDst : in STD_LOGIC;           
           WriteBackToReg : out STD_LOGIC_VECTOR (4 downto 0);
           rt : in STD_LOGIC_VECTOR (4 downto 0);
           rd : in STD_LOGIC_VECTOR (4 downto 0));
end component;

signal en, regwr, jump, pcSrc, zero, branch, BranchGEZ, BranchGTZ, greater : std_logic := '0';
signal rd1, rd2, do, digits, instr, pc4, resMUXmem : std_logic_vector(31 downto 0);
signal jumpAddress : std_logic_vector(31 downto 0);
signal branchAddress : std_logic_vector(31 downto 0);
signal regDst, extOp, memWrite, memtoReg : std_logic;
signal memData, ext_Imm, aluResult : std_logic_vector(31 downto 0);
signal funct : std_logic_vector(5 downto 0);
signal shift_amount, reg_d, reg_t, writeBackToReg : std_logic_vector(4 downto 0);
signal aluOp : std_logic_vector(1 downto 0);
signal aluSrc : std_logic;

signal PC_IF_ID: std_logic_vector (31 downto 0);
signal Instr_IF_ID: std_logic_vector (31 downto 0);

signal PC4_ID_EX: std_logic_vector (31 downto 0);
signal RD1_ID_EX: std_logic_vector (31 downto 0);
signal RD2_ID_EX: std_logic_vector (31 downto 0);

signal MemtoReg_ID_EX: std_logic;
signal RegWrite_ID_EX: std_logic;
signal MemWrite_ID_EX: std_logic;
signal Branch_ID_EX: std_logic;
signal BranchGEZ_ID_EX: std_logic;
signal BranchGTZ_ID_EX: std_logic;
signal ALUOp_ID_EX: std_logic_vector(1 downto 0);
signal ALUSrc_ID_EX: std_logic;

signal func_ID_EX: std_logic_vector(5 downto 0);
signal sa_ID_EX: std_logic_vector(4 downto 0);
signal rt_ID_EX: std_logic_vector(4 downto 0);
signal rd_ID_EX: std_logic_vector(4 downto 0);
signal Ext_imm_ID_EX: std_logic_vector(31 downto 0);

signal MemtoReg_EX_MEM: std_logic;
signal RegWrite_EX_MEM: std_logic;
signal MemWrite_EX_MEM: std_logic;
signal Branch_EX_MEM: std_logic;
signal BranchGEZ_EX_MEM: std_logic;
signal BranchGTZ_EX_MEM: std_logic;
signal Zero_EX_MEM: std_logic;
signal Greater_EX_MEM: std_logic;

signal RD2_EX_MEM: std_logic_vector (31 downto 0);
signal writeBackToReg_EX_MEM: std_logic_vector (4 downto 0);
signal aluRes_EX_MEM: std_logic_vector (31 downto 0);
signal BranchAddress_EX_MEM: std_logic_vector (31 downto 0);

signal MemtoReg_MEM_WB: std_logic;
signal RegWrite_MEM_WB: std_logic;

signal aluRes_MEM_WB: std_logic_vector (31 downto 0);
signal readData_MEM_WB: std_logic_vector (31 downto 0);
signal writeBackToReg_MEM_WB: std_logic_vector (4 downto 0);

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
        when "00000010" => digits <= RD1_ID_EX;
        when "00000011" => digits <= RD2_ID_EX;
        when "00000100" => digits <= Ext_Imm_ID_EX;
        when "00000101" => digits <= aluRes_EX_MEM;
        when "00000110" => digits <= readData_MEM_WB;  
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
  Port map(Instr => Instr_IF_ID(31 downto 26),
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
Port map ( RegWr => RegWrite_MEM_WB,
           ExtOp => extOP, 
           clk => clk,
           en => en,
           Instr => Instr_IF_ID(25 downto 0), 
           WD => resMUXmem,
           RD1 => rd1,
           RD2 => rd2, 
           Ext_Imm => ext_Imm,
           funct => funct,
           sa => shift_amount,
           rt => reg_t,
           rd => reg_d,          
           WriteAddress => writeBackToReg_MEM_WB);
       
     Unitate_Executie: EX
   Port map(RD1 => rd1_ID_EX,
           RD2 => rd2_ID_EX, 
           Ext_Imm => Ext_imm_ID_EX,
           ALUSrc => aluSrc_ID_EX,
           sa => sa_ID_EX,
           func => func_ID_EX,
           ALUOp => aluOp_ID_EX,
           PC4 => pc4_ID_EX,
           Zero => zero,
           Greater => greater, -- lipseste din ex/mem
           ALURes => aluResult,
           BranchAddress => branchAddress,
           rt => rt_ID_EX,
           rd => rd_ID_EX, 
           RegDst => regDst, 
           WriteBackToReg => writeBackToReg);
           
     Unitate_Memorie : MEM
            Port map(clk => clk,                       
                     MemWrite => memWrite_EX_MEM,                    
                     enable => en,                       
                     addr =>  aluRes_EX_MEM(5 downto 0),     
                     WriteData => rd2_EX_MEM,
                     ReadData => memData);
           
     
     mux_mem_to_reg: resMUXmem <= aluRes_MEM_WB when MemtoReg_MEM_WB = '0' else readData_MEM_WB;       --Unitatea de scriere a rezultatului WB (Write-Back)  
        
     pcSrc <= (branch_EX_MEM and zero_EX_MEM) or (BranchGTZ_EX_MEM and Greater_EX_MEM) or (BranchGEZ_EX_MEM and (zero_EX_MEM or greater_EX_MEM)); 
     JumpAddress <= PC_IF_ID(31 downto 26) & Instr_IF_ID(25 downto 0);                
                
     registru_IF_ID:
     process(clk, en)
     begin
        if(rising_edge (clk)) then 
            if(en = '1') then 
                PC_IF_ID  <= pc4; 
                Instr_IF_ID <= instr; 
            end if;
            end if;
     end process;           
             
     registru_ID_EX:
     process(clk, en)
     begin
        if(rising_edge (clk)) then 
            if(en = '1') then 
       
                MemWrite_ID_EX <= MemWrite;
                MemtoReg_ID_EX <= memtoReg;
                RegWrite_ID_EX <= regWr;
                Branch_ID_EX <= branch;
                BranchGEZ_ID_EX <= branchGTZ;
                BranchGTZ_ID_EX <= branchGEZ;
                ALUOp_ID_EX <= aluOp;
                ALUSrc_ID_EX <= aluSrc;
                
                PC4_ID_EX <= PC_IF_ID;
                RD2_ID_EX <= rd2;
                RD1_ID_EX <= rd1;
               
                func_ID_EX <= funct;
                sa_ID_EX <= shift_amount;
                rt_ID_EX <= reg_t;
                rd_ID_EX <= reg_d;
                Ext_imm_ID_EX <= Ext_Imm;  
              
            end if;
            end if;
     end process;   
     
     registru_EX_MEM:
     process(clk, en)
     begin
        if(rising_edge (clk)) then 
            if(en = '1') then    
           
                MemtoReg_EX_MEM <= MemtoReg_ID_EX;
                RegWrite_EX_MEM <=  RegWrite_ID_EX;
                
                MemWrite_EX_MEM <= MemWrite_ID_EX;
                Branch_EX_MEM <= Branch_ID_EX;
                BranchGTZ_EX_MEM <= BranchGTZ_ID_EX;
                BranchGEZ_EX_MEM <= BranchGEZ_ID_EX;
                
                Zero_EX_MEM <= zero;
                Greater_EX_MEM <= greater;
                       
                writeBackToReg_EX_MEM <= writeBackToReg;                     
                BranchAddress_EX_MEM <= branchAddress;
                
                aluRes_EX_MEM  <= aluResult;
                RD2_EX_MEM <= RD2_ID_EX;
            end if;
            end if;
     end process;   
       
     registru_MEM_WB:
     process(clk, en)
     begin
        if(rising_edge (clk)) then 
            if(en = '1') then                        
                MemtoReg_MEM_WB <= MemtoReg_EX_MEM;
                RegWrite_MEM_WB <= RegWrite_EX_MEM;

                aluRes_MEM_WB <= aluRes_EX_MEM;
                readData_MEM_WB <= memData;
                writeBackToReg_MEM_WB <= writeBackToReg_EX_MEM;
            end if;
            end if;
     end process;      
                
end Behavioral;




