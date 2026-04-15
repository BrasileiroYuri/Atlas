library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity if_stage is
  port (
    clk, rst         : in  std_logic;
  --- we're not using this yet
    we          : in  std_logic;                      -- vem da hazard_unit
    branch      : in  std_logic;                      -- taken ou not taken
    branch_addr : in  std_logic_vector(31 downto 0);  -- endereço do branch
  ---
    pcplus4     : out std_logic_vector(31 downto 0);
    out_instr   : out std_logic_vector(31 downto 0)
  );
end entity if_stage;

architecture rtl of if_stage is

  signal pc_plus4_internal : std_logic_vector(31 downto 0); -- Holds  PC + 4.
  signal current_pc   : std_logic_vector(31 downto 0); -- Current PC value.
  signal next_pc      : std_logic_vector(31 downto 0); -- Signal that should be BRANCH or PC+4
  signal raw_instr    : std_logic_vector(31 downto 0); -- Instruction fetched memory.

begin

  PC : entity work.program_counter
    port map(
      clk      => clk,
      rst      => rst,
      we       => we,
      addr_in  => next_pc,
      addr_out => current_pc
    );

  IM : entity work.instruction_memory
    port map(
      addr        => current_pc,
      instruction => raw_instr
    );

  pc_plus4_internal <= std_logic_vector(unsigned(current_pc) + 4);

  next_pc   <= pc_plus4_internal;
  pcplus4   <= pc_plus4_internal;
  out_instr <= raw_instr;

end architecture rtl;
