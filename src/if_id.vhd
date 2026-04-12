library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity if_id is
  port (
  clk, we : in std_logic;
  in_instr : in std_logic_vector(31 downto 0);
  out_instr : out std_logic_vector(31 downto 0);
  );
end entity if_id;

architecture rtl of if_id is
  signal mem : std_logic_vector(31 downto 0);
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        mem <= in_instr;
      end if;
    end if;
  end process;

  out_instr <= mem;

end architecture rtl;
