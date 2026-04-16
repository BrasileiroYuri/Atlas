library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instruction_memory is
  port (
  addr : in std_logic_vector(31 downto 0);
  instruction : out std_logic_vector(31 downto 0)
  );
end entity instruction_memory;

architecture rtl of instruction_memory is

  -- For now, we are using only 32 instructions.
  type instruct_mem is array (0 to 31) of std_logic_vector(31 downto 0);
signal mem : instruct_mem := (others => (others => '0'));
begin

instruction <= mem(to_integer(unsigned(addr(6 downto 2))));
end architecture rtl;
