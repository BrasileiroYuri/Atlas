library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_wb_stage is
end entity;

architecture sim of tb_wb_stage is
    -- Entradas de Dados
    signal tb_ReadDataW  : std_logic_vector(31 downto 0) := x"11111111";
    signal tb_ALUResultM : std_logic_vector(31 downto 0) := x"22222222";
    signal tb_PCPlus4W   : std_logic_vector(31 downto 0) := x"33333333";
    
    -- Controle
    signal tb_ResultSrcW : std_logic_vector(1 downto 0) := "00";
    signal tb_RdW_in     : std_logic_vector(4 downto 0)  := "00101"; -- x5
    signal tb_RegWriteW  : std_logic := '1';

    -- Saídas
    signal tb_ResultW    : std_logic_vector(31 downto 0);
    signal tb_RdW_out    : std_logic_vector(4 downto 0);
    signal tb_RegWrite_O : std_logic;

begin

    -- Instanciação do Stage
    DUT: entity work.wb_stage
        port map (
            RdW_in        => tb_RdW_in,
            RegWriteW_in  => tb_RegWriteW,
            ResultSrcW    => tb_ResultSrcW,
            ReadDataW     => tb_ReadDataW,
            PCPlus4W      => tb_PCPlus4W,
            ALUResultM    => tb_ALUResultM,
            RdW_out       => tb_RdW_out,
            RegWriteW_out => tb_RegWrite_O,
            ResultW       => tb_ResultW
        );

    process
    begin
        report "=== INICIANDO TESTE DO WB_STAGE (WRITE BACK) ===";

        -- TESTE 1: Selecionar ALU (ResultSrc = 00)
        tb_ResultSrcW <= "00";
        wait for 10 ns;
        report "Teste 1 (ALU): Esperado 0x22222222 | Lido: 0x" & to_hstring(tb_ResultW);

        -- TESTE 2: Selecionar Memória (ResultSrc = 01)
        tb_ResultSrcW <= "01";
        wait for 10 ns;
        report "Teste 2 (DataMem): Esperado 0x11111111 | Lido: 0x" & to_hstring(tb_ResultW);

        -- TESTE 3: Selecionar PC+4 (ResultSrc = 10 - Instruções JUMP)
        tb_ResultSrcW <= "10";
        wait for 10 ns;
        report "Teste 3 (PC+4): Esperado 0x33333333 | Lido: 0x" & to_hstring(tb_ResultW);

        -- TESTE 4: Verificação de Sinais de Passagem
        report "Teste 4: Verificando endereco de destino (Rd)";
        if tb_RdW_out = "00101" and tb_RegWrite_O = '1' then
            report "SUCESSO: Sinais Rd e RegWrite propagados corretamente.";
        else
            report "FALHA: Erro na propagacao dos sinais de controle.";
        end if;

        report "=== FIM DO TESTE WB_STAGE ===";
        wait;
    end process;
end architecture;