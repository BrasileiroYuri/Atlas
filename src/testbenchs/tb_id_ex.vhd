library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_id_ex is
end entity;

architecture sim of tb_id_ex is
    -- Sinais de clock e controle
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal we  : std_logic := '0';

    -- Sinais de entrada (Estágio Decode)
    signal RegWriteD   : std_logic := '0';
    signal ALUControlD : std_logic_vector(2 downto 0) := "000";
    signal RD1D        : std_logic_vector(31 downto 0) := (others => '0');
    signal PCD         : std_logic_vector(31 downto 0) := (others => '0');
    signal RdD         : std_logic_vector(4 downto 0)  := (others => '0');

    -- Sinais de saída (Estágio Execute)
    signal RegWriteE   : std_logic;
    signal ALUControlE : std_logic_vector(2 downto 0);
    signal RD1E        : std_logic_vector(31 downto 0);
    signal PCE         : std_logic_vector(31 downto 0);
    signal RdE         : std_logic_vector(4 downto 0);

begin

    -- Instanciação do componente sob teste (DUT)
    DUT: entity work.id_ex
        port map (
            clk => clk, rst => rst, we => we,
            RegWriteD => RegWriteD, RegWriteE => RegWriteE,
            ResultSrcD => "00", ResultSrcE => open,
            MemWriteD => '0', MemWriteE => open,
            JumpD => '0', JumpE => open,
            BranchD => '0', BranchE => open,
            ALUControlD => ALUControlD, ALUControlE => ALUControlE,
            ALUSrcD => '0', ALUSrcE => open,
            ImmExtD => (others => '0'), ImmExtE => open,
            RD1D => RD1D, RD1E => RD1E,
            RD2D => (others => '0'), RD2E => open,
            PCD => PCD, PCE => PCE,
            RdD => RdD, RdE => RdE,
            PCPlus4D => (others => '0'), PCPlus4E => open
        );

    -- Clock de 10ns (100MHz)
    clk <= not clk after 5 ns;

    process
    begin
        report "=== INICIANDO TESTE DO REGISTRADOR ID/EX ===";

        -- 1. Teste de Reset
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait for 2 ns;
        report "Teste 1: Reset verificado em PCE: " & to_hstring(PCE);

        -- 2. Teste de Escrita (we = '1')
        we          <= '1';
        RegWriteD   <= '1';
        ALUControlD <= "101";
        RD1D        <= x"AAAA5555";
        PCD         <= x"00001000";
        RdD         <= "00111"; -- x7
        
        -- O dado não deve mudar antes do clock
        wait for 2 ns;
        report "Teste 2a: Verificando se saida e estavel antes do clock";
        report "PCE (antes do clk): " & to_hstring(PCE);

        wait until rising_edge(clk);
        wait for 2 ns; -- Tempo de hold
        report "Teste 2b: Saida apos borda de subida";
        report "RD1E: " & to_hstring(RD1E);
        report "RdE: " & to_string(RdD);

        -- 3. Teste de Congelamento (we = '0') - Importante para Stalls
        we   <= '0';
        RD1D <= x"FFFFFFFF"; -- Dado novo que deve ser bloqueado
        
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 3: Verificando Stall (we=0)";
        if RD1E = x"AAAA5555" then
            report "SUCESSO: Dado antigo mantido.";
        else
            report "FALHA: O registrador nao segurou o valor!";
        end if;

        -- 4. Teste de Reset Assíncrono/Síncrono (depende da sua RTL)
        rst <= '1';
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 4: Reset final verificado.";

        report "=== FIM DO TESTE ID/EX ===";
        wait;
    end process;

end architecture;