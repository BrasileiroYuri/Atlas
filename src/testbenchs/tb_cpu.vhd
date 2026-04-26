library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_cpu is
end entity tb_cpu;

architecture sim of tb_cpu is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
begin
    -- Instancia o processador completo
    DUT: entity work.cpu port map (
        clk => clk,
        rst => rst
    );

    -- Gerador de Clock (100MHz / 10ns)
    clk <= not clk after 5 ns;

    process
    begin
        report "==============================================================";
        report " ATLAS RISC-V: INICIANDO EXECUCAO DO PROGRAMA NO PIPELINE";
        report "==============================================================";
        
        -- Reset inicial
        rst <= '1';
        wait for 25 ns;
        rst <= '0';
        
        report ">>> Reset desativado. O processador comecou a trabalhar!";
        
        -- Deixamos rodar por alguns ciclos para as instrucoes passarem pelos 5 estagios
        -- Ciclo 1: IF (lw x1)
        -- Ciclo 2: ID (lw x1), IF (lw x2)
        -- Ciclo 3: EX (lw x1), ID (lw x2), IF (add)
        -- Ciclo 4: MEM(lw x1), EX (lw x2), ID (add), IF (sw)
        -- Ciclo 5: WB (lw x1) -> Registrador x1 recebe 10!
        
        wait for 200 ns;

        report "==============================================================";
        report " FIM DA SIMULACAO. VERIFIQUE AS ONDAS NO GTKWAVE!";
        report "==============================================================";
        
        std.env.stop;
    end process;
end architecture;