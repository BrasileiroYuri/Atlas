library IEEE;
use IEEE.std_logic_1164.all;

entity tb_aludec is
end entity tb_aludec;

architecture sim of tb_aludec is

  -- Sinais de entrada
  signal tb_opb5     : std_logic := '0';
  signal tb_funct3   : std_logic_vector(2 downto 0) := "000";
  signal tb_funct7b5 : std_logic := '0';
  signal tb_ALUOp    : std_logic_vector(1 downto 0) := "00";
  
  -- Sinal de saída
  signal tb_ALUControl : std_logic_vector(2 downto 0);

begin

  -- Instanciação Direta do Especialista da ULA (Mais limpo, sem "component")
  DUT: entity work.aludec port map (
    opb5       => tb_opb5,
    funct3     => tb_funct3,
    funct7b5   => tb_funct7b5,
    ALUOp      => tb_ALUOp,
    ALUControl => tb_ALUControl
  );

  process
  begin
    report "==============================================================";
    report " INICIANDO DEPURACAO: ALU DECODER (ESPECIALISTA DA ULA)";
    report "==============================================================";
    wait for 10 ns;

    -- ==========================================
    -- TESTE 1: INSTRUÇÕES DE MEMÓRIA (LD/ST)
    -- ==========================================
    report "";
    report "--- [TESTE 1] TIPO: MEMORIA (LD/ST) ---";
    tb_ALUOp    <= "00"; -- MainDec diz: é Memória!
    tb_opb5     <= '0';  -- Irrelevante
    tb_funct3   <= "010";-- Irrelevante (o ALUOp 00 sobrepõe)
    tb_funct7b5 <= '0';  -- Irrelevante
    wait for 10 ns;
    
    report "[1. Entradas]     ALUOp: 00 (Soma de Endereços)";
    report "[2. Esperado]     A ULA deve SOMAR base+imediato -> Esperado: 000 (ADD)";
    report "[3. Gerado]       Gerado: " & to_string(tb_ALUControl);

    assert tb_ALUControl = "000" 
      report "FALHA [TESTE 1]: A ULA devia estar configurada para SOMAR (000) em instrucoes de memoria." 
      severity error;

    -- ==========================================
    -- TESTE 2: BRANCH JZ (Comparar Igualdade)
    -- ==========================================
    report "";
    report "--- [TESTE 2] TIPO: BRANCH (JZ / BEQ) ---";
    tb_ALUOp    <= "01";  -- MainDec diz: é Branch!
    tb_funct3   <= "000"; -- BEQ/JZ
    tb_opb5     <= '0';
    tb_funct7b5 <= '0';
    wait for 10 ns;
    
    report "[1. Entradas]     ALUOp: 01 (Branch) | funct3: 000 (JZ)";
    report "[2. Esperado]     A ULA deve SUBTRAIR para ligar a flag Zero -> Esperado: 001 (SUB)";
    report "[3. Gerado]       Gerado: " & to_string(tb_ALUControl);

    assert tb_ALUControl = "001" 
      report "FALHA [TESTE 2]: A ULA devia estar configurada para SUBTRAIR (001) num Branch de igualdade." 
      severity error;

    -- ==========================================
    -- TESTE 3: MATEMÁTICA BÁSICA (ADD)
    -- ==========================================
    report "";
    report "--- [TESTE 3] TIPO: MATEMATICA (ADD) ---";
    tb_ALUOp    <= "10";  -- MainDec diz: Lógica Matemática!
    tb_funct3   <= "000"; -- ADD ou SUB
    tb_opb5     <= '1';   -- É Tipo-R
    tb_funct7b5 <= '0';   -- Bit 30 é zero -> É ADD normal
    wait for 10 ns;
    
    report "[1. Entradas]     ALUOp: 10 | funct3: 000 | funct7b5: 0";
    report "[2. Esperado]     Matematica, Tipo-R, Sem bit de subtracao -> Esperado: 000 (ADD)";
    report "[3. Gerado]       Gerado: " & to_string(tb_ALUControl);

    assert tb_ALUControl = "000" 
      report "FALHA [TESTE 3]: A ULA devia estar configurada para SOMAR (000) na instrucao ADD." 
      severity error;

    -- ==========================================
    -- TESTE 4: MATEMÁTICA BÁSICA (SUB / CMP)
    -- ==========================================
    report "";
    report "--- [TESTE 4] TIPO: MATEMATICA (SUB / CMP) ---";
    tb_ALUOp    <= "10";  -- MainDec diz: Lógica Matemática!
    tb_funct3   <= "000"; -- ADD ou SUB
    tb_opb5     <= '1';   -- É Tipo-R
    tb_funct7b5 <= '1';   -- Bit 30 é UM -> É SUB / CMP!
    wait for 10 ns;
    
    report "[1. Entradas]     ALUOp: 10 | funct3: 000 | funct7b5: 1";
    report "[2. Esperado]     Matematica, Tipo-R, COM bit subtracao ativo -> Esperado: 001 (SUB)";
    report "[3. Gerado]       Gerado: " & to_string(tb_ALUControl);

    assert tb_ALUControl = "001" 
      report "FALHA [TESTE 4]: A ULA devia estar configurada para SUBTRAIR (001) na instrucao SUB/CMP." 
      severity error;

    -- ==========================================
    -- TESTE 5: A VOSSA INSTRUÇÃO XOR / NOT
    -- ==========================================
    report "";
    report "--- [TESTE 5] TIPO: MATEMATICA (XOR / NOT) ---";
    tb_ALUOp    <= "10";  -- MainDec diz: Lógica Matemática!
    tb_funct3   <= "100"; -- XOR (Vosso mapeamento do inst.txt)
    tb_opb5     <= '0';   -- Tipo-I (XORI) ou Tipo-R (XOR)
    tb_funct7b5 <= '0';
    wait for 10 ns;
    
    report "[1. Entradas]     ALUOp: 10 | funct3: 100";
    report "[2. Esperado]     Operador Logico XOR (usado tb no NOT) -> Esperado: 100 (XOR)";
    report "[3. Gerado]       Gerado: " & to_string(tb_ALUControl);

    assert tb_ALUControl = "100" 
      report "FALHA [TESTE 5]: A ULA devia estar configurada para XOR (100) na instrucao XOR/NOT." 
      severity error;

    -- ==========================================
    -- FIM DOS TESTES
    -- ==========================================
    report "";
    report "==============================================================";
    report " TODOS OS TESTES PASSARAM COM SUCESSO! (ALU DECODER)";
    report "==============================================================";
    
    std.env.stop;
  end process;

end architecture sim;