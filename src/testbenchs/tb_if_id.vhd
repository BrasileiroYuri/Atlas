library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_if_id is
end entity;

architecture sim of tb_if_id is
    -- Sinais de clock e controle
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal we  : std_logic := '1';

    -- Sinais de entrada (Estágio Fetch)
    signal InstrF   : std_logic_vector(31 downto 0) := (others => '0');
    signal PCF      : std_logic_vector(31 downto 0) := (others => '0');
    signal PCPlus4F : std_logic_vector(31 downto 0) := (others => '0');

    -- Sinais de saída (Estágio Decode)
    signal InstrD   : std_logic_vector(31 downto 0);
    signal PCD      : std_logic_vector(31 downto 0);
    signal PCPlus4D : std_logic_vector(31 downto 0);

begin

    -- Instanciação do DUT
    DUT: entity work.if_id
        port map (
            clk => clk, rst => rst, we => we,
            InstrF => InstrF, InstrD => InstrD,
            PCF => PCF, PCD => PCD,
            PCPlus4F => PCPlus4F, PCPlus4D => PCPlus4D
        );

    -- Clock de 10ns
    clk <= not clk after 5 ns;

    process
    begin
        report "=== INICIANDO TESTE DO REGISTRADOR IF/ID ===";

        -- 1. Reset
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait for 2 ns;

        -- 2. Teste de Fluxo Normal (Simulando 2 instruções)
        -- Instrução 1: ADDI x1, x0, 10
        InstrF   <= x"00A00093"; 
        PCF      <= x"00000000";
        PCPlus4F <= x"00000004";
        
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 1: InstrD recebeu ADDI? " & to_hstring(InstrD);

        -- Instrução 2: LW x2, 0(x1)
        InstrF   <= x"0000A103";
        PCF      <= x"00000004";
        PCPlus4F <= x"00000008";

        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 2: PCD atualizado para 0x4? " & to_hstring(PCD);

        -- 3. Teste de STALL (we = '0')
        -- O hardware de Hazard detecta um conflito e trava o IF/ID
        we <= '0';
        InstrF <= x"FFFFFFFF"; -- Nova instrução vindo do Fetch
        
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 3: Verificando Stall (O valor deve ser mantido)";
        if InstrD = x"0000A103" then
            report "SUCESSO: Stall funcionando, InstrD manteve LW.";
        else
            report "FALHA: Stall ignorado!";
        end if;

        -- 4. Retomando o fluxo
        we <= '1';
        wait until rising_edge(clk);
        wait for 2 ns;
        report "Teste 4: Fluxo retomado. InstrD: " & to_hstring(InstrD);

        report "=== FIM DO TESTE IF/ID ===";
        wait;
    end process;
end architecture;