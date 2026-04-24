library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity if_stage is
  port (
    clk, rst,we         : in  std_logic;

    PCSrcE      : in  std_logic;                      -- taken or not taken
    PCTargetE : in  std_logic_vector(31 downto 0);  -- endereço do branch
    PCPlus4F     : out std_logic_vector(31 downto 0);
    PCF     : out std_logic_vector(31 downto 0);
    InstrF   : out std_logic_vector(31 downto 0)
  );
end entity if_stage;

architecture rtl of if_stage is

  signal PCPlus4 : std_logic_vector(31 downto 0); -- Holds  PC + 4.
  signal PCF_in: std_logic_vector(31 downto 0); -- Signal that should be BRANCH or PC+4
  signal PCF_out   : std_logic_vector(31 downto 0); -- Current PC value.

begin

  PC : entity work.program_counter
    port map(
      clk      => clk,
      rst      => rst,
      we       => we,
      PCF_in  => PCF_in,
      PCF_out => PCF_out
    );

  IM : entity work.instruction_memory
    port map(
      PCF        => PCF_out,
      InstrF => InstrF
    );

    process(PCSrcE, PCPlus4, PCTargetE)
    begin
      case PCSrcE is
        when '1' =>
          PCF_in <=PCTargetE;
        when others =>
          PCF_in <=PCPlus4;
      end case;
    end process;


  PCF<= PCF_out;
  PCPlus4 <= std_logic_vector(unsigned(PCF_out) + 4);
  PCPlus4F   <= PCPlus4;

end architecture rtl;
