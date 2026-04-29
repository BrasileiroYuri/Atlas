library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex_stage is
  port (
  --- Sinais que apenas passam pelo stage.
    RegWriteE_in : in std_logic;
    RegWriteE_out : out std_logic;

    ResultSrcE_in : in std_logic_vector(1 downto 0);
    ResultSrcE_out : out std_logic_vector(1 downto 0);

    MemWriteE_in : in std_logic;
    MemWriteE_out : out std_logic;

    RdE_in : in std_logic_vector(4 downto 0);
    RdE_out : out std_logic_vector(4 downto 0);

    PCPlusE_in : in std_logic_vector(31 downto 0);
    PCPlusE_out : out std_logic_vector(31 downto 0);
  --- Sinais para branch.
    JumpE : in std_logic;
    BranchE : in std_logic;
  --- Sinais consumidos no ex_stage.
    ALUControlE : in std_logic_vector(2 downto 0);
    ALUSrcE : in std_logic;
  --- Entradas dos MUXs.
    ResultW : in std_logic_vector(31 downto  0);
    ALUResultM : in std_logic_vector(31 downto  0);
  --- Seletores do MUXs, vindos da HU.
    ForwardAE : in std_logic_vector(1 downto 0);
    ForwardBE : in std_logic_vector(1 downto 0);
  ---

    RD1E : in std_logic_vector(31 downto 0);
    RD2E : in std_logic_vector(31 downto 0);

    ALUResultE : out std_logic_vector(31 downto 0);
    WriteDataE : out std_logic_vector(31 downto 0);

    PCE : in std_logic_vector(31 downto 0);
    ImmExtE : in std_logic_vector(31 downto 0);

    PCTargetE :out std_logic_vector(31 downto 0);

    ResultSRCE0 : out std_logic;

    PCSrcE : out std_logic
  );
end entity ex_stage;


architecture rtl of ex_stage is

signal Zero : std_logic;
signal SrcAE : std_logic_vector(31 downto 0);

signal SrcB : std_logic_vector(31 downto 0);
signal SrcBE : std_logic_vector(31 downto 0);

begin
  ULA : entity work.ula
    port map(
     SrcAE => SrcAE,
     SrcBE => SrcBE,
     ALUControlE => ALUControlE,
     ALUResultE => ALUResultE,
     ZeroE => Zero
    );

  process(ForwardAE, RD1E, ALUResultM, ResultW)
  begin
    case ForwardAE is
      when "00" =>
        SrcAE <= RD1E;
      when "01" =>
        SrcAE <= ResultW;
      when "10" =>
        SrcAE <= ALUResultM;
      when others =>
        SrcAE <= (others => '0');
    end case;
  end process;


  process(ForwardBE, RD2E, ALUResultM, ResultW)
  begin
    case ForwardBE is
      when "00" =>
        SrcB <= RD2E;
      when "01" =>
        SrcB <= ResultW;
      when "10" =>
        SrcB <= ALUResultM;
      when others =>
        SrcB <= (others => '0');
    end case;
  end process;

  process(ALUSrcE, ImmExtE, SrcB)
    begin
      case ALUSrcE is
        when '1' =>
          SrcBE <= ImmExtE;
        when others =>
          SrcBE <= SrcB;
      end case;
    end process;

  RegWriteE_out <= RegWriteE_in;
  ResultSrcE0 <= ResultSrcE_in(0);
  ResultSrcE_out <= ResultSrcE_in;
  MemWriteE_out <= MemWriteE_in;
  RdE_out <= RdE_in;
  PCPlusE_out <= PCPlusE_in;


  WriteDataE <= SrcB;
  PCTargetE <= std_logic_vector(unsigned(PCE) + unsigned(ImmExtE));
  PCSrcE <= JumpE or (BranchE and Zero);
end architecture rtl;
