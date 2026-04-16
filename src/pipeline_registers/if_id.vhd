library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity if_id is
  port (
  clk, rst : in std_logic;
  we : in std_logic; -- When we = '0' we have a stall.

  in_instr : in std_logic_vector(31 downto 0);
  next_pc_in  : in std_logic_vector(31 downto 0);

  next_pc_out  : out std_logic_vector(31 downto 0);
  out_instr : out std_logic_vector(31 downto 0)
  );
end entity if_id;

architecture rtl of if_id is
  signal mem_instr   : std_logic_vector(31 downto 0);
  signal mem_next_pc : std_logic_vector(31 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        mem_instr   <= (others => '0');  -- reseta o registrador interno
        mem_next_pc <= (others => '0');  -- reseta o registrador interno
      elsif we = '1' then
        mem_instr   <= in_instr;
        mem_next_pc <= next_pc_in;
      end if;
    end if;
  end process;

  out_instr   <= mem_instr;
  next_pc_out <= mem_next_pc;

end architecture rtl;
