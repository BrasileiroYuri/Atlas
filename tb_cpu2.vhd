library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_cpu2 is
end entity tb_cpu2;

architecture rtl of tb_cpu2 is
    signal tb_clk, tb_rst : std_logic := '0';
    signal s_RdW          : std_logic_vector(4 downto 0) := "00000";
    signal s_ResultW      : std_logic_vector(31 downto 0);
begin

    CPU : entity work.cpu port map (
        clk     => tb_clk,
        rst     => tb_rst,
        RdW     => s_RdW,
        ResultW => s_ResultW
    );

    clk_process : process
    begin
        while true loop
            tb_clk <= '0'; wait for 5 ns;
            tb_clk <= '1'; wait for 5 ns;
        end loop;
    end process;

test_proc : process
    variable found_1 : boolean := false;
    variable found_2 : boolean := false;
    variable found_3 : boolean := false;
    variable found_4 : boolean := false;
    variable found_5 : boolean := false;
begin
 tb_rst <= '1';
    wait until rising_edge(tb_clk);
    tb_rst <= '0';

    -- Amostra em cada rising edge, não em tempo absoluto
    for i in 1 to 20 loop
        wait until rising_edge(tb_clk);
--        wait for 1 ns;

        report "Ciclo " & integer'image(i) &
               " | RdW=" & to_hstring("000" & s_RdW) &
               " | ResultW=" & to_hstring(s_ResultW)
        severity note;

        -- Captura no ciclo exato em que o WB produz resultado
        if s_RdW = "00011" and s_ResultW = x"00000004" then
            report "PASS: ADD x3,x1,x2 = 4 no ciclo " & integer'image(i)
            severity note;
            found_1 := true;
        end if;

        if s_RdW = "00110" and s_ResultW = x"00000001" then
            report "PASS: SUB x6,x5,x4 = 1 no ciclo " & integer'image(i)
            severity note;
            found_2 := true;
        end if;

        if s_RdW = "01111" and s_ResultW = x"00000002" then
            report "PASS: NOT x15 x7 = 2 no ciclo " & integer'image(i)
            severity note;
            found_3 := true;
        end if;

        if s_RdW = "01001" and s_ResultW = x"00000002" then
            report "PASS: AND x9 x1 x8 = 2 no ciclo " & integer'image(i)
            severity note;
            found_4 := true;
        end if;

        if s_RdW = "01011" and s_ResultW = x"00000003" then
            report "PASS: OR x11 x1 x8 = 3 no ciclo " & integer'image(i)
            severity note;
            found_5 := true;
        end if;
    end loop;

    assert found_1
        report "FALHA: resultado correto nunca apareceu no WB 1"
        severity error;

    assert found_2
        report "FALHA: resultado correto nunca apareceu no WB 2"
        severity error;

    assert found_3
        report "FALHA: resultado correto nunca apareceu no WB 3"
        severity error;

    assert found_4
        report "FALHA: resultado correto nunca apareceu no WB 4"
        severity error;

    assert found_5
        report "FALHA: resultado correto nunca apareceu no WB 5"
        severity error;
    report "=== FIM ===" severity note;
    wait;
end process;
end architecture rtl;
