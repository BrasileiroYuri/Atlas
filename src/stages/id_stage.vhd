library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity id_stage is
  port (
    clk, rst : in std_logic;

    -- ENTRADAS IF/ID
    InstrD_in   : in std_logic_vector(31 downto 0);
    PCD_in      : in std_logic_vector(31 downto 0);
    PCPlus4D_in : in std_logic_vector(31 downto 0);

    -- ENTRADAS DE RETORNO MEM/WB
    RegWriteW   : in std_logic;
    RdW         : in std_logic_vector(4 downto 0);
    ResultW     : in std_logic_vector(31 downto 0);

    -- SAÍDAS DE CONTROLE ID/EX
    RegWriteD   : out std_logic;
    ResultSrcD  : out std_logic_vector(1 downto 0);
    MemWriteD   : out std_logic;
    JumpD       : out std_logic;
    BranchD     : out std_logic;
    ALUControlD : out std_logic_vector(2 downto 0);
    ALUSrcD     : out std_logic;

    -- SAÍDAS DE DADOS ID/EX
    ImmExtD      : out std_logic_vector(31 downto 0);
    RD1D         : out std_logic_vector(31 downto 0);
    RD2D         : out std_logic_vector(31 downto 0);
    PCD_out      : out std_logic_vector(31 downto 0);
    PCPlus4D_out : out std_logic_vector(31 downto 0);

  --- Para a HU
    Rs1D         : out std_logic_vector(4 downto 0);
    Rs2D         : out std_logic_vector(4 downto 0);
  ---

    RdD          : out std_logic_vector(4 downto 0)
  );
end entity id_stage;

architecture rtl of id_stage is

  signal s_ImmSrc : std_logic_vector(1 downto 0);

begin

  -- Passagens diretas
  PCD_out      <= PCD_in;
  PCPlus4D_out <= PCPlus4D_in;

  -- Fatiamento para a frente
  RdD  <= InstrD_in(11 downto 7);
  Rs1D <= InstrD_in(19 downto 15);
  Rs2D <= InstrD_in(24 downto 20);

  CU: entity work.control_unit
    port map(
      op         => InstrD_in(6 downto 0),
      funct3     => InstrD_in(14 downto 12),
      funct7b5   => InstrD_in(30),

      ResultSrc  => ResultSrcD,
      MemWrite   => MemWriteD,
      Branch     => BranchD,
      ALUSrc     => ALUSrcD,
      RegWrite   => RegWriteD,
      Jump       => JumpD,
      ALUControl => ALUControlD,

      ImmSrc     => s_ImmSrc
    );

  RG: entity work.register_file
    port map(
      clk     => clk,
      we      => RegWriteW,
      in_addr => RdW,
      in_data => ResultW,
      R1      => InstrD_in(19 downto 15),
      R2      => InstrD_in(24 downto 20),
      Out1    => RD1D,
      Out2    => RD2D
    );

  SEU: entity work.se_unit
    port map(
      in_instr => InstrD_in,
      ImmSrc   => s_ImmSrc,
      imm      => ImmExtD
    );

end architecture rtl;
