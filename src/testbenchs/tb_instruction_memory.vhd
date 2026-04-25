library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_instruction_memory is
end entity;

architecture sim of tb_instruction_memory is

    signal s_addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal s_instruction : std_logic_vector(31 downto 0);

begin

    uut: entity work.instruction_memory
        port map (
            addr        => s_addr,
            instruction => s_instruction
        );

    test_proc : process
        variable v_success : boolean := true;
    begin
        report "Iniciando Testbench da Instruction Memory...";


        s_addr <= std_logic_vector(to_unsigned(0, 32));
        wait for 10 ns;

        assert s_instruction = x"00000000"
            report "FAIL: Esperava 0 no endereço 0" severity error;
        if s_instruction /= x"00000000" then v_success := false; end if;

        s_addr <= std_logic_vector(to_unsigned(4, 32));
        wait for 10 ns;

        assert s_instruction = x"00000000"
            report "FAIL: Esperava 0 no endereço 4" severity error;
        if s_instruction /= x"00000000" then v_success := false; end if;

        -----------------------------------------------------------
        -- RESUMO
        -----------------------------------------------------------
        if v_success then
            report "   SUCESSO: INSTRUCTION MEMORY VALIDADA!   ";
        end if;

        wait;
    end process;

end architecture;
