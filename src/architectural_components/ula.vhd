library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula is
  port (
    R1, R2     : in  std_logic_vector(31 downto 0);
    ALUControl : in  std_logic_vector(2 downto 0);
    ALUResult  : out std_logic_vector(31 downto 0);
    Zero       : out std_logic
  );
end entity ula;

architecture rtl of ula is
  signal result_internal : std_logic_vector(31 downto 0);
begin

  process (R1, R2, ALUControl)
  begin
    case ALUControl is
      when "000" =>
        result_internal <= std_logic_vector(signed(R1) + signed(R2));
      when "001" =>
        result_internal <= std_logic_vector(signed(R1) - signed(R2));
      when "010" =>
        result_internal <= R1 and R2;
      when "011" =>
        result_internal <= R1 or R2;
      when "100" =>
        result_internal <= R1 xor R2;
      when "101" =>
        if signed(R1) < signed(R2) then
          result_internal <= x"00000001";
        else
          result_internal <= x"00000000";
        end if;
      when others =>
        result_internal <= (others => '0');
    end case;
  end process;

  ALUResult <= result_internal;
  Zero <= '1' when result_internal = x"00000000" else '0';

end architecture rtl;
