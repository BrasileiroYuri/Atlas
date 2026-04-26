library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_mem_stage is
end entity;

architecture sim of tb_mem_stage is
    -- Controle
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal MemWriteM  : std_logic := '0';

    -- Sinais de Passagem (Inputs)
    signal RegWriteM_in  : std_logic := '0';
    signal ResultSrcM_in : std_logic_vector(1 downto 0) := "00";
    signal RdM_in        : std_logic_vector(4 downto 0) := "00000";
    signal ALUResultM_in : std_logic_vector(31 downto 0) := (others => '0');

    -- Dados
    signal WriteDataM   : std_logic_vector(31 downto 0) := (others => '0');
    signal DataMem_out  : std_logic_vector(31 downto 0);

    -- Sinais de Passagem (Outputs)
    signal RegWriteM_out : std_logic;
    signal RdM_out       : std_logic_vector(4 downto 0);

begin

    -- Instanciação do MEM Stage
    DUT: entity work.mem_stage
        port map (
            clk => clk, rst => rst,
            MemWriteM      => MemWriteM,
            RegWriteM_in   => RegWriteM_in,
            RegWriteM_out  => RegWriteM_out,
            ResultSrcM_in  => ResultSrcM_in,
            ResultSrcM_out => open,
            RdM_in         => RdM_in,
            RdM_out        => RdM_out,
            PCPlus4M_in    => (others => '0'),
            PCPlus4M_out   => open,
            ALUResultM_in  => ALUResultM_in,
            ALUResultM_out => open,
            WriteDataM     => WriteDataM,
            DataMem_out    => DataMem_out
        );

    -- Clock de 10ns
    clk <= not clk after 5 ns;

    process
    begin
        report "=== INICIANDO TESTE DO MEM_STAGE ===";

        -- 1. Reset
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait for 2 ns;

        -- 2. Teste de Escrita (SW x5, 4(x0))
        -- Vamos simular a gravação do valor 0xAAAA5555 no endereço 4
        ALUResultM_in <= x"00000004"; -- Endereço calculado no EX stage
        WriteDataM    <= x"AAAA5555"; -- Dado vindo do RD2 do Register File
        MemWriteM     <= '1';
        RegWriteM_in  <= '0';         -- Store não escreve no Register File
        RdM_in        <= "00101";     -- rd (x5)
        
        wait until rising_edge(clk);
        MemWriteM <= '0';
        wait for 2 ns;
        report "Teste 1 (Store): Escrita no endereco 0x4 concluida.";

        -- 3. Teste de Leitura (LW x10, 4(x0))
        -- O endereço continua sendo 4, MemWrite vai para 0
        ALUResultM_in <= x"00000004";
        MemWriteM     <= '0';
        RegWriteM_in  <= '1';         -- Load vai escrever no Register File depois
        RdM_in        <= "01010";     -- rd (x10)
        
        wait for 5 ns; -- Leitura assíncrona da memória
        report "Teste 2 (Load): Lido do endereco 0x4: 0x" & to_hstring(DataMem_out);
        
        -- 4. Verificação dos sinais de passagem
        report "Teste 3: Verificando sinais de passagem";
        if RdM_out = "01010" and RegWriteM_out = '1' then
            report "SUCESSO: Sinais de controle preservados para o WB.";
        else
            report "FALHA: Erro no redirecionamento dos sinais.";
        end if;

        report "=== FIM DO TESTE MEM_STAGE ===";
        wait;
    end process;

end architecture;