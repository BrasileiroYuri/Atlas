library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_id_stage is
end entity;

architecture sim of tb_id_stage is
    -- Sinais de Clock e Reset
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    -- Entradas
    signal tb_InstrD_in : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_RegWriteW : std_logic := '0';
    signal tb_RdW       : std_logic_vector(4 downto 0) := "00000";
    signal tb_ResultW   : std_logic_vector(31 downto 0) := (others => '0');

    -- Saídas de Controle
    signal tb_RegWriteD   : std_logic;
    signal tb_ALUControlD : std_logic_vector(2 downto 0);
    signal tb_ALUSrcD      : std_logic;
    signal tb_ImmExtD     : std_logic_vector(31 downto 0);

    -- Saídas de Dados
    signal tb_RD1D : std_logic_vector(31 downto 0);
    signal tb_RD2D : std_logic_vector(31 downto 0);

begin

    -- Instanciação do Stage
    DUT: entity work.id_stage
        port map (
            clk => clk, rst => rst,
            InstrD_in => tb_InstrD_in,
            PCD_in => (others => '0'), PCPlus4D_in => (others => '0'),
            RegWriteW => tb_RegWriteW, RdW => tb_RdW, ResultW => tb_ResultW,
            RegWriteD => tb_RegWriteD, ResultSrcD => open, MemWriteD => open,
            JumpD => open, BranchD => open, ALUControlD => tb_ALUControlD,
            ALUSrcD => tb_ALUSrcD, ImmExtD => tb_ImmExtD,
            RD1D => tb_RD1D, RD2D => tb_RD2D,
            PCD_out => open, PCPlus4D_out => open, RdD => open
        );

    -- Clock 10ns
    clk <= not clk after 5 ns;

    process
    begin
        report "=== INICIANDO TESTE DO ID_STAGE (DECODE) ===";

        -- 1. Reset e Escrita Inicial no Register File
        -- Vamos simular que no ciclo anterior (Write Back), escrevemos 50 no x1
        tb_RegWriteW <= '1';
        tb_RdW       <= "00001"; -- x1
        tb_ResultW   <= std_logic_vector(to_unsigned(50, 32));
        wait until rising_edge(clk);
        tb_RegWriteW <= '0';
        wait for 2 ns;

        -- 2. Teste Instrução ADDI x2, x1, 10
        -- Binário: [ Imm(11:0) | rs1 | f3 | rd | opcode ]
        -- 000000001010 | 00001 | 000 | 00010 | 0010011
        tb_InstrD_in <= x"00A08113"; 
        wait for 10 ns;
        report "Teste 1: ADDI x2, x1, 10";
        report "RD1D (Valor de x1) esperado: 50 | Lido: " & to_integer(unsigned(tb_RD1D))'image;
        report "ImmExtD esperado: 10 | Lido: " & to_integer(unsigned(tb_ImmExtD))'image;
        report "ALUSrcD esperado: 1 | Lido: " & std_logic'image(tb_ALUSrcD);

        -- 3. Teste Instrução ADD x3, x1, x1
        -- Binário: 0000000 00001 00001 000 00011 0110011
        tb_InstrD_in <= x"001081B3";
        wait for 10 ns;
        report "";
        report "Teste 2: ADD x3, x1, x1";
        report "ALUSrcD esperado: 0 | Lido: " & std_logic'image(tb_ALUSrcD);
        report "ALUControlD esperado: 000 | Lido: " & to_string(tb_ALUControlD);

        -- 4. Teste Instrução LW x4, 20(x1)
        -- Binário: 000000010100 | 00001 | 010 | 00100 | 0000011
        tb_InstrD_in <= x"0140A203";
        wait for 10 ns;
        report "";
        report "Teste 3: LW x4, 20(x1)";
        report "RegWriteD esperado: 1 | Lido: " & std_logic'image(tb_RegWriteD);
        report "ImmExtD esperado: 20 | Lido: " & to_integer(unsigned(tb_ImmExtD))'image;

        report "=== FIM DO TESTE ID_STAGE ===";
        wait;
    end process;
end architecture;