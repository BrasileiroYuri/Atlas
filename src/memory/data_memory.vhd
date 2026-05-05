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

  -- Memória RAM
  signal mem : memory_t := (
      0      => x"0000000A", -- RAM[0]  = 10
      1      => x"00000005", -- RAM[4]  = 5
      2      => x"FFFFFFFB", -- RAM[8]  = -5 (Para o teste do JN)
      3      => x"00000000", -- RAM[12] = 0 (Endereço Alvo)
      others => (others => '0')
    );

begin
  process(clk)
  begin
    if rising_edge(clk) then
      if MemWriteM = '1' then
        mem(to_integer(unsigned(addr(6 downto 2)))) <= input;  -- Escrita
      end if;
    end if;
  end process;

  -- Leitura combinacional
  output <= mem(to_integer(unsigned(addr(6 downto 2))));
end architecture rtl;
