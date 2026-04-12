library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pc is
  port (
  clk, we : in std_logic;

  addr_in : in std_logic_vector(31 downto 0);
  addr_out : out std_logic_vector(31 downto 0)
  );
end entity pc;

architecture rtl of pc is
  signal mem : std_logic_vector(31 downto 0);
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        mem <= addr_in;
      end if;
    end if;
  end process;

  addr_out <= mem;

end architecture rtl;
