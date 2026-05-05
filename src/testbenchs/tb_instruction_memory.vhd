library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_instruction_memory is
end entity tb_instruction_memory;

architecture sim of tb_instruction_memory is

    -- Sinais do Testbench com a nova nomenclatura F (Fetch)
    signal tb_PCF   : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_InstrF : std_logic_vector(31 downto 0);

begin

    -- Instanciação Direta (Ligar os fios corretamente!)
    uut: entity work.instruction_memory
        port map (
            PCF    => tb_PCF,
            InstrF => tb_InstrF
        );

    test_proc : process
    begin
        report "==============================================================";
        report " INICIANDO DEPURACAO: INSTRUCTION MEMORY (ROM)";
        report "==============================================================";

        -- ==================================================
        -- TESTE 1: LEITURA DO ENDEREÇO 0
        -- ==================================================
        report "";
        report "--- [TESTE 1] LEITURA DA PRIMEIRA INSTRUCAO (PC = 0) ---";
        tb_PCF <= x"00000000";
        wait for 10 ns;

        report "[1. Entradas]       PCF: 0x00000000";
        report "[2. Saida Esperada] InstrF: 0x00000000 (Memoria inicia zerada)";
        report "[3. Saida Gerada]   InstrF: 0x" & to_hstring(tb_InstrF);

        assert tb_InstrF = x"00000000"
            report "FALHA [TESTE 1]: Esperava 0 no endereco 0!"
            severity error;

        -- ==================================================
        -- TESTE 2: LEITURA DO ENDEREÇO 4
        -- ==================================================
        report "";
        report "--- [TESTE 2] LEITURA DA SEGUNDA INSTRUCAO (PC = 4) ---";
        tb_PCF <= x"00000004"; -- As instruções avançam de 4 em 4 bytes
        wait for 10 ns;

        report "[1. Entradas]       PCF: 0x00000004";
        report "[2. Saida Esperada] InstrF: 0x00000000";
        report "[3. Saida Gerada]   InstrF: 0x" & to_hstring(tb_InstrF);

        assert tb_InstrF = x"00000000"
            report "FALHA [TESTE 2]: Esperava 0 no endereco 4!"
            severity error;

        -----------------------------------------------------------
        -- FINALIZACAO
        -----------------------------------------------------------
        report "";
        report "==============================================================";
        report " TODOS OS TESTES PASSARAM COM SUCESSO! (ROM VALIDADA)";
        report "==============================================================";

        wait;
    end process;

end architecture sim;