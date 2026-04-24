library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula is
  port (
    SrcAE     : in  std_logic_vector(31 downto 0);
    SrcBE : in std_logic_vector(31 downto 0);

    ALUControlE : in  std_logic_vector(2 downto 0);

    ALUResultE  : out std_logic_vector(31 downto 0);
    ZeroE       : out std_logic
  );
end entity ula;

architecture rtl of ula is
  signal result_internal : std_logic_vector(31 downto 0);
begin

  process (SrcAE, SrcBE, ALUControlE)
  begin
    case ALUControlE is
      when "000" =>
        result_internal <= std_logic_vector(signed(SrcAE) + signed(SrcBE));
      when "001" =>
        result_internal <= std_logic_vector(signed(SrcAE) - signed(SrcBE));
      when "010" =>
        result_internal <= SrcAE and SrcBE;
      when "011" =>
        result_internal <= SrcAE or SrcBE;
      when "100" =>
        result_internal <= SrcAE xor SrcBE;
      when "101" =>
        if signed(SrcAE) < signed(SrcBE) then
          result_internal <= x"00000001";
        else
          result_internal <= x"00000000";
        end if;
      when others =>
        result_internal <= (others => '0');
    end case;
  end process;

  ALUResultE <= result_internal;
  ZeroE <= '1' when result_internal = x"00000000" else '0';

end architecture rtl;
