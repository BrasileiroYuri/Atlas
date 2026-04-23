library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_memory is
  port (
  clk, rst, MemWriteM : in std_logic;
  addr, input : in std_logic_vector(31 downto 0);
  output : out std_logic_vector(31 downto 0)
  );
end entity data_memory;

architecture rtl of data_memory is

  type memory_t is array (0 to 31) of std_logic_vector(31 downto 0);
  signal mem : memory_t;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        mem <= (others => (others => '0'));
      elsif MemWriteM = '1' then

        mem(to_integer(unsigned(addr(6 downto 2)))) <= input;  -- escrita

      end if;
    end if;
  end process;

  output <= mem(to_integer(unsigned(addr(6 downto 2))));

end architecture rtl;
