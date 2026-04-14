library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity id_ex is
  port (
    clk, we : in std_logic;

    -- It's missing control signals!

    imm : in std_logic_vector(31 downto 0);
    rs1_value, rs2_value : in std_logic_vector(31 downto 0);
    rd : in std_logic_vector(31 downto 0);

    pcplus4 : in std_logic_vector(31 downto 0)
  );
end entity id_ex;

architecture rtl of id_ex is
  signal rs1_reg, rs2_reg, rd_reg : std_logic_vector(31 downto 0);
  signal imm_reg : std_logic_vector(31 downto 0);
  signal pcplus4_reg : std_logic_vector(31 downto 0);

begin





end architecture rtl;
