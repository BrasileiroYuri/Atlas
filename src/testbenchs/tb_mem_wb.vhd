library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_mem_wb is
end entity;

architecture sim of tb_mem_wb is
    -- Controle
    signal clk, rst, we : std_logic := '0';

    -- Entradas (Estágio Memory)
    signal RegWriteM  : std_logic := '0';
    signal ResultSrcM : std_logic_vector(1 downto 0) := "00";
    signal RdM        : std_logic_vector(4 downto 0) := "00000";
    signal DataMem_in : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUResultM : std_logic_vector(31 downto 0) := (others => '0');
    signal PCPlus4M   : std_logic_vector(31 downto 0) := (others => '0');

    -- Saídas (Estágio Write Back)
    signal RegWriteW  : std_logic;
    signal ReadDataW  : std_logic_vector(31 downto 0);
    signal ALUResultW : std_logic_vector(31 downto 0);
    signal RdW        : std_logic_vector(4 downto 0);

begin

    -- Instanciação do DUT
    DUT: entity work.mem_wb
        port map (
            clk => clk, rst => rst, we => we,
            RegWriteM => RegWriteM, RegWriteW => RegWriteW,
            ResultSrcM => ResultSrcM, ResultSrcW => open,
            RdM => RdM, RdW => RdW,
            DataMem_in => DataMem_in, ReadDataW => ReadDataW,
            ALUResultM => ALUResultM, ALUResultW => ALUResultW,
            PCPlus4M => PCPlus4M, PCPlus4W => open
        );

    -- Clock (10ns)
    clk <= not clk after 5 ns;

    process
    begin
        report "=== INICIANDO TESTE DO REGISTRADOR MEM/WB ===";

        -- 1. Reset
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        we  <= '1';
        wait for 2 ns;

        -- 2. Testando fluxo de dados de uma instrução LW (Load Word)
        -- O dado vem da memória (DataMem_in)
        RegWriteM  <= '1';
        ResultSrcM <= "01"; -- Indica que o resultado vem da memória
        RdM        <= "01010"; -- Registrador x10
        DataMem_in <= x"ABCDE001";
        ALUResultM <= x"00000040"; -- Endereço calculado pela ULA
        
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 1: Escrita de LW";
        report "ReadDataW esperado: 0xABCDE001 | Lido: 0x" & to_hstring(ReadDataW);
        report "RdW (destino): " & to_string(RdW);

        -- 3. Testando fluxo de uma instrução Tipo-R (ADD)
        -- O dado vem da ALU (ALUResultM)
        RegWriteM  <= '1';
        ResultSrcM <= "00";
        RdM        <= "00101"; -- Registrador x5
        ALUResultM <= x"00000019"; -- 25 em decimal
        
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 2: Escrita de Tipo-R";
        report "ALUResultW esperado: 0x00000019 | Lido: 0x" & to_hstring(ALUResultW);

        -- 4. Teste de trava (we = '0')
        we <= '0';
        ALUResultM <= x"FFFFFFFF"; -- Novo dado que deve ser ignorado
        
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 3: Verificando Stall no WB";
        if ALUResultW = x"00000019" then
            report "SUCESSO: Valor anterior mantido.";
        else
            report "FALHA: Registrador sobrescrito indevidamente!";
        end if;

        report "=== FIM DO TESTE MEM/WB ===";
        wait;
    end process;
end architecture;