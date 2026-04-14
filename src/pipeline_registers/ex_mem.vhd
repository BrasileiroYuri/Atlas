library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex_mem is
  port (
  clk, we, zero : in std_logic;
  --- Controls signals!
  -- Address.
  alu_result, rs2 : in std_logic_vector(31 downto 0)
  );
end entity ex_mem;

architecture rtl of ex_mem is

begin



end architecture rtl;
