library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity se_unit is
  port (
  clk      : in std_logic;
  in_instr : in std_logic_vector(31 downto 0);
  imm      : out std_logic_vector(31 downto 0)
  );
end entity se_unit;

architecture rtl of se_unit is

begin


end architecture rtl;
