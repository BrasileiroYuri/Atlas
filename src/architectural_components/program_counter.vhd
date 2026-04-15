library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity program_counter is
  port (
    clk, rst      : in  std_logic;
    we       : in  std_logic;

    addr_in  : in  std_logic_vector(31 downto 0);
    addr_out : out std_logic_vector(31 downto 0)

  );
end entity program_counter;

architecture rtl of program_counter is
  signal mem : std_logic_vector(31 downto 0) := (others => '0');
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        mem <= (others => '0');
      elsif we = '1' then
        mem <= addr_in;
      end if;
    end if;
  end process;

  addr_out <= mem;

end architecture;
