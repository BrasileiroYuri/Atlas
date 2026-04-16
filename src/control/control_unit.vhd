library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_unit is
  port(
    instruction : in std_logic_vector(31 downto 0)
      -- It's missing control signals!
    );
end entity control_unit;

architecture rtl of control_unit is

begin



end architecture rtl;
