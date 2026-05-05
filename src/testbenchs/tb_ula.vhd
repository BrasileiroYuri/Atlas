library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ula is
end entity tb_ula;

architecture sim of tb_ula is

  component ula is
    port (
      R1         : in  std_logic_vector(31 downto 0);
      R2         : in  std_logic_vector(31 downto 0);
      ALUControl : in  std_logic_vector(2 downto 0);
      ALUResult  : out std_logic_vector(31 downto 0);
      Zero       : out std_logic
    );
  end component;

  signal tb_R1         : std_logic_vector(31 downto 0) := (others => '0');
  signal tb_R2         : std_logic_vector(31 downto 0) := (others => '0');
  signal tb_ALUControl : std_logic_vector(2 downto 0) := "000";
  signal tb_ALUResult  : std_logic_vector(31 downto 0);
  signal tb_Zero       : std_logic;

begin

  DUT: ula port map (
    R1         => tb_R1,
    R2         => tb_R2,
    ALUControl => tb_ALUControl,
    ALUResult  => tb_ALUResult,
    Zero       => tb_Zero
  );


  process
  begin
    report "==============================================================";
    report " INICIANDO DEPURACAO: UNIDADE LOGICO ARITMETICA (ULA)";
    report "==============================================================";
    wait for 10 ns;

    -- ==========================================
    -- TESTE 1: SOMA BÁSICA
    -- ==========================================
    report "";
    report "--- [TESTE 1] OPERACAO: ADD (Soma) ---";
    tb_SrcAE <= x"0000000F"; -- 15 em decimal
    tb_SrcBE <= x"0000000A"; -- 10 em decimal
    tb_ALUControlE <= "000";
    wait for 10 ns;

    report "[1. Entradas]       SrcA: 0x0000000F | SrcB: 0x0000000A | Ctrl: 000";
    report "[2. Saida Esperada] Result: 0x00000019 | Zero: '0'";
    report "[3. Saida Gerada]   Result: 0x" & to_hstring(tb_ALUResultE) & " | Zero: '" & std_logic'image(tb_ZeroE) & "'";

    -- Valida tanto o cálculo matemático como a Flag Zero
    assert tb_ALUResultE = x"00000019" and tb_ZeroE = '0'
      report "FALHA [TESTE 1]: Erro na soma basica!"
      severity error;

    -- ==========================================
    -- TESTE 2: O SEU "CMP" / "JZ"
    -- ==========================================
    report "";
    report "--- [TESTE 2] OPERACAO: SUB (Comparacao / JZ) ---";
    tb_SrcAE <= x"0000002A"; -- 42
    tb_SrcBE <= x"0000002A"; -- 42
    tb_ALUControlE <= "001";
    wait for 10 ns;

    report "[1. Entradas]       SrcA: 0x0000002A | SrcB: 0x0000002A | Ctrl: 001";
    report "[2. Saida Esperada] Result: 0x00000000 | Zero: '1'";
    report "[3. Saida Gerada]   Result: 0x" & to_hstring(tb_ALUResultE) & " | Zero: '" & std_logic'image(tb_ZeroE) & "'";

    assert tb_ALUResultE = x"00000000" and tb_ZeroE = '1'
      report "FALHA [TESTE 2]: Erro na subtracao/comparacao (Flag Zero nao acendeu)!"
      severity error;

    -- ==========================================
    -- TESTE 3: O SEU "JN" (SLT)
    -- ==========================================
    report "";
    report "--- [TESTE 3] OPERACAO: SLT (Menor Que / JN) ---";
    tb_SrcAE <= x"FFFFFFFB"; -- -5 (Complemento de 2)
    tb_SrcBE <= x"0000000A"; -- 10
    tb_ALUControlE <= "101";
    wait for 10 ns;

    report "[1. Entradas]       SrcA: 0xFFFFFFFB (-5) | SrcB: 0x0000000A (10) | Ctrl: 101";
    report "[2. Saida Esperada] Result: 0x00000001 | Zero: '0'";
    report "[3. Saida Gerada]   Result: 0x" & to_hstring(tb_ALUResultE) & " | Zero: '" & std_logic'image(tb_ZeroE) & "'";

    assert tb_ALUResultE = x"00000001" and tb_ZeroE = '0'
      report "FALHA [TESTE 3]: Erro na operacao Set Less Than!"
      severity error;

    -- ==========================================
    -- TESTE 4: O SEU "NOT" (XORI com -1)
    -- ==========================================
    report "";
    report "--- [TESTE 4] OPERACAO: XOR (Ou Exclusivo / Seu comando NOT) ---";
    tb_SrcAE <= x"000000FF";
    tb_SrcBE <= x"FFFFFFFF"; -- -1 em hexadecimal
    tb_ALUControlE <= "100";
    wait for 10 ns;

    report "[1. Entradas]       SrcA: 0x000000FF | SrcB: 0xFFFFFFFF (-1) | Ctrl: 100";
    report "[2. Saida Esperada] Result: 0xFFFFFF00 | Zero: '0'";
    report "[3. Saida Gerada]   Result: 0x" & to_hstring(tb_ALUResultE) & " | Zero: '" & std_logic'image(tb_ZeroE) & "'";

    assert tb_ALUResultE = x"FFFFFF00" and tb_ZeroE = '0'
      report "FALHA [TESTE 4]: Erro na operacao XOR/NOT!"
      severity error;

    report "";
    report "==============================================================";
    report " TODOS OS TESTES PASSARAM COM SUCESSO! (ULA VALIDADA)";
    report "==============================================================";
    wait;
  end process;

end architecture sim;