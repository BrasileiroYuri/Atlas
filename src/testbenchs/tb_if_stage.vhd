library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_if_stage is
end entity;

architecture sim of tb_if_stage is
    -- Controle
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal we         : std_logic := '1';

    -- Entradas (Vindas do Execute Stage)
    signal PCSrcE     : std_logic := '0';
    signal PCTargetE  : std_logic_vector(31 downto 0) := (others => '0');

    -- Saídas (Para o IF/ID Register)
    signal PCPlus4F   : std_logic_vector(31 downto 0);
    signal PCF        : std_logic_vector(31 downto 0);
    signal InstrF     : std_logic_vector(31 downto 0);

begin

    -- Instanciação do IF Stage
    DUT: entity work.if_stage
        port map (
            clk       => clk,
            rst       => rst,
            we        => we,
            PCSrcE    => PCSrcE,
            PCTargetE => PCTargetE,
            PCPlus4F  => PCPlus4F,
            PCF       => PCF,
            InstrF    => InstrF
        );

    -- Clock de 10ns
    clk <= not clk after 5 ns;

    process
    begin
        report "=== INICIANDO TESTE DO IF_STAGE (FETCH) ===";

        -- 1. Reset do Sistema
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait for 2 ns;
        report "Teste 1: Apos reset, PC deve ser 0. Lido: 0x" & to_hstring(PCF);

        -- 2. Incremento Sequencial (PC + 4)
        -- Esperamos ver o PC mudar de 0 para 4 e depois para 8
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 2a: PC incrementou para 4? Lido: 0x" & to_hstring(PCF);
        
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 2b: PC incrementou para 8? Lido: 0x" & to_hstring(PCF);

        -- 3. Teste de STALL (we = '0')
        -- O PC não deve mudar na próxima borda de clock
        we <= '0';
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 3: Verificando Stall (we=0). PC deve manter 8. Lido: 0x" & to_hstring(PCF);
        
        -- 4. Teste de Salto (Branch/Jump Taken)
        we      <= '1';
        PCSrcE  <= '1';
        PCTargetE <= x"00000040"; -- Salto para o endereço 64
        
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 4: Branch tomado para 0x40. Lido: 0x" & to_hstring(PCF);
        
        -- 5. Volta para fluxo sequencial
        PCSrcE <= '0';
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 5: Volta ao sequencial (0x40 + 4). Lido: 0x" & to_hstring(PCF);

        report "=== FIM DO TESTE IF_STAGE ===";
        wait;
    end process;

end architecture;