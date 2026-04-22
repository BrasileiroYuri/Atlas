library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_data_memory is
end entity;

architecture sim of tb_data_memory is

    -- Sinais para conectar à UUT
    signal clk    : std_logic := '0';
    signal rst    : std_logic := '0';
    signal we     : std_logic := '0';
    signal addr   : std_logic_vector(31 downto 0) := (others => '0');
    signal input  : std_logic_vector(31 downto 0) := (others => '0');
    signal output : std_logic_vector(31 downto 0);

begin

    -- Instanciação da Data Memory
    uut: entity work.data_memory
        port map (
            clk    => clk,
            rst    => rst,
            we     => we,
            addr   => addr,
            input  => input,
            output => output
        );

    -- Gerador de Clock (10ns)
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
    end process;

    test_proc : process
        variable v_success : boolean := true;
    begin
        report "Iniciando Testbench da Data Memory...";

        rst <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        rst <= '0';
        
        addr <= std_logic_vector(to_unsigned(5, 32)); -- Verifica endereço 5
        wait for 1 ns;
        assert output = x"00000000" 
            report "FAIL: Memoria nao foi zerada no reset!" severity error;
        if output /= x"00000000" then v_success := false; end if;

        we <= '1';
        addr <= std_logic_vector(to_unsigned(10, 32)); -- Endereço 10
        input <= x"CAFEBABE";
        wait until rising_edge(clk);
        
        we <= '0'; -- Desativa escrita
        wait for 1 ns;
        
        assert output = x"CAFEBABE" 
            report "FAIL: Erro na escrita/leitura do endereco 10" severity error;
        if output /= x"CAFEBABE" then v_success := false; end if;

        we <= '0';
        input <= x"DEADC0DE"; -- Tenta sobrescrever sem permissão
        wait until rising_edge(clk);
        wait for 1 ns;

        assert output = x"CAFEBABE" 
            report "FAIL: Dado alterado com Write Enable em '0'!" severity error;
        if output /= x"CAFEBABE" then v_success := false; end if;

        addr <= std_logic_vector(to_unsigned(5, 32));
        wait for 1 ns;
        
        assert output = x"00000000" 
            report "FAIL: Leitura do endereco 5 retornou lixo!" severity error;
        if output /= x"00000000" then v_success := false; end if;

        -- RESUMO FINAL
        if v_success then
            report "   SUCESSO: DATA MEMORY VALIDADA!          ";
        else
            report "   ERRO: FALHA NOS TESTES DA DATA MEMORY.  ";
        end if;

        wait;
    end process;

end architecture;