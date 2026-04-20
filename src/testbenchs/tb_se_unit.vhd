library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_se_unit is
end entity;

architecture sim of tb_se_unit is
  signal in_instr : std_logic_vector(31 downto 0) := (others => '0');
  signal imm      : std_logic_vector(31 downto 0);
begin
  uut: entity work.se_unit
    port map (
      in_instr => in_instr,
      imm      => imm
    );

  test_proc : process
  begin
    report "==============================================================";
    report " INICIANDO DEPURACAO DIDATICA: EXTENSOR DE SINAL (SE_UNIT)";
    report "==============================================================";

    --------------------------------------------------
    -- TESTE 1: Tipo-I (LD)
    --------------------------------------------------
    in_instr <= x"00412083";
    wait for 10 ns;
    report "";
    report "--- [TESTE 1] INSTRUCAO: LD (Tipo-I) ---";
    report "[1. Entrada]      Hex: 0x" & to_hstring(in_instr);
    report "[2. Decodificao]  Opcode isolado: " & to_string(in_instr(6 downto 0));
    report "[3. Immsrc]       Logica ativada: immsrc = 00 (Tratar como Tipo-I)";
    report "[4. Fatiamento]   Extraindo in_instr(31 downto 20) -> " & to_string(in_instr(31 downto 20));
    report "[5. Extensao]     Bit de Sinal (31) = '" & std_logic'image(in_instr(31)) & "' -> Preenchendo a esquerda";
    report "[6. Validacao]    Esperado: 0x00000004 | Saida gerada: 0x" & to_hstring(imm);
    report "[7. Fluxograma]   Opcode (" & to_string(in_instr(6 downto 0)) & ") -> immsrc(00) -> imm = 0x" & to_hstring(imm);

    --------------------------------------------------
    -- TESTE 2: Tipo-B (Branch / JZ)
    --------------------------------------------------
    in_instr <= x"00008463";
    wait for 10 ns;
    report "";
    report "--- [TESTE 2] INSTRUCAO: JZ / BEQ (Tipo-B) ---";
    report "[1. Entrada]      Hex: 0x" & to_hstring(in_instr);
    report "[2. Decodificao]  Opcode isolado: " & to_string(in_instr(6 downto 0));
    report "[3. Immsrc]       Logica ativada: immsrc = 10 (Tratar como Tipo-B)";
    report "[4. Fatiamento]   Embaralhado (31 | 7 | 30:25 | 11:8) -> " &
           std_logic'image(in_instr(31)) & " | " &
           std_logic'image(in_instr(7))  & " | " &
           to_string(in_instr(30 downto 25)) & " | " &
           to_string(in_instr(11 downto 8));
    report "[5. Alinhamento]  Adicionando '0' no bit 0 (Obrigatorio para branches)";
    report "[6. Validacao]    Esperado: 0x00000008 | Saida gerada: 0x" & to_hstring(imm);
    report "[7. Fluxograma]   Opcode (" & to_string(in_instr(6 downto 0)) & ") -> immsrc(10) -> imm = 0x" & to_hstring(imm);

    --------------------------------------------------
    -- TESTE 3: Tipo-J (Jump / J)
    --------------------------------------------------
    in_instr <= x"FF9FF06F";
    wait for 10 ns;
    report "";
    report "--- [TESTE 3] INSTRUCAO: J / JAL (Tipo-J) ---";
    report "[1. Entrada]      Hex: 0x" & to_hstring(in_instr);
    report "[2. Decodificao]  Opcode isolado: " & to_string(in_instr(6 downto 0));
    report "[3. Immsrc]       Logica ativada: immsrc = 11 (Tratar como Tipo-J)";
    report "[4. Fatiamento]   Embaralhado (31 | 19:12 | 20 | 30:21) -> " &
           std_logic'image(in_instr(31)) & " | " &
           to_string(in_instr(19 downto 12)) & " | " &
           std_logic'image(in_instr(20)) & " | " &
           to_string(in_instr(30 downto 21));
    report "[5. Extensao]     Bit de Sinal (31) = '" & std_logic'image(in_instr(31)) & "' -> Numero Negativo!";
    report "[6. Validacao]    Esperado: 0xFFFFFFF8 | Saida gerada: 0x" & to_hstring(imm);
    report "[7. Fluxograma]   Opcode (" & to_string(in_instr(6 downto 0)) & ") -> immsrc(11) -> imm = 0x" & to_hstring(imm);

    report "";
    report "==============================================================";
    report " FIM DA DEPURACAO";
    report "==============================================================";
    wait;
  end process;
end architecture sim;
