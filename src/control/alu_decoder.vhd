library IEEE;
use IEEE.std_logic_1164.all;

entity aludec is
  port (
    opb5       : in  std_logic;
    funct3     : in  std_logic_vector(2 downto 0);
    funct7b5   : in  std_logic;
    ALUOp      : in  std_logic_vector(1 downto 0);

    ALUControl : out std_logic_vector(2 downto 0)
  );
end entity aludec;

architecture rtl of aludec is
begin

  process(opb5, funct3, funct7b5, ALUOp)
    variable RtypeSub : std_logic;
  begin
    RtypeSub := funct7b5 and opb5;

    case ALUOp is
      when "00" =>
        ALUControl <= "000";

      when "01" =>
        ALUControl <= "001";

      when "10" =>
        case funct3 is
          when "000" =>
            if RtypeSub = '1' then
              ALUControl <= "001"; -- SUB
            else
              ALUControl <= "000"; -- ADD
            end if;

          when "111" => ALUControl <= "010"; -- AND
          when "110" => ALUControl <= "011"; -- OR
          when "100" => ALUControl <= "100"; -- XOR / NOT

          when others => ALUControl <= "000";
        end case;
      when "11" =>
        ALUControl <="111";

      when others =>
        ALUControl <= "000";
    end case;
  end process;

end architecture rtl;
