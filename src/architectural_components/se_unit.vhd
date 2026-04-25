library IEEE;
use IEEE.std_logic_1164.all;

entity se_unit is
  port (
    in_instr : in  std_logic_vector(31 downto 0);
    ImmSrc   : in  std_logic_vector(1 downto 0);
    imm      : out std_logic_vector(31 downto 0)
  );
end entity se_unit;

architecture rtl of se_unit is
begin
  process(in_instr, ImmSrc)
  begin
    case ImmSrc is
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
  end process;
end architecture rtl;