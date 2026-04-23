library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_stage is
  port (
  clk, rst : in std_logic;

  MemWriteM : in std_logic;

  --- Sinais não consumidos, apenas de redirecionamento (apenas passam no stage).
  RegWriteM_in : in std_logic;
  RegWriteM_out : out std_logic;

  ResultSrcM_in: in std_logic_vector(1 downto 0);
  ResultSrcM_out: out std_logic_vector(1 downto 0);

  RdM_in : in std_logic_vector(4 downto 0);
  RdM_out : out std_logic_vector(4 downto 0);

  PCPlus4M_in : in std_logic_vector(31 downto 0);
  PCPlus4M_out : out std_logic_vector(31 downto 0);
  --- Redirecionamento do ALUResultM
  ALUResultM_in : in std_logic_vector (31 downto 0);
  ALUResultM_out : out std_logic_vector (31 downto 0);
  ---

  WriteDataM : in std_logic_vector(31 downto 0);
  DataMem_out : out std_logic_vector(31 downto 0)
  );
end entity mem_stage;

architecture rtl of mem_stage is
begin

 DM: entity work.data_memory
 port map(
  clk => clk,
  rst => rst,
  MemWriteM => MemWriteM,
  addr => ALUResultM_in,
  input => WriteDataM,
  output => DataMem_out
);

RegWriteM_out <= RegWriteM_in;
ResultSrcM_out <= ResultSrcM_in;
RdM_out <= RdM_in;
PCPlus4M_out <= PCPlus4M_in;
ALUResultM_out <= ALUResultM_in;

end architecture rtl;

