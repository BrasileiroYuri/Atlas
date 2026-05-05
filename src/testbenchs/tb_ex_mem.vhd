library IEEE;
use IEEE.std_logic_1164.all;

entity tb_ex_mem is
end entity;

architecture sim of tb_ex_mem is
    -- Sinais de Controle
    signal clk, rst, we : std_logic := '0';
    
    -- Entradas (Estágio Execute)
    signal RegWriteE  : std_logic := '0';
    signal ResultSrcE : std_logic_vector(1 downto 0) := "00";
    signal ALUResultE : std_logic_vector(31 downto 0) := (others => '0');
    signal RdE        : std_logic_vector(4 downto 0) := (others => '0');
    
    -- Saídas (Estágio Memory)
    signal RegWriteM  : std_logic;
    signal ALUResultM : std_logic_vector(31 downto 0);
    signal RdM        : std_logic_vector(4 downto 0);

begin
    -- Instanciação do Componente
    DUT: entity work.ex_mem
        port map (
            clk => clk, rst => rst, we => we,
            RegWriteE => RegWriteE, ResultSrcE => ResultSrcE, MemWriteE => '0',
            ALUResultE => ALUResultE, WriteDataE => (others => '0'),
            RdE => RdE, PCPlus4E => (others => '0'),
            RegWriteM => RegWriteM, ResultSrcM => ResultSrcM, MemWriteM => open,
            ALUResultM => ALUResultM, WriteDataM => open,
            RdM => RdM, PCPlus4M => open
        );

    -- Gerador de Clock (10ns de período)
    clk <= not clk after 5 ns;

    process
    begin
        report "=== INICIANDO TESTE DO REGISTRADOR EX/MEM ===";
        
        -- 1. Reset Inicial
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        we  <= '1';
        
        -- 2. Testar Escrita (Dados devem mudar apenas na borda de subida)
        RegWriteE  <= '1';
        ALUResultE <= x"AAAA0000";
        RdE        <= "00101"; -- Registrador x5
        
        wait until rising_edge(clk);
        wait for 2 ns; -- Pequeno delay para estabilização
        report "Teste 1: Escrita Ativa";
        report "Saida ALUResultM: 0x" & to_hstring(tb_ALUResultM);
        
        -- 3. Testar Write Enable (we = '0')
        we <= '0';
        RegWriteE  <= '0';
        ALUResultE <= x"FFFFFFFF"; -- Nova entrada que deve ser IGNORADA
        
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 2: Write Enable Desativado (Mantendo valor antigo)";
        report "Esperado: 0xAAAA0000 | Saida: 0x" & to_hstring(tb_ALUResultM);
        
        -- 4. Testar Reset
        rst <= '1';
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 3: Reset Ativo";
        report "Esperado: 0 | Saida RegWriteM: " & std_logic'image(tb_RegWriteM);

        report "=== FIM DO TESTE EX/MEM ===";
        wait;
    end process;
end architecture;