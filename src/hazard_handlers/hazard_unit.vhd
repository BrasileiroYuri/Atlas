library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hazard_unit is
  port (
  Rs1E : in std_logic_vector(4 downto  0);
  Rs2E : in std_logic_vector(4 downto  0);

  RdM  : in std_logic_vector(4 downto  0);
  RdW  : in std_logic_vector(4 downto  0);



  ForwardAE : out std_logic_vector(1 downto 0);
  ForwardBE : out std_logic_vector(1 downto 0)
  );
end entity hazard_unit;

architecture rtl of hazard_unit is

begin



end architecture rtl;
