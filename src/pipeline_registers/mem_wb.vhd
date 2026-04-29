library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_wb is
  port (

  clk, rst : in std_logic;

  RegWriteM : in std_logic;
  RegWriteW : out std_logic;

  ResultSrcM : in std_logic_vector(1 downto 0);
  ResultSrcW : out std_logic_vector(1 downto 0);

  RdM : in std_logic_vector(4 downto 0);
  RdW : out std_logic_vector(4 downto 0);

  DataMem_in : in std_logic_vector(31 downto 0);
  ReadDataW : out std_logic_vector(31 downto 0);

  ALUResultM: in std_logic_vector(31 downto 0);
  ALUResultW: out std_logic_vector(31 downto 0);

  PCPlus4M : in std_logic_vector(31 downto 0);
  PCPlus4W : out std_logic_vector(31 downto 0)
  );
end entity mem_wb;

architecture rtl of mem_wb is

  signal RegWrite : std_logic;
  signal ResultSrc : std_logic_vector(1 downto 0);
  signal ALUResult : std_logic_vector(31 downto 0);
  signal DataMem : std_logic_vector(31 downto 0);
  signal Rd : std_logic_vector(4 downto 0);
  signal PCPlus4 : std_logic_vector(31 downto 0);

begin

  process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1' then
          RegWrite <= '0';
          ResultSrc <="00";
          ALUResult <= (others => '0');
          DataMem <= (others => '0');
          Rd <= (others => '0');
          PCPlus4 <= (others => '0');
        else
          RegWrite <= RegWriteM;
          ResultSrc <= ResultSrcM;
          ALUResult <= ALUResultM;
          DataMem <= DataMem_in;
          Rd <= RdM;
          PCPlus4 <= PCPlus4M;
        end if;
      end if;
    end process;

RegWriteW <= RegWrite;
ResultSrcW <= ResultSrc;
ALUResultW <= ALUResult;
ReadDataW <= DataMem;
RdW <= Rd;
PCPlus4W <= PCPlus4;

end architecture rtl;
