library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity if_id is
  port (
  clk, rst : in std_logic;

  we : in std_logic; -- When we = '0' we have a stall.

  InstrF : in std_logic_vector(31 downto 0);
  InstrD : out std_logic_vector(31 downto 0);

  PCF  : in std_logic_vector(31 downto 0);
  PCD  : out std_logic_vector(31 downto 0);

  PCPlus4F : in std_logic_vector(31 downto 0);
  PCPlus4D : out std_logic_vector(31 downto 0)
  );
end entity if_id;

architecture rtl of if_id is

  signal Instr   : std_logic_vector(31 downto 0);
  signal PC : std_logic_vector(31 downto 0);
  signal PCPlus4 : std_logic_vector(31 downto 0);

begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        Instr   <= (others => '0');  -- reseta o registrador interno
        PC <= (others => '0');  -- reseta o registrador interno
        PCPlus4 <= (others => '0');  -- reseta o registrador interno
      elsif we = '1' then
        Instr <= InstrF;
        PC <= PCF;
        PCPlus4 <= PCPlus4F;
      end if;
    end if;
  end process;

  InstrD   <= Instr;
  PCD <= PC;
  PCPlus4D<= PCPlus4;

end architecture rtl;
