library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity id_stage is
  port (
  clk, rst : in std_logic;
  we : in std_logic;

  in_instruction : in std_logic_vector(31 downto 0);

  rs1, rs2 : in std_logic_vector(31 downto 0);
  rd : in std_logic_vector(31 downto 0);

  pcplus4_in : in std_logic_vector(31 downto 0);
  pcplus4_out : out std_logic_vector(31 downto 0);

  write_addr, write_data : in std_logic_vector(31 downto 0) -- Used to write on register file.
  );
end entity id_stage;


architecture rtl of id_stage is

  signal r1_out, r2_out : std_logic_vector(31 downto 0);
  signal imm_out : std_logic_vector(31 downto 0);

begin

  RG: entity work.register_file -- Register File
    port map(
    clk =>clk,
    we => we,
    in_addr => write_addr,
    in_data => write_data,
    R1 => rs1,
    R2 => rs2,
    Out1 => r1_out,
    Out2 => r2_out,
    );


  SEU : entity work.se_unit -- Sign-extend unit
    port map(
    in_instr => in_instruction,
    imm => imm_out,
    )

  process(clk)
  begin
    if rising_edge(clk) then
      if

    end if;
  end process ;


end architecture rtl;
