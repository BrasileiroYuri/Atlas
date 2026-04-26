library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--TODO: assembly
entity instruction_memory is
  port (
  PCF : in std_logic_vector(31 downto 0);
  InstrF : out std_logic_vector(31 downto 0)
  );
end entity instruction_memory;

architecture rtl of instruction_memory is

  -- For now, we are using only 32 instructions.
  type instruct_mem is array (0 to 31) of std_logic_vector(31 downto 0);
  -- ISSO AKI É PARA TESTAR
  signal mem : instruct_mem := (
      0 => x"00002083", -- Tradução em Hex do: LD x1, 0(x0)
      1 => x"00402103", -- Tradução em Hex do: LD x2, 4(x0)
      2 => x"002081B3", -- Tradução em Hex do: ADD x3, x1, x2
      3 => x"00302423", -- Tradução em Hex do: ST x3, 8(x0)
      others => (others => '0')
    );
    -- Não apagar abaixo é para teste
-- signal mem : instruct_mem := (others => (others => '0'));
begin


InstrF <= mem(to_integer(unsigned(PCF(6 downto 2))));
end architecture rtl;
