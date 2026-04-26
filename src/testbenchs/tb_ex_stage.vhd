library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ex_stage is
end entity;

architecture sim of tb_ex_stage is
    -- Sinais de Controle
    signal tb_ALUControlE : std_logic_vector(2 downto 0) := "000";
    signal tb_ALUSrcE      : std_logic := '0';
    signal tb_JumpE        : std_logic := '0';
    signal tb_BranchE      : std_logic := '0';

    -- Sinais de Dados
    signal tb_RD1E        : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_RD2E        : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_PCE         : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_ImmExtE     : std_logic_vector(31 downto 0) := (others => '0');

    -- Saídas
    signal tb_ALUResultE  : std_logic_vector(31 downto 0);
    signal tb_PCTargetE   : std_logic_vector(31 downto 0);
    signal tb_SELMux      : std_logic;

begin

    -- Instanciação do Stage
    DUT: entity work.ex_stage
        port map (
            RegWriteE_in   => '0', RegWriteE_out => open,
            ResultSrcE_in  => "00", ResultSrcE_out => open,
            MemWriteE_in   => '0', MemWriteE_out => open,
            RdE_in         => "00000", RdE_out => open,
            PCPlusE_in     => (others => '0'), PCPlusE_out => open,
            JumpE          => tb_JumpE,
            BranchE        => tb_BranchE,
            ALUControlE    => tb_ALUControlE,
            ALUSrcE        => tb_ALUSrcE,
            RD1E           => tb_RD1E,
            RD2E           => tb_RD2E,
            ALUResultE     => tb_ALUResultE,
            WriteDataE     => open,
            PCE            => tb_PCE,
            ImmExtE        => tb_ImmExtE,
            PCTargetE      => tb_PCTargetE,
            SELMux         => tb_SELMux
        );

    process
    begin
        report "=== INICIANDO TESTE DO EXECUTE STAGE (EX) ===";

        -- TESTE 1: Soma com Registradores (Tipo-R: ADD x1, x2, x3)
        -- 10 + 20 = 30
        tb_RD1E <= x"0000000A"; -- 10
        tb_RD2E <= x"00000014"; -- 20
        tb_ALUSrcE <= '0';      -- Seleciona RD2E
        tb_ALUControlE <= "000"; -- Soma
        wait for 10 ns;
        report "Teste 1 (ADD): Resultado = 0x" & to_hstring(tb_ALUResultE);

        -- TESTE 2: Soma com Imediato (Tipo-I: ADDI x1, x2, 5)
        -- 10 + 5 = 15
        tb_ImmExtE <= x"00000005";
        tb_ALUSrcE <= '1';      -- Seleciona Imediato
        wait for 10 ns;
        report "Teste 2 (ADDI): Resultado = 0x" & to_hstring(tb_ALUResultE);

        -- TESTE 3: Cálculo de PCTarget (PCE + ImmExt)
        -- PC=0x1000 + Imm=0x4 -> Target=0x1004
        tb_PCE <= x"00001000";
        tb_ImmExtE <= x"00000004";
        wait for 10 ns;
        report "Teste 3: PCTarget calculado = 0x" & to_hstring(tb_PCTargetE);

        -- TESTE 4: Lógica de Branch (BEQ)
        -- RD1=10, RD2=10 -> Zero=1 -> SELMux deve ser 1
        tb_RD1E <= x"0000000A";
        tb_RD2E <= x"0000000A";
        tb_ALUSrcE <= '0';
        tb_ALUControlE <= "001"; -- Subtração (para comparar)
        tb_BranchE <= '1';
        wait for 10 ns;
        report "Teste 4: Branch Equal (BEQ) -> SELMux = " & std_logic'image(tb_SELMux);

        -- TESTE 5: Instrução de JUMP (JAL)
        -- JumpE=1 deve forçar SELMux=1 independente do Branch ou Zero
        tb_JumpE <= '1';
        tb_BranchE <= '0';
        wait for 10 ns;
        report "Teste 5: Jump Ativo -> SELMux = " & std_logic'image(tb_SELMux);

        report "=== FIM DO TESTE EX_STAGE ===";
        wait;
    end process;
end architecture;