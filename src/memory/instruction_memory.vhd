library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instruction_memory is
  port (
    PCF : in std_logic_vector(31 downto 0);
    InstrF : out std_logic_vector(31 downto 0)
  );
end entity instruction_memory;

architecture rtl of instruction_memory is
  -- Nota: Numa FPGA, o tamanho da ROM costuma ser muito maior (ex: 1024 a 4096 palavras).
  type instruct_mem is array (0 to 31) of std_logic_vector(31 downto 0);


  signal mem : instruct_mem := (
        0  => x"00002083", -- LD x1, 0(x0)
        1  => x"00402103", -- LD x2, 4(x0)
        2  => x"002081B3", -- ADD x3, x1, x2  (x3 = 25)
        3  => x"40208233", -- SUB x4, x1, x2  (x4 = 5)
        4  => x"0020F2B3", -- AND x5, x1, x2  (x5 = 10)
        5  => x"00526333", -- OR x6, x4, x5   (x6 = 15)
        6  => x"001343B3", -- XOR x7, x6, x1  (x7 = 0)
        7  => x"FFF3C413", -- NOT x8, x7      (x8 = -1)
        8  => x"00038463", -- JZ x7, +8       (Pula para inst 10)
        9  => x"00000433", -- ARMADILHA 1: ADD x8, x0, x0
        10 => x"00044463", -- JN x8, +8       (Pula para inst 12)
        11 => x"000001B3", -- ARMADILHA 2: ADD x3, x0, x0
        12 => x"0080006F", -- J +8            (Pula para inst 14)
        13 => x"00000233", -- ARMADILHA 3: ADD x4, x0, x0
        14 => x"00302423", -- ST x3, 8(x0)    (Salva 25 na RAM[8])
        others => (others => '0')
    );

begin
  InstrF <= mem(to_integer(unsigned(PCF(6 downto 2))));
end architecture rtl;
