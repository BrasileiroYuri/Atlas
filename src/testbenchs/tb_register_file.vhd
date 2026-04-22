library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_register_file is
end entity;

architecture sim of tb_register_file is

    -- Sinais para conectar ao UUT
    signal clk      : std_logic := '0';
    signal we       : std_logic := '0';
    signal in_addr  : std_logic_vector(4 downto 0)  := (others => '0');
    signal R1       : std_logic_vector(4 downto 0)  := (others => '0');
    signal R2       : std_logic_vector(4 downto 0)  := (others => '0');
    signal in_data  : std_logic_vector(31 downto 0) := (others => '0');
    signal Out1     : std_logic_vector(31 downto 0);
    signal Out2     : std_logic_vector(31 downto 0);

begin

    -- Instanciação do componente
    uut: entity work.register_file
        port map (
            clk     => clk,
            we      => we,
            in_addr => in_addr,
            R1      => R1,
            R2      => R2,
            in_data => in_data,
            Out1    => Out1,
            Out2    => Out2
        );

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
        report "Iniciando Testbench do Register File...";

        we <= '1';
        in_addr <= "00000";
        in_data <= x"FFFFFFFF";
        R1 <= "00000";
        wait until rising_edge(clk);
        wait for 1 ns; -- Aguarda propagação

        assert Out1 = x"00000000"
            report "FAIL: Registrador 0 foi alterado! (Deveria ser fixo em zero)"
            severity error;
        if Out1 /= x"00000000" then v_success := false; end if;

        we <= '1';
        in_addr <= "00101"; -- R5
        in_data <= x"12345678";
        wait until rising_edge(clk);

        -- Escrever 0xDEADBEEF no Reg 10
        in_addr <= "01010"; -- R10
        in_data <= x"DEADBEEF";
        wait until rising_edge(clk);

        we <= '0'; -- Desativa escrita
        
        -- Configura endereços de leitura
        R1 <= "00101"; -- Aponta para R5
        R2 <= "01010"; -- Aponta para R10
        wait for 2 ns; -- Leitura combinacional

        assert Out1 = x"12345678"
            report "FAIL: Erro na leitura do Registrador 5" severity error;
        if Out1 /= x"12345678" then v_success := false; end if;

        assert Out2 = x"DEADBEEF"
            report "FAIL: Erro na leitura do Registrador 10" severity error;
        if Out2 /= x"DEADBEEF" then v_success := false; end if;

        we <= '0';
        in_addr <= "00101";    -- Tenta escrever no R5 novamente
        in_data <= x"00000000"; -- Tenta zerar o dado
        wait until rising_edge(clk);
        wait for 1 ns;

        assert Out1 = x"12345678"
            report "FAIL: Dado foi sobrescrito com WE='0'!" severity error;
        if Out1 /= x"12345678" then v_success := false; end if;

        if v_success then
            report "   SUCESSO: REGISTER FILE VALIDADO!        ";
        else
            report "   ERRO: O TESTE TERMINOU COM FALHAS.      ";
        end if;

        wait; -- Para a simulação
    end process;

end architecture;