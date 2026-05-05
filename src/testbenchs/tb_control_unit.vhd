library IEEE;
use IEEE.std_logic_1164.all;

entity tb_control_unit is
end entity;

architecture sim of tb_control_unit is
    -- Sinais de entrada
    signal tb_op       : std_logic_vector(6 downto 0) := (others => '0');
    signal tb_funct3   : std_logic_vector(2 downto 0) := (others => '0');
    signal tb_funct7b5 : std_logic := '0';

    -- Sinais de saída
    signal tb_ResultSrc  : std_logic_vector(1 downto 0);
    signal tb_MemWrite   : std_logic;
    signal tb_Branch     : std_logic;
    signal tb_ALUSrc     : std_logic;
    signal tb_RegWrite   : std_logic;
    signal tb_Jump       : std_logic;
    signal tb_ImmSrc     : std_logic_vector(1 downto 0);
    signal tb_ALUControl : std_logic_vector(2 downto 0);

begin

    -- Instanciação direta da Unidade de Controle
    DUT: entity work.control_unit
        port map (
            op         => tb_op,
            funct3     => tb_funct3,
            funct7b5   => tb_funct7b5,
            ResultSrc  => tb_ResultSrc,
            MemWrite   => tb_MemWrite,
            Branch     => tb_Branch,
            ALUSrc     => tb_ALUSrc,
            RegWrite   => tb_RegWrite,
            Jump       => tb_Jump,
            ImmSrc     => tb_ImmSrc,
            ALUControl => tb_ALUControl
        );

    process
    begin
        report "==============================================================";
        report " INICIANDO DEPURACAO DA UNIDADE DE CONTROLE (RISC-V)";
        report "==============================================================";

      
        tb_op       <= "0110011"; -- Opcode Tipo-R
        tb_funct3   <= "000";     -- ADD
        tb_funct7b5 <= '0';       -- ADD (se fosse '1' seria SUB)
        wait for 10 ns;
        report "--- [TESTE 1] TIPO-R (ADD) ---";
        report "RegWrite esperado: 1 | Saida: " & std_logic'image(tb_RegWrite);
        report "ALUSrc esperado: 0 (Usa Reg B) | Saida: " & std_logic'image(tb_ALUSrc);
        report "ALUControl esperado: 000 (Soma) | Saida: " & to_string(tb_ALUControl);

      
        tb_op       <= "0000011"; -- Opcode Load
        tb_funct3   <= "010";     -- LW
        tb_funct7b5 <= '0';
        wait for 10 ns;
        report "";
        report "--- [TESTE 2] LOAD WORD (LW) ---";
        report "ALUSrc esperado: 1 (Usa Imediato) | Saida: " & std_logic'image(tb_ALUSrc);
        report "MemWrite esperado: 0 | Saida: " & std_logic'image(tb_MemWrite);
        report "ResultSrc esperado: 01 (Vem da Memoria) | Saida: " & to_string(tb_ResultSrc);

      
        tb_op       <= "0100011"; -- Opcode Store
        tb_funct3   <= "010";     -- SW
        wait for 10 ns;
        report "";
        report "--- [TESTE 3] STORE WORD (SW) ---";
        report "MemWrite esperado: 1 | Saida: " & std_logic'image(tb_MemWrite);
        report "RegWrite esperado: 0 | Saida: " & std_logic'image(tb_RegWrite);
        report "ImmSrc esperado: 01 (Tipo-S) | Saida: " & to_string(tb_ImmSrc);

       
        tb_op       <= "1100011"; -- Opcode Branch
        tb_funct3   <= "000";     -- BEQ
        wait for 10 ns;
        report "";
        report "--- [TESTE 4] BRANCH (BEQ) ---";
        report "Branch esperado: 1 | Saida: " & std_logic'image(tb_Branch);
        report "ALUControl esperado: 001 (Subtracao para comparar) | Saida: " & to_string(tb_ALUControl);
        report "RegWrite esperado: 0 | Saida: " & std_logic'image(tb_RegWrite);

        report "";
        report "==============================================================";
        report " FIM DOS TESTES DA UNIDADE DE CONTROLE";
        report "==============================================================";
        wait;
    end process;
end architecture;