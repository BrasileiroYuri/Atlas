library IEEE;
use IEEE.std_logic_1164.all;

entity maindec is
  port (
    op        : in  std_logic_vector(6 downto 0);

    ResultSrc : out std_logic_vector(1 downto 0);
    MemWrite  : out std_logic;
    Branch    : out std_logic;
    ALUSrc    : out std_logic;
    RegWrite  : out std_logic;
    Jump      : out std_logic;
    ImmSrc    : out std_logic_vector(1 downto 0);
    ALUOp     : out std_logic_vector(1 downto 0)
  );
end entity maindec;

architecture rtl of maindec is
begin

  process(op)
  begin
    ResultSrc <= "00";
    MemWrite  <= '0';
    Branch    <= '0';
    ALUSrc    <= '0';
    RegWrite  <= '0';
    Jump      <= '0';
    ImmSrc    <= "00";
    ALUOp     <= "00";

    case op is
      -- TIPO-R (ADD, SUB, CMP, AND, OR, XOR)
      when "0110011" =>
        RegWrite  <= '1';
        ImmSrc    <= "00";
        ALUSrc    <= '0';
        MemWrite  <= '0';
        ResultSrc <= "00";
        Branch    <= '0';
        ALUOp     <= "10";
        Jump      <= '0';

      -- TIPO-I DE MEMÓRIA (LD - Load)
      when "0000011" =>
        RegWrite  <= '1';
        ImmSrc    <= "00";
        ALUSrc    <= '1';
        MemWrite  <= '0';
        ResultSrc <= "01";
        Branch    <= '0';
        ALUOp     <= "00";
        Jump      <= '0';

      -- TIPO-I DE ULA (NOT / XORI)
      when "0010011" =>
        RegWrite  <= '1';
        ImmSrc    <= "00";
        ALUSrc    <= '1';
        MemWrite  <= '0';
        ResultSrc <= "00";
        Branch    <= '0';
        ALUOp     <= "11"; -- Adicionando 11
        Jump      <= '0';

      -- TIPO-S (ST - Store)
      when "0100011" =>
        RegWrite  <= '0';
        ImmSrc    <= "01";
        ALUSrc    <= '1';
        MemWrite  <= '1';
        ResultSrc <= "00";
        Branch    <= '0';
        ALUOp     <= "00";
        Jump      <= '0';

      -- TIPO-B (JN, JZ - Branches)
      when "1100011" =>
        RegWrite  <= '0';
        ImmSrc    <= "10";
        ALUSrc    <= '0';
        MemWrite  <= '0';
        ResultSrc <= "00";
        Branch    <= '1';
        ALUOp     <= "01";
        Jump      <= '0';

      -- TIPO-J (J - Jump / JAL)
      when "1101111" =>
        RegWrite  <= '1';
        ImmSrc    <= "11";
        ALUSrc    <= '0';
        MemWrite  <= '0';
        ResultSrc <= "10";
        Branch    <= '0';
        ALUOp     <= "00";
        Jump      <= '1';

      -- OUTROS
      when others =>
        null;

    end case;
  end process;

end architecture rtl;
