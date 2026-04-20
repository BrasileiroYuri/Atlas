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
    report " INICIANDO DEPURACAO DIDATICA: UNIDADE LOGICO ARITMETICA (ULA)";
    report "==============================================================";
    wait for 10 ns;

    -- ==========================================
    -- TESTE 1: SOMA BÁSICA
    -- ==========================================
    report "";
    report "--- [TESTE 1] OPERACAO: ADD (Soma) ---";
    tb_R1 <= x"0000000F"; -- 15 em decimal
    tb_R2 <= x"0000000A"; -- 10 em decimal
    tb_ALUControl <= "000";
    wait for 10 ns;
    report "[1. Entradas]     R1: 0x0000000F | R2: 0x0000000A";
    report "[2. Controle]     ALUControl isolado: 000";
    report "[3. Decodificao]  Logica ativada: Soma (R1 + R2)";
    report "[4. Execucao]     15 + 10 = 25 (0x19)";
    report "[5. Validacao]    Esperado: 0x00000019 | Saida gerada: 0x" & to_hstring(tb_ALUResult);
    report "[6. Flag Zero]    Esperado: '0' | Saida gerada: '" & std_logic'image(tb_Zero) & "'";
    report "[7. Fluxograma]   R1,R2 -> Ctrl(000) -> Result=0x00000019, Z='0'";

    -- ==========================================
    -- TESTE 2: O SEU "CMP" / "JZ"
    -- ==========================================
    report "";
    report "--- [TESTE 2] OPERACAO: SUB (Comparacao / JZ) ---";
    tb_R1 <= x"0000002A"; -- 42
    tb_R2 <= x"0000002A"; -- 42
    tb_ALUControl <= "001";
    wait for 10 ns;
    report "[1. Entradas]     R1: 0x0000002A | R2: 0x0000002A";
    report "[2. Controle]     ALUControl isolado: 001";
    report "[3. Decodificao]  Logica ativada: Subtracao (R1 - R2)";
    report "[4. Execucao]     42 - 42 = 0 (Isso deve disparar a Flag Zero!)";
    report "[5. Validacao]    Esperado: 0x00000000 | Saida gerada: 0x" & to_hstring(tb_ALUResult);
    report "[6. Flag Zero]    Esperado: '1' | Saida gerada: '" & std_logic'image(tb_Zero) & "'";
    report "[7. Fluxograma]   R1,R2 -> Ctrl(001) -> Result=0x00000000, Z='1'";

    -- ==========================================
    -- TESTE 3: O SEU "JN" (SLT)
    -- ==========================================
    report "";
    report "--- [TESTE 3] OPERACAO: SLT (Menor Que / JN) ---";
    tb_R1 <= x"FFFFFFFB"; -- -5 (Complemento de 2)
    tb_R2 <= x"0000000A"; -- 10
    tb_ALUControl <= "101";
    wait for 10 ns;
    report "[1. Entradas]     R1: 0xFFFFFFFB (-5) | R2: 0x0000000A (10)";
    report "[2. Controle]     ALUControl isolado: 101";
    report "[3. Decodificao]  Logica ativada: Set Less Than (R1 < R2)";
    report "[4. Execucao]     -5 e menor que 10? Sim! -> Setando para 1";
    report "[5. Validacao]    Esperado: 0x00000001 | Saida gerada: 0x" & to_hstring(tb_ALUResult);
    report "[6. Flag Zero]    Esperado: '0' | Saida gerada: '" & std_logic'image(tb_Zero) & "'";
    report "[7. Fluxograma]   R1,R2 -> Ctrl(101) -> Result=0x00000001, Z='0'";

    -- ==========================================
    -- TESTE 4: O SEU "NOT" (XORI com -1)
    -- ==========================================
    report "";
    report "--- [TESTE 4] OPERACAO: XOR (Ou Exclusivo / Seu comando NOT) ---";
    tb_R1 <= x"000000FF";
    tb_R2 <= x"FFFFFFFF"; -- -1 em hexadecimal
    tb_ALUControl <= "100";
    wait for 10 ns;
    report "[1. Entradas]     R1: 0x000000FF | R2: 0xFFFFFFFF (-1)";
    report "[2. Controle]     ALUControl isolado: 100";
    report "[3. Decodificao]  Logica ativada: R1 xor R2";
    report "[4. Execucao]     Invertendo todos os bits de R1 (Comportamento NOT)";
    report "[5. Validacao]    Esperado: 0xFFFFFF00 | Saida gerada: 0x" & to_hstring(tb_ALUResult);
    report "[6. Flag Zero]    Esperado: '0' | Saida gerada: '" & std_logic'image(tb_Zero) & "'";
    report "[7. Fluxograma]   R1,R2 -> Ctrl(100) -> Result=0xFFFFFF00, Z='0'";

    report "";
    report "==============================================================";
    report " FIM DA DEPURACAO DA ULA";
    report "==============================================================";
    wait;
  end process;

end architecture sim;
