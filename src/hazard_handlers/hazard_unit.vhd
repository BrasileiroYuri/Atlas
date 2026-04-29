library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hazard_unit is
  port (

  --- ID stage
  Rs1D : in std_logic_vector(4 downto  0);
  Rs2D : in std_logic_vector(4 downto  0);
  StallD : out std_logic;
  FlushD : out std_logic;
  --- MEM stage
  RdM  : in std_logic_vector(4 downto  0);
  RegWriteM : in std_logic;
  --- EX stage
  RdE : in std_logic_vector(4 downto 0);
  Rs1E : in std_logic_vector(4 downto  0);
  Rs2E : in std_logic_vector(4 downto  0);
  FlushE : out std_logic;
  PCSrcE : in std_logic;
  ResultSrcE0 : in std_logic;
  --- WB stage
  RdW  : in std_logic_vector(4 downto  0);
  RegWriteW  : in std_logic;
  --- PC
  StallF : out std_logic;

  ForwardAE : out std_logic_vector(1 downto 0);
  ForwardBE : out std_logic_vector(1 downto 0)
  );
end entity hazard_unit;

architecture rtl of hazard_unit is
  signal lwStall : std_logic;
begin

  process(Rs1E, RdM, RegWriteM, RdW, RegWriteW)
  begin
    if ((Rs1E = RdM) and RegWriteM = '1') and (Rs1E /= "00000") then
      ForwardAE <= "10";
    elsif ((Rs1E = RdW) and RegWriteW = '1') and (Rs1E /= "00000") then
      ForwardAE <= "01";
    else
      ForwardAE <= "00";
    end if;
  end process;

  process(Rs2E, RdM, RegWriteM, RdW, RegWriteW)
  begin
    if ((Rs2E = RdM) and RegWriteM = '1') and (Rs2E /= "00000") then
      ForwardBE <= "10";
    elsif ((Rs2E = RdW) and RegWriteW = '1') and (Rs2E /= "00000") then
      ForwardBE <= "01";
    else
      ForwardBE <= "00";
    end if;
  end process;

  lwStall <= '1' when
    (ResultSrcE0 = '1') and
    (RdE /= "00000") and
    ((Rs1D = RdE) or (Rs2D = RdE))
  else
    '0';

  --- Stall:
  StallF <= lwStall;
  StallD <= lwStall;
  --- Flush:
  FlushD <= PCSrcE;
  FlushE <= lwStall or PCSrcE;

end architecture rtl;
