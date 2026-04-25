library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_se_unit is
end entity tb_se_unit;

architecture sim of tb_se_unit is

  -- Sinais do Testbench (com prefixo tb_ para organização)
  signal tb_in_instr : std_logic_vector(31 downto 0) := (others => '0');
  signal tb_ImmSrc   : std_logic_vector(1 downto 0)  := "00";
  signal tb_imm      : std_logic_vector(31 downto 0);

begin

  -- Instanciação Direta
  DUT: entity work.se_unit 
    port map (
      in_instr => tb_in_instr,
      ImmSrc   => tb_ImmSrc,
      imm      => tb_imm
    );

  test_proc : process
  begin
    report "==============================================================";
    report " INICIANDO DEPURACAO: EXTENSOR DE SINAL (SE_UNIT)";
    report "==============================================================";
    wait for 10 ns;

    -- ==================================================
    -- TESTE 1: TIPO-I (Ex: LD / lw x1, 4(x2))
    -- ==================================================
    report "";
    report "--- [TESTE 1] EXTENSAO: TIPO-I (Imediato de 12 bits) ---";
    tb_in_instr <= x"00412083"; -- Instrução com Imediato = 4
    tb_ImmSrc   <= "00";        -- Sinal de Controlo exige Tipo-I
    wait for 10 ns;
    
    report "[1. Entradas]       Instr: 0x00412083 | ImmSrc: '00'";
    report "[2. Saida Esperada] 0x00000004";
    report "[3. Saida Gerada]   0x" & to_hstring(tb_imm);
    
    -- O assert vem logo a seguir para validar o que foi reportado acima
    assert tb_imm = x"00000004" 
      report "FALHA [TESTE 1]: O Extensor de Sinal Tipo-I gerou um valor incorreto!" 
      severity error;

    -- ==================================================
    -- TESTE 2: TIPO-S (Ex: ST / sw x1, 4(x2))
    -- ==================================================
    report "";
    report "--- [TESTE 2] EXTENSAO: TIPO-S (Imediato Fatiado) ---";
    tb_in_instr <= x"00112223"; -- Instrução com Imediato = 4 (Fatiado em 31:25 e 11:7)
    tb_ImmSrc   <= "01";        -- Sinal de Controlo exige Tipo-S
    wait for 10 ns;
    
    report "[1. Entradas]       Instr: 0x00112223 | ImmSrc: '01'";
    report "[2. Saida Esperada] 0x00000004";
    report "[3. Saida Gerada]   0x" & to_hstring(tb_imm);
    
    assert tb_imm = x"00000004" 
      report "FALHA [TESTE 2]: O Extensor de Sinal Tipo-S fatiou errado!" 
      severity error;

    -- ==================================================
    -- TESTE 3: TIPO-B (Ex: JZ, JN / beq x1, x0, 8)
    -- ==================================================
    report "";
    report "--- [TESTE 3] EXTENSAO: TIPO-B (Branch com Bit 0 Adicionado) ---";
    tb_in_instr <= x"00008463"; -- Imediato = 8
    tb_ImmSrc   <= "10";        -- Sinal de Controlo exige Tipo-B
    wait for 10 ns;
    
    report "[1. Entradas]       Instr: 0x00008463 | ImmSrc: '10'";
    report "[2. Saida Esperada] 0x00000008";
    report "[3. Saida Gerada]   0x" & to_hstring(tb_imm);
    
    assert tb_imm = x"00000008" 
      report "FALHA [TESTE 3]: O Extensor de Sinal Tipo-B errou no alinhamento!" 
      severity error;

    -- ==================================================
    -- TESTE 4: TIPO-J (Ex: J / jal x0, -8)
    -- ==================================================
    report "";
    report "--- [TESTE 4] EXTENSAO: TIPO-J (Jump Negativo) ---";
    tb_in_instr <= x"FF9FF06F"; -- Imediato = -8 (Embaralhado gigante)
    tb_ImmSrc   <= "11";        -- Sinal de Controlo exige Tipo-J
    wait for 10 ns;
    
    report "[1. Entradas]       Instr: 0xFF9FF06F | ImmSrc: '11'";
    report "[2. Saida Esperada] 0xFFFFFFF8 (-8 em Hex)";
    report "[3. Saida Gerada]   0x" & to_hstring(tb_imm);
    
    assert tb_imm = x"FFFFFFF8" 
      report "FALHA [TESTE 4]: O Extensor de Sinal Tipo-J falhou no sinal negativo!" 
      severity error;

    report "";
    report "==============================================================";
    report " TODOS OS TESTES PASSARAM COM SUCESSO! (SE_UNIT VALIDADA)";
    report "==============================================================";
    wait;
  end process;

end architecture sim;