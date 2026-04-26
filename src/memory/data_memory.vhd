/*library IEEE;
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
*/
--------- CÓDIGO DE TESTE, CUIDADO PARA APAGAR OS COMENTÁRIOS ACIMA --------
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

  -- INJETANDO OS DADOS INICIAIS AQUI!
  signal mem : memory_t := (
    0      => x"0000000A", -- Endereço 0 recebe 10 (decimal)
    1      => x"00000014", -- Endereço 4 recebe 20 (decimal)
    others => (others => '0')
  );

begin

  process(clk)
  begin
    if rising_edge(clk) then
      -- Na simulação em FPGA/Sintese real.
      if rst = '1' then
        mem <= (
          0      => x"0000000A", -- Mantém os valores iniciais no reset
          1      => x"00000014",
          others => (others => '0')
        );
      elsif MemWriteM = '1' then
        mem(to_integer(unsigned(addr(6 downto 2)))) <= input;  -- escrita
      end if;
    end if;
  end process;

  output <= mem(to_integer(unsigned(addr(6 downto 2))));

end architecture rtl;
