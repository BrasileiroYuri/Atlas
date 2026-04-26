library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex_mem is
  port (
  clk, rst, we : in std_logic;

  RegWriteE : in std_logic;
  ResultSrcE : in std_logic_vector(1 downto 0);
  MemWriteE : in std_logic;

  ALUResultE: in std_logic_vector(31 downto 0);
  WriteDataE: in std_logic_vector(31 downto 0);

  RdE : in std_logic_vector(4 downto 0);
  PCPlus4E : in std_logic_vector(31 downto 0);

  RegWriteM : out std_logic;
  ResultSrcM : out std_logic_vector(1 downto 0);
  MemWriteM : out std_logic;

  ALUResultM : out std_logic_vector(31 downto 0);
  WriteDataM : out std_logic_vector(31 downto 0);

  RdM : out std_logic_vector(4 downto 0);
  PCPlus4M : out std_logic_vector(31 downto 0)
  );
end entity ex_mem;
architecture rtl of ex_mem is

  signal RegWrite : std_logic;
  signal ResultSrc : std_logic_vector(1 downto 0);
  signal MemWrite : std_logic;
  signal ALUResult : std_logic_vector(31 downto 0);
  signal WriteData : std_logic_vector(31 downto 0);
  signal Rd : std_logic_vector(4 downto 0);
  signal PCPlus4 : std_logic_vector(31 downto 0);

begin
  process(clk)
    begin
    if rising_edge(clk) then
      if rst = '1' then
        RegWrite <= '0';
        ResultSrc <= "00";
        MemWrite <= '0';
        ALUResult <= (others => '0');
        WriteData <= (others => '0');
        Rd <= (others => '0');
        PCPlus4 <= (others => '0');
      elsif we = '1' then
        RegWrite <= RegWriteE;
        ResultSrc <= ResultSrcE;
        MemWrite <= MemWriteE;
        ALUResult <= ALUResultE;
        WriteData <= WriteDataE;
        Rd <= RdE;
        PCPlus4 <= PCPlus4E;
      end if;
    end if;
  end process;

RegWriteM <= RegWrite;
ResultSrcM <= ResultSrcE;
MemWriteM <= MemWriteE;
ALUResultM <= ALUResultE;
WriteDataM <= WriteDataE;
RdM <= RdE;
PCPlus4M <= PCPlus4E;

end architecture rtl;
