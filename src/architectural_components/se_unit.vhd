library IEEE;
use IEEE.std_logic_1164.all;

entity se_unit is
  port (
    in_instr : in  std_logic_vector(31 downto 0);
    -- Futuramente: immsrc : in std_logic_vector(1 downto 0);
    imm      : out std_logic_vector(31 downto 0)
  );
end entity se_unit;

architecture rtl of se_unit is
  signal opcode : std_logic_vector(6 downto 0);
begin
  opcode <= in_instr(6 downto 0);

  -- Tudo em UM ÚNICO PROCESSO para evitar o Delta Delay
  process(in_instr, opcode)
    -- Declaramos uma VARIÁVEL (atualiza na hora!)
    variable v_immsrc : std_logic_vector(1 downto 0);
  begin

    -- ==========================================
    -- BLOCO 1: O "Gerente" (Decisão)
    -- Note o uso de ':=' em vez de '<='
    -- ==========================================
    case opcode is
      when "0000011" | "0010011" => v_immsrc := "00"; -- I-Type
      when "0100011"             => v_immsrc := "01"; -- S-Type
      when "1100011"             => v_immsrc := "10"; -- B-Type
      when "1101111"             => v_immsrc := "11"; -- J-Type
      when others                => v_immsrc := "00";
    end case;

    -- ==========================================
    -- BLOCO 2: O "Operário" (Montagem)
    -- Lê a variável 'v_immsrc' instantaneamente
    -- ==========================================
    if opcode = "0110011" then
        imm <= (others => '0'); -- Força zero para R-Type
    else
        case v_immsrc is
          when "00" =>
            imm <= (31 downto 12 => in_instr(31)) & in_instr(31 downto 20);
          when "01" =>
            imm <= (31 downto 12 => in_instr(31)) & in_instr(31 downto 25) & in_instr(11 downto 7);
          when "10" =>
            imm <= (31 downto 12 => in_instr(31)) & in_instr(7) & in_instr(30 downto 25) & in_instr(11 downto 8) & '0';
          when "11" =>
            imm <= (31 downto 20 => in_instr(31)) & in_instr(19 downto 12) & in_instr(20) & in_instr(30 downto 21) & '0';
          when others =>
            imm <= (others => '0');
        end case;
    end if;
  end process;

end architecture rtl;
