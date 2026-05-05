library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_program_counter is
end entity tb_program_counter;

architecture sim of tb_program_counter is

  -- Sinais do Testbench com a nova nomenclatura F (Fetch)
  signal tb_clk     : std_logic := '0';
  signal tb_rst     : std_logic := '0';
  signal tb_we      : std_logic := '0';
  signal tb_PCF_in  : std_logic_vector(31 downto 0) := (others => '0');
  signal tb_PCF_out : std_logic_vector(31 downto 0);

begin

  -- Instanciação Direta
  uut: entity work.program_counter
    port map (
      clk     => tb_clk,
      rst     => tb_rst,
      we      => tb_we,
      PCF_in  => tb_PCF_in,
      PCF_out => tb_PCF_out
    );

  -- Gerador de Clock (Período de 10 ns)
  clk_process : process
  begin
    while true loop
      tb_clk <= '0';
      wait for 5 ns;
      tb_clk <= '1';
      wait for 5 ns;
    end loop;
  end process;

  -- Processo de Testes
  test_proc : process
  begin
    report "==============================================================";
    report " INICIANDO DEPURACAO: PROGRAM COUNTER (PC)";
    report "==============================================================";
    
    --------------------------------------------------
    -- TESTE 1: RESET ASSINCRONO/SINCRONO
    --------------------------------------------------
    report "";
    report "--- [TESTE 1] COMPORTAMENTO: RESET ---";
    tb_rst <= '1';
    tb_we  <= '0';
    tb_PCF_in <= x"12345678"; -- Tentando injetar lixo durante o reset

    wait until rising_edge(tb_clk);
    wait for 1 ns; -- Pequeno atraso para o sinal estabilizar nas ondas

    report "[1. Entradas]       Rst: '1' | WE: '0' | PCF_in: 0x12345678";
    report "[2. Saida Esperada] 0x00000000 (Zeradinho)";
    report "[3. Saida Gerada]   0x" & to_hstring(tb_PCF_out);

    assert tb_PCF_out = x"00000000"
      report "FALHA [TESTE 1]: Reset nao limpou o PC!"
      severity error;

    --------------------------------------------------
    -- TESTE 2: ESCRITA NORMAL (PULO / PROXIMA INSTRUCAO)
    --------------------------------------------------
    report "";
    report "--- [TESTE 2] COMPORTAMENTO: ESCRITA NORMAL (WE='1') ---";
    tb_rst <= '0';
    tb_we  <= '1';
    tb_PCF_in <= x"00000010"; -- PC = 16

    wait until rising_edge(tb_clk);
    wait for 1 ns;

    report "[1. Entradas]       Rst: '0' | WE: '1' | PCF_in: 0x00000010";
    report "[2. Saida Esperada] 0x00000010";
    report "[3. Saida Gerada]   0x" & to_hstring(tb_PCF_out);

    assert tb_PCF_out = x"00000010"
      report "FALHA [TESTE 2]: Escrita falhou! O PC nao atualizou."
      severity error;

    --------------------------------------------------
    -- TESTE 3: CONGELAMENTO / STALL (WE='0')
    --------------------------------------------------
    report "";
    report "--- [TESTE 3] COMPORTAMENTO: CONGELAMENTO / STALL (WE='0') ---";
    tb_we <= '0';
    tb_PCF_in <= x"FFFFFFFF"; -- Tenta forçar um novo valor enquanto tá congelado

    wait until rising_edge(tb_clk);
    wait for 1 ns;

    report "[1. Entradas]       Rst: '0' | WE: '0' | PCF_in: 0xFFFFFFFF";
    report "[2. Saida Esperada] 0x00000010 (Manter o valor anterior)";
    report "[3. Saida Gerada]   0x" & to_hstring(tb_PCF_out);

    assert tb_PCF_out = x"00000010"
      report "FALHA [TESTE 3]: Valor do PC alterou-se durante um STALL (WE='0')!"
      severity error;

    --------------------------------------------------
    -- TESTE 4: SOBRESCRITA (NOVO PULO)
    --------------------------------------------------
    report "";
    report "--- [TESTE 4] COMPORTAMENTO: SOBRESCRITA ---";
    tb_we <= '1';
    tb_PCF_in <= x"00000020"; -- PC = 32

    wait until rising_edge(tb_clk);
    wait for 1 ns;

    report "[1. Entradas]       Rst: '0' | WE: '1' | PCF_in: 0x00000020";
    report "[2. Saida Esperada] 0x00000020";
    report "[3. Saida Gerada]   0x" & to_hstring(tb_PCF_out);

    assert tb_PCF_out = x"00000020"
      report "FALHA [TESTE 4]: Sobrescrita falhou!"
      severity error;

    --------------------------------------------------
    -- FINALIZACAO
    --------------------------------------------------
    report "";
    report "==============================================================";
    report " TODOS OS TESTES PASSARAM COM SUCESSO! (PC VALIDADO)";
    report "==============================================================";
    
    -- Para a simulação (evita que o relógio fique a rodar infinitamente)
    std.env.stop;
  end process;

end architecture sim;