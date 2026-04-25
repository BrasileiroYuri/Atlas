library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu is
  port (
    clk, rst : in std_logic
  );
end entity cpu;

architecture rtl of cpu is

  -- ==============================================================================
  -- 1. SINAIS DE INTERLIGAÇÃO (Organizados por Estágio)
  -- ==============================================================================

  -- Fios Globais (Happy Path: Esteiras sempre a andar)
  signal s_pipeline_we : std_logic := '1';

  -- FETCH (IF)
  signal s_PCF, s_PCPlus4F, s_InstrF : std_logic_vector(31 downto 0);

  -- DECODE (ID)
  signal s_InstrD, s_PCD, s_PCPlus4D : std_logic_vector(31 downto 0);
  signal s_RegWriteD, s_MemWriteD, s_JumpD, s_BranchD, s_ALUSrcD : std_logic;
  signal s_ResultSrcD : std_logic_vector(1 downto 0);
  signal s_ALUControlD : std_logic_vector(2 downto 0);
  signal s_ImmExtD, s_RD1D, s_RD2D, s_PCD_out, s_PCPlus4D_out : std_logic_vector(31 downto 0);
  signal s_RdD : std_logic_vector(4 downto 0);

  -- EXECUTE (EX)
  signal s_RegWriteE, s_MemWriteE, s_JumpE, s_BranchE, s_ALUSrcE : std_logic;
  signal s_ResultSrcE : std_logic_vector(1 downto 0);
  signal s_ALUControlE : std_logic_vector(2 downto 0);
  signal s_ImmExtE, s_RD1E, s_RD2E, s_PCE, s_PCPlus4E : std_logic_vector(31 downto 0);
  signal s_RdE : std_logic_vector(4 downto 0);

  signal s_RegWriteE_out, s_MemWriteE_out : std_logic;
  signal s_ResultSrcE_out : std_logic_vector(1 downto 0);
  signal s_RdE_out : std_logic_vector(4 downto 0);
  signal s_PCPlusE_out, s_ALUResultE, s_WriteDataE, s_PCTargetE : std_logic_vector(31 downto 0);
  signal s_SELMux : std_logic; -- O sinal de PULO que volta para o IF!

  -- MEMORY (MEM)
  signal s_RegWriteM, s_MemWriteM : std_logic;
  signal s_ResultSrcM : std_logic_vector(1 downto 0);
  signal s_ALUResultM, s_WriteDataM, s_PCPlus4M : std_logic_vector(31 downto 0);
  signal s_RdM : std_logic_vector(4 downto 0);

  signal s_RegWriteM_out : std_logic;
  signal s_ResultSrcM_out : std_logic_vector(1 downto 0);
  signal s_RdM_out : std_logic_vector(4 downto 0);
  signal s_PCPlus4M_out, s_ALUResultM_out, s_DataMem_out : std_logic_vector(31 downto 0);

  -- WRITEBACK (WB)
  signal s_RegWriteW : std_logic;
  signal s_ResultSrcW : std_logic_vector(1 downto 0);
  signal s_RdW : std_logic_vector(4 downto 0);
  signal s_ReadDataW, s_ALUResultW, s_PCPlus4W : std_logic_vector(31 downto 0);

  -- Fios Finais de Retorno (Voltam para o ID)
  signal s_RdW_out : std_logic_vector(4 downto 0);
  signal s_RegWriteW_out : std_logic;
  signal s_ResultW : std_logic_vector(31 downto 0);


begin

  -- ==============================================================================
  -- 2. INSTANCIAÇÃO DA FÁBRICA (Estágios e Esteiras)
  -- ==============================================================================

  -- >>> ESTÁGIO 1: INSTRUCTION FETCH (IF) <<<
  IF_STG: entity work.if_stage port map(
    clk         => clk,
    rst         => rst,
    we          => s_pipeline_we,
    PCSrcE      => s_SELMux,      -- O Fio que vem do EX para dizer se salta
    PCTargetE   => s_PCTargetE,   -- O endereço alvo calculado no EX
    PCPlus4F    => s_PCPlus4F,
    PCF         => s_PCF,
    InstrF      => s_InstrF
  );

  -- [Esteira IF/ID]
  IF_ID_REG: entity work.if_id port map(
    clk        => clk,
    rst        => rst,
    we         => s_pipeline_we,
    InstrF     => s_InstrF,
    InstrD     => s_InstrD,
    PCF        => s_PCF,
    PCD        => s_PCD,
    PCPlus4F   => s_PCPlus4F,
    PCPlus4D   => s_PCPlus4D
  );

  -- >>> ESTÁGIO 2: INSTRUCTION DECODE (ID) <<<
  ID_STG: entity work.id_stage port map(
    clk          => clk,
    rst          => rst,
    InstrD_in    => s_InstrD,
    PCD_in       => s_PCD,
    PCPlus4D_in  => s_PCPlus4D,
    -- Cabos de Retorno do Writeback
    RegWriteW    => s_RegWriteW_out,
    RdW          => s_RdW_out,
    ResultW      => s_ResultW,
    -- Saídas
    RegWriteD    => s_RegWriteD,
    ResultSrcD   => s_ResultSrcD,
    MemWriteD    => s_MemWriteD,
    JumpD        => s_JumpD,
    BranchD      => s_BranchD,
    ALUControlD  => s_ALUControlD,
    ALUSrcD      => s_ALUSrcD,
    ImmExtD      => s_ImmExtD,
    RD1D         => s_RD1D,
    RD2D         => s_RD2D,
    PCD_out      => s_PCD_out,
    PCPlus4D_out => s_PCPlus4D_out,
    RdD          => s_RdD
  );

  -- [Esteira ID/EX]
  ID_EX_REG: entity work.id_ex port map(
    clk          => clk,
    rst          => rst,
    we           => s_pipeline_we,
    RegWriteD    => s_RegWriteD,    RegWriteE    => s_RegWriteE,
    ResultSrcD   => s_ResultSrcD,   ResultSrcE   => s_ResultSrcE,
    MemWriteD    => s_MemWriteD,    MemWriteE    => s_MemWriteE,
    JumpD        => s_JumpD,        JumpE        => s_JumpE,
    BranchD      => s_BranchD,      BranchE      => s_BranchE,
    ALUControlD  => s_ALUControlD,  ALUControlE  => s_ALUControlE,
    ALUSrcD      => s_ALUSrcD,      ALUSrcE      => s_ALUSrcE,
    ImmExtD      => s_ImmExtD,      ImmExtE      => s_ImmExtE,
    RD1D         => s_RD1D,         RD1E         => s_RD1E,
    RD2D         => s_RD2D,         RD2E         => s_RD2E,
    PCD          => s_PCD_out,      PCE          => s_PCE,
    RdD          => s_RdD,          RdE          => s_RdE,
    PCPlus4D     => s_PCPlus4D_out, PCPlus4E     => s_PCPlus4E
  );

  -- >>> ESTÁGIO 3: EXECUTE (EX) <<<
  EX_STG: entity work.ex_stage port map(
    RegWriteE_in   => s_RegWriteE,     RegWriteE_out   => s_RegWriteE_out,
    ResultSrcE_in  => s_ResultSrcE,    ResultSrcE_out  => s_ResultSrcE_out,
    MemWriteE_in   => s_MemWriteE,     MemWriteE_out   => s_MemWriteE_out,
    RdE_in         => s_RdE,           RdE_out         => s_RdE_out,
    PCPlusE_in     => s_PCPlus4E,      PCPlusE_out     => s_PCPlusE_out,
    JumpE          => s_JumpE,
    BranchE        => s_BranchE,
    ALUControlE    => s_ALUControlE,
    ALUSrcE        => s_ALUSrcE,
    RD1E           => s_RD1E,
    RD2E           => s_RD2E,
    ALUResultE     => s_ALUResultE,
    WriteDataE     => s_WriteDataE,
    PCE            => s_PCE,
    ImmExtE        => s_ImmExtE,
    PCTargetE      => s_PCTargetE,
    SELMux         => s_SELMux
  );

  -- [Esteira EX/MEM]
  EX_MEM_REG: entity work.ex_mem port map(
    clk          => clk,
    rst          => rst,
    we           => s_pipeline_we,
    RegWriteE    => s_RegWriteE_out,   RegWriteM  => s_RegWriteM,
    ResultSrcE   => s_ResultSrcE_out,  ResultSrcM => s_ResultSrcM,
    MemWriteE    => s_MemWriteE_out,   MemWriteM  => s_MemWriteM,
    ALUResultE   => s_ALUResultE,      ALUResultM => s_ALUResultM,
    WriteDataE   => s_WriteDataE,      WriteDataM => s_WriteDataM,
    RdE          => s_RdE_out,         RdM        => s_RdM,
    PCPlus4E     => s_PCPlusE_out,     PCPlus4M   => s_PCPlus4M
  );

  -- >>> ESTÁGIO 4: MEMORY ACCESS (MEM) <<<
  MEM_STG: entity work.mem_stage port map(
    clk             => clk,
    rst             => rst,
    MemWriteM       => s_MemWriteM,
    RegWriteM_in    => s_RegWriteM,    RegWriteM_out   => s_RegWriteM_out,
    ResultSrcM_in   => s_ResultSrcM,   ResultSrcM_out  => s_ResultSrcM_out,
    RdM_in          => s_RdM,          RdM_out         => s_RdM_out,
    PCPlus4M_in     => s_PCPlus4M,     PCPlus4M_out    => s_PCPlus4M_out,
    ALUResultM_in   => s_ALUResultM,   ALUResultM_out  => s_ALUResultM_out,
    WriteDataM      => s_WriteDataM,
    DataMem_out     => s_DataMem_out
  );

  -- [Esteira MEM/WB]
  MEM_WB_REG: entity work.mem_wb port map(
    clk          => clk,
    rst          => rst,
    we           => s_pipeline_we,
    RegWriteM    => s_RegWriteM_out,   RegWriteW  => s_RegWriteW,
    ResultSrcM   => s_ResultSrcM_out,  ResultSrcW => s_ResultSrcW,
    RdM          => s_RdM_out,         RdW        => s_RdW,
    DataMem_in   => s_DataMem_out,     ReadDataW  => s_ReadDataW,
    ALUResultM   => s_ALUResultM_out,  ALUResultW => s_ALUResultW,
    PCPlus4M     => s_PCPlus4M_out,    PCPlus4W   => s_PCPlus4W
  );

  -- >>> ESTÁGIO 5: WRITEBACK (WB) <<<
  WB_STG: entity work.wb_stage port map(
    RdW_in        => s_RdW,
    RegWriteW_in  => s_RegWriteW,
    ResultSrcW    => s_ResultSrcW,
    ReadDataW     => s_ReadDataW,
    PCPlus4W      => s_PCPlus4W,
    ALUResultM    => s_ALUResultW, -- Atenção: Porta chama-se M, mas leva o sinal W!

    -- Saídas finais que dão a volta até ao ID
    RdW_out       => s_RdW_out,
    RegWriteW_out => s_RegWriteW_out,
    ResultW       => s_ResultW
  );

end architecture rtl;
