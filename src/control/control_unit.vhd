library IEEE;
use IEEE.std_logic_1164.all;

entity control_unit is
  port (
    -- ENTRADAS (Fatias da instrução vindas do id_stage)
    op         : in  std_logic_vector(6 downto 0); -- bits 6:0
    funct3     : in  std_logic_vector(2 downto 0); -- bits 14:12
    funct7b5   : in  std_logic;                    -- bit 30

    -- SAÍDAS (Sinais de Controlo para o Datapath)
    ResultSrc  : out std_logic_vector(1 downto 0);
    MemWrite   : out std_logic;
    Branch     : out std_logic;
    ALUSrc     : out std_logic;
    RegWrite   : out std_logic;
    Jump       : out std_logic;
    ImmSrc     : out std_logic_vector(1 downto 0);
    ALUControl : out std_logic_vector(2 downto 0)
  );
end entity control_unit;

architecture struct of control_unit is

  signal s_ALUOp : std_logic_vector(1 downto 0);

begin

  MD: entity work.maindec
    port map (
      op        => op,

      -- Sinais que vão direto para fora
      ResultSrc => ResultSrc,
      MemWrite  => MemWrite,
      Branch    => Branch,
      ALUSrc    => ALUSrc,
      RegWrite  => RegWrite,
      Jump      => Jump,
      ImmSrc    => ImmSrc,

      -- Sinal interno que vai para o aludec
      ALUOp     => s_ALUOp
    );

  AD: entity work.aludec
    port map (
      opb5       => op(5),     -- Extrai o bit 5 do opcode para saber se é Tipo-R ou Tipo-I
      funct3     => funct3,
      funct7b5   => funct7b5,
      ALUOp      => s_ALUOp,   -- Recebe o fio que veio do maindec

      ALUControl => ALUControl
    );

end architecture struct;
