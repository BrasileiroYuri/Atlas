library IEEE;
use IEEE.std_logic_1164.all;

entity tb_maindec is
end entity;

architecture sim of tb_maindec is
    signal op        : std_logic_vector(6 downto 0) := (others => '0');
    signal ResultSrc : std_logic_vector(1 downto 0);
    signal MemWrite  : std_logic;
    signal Branch    : std_logic;
    signal ALUSrc    : std_logic;
    signal RegWrite  : std_logic;
    signal Jump      : std_logic;
    signal ImmSrc    : std_logic_vector(1 downto 0);
    signal ALUOp     : std_logic_vector(1 downto 0);

begin

    DUT: entity work.maindec
        port map (
            op        => op,
            ResultSrc => ResultSrc,
            MemWrite  => MemWrite,
            Branch    => Branch,
            ALUSrc    => ALUSrc,
            RegWrite  => RegWrite,
            Jump      => Jump,
            ImmSrc    => ImmSrc,
            ALUOp     => ALUOp
        );

    process
    begin
        report "=== INICIANDO TESTE DO MAIN DECODER ===";

        -- 1. Teste Tipo-R (Ex: ADD, SUB)
        op <= "0110011";
        wait for 10 ns;
        assert (RegWrite = '1' and ALUSrc = '0' and ALUOp = "10")
            report "Erro no Tipo-R" severity error;

        -- 2. Teste Tipo-I Load (Ex: LW)
        op <= "0000011";
        wait for 10 ns;
        assert (RegWrite = '1' and ALUSrc = '1' and ResultSrc = "01")
            report "Erro no Tipo-I Load" severity error;

        -- 3. Teste Tipo-S (Ex: SW)
        op <= "0100011";
        wait for 10 ns;
        assert (MemWrite = '1' and RegWrite = '0' and ImmSrc = "01")
            report "Erro no Tipo-S" severity error;

        -- 4. Teste Tipo-B (Ex: BEQ)
        op <= "1100011";
        wait for 10 ns;
        assert (Branch = '1' and ALUOp = "01" and ImmSrc = "10")
            report "Erro no Tipo-B" severity error;

        -- 5. Teste Tipo-J (Ex: JAL)
        op <= "1101111";
        wait for 10 ns;
        assert (Jump = '1' and RegWrite = '1' and ResultSrc = "10")
            report "Erro no Tipo-J" severity error;

        report "=== FIM DO TESTE DO MAIN DECODER ===";
        wait;
    end process;
end architecture;