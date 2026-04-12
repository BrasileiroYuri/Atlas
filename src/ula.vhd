library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula is
  port (
  R1, R2 : in std_logic_vector(31 downto 0);

  result : out std_logic_vector(31 downto 0);

  op : in std_logic_vector(3 downto 0)
  );
end entity ula;

architecture rtl of ula is
begin



end architecture rtl;
