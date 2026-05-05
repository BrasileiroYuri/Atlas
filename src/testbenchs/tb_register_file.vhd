library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_register_file is
end entity tb_register_file;

architecture sim of tb_register_file is

    -- Sinais do Testbench com prefixo tb_
    signal tb_clk      : std_logic := '0';
    signal tb_we       : std_logic := '0';
    signal tb_in_addr  : std_logic_vector(4 downto 0)  := (others => '0');
    signal tb_R1       : std_logic_vector(4 downto 0)  := (others => '0');
    signal tb_R2       : std_logic_vector(4 downto 0)  := (others => '0');
    signal tb_in_data  : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_Out1     : std_logic_vector(31 downto 0);
    signal tb_Out2     : std_logic_vector(31 downto 0);

begin

    -- Instanciação Direta do componente
    uut: entity work.register_file
        port map (
            clk     => tb_clk,
            we      => tb_we,
            in_addr => tb_in_addr,
            R1      => tb_R1,
            R2      => tb_R2,
            in_data => tb_in_data,
            Out1    => tb_Out1,
            Out2    => tb_Out2
        );

    -- Gerador de Clock
    clk_process : process
    begin
        while true loop
            tb_clk <= '0'; 
            wait for 5 ns;
            tb_clk <= '1'; 
            wait for 5 ns;
        end loop;
    end process;

    test_proc : process
    begin
        report "==============================================================";
        report " INICIANDO DEPURACAO: REGISTER FILE (BANCO DE REGISTRADORES)";
        report "==============================================================";

        -- ==================================================
        -- TESTE 1: REGISTRADOR ZERO (HARDWIRED TO 0)
        -- ==================================================
        report "";
        report "--- [TESTE 1] PROTECAO DO REGISTRADOR 0 (x0) ---";
        tb_we      <= '1';
        tb_in_addr <= "00000";         -- Tenta escrever no R0
        tb_in_data <= x"FFFFFFFF";     -- Tenta forçar tudo para 1
        tb_R1      <= "00000";         -- Prepara para ler o R0
        
        wait until rising_edge(tb_clk);
        wait for 1 ns; -- Aguarda propagação

        report "[1. Entradas]       WE: '1' | Addr: 00000 | Data: 0xFFFFFFFF";
        report "[2. Saida Esperada] Out1: 0x00000000 (O R0 nunca muda)";
        report "[3. Saida Gerada]   Out1: 0x" & to_hstring(tb_Out1);

        assert tb_Out1 = x"00000000"
            report "FALHA [TESTE 1]: O Registrador 0 foi alterado! Deveria ser sempre zero."
            severity error;

        -- ==================================================
        -- TESTE 2: ESCRITA E LEITURA (DUAS PORTAS EM SIMULTÂNEO)
        -- ==================================================
        report "";
        report "--- [TESTE 2] ESCRITA E LEITURA DE MULTIPLOS REGISTRADORES ---";
        
        -- Passo 2.1: Escrever no R5
        tb_we      <= '1';
        tb_in_addr <= "00101"; -- R5
        tb_in_data <= x"12345678";
        wait until rising_edge(tb_clk);

        -- Passo 2.2: Escrever no R10
        tb_in_addr <= "01010"; -- R10
        tb_in_data <= x"DEADBEEF";
        wait until rising_edge(tb_clk);

        -- Passo 2.3: Ler R5 e R10 simultaneamente
        tb_we <= '0'; -- Desativa a escrita
        tb_R1 <= "00101"; -- Aponta a porta de leitura 1 para o R5
        tb_R2 <= "01010"; -- Aponta a porta de leitura 2 para o R10
        wait for 2 ns; -- A leitura é assíncrona/combinacional

        report "[1. Entradas]       Ler R1: 00101 (R5) | Ler R2: 01010 (R10)";
        report "[2. Saida Esperada] Out1: 0x12345678 | Out2: 0xDEADBEEF";
        report "[3. Saida Gerada]   Out1: 0x" & to_hstring(tb_Out1) & " | Out2: 0x" & to_hstring(tb_Out2);

        assert tb_Out1 = x"12345678" and tb_Out2 = x"DEADBEEF"
            report "FALHA [TESTE 2]: Erro na leitura simultanea dos registradores R5 e R10!" 
            severity error;

        -- ==================================================
        -- TESTE 3: STALL / PROTECAO DE ESCRITA (WE='0')
        -- ==================================================
        report "";
        report "--- [TESTE 3] PROTECAO DE ESCRITA (WE='0') ---";
        tb_we      <= '0';             -- Escrita DESLIGADA
        tb_in_addr <= "00101";         -- Tenta apontar para o R5
        tb_in_data <= x"00000000";     -- Tenta zerar o dado
        
        wait until rising_edge(tb_clk);
        wait for 1 ns;

        -- R1 ainda está apontado para "00101" do teste anterior
        report "[1. Entradas]       WE: '0' | Addr: 00101 (R5) | Novo Data: 0x00000000";
        report "[2. Saida Esperada] Out1: 0x12345678 (Valor antigo mantido)";
        report "[3. Saida Gerada]   Out1: 0x" & to_hstring(tb_Out1);

        assert tb_Out1 = x"12345678"
            report "FALHA [TESTE 3]: O dado foi sobrescrito mesmo com WE='0'!" 
            severity error;

        -- ==================================================
        -- FIM DOS TESTES
        -- ==================================================
        report "";
        report "==============================================================";
        report " TODOS OS TESTES PASSARAM COM SUCESSO! (REGISTER FILE)";
        report "==============================================================";

        std.env.stop; -- Termina a simulação
    end process;

end architecture sim;