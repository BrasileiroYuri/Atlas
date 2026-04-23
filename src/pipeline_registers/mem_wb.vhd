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

  ALUResultM_in: in std_logic_vector(31 downto 0);
  ALUResultM_out: out std_logic_vector(31 downto 0)
  );
end entity mem_wb;

architecture rtl of mem_wb is
begin



end architecture rtl;
