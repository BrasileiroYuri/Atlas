library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity id_ex is
  port (

    clk, rst, we : in std_logic;

--- Sinais de controle:
    RegWriteD: in std_logic;
    RegWriteE: out std_logic;

    ResultSrcD: in std_logic_vector(1 downto 0);
    ResultSrcE: out std_logic_vector(1 downto 0);

    MemWriteD: in std_logic;
    MemWriteE: out std_logic;

    JumpD: in std_logic;
    JumpE: out std_logic;

    BranchD: in std_logic;
    BranchE: out std_logic;

    ALUControlD: in std_logic_vector(2 downto 0);
    ALUControlE: out std_logic_vector(2 downto 0);

    ALUSrcD: in std_logic;
    ALUSrcE: out std_logic;

  --- Para a Hazard Unit.
    Rs1D : in std_logic_vector(4 downto 0);
    Rs1E : out std_logic_vector(4 downto 0);

    Rs2D : in std_logic_vector(4 downto 0);
    Rs2E : out std_logic_vector(4 downto 0);
  ---

    ImmExtD : in std_logic_vector(31 downto 0);
    ImmExtE : out std_logic_vector(31 downto 0);

    RD1D  : in std_logic_vector(31 downto 0);
    RD1E  : out std_logic_vector(31 downto 0);

    RD2D  : in std_logic_vector(31 downto 0);
    RD2E  : out std_logic_vector(31 downto 0);

    PCD : in std_logic_vector(31 downto 0);
    PCE : out std_logic_vector(31 downto 0);

    RdD : in std_logic_vector(4 downto 0);
    RdE : out std_logic_vector(4 downto 0);

    PCPlus4D : in std_logic_vector(31 downto 0);
    PCPlus4E : out std_logic_vector(31 downto 0)

  );
end entity id_ex;

architecture rtl of id_ex is

  --- Sinais de controle.
  signal RegWrite : std_logic;
  signal ResultSrc : std_logic_vector(1 downto 0);
  signal MemWrite : std_logic;
  signal Jump : std_logic;
  signal Branch : std_logic;
  signal ALUControl : std_logic_vector(2 downto 0);
  signal ALUSrc : std_logic;
  ---
  signal RD1 : std_logic_vector(31 downto 0);
  signal RD2 : std_logic_vector(31 downto 0);
  signal PC : std_logic_vector (31 downto 0);
  signal Rd : std_logic_vector(4 downto 0);
  signal ImmExt : std_logic_vector(31 downto 0);
  signal PCPlus4 : std_logic_vector(31 downto 0);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        RegWrite <= '0';
        ResultSrc <= (others => '0');
        MemWrite <= '0';
        Jump <= '0';
        Branch <= '0';
        ALUControl <= (others => '0');
        ALUSrc <= '0';

        RD1 <= (others => '0');
        RD2 <= (others => '0');
        PC <= (others => '0');
        Rd<= (others => '0');
        ImmExt<= (others => '0');
        PCPlus4<= (others => '0');
      elsif we = '1' then
        RegWrite <= RegWriteD;
        ResultSrc <= ResultSrcD;
        MemWrite <= MemWriteD;
        Jump <= JumpD;
        Branch <= BranchD;
        ALUControl <= ALUControlD;
        ALUSrc <= ALUSrcD;

        RD1 <= RD1D;
        RD2 <= RD2D;
        PC <= PCD;
        Rd<= RdD;
        ImmExt <= ImmExtD;
        PCPlus4<= PCPlus4D;
      end if;
    end if;
  end process;

RegWriteE <= RegWrite;
ResultSrcE <= ResultSrc;
MemWriteE <= MemWrite;
JumpE <= Jump;
BranchE <= Branch;
ALUControlE <= ALUControl;
ALUSrcE <= ALUSrc;

RD1E <= RD1;
RD2E <= RD2;
PCE <= PC;
RdE <= Rd;
ImmExtE <= ImmExt;
PCPlus4E <= PCPlus4;

end architecture rtl;
