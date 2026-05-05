library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_data_memory is
end entity tb_data_memory;

architecture sim of tb_data_memory is

    -- Sinais do Testbench com a nomenclatura correta (MemWriteM)
    signal tb_clk       : std_logic := '0';
    signal tb_rst       : std_logic := '0';
    signal tb_MemWriteM : std_logic := '0';
    signal tb_addr      : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_input     : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_output    : std_logic_vector(31 downto 0);

begin

    -- Instanciação Direta
    uut: entity work.data_memory
        port map (
            clk       => tb_clk,
            rst       => tb_rst,
            MemWriteM => tb_MemWriteM,
            addr      => tb_addr,
            input     => tb_input,
            output    => tb_output
        );

    -- Gerador de Clock (Período de 10ns)
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
        report " INICIANDO DEPURACAO: DATA MEMORY (RAM)";
        report "==============================================================";

        -- ==================================================
        -- TESTE 1: RESET
        -- ==================================================
        report "";
        report "--- [TESTE 1] COMPORTAMENTO: RESET ---";
        tb_rst <= '1';
        wait until rising_edge(tb_clk);
        wait for 1 ns; -- Aguarda propagação
        tb_rst <= '0';

        tb_addr <= std_logic_vector(to_unsigned(5, 32)); -- Verifica endereço 5
        wait for 1 ns;

        report "[1. Entradas]       Rst: '1' -> '0' | Addr: 5";
        report "[2. Saida Esperada] 0x00000000 (Memoria zerada)";
        report "[3. Saida Gerada]   0x" & to_hstring(tb_output);

        assert tb_output = x"00000000"
            report "FALHA [TESTE 1]: Memoria nao foi zerada no reset!" 
            severity error;

        -- ==================================================
        -- TESTE 2: ESCRITA NORMAL
        -- ==================================================
        report "";
        report "--- [TESTE 2] COMPORTAMENTO: ESCRITA E LEITURA ---";
        tb_MemWriteM <= '1';
        tb_addr      <= std_logic_vector(to_unsigned(10, 32)); -- Endereço 10
        tb_input     <= x"CAFEBABE";
        
        wait until rising_edge(tb_clk); -- Grava na subida do clock
        
        tb_MemWriteM <= '0'; -- Desativa escrita
        wait for 1 ns;       -- A leitura é combinacional (imediata)

        report "[1. Entradas]       MemWriteM: '1' | Addr: 10 | Input: 0xCAFEBABE";
        report "[2. Saida Esperada] 0xCAFEBABE";
        report "[3. Saida Gerada]   0x" & to_hstring(tb_output);

        assert tb_output = x"CAFEBABE"
            report "FALHA [TESTE 2]: Erro na escrita ou leitura do endereco 10!" 
            severity error;

        -- ==================================================
        -- TESTE 3: TENTATIVA DE SOBRESCRITA (MemWriteM = '0')
        -- ==================================================
        report "";
        report "--- [TESTE 3] COMPORTAMENTO: PROTECAO DE ESCRITA (STALL) ---";
        tb_MemWriteM <= '0';
        tb_input     <= x"DEADC0DE"; -- Tenta gravar um novo valor
        
        wait until rising_edge(tb_clk);
        wait for 1 ns;

        report "[1. Entradas]       MemWriteM: '0' | Addr: 10 | Novo Input: 0xDEADC0DE";
        report "[2. Saida Esperada] 0xCAFEBABE (Valor antigo mantido)";
        report "[3. Saida Gerada]   0x" & to_hstring(tb_output);

        assert tb_output = x"CAFEBABE"
            report "FALHA [TESTE 3]: Dado foi sobrescrito mesmo com MemWriteM em '0'!" 
            severity error;

        -- ==================================================
        -- TESTE 4: LEITURA DE OUTRO ENDEREÇO
        -- ==================================================
        report "";
        report "--- [TESTE 4] COMPORTAMENTO: INDEPENDENCIA DE ENDERECOS ---";
        tb_addr <= std_logic_vector(to_unsigned(5, 32)); -- Volta pro endereço 5
        wait for 1 ns;

        report "[1. Entradas]       Addr: 5";
        report "[2. Saida Esperada] 0x00000000 (Ainda deve estar vazio)";
        report "[3. Saida Gerada]   0x" & to_hstring(tb_output);

        assert tb_output = x"00000000"
            report "FALHA [TESTE 4]: Leitura do endereco 5 retornou lixo!" 
            severity error;

        -----------------------------------------------------------
        -- FINALIZACAO
        -----------------------------------------------------------
        report "";
        report "==============================================================";
        report " TODOS OS TESTES PASSARAM COM SUCESSO! (RAM VALIDADA)";
        report "==============================================================";

        -- Encerra a simulação
        std.env.stop;
    end process;

end architecture sim;