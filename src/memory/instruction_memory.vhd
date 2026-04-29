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
      0 => "0000000" & "00000" & "00001" & "000" & "00011" & "0110011", -- ADD x3, x1, x0
      1 => "0000000" & "00011" & "00011" & "000" & "00100" & "0110011", -- ADD x4, x3, x3
      2 => "0000000" & "00100" & "00100" & "000" & "00101" & "0110011", -- ADD x5, x4, x4
      --0 => "0000000" & "01000" & "00001" & "111" & "01001" & "0110011", -- AND x9, x1, x8 (x9 = 01 and 11) = 2
      --1 => "0100000" & "00100" & "00101" & "000" & "00110" & "0110011", -- SUB x6, x5, x4 (x6 = x5 - x4)
      --2 => "1000000" & "00000" & "00111" & "100" & "01111" & "0010011", -- NOT x15, x7
      --3 => "0000000" & "00010" & "00001" & "000" & "00011" & "0110011", -- ADD x3, x1, x2 (x3 = 1 + 2)
      --4 => "0000000" & "01000" & "00001" & "110" & "01010" & "0110011", -- OR x10, x1, x8 (x10 = 10 or 11) = 3
      --5 => "0000000" & "00110" & "00011" & "000" & "10000" & "0110011", -- ADD x16, x3, x6
      others => (others => '0')
    );
begin


InstrF <= mem(to_integer(unsigned(PCF(6 downto 2))));
end architecture rtl;
