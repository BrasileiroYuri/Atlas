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
  type instruct_mem is array (0 to 31) of std_logic_vector(31 downto 0);

  signal mem : instruct_mem := (
        -- LEITURAS (LD)
        0  => b"000000000000_00000_010_00001_0000011", -- LD x1, 0(x0)  | x1 = 10
        1  => b"000000000100_00000_010_00010_0000011", -- LD x2, 4(x0)  | x2 = 5
        
        -- MATEMÁTICA E LÓGICA (TIPO-R e TIPO-I)
        2  => b"0000000_00010_00001_000_00011_0110011", -- ADD x3, x1, x2 | x3 = 15
        3  => b"0100000_00010_00001_000_00100_0110011", -- SUB x4, x1, x2 | x4 = 5
        4  => b"0000000_00100_00011_111_00101_0110011", -- AND x5, x3, x4 | x5 = 5
        5  => b"0000000_00100_00011_110_00110_0110011", -- OR  x6, x3, x4 | x6 = 15
        6  => b"0000000_00110_00101_100_00111_0110011", -- XOR x7, x5, x6 | x7 = 10 (Senha)
        7  => b"111111111111_00010_100_01000_0010011", -- NOT x8, x2     | x8 = -6
        
        -- TESTE DE SALTO ZERO (CMP e JZ)
        8  => b"0100000_00001_00001_000_01001_0110011", -- CMP x9, x1, x1 | x9 = 0
        9  => b"0_000000_00000_01001_000_0100_0_1100011", -- JZ x9, +8      | Pula a instrução 10
        10 => b"0000000_00000_00000_000_00111_0110011", -- ADD x7, x0, x0 | (Falha) Apaga a senha
        
        -- TESTE DE SALTO NEGATIVO (JN)
        11 => b"000000001000_00000_010_01010_0000011", -- LD x10, 8(x0)  | x10 = -5
        12 => b"0_000000_00000_01010_100_0100_0_1100011", -- JN x10, +8     | Pula a instrução 13
        13 => b"0000000_00000_00000_000_00111_0110011", -- ADD x7, x0, x0 | (Falha) Apaga a senha
        
        -- TESTE DE SALTO INCONDICIONAL (J) E ESCRITA (ST)
        14 => b"0_0000000100_0_00000000_00000_1101111", -- J +8           | Pula a instrução 15
        15 => b"0000000_00000_00000_010_01100_0100011", -- ST x0, 12(x0)  | (Falha) Grava 0 na RAM
        16 => b"0000000_00111_00000_010_01100_0100011", -- ST x7, 12(x0)  | (Sucesso) Grava 10 na RAM
  
        others => (others => '0')
    );

begin
  InstrF <= mem(to_integer(unsigned(PCF(6 downto 2))));
end architecture rtl;
