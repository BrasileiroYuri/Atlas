library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu is
  port (
  clk, rst : in std_logic
  );
end entity cpu;

architecture rtl of cpu is

  signal pipeline_we : std_logic;
  signal pcplus4: std_logic_vector(31 downto 0);
  signal out_instr : std_logic_vector(31 downto 0);

 -- temporary (until we implement branch)
  signal branch      : std_logic := '0';
  signal branch_addr : std_logic_vector(31 downto 0) := (others => '0');

begin
  IF_STG: entity work.if_stage
  port map(
    clk         => clk,
    we          => pipeline_we,   -- '1' normal, '0' em stall
    rst         => rst,
    pcplus4     => pcplus4,
    out_instr   => out_instr,
      branch => branch,
  branch_addr => branch_addr
  );

  IF_ID: entity work.if_id
  port map(
    clk => clk,
    rst => rst,
    we=>pipeline_we,
    in_instr => out_instr,
    next_pc_in => pcplus4
  );


  --....


end architecture rtl;
