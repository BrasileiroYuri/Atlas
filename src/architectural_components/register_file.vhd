library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Author: Yuri Santos
entity register_file is
  port(
    clk     : in  std_logic;
    we      : in  std_logic; -- Write enable

    in_addr : in  std_logic_vector(4 downto 0); -- Register input adress.

    R1      : in  std_logic_vector(4 downto 0);
    R2      : in  std_logic_vector(4 downto 0);

    in_data : in  std_logic_vector(31 downto 0);

    Out1    : out std_logic_vector(31 downto 0);
    Out2    : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of register_file is

  type memory_t is array (0 to 31) of std_logic_vector(31 downto 0);
  signal mem : memory_t := (
  1 => x"00000001",
  2 => x"00000002",
  4 => x"00000004",
  5 => x"00000005",
  7 => x"FFFFFFFD",
  8 => x"00000003",
  others => (others => '0')
);

begin

  -- READ (combinational)
  Out1 <= (others => '0') when R1 = "00000" else mem(to_integer(unsigned(R1)));
  Out2 <= (others => '0') when R2 = "00000" else mem(to_integer(unsigned(R2)));

  -- WRITE (synchronous)
  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' and in_addr /= "00000" then -- We don't write when in_addr = 0.
        mem(to_integer(unsigned(in_addr))) <= in_data;
      end if;
    end if;
  end process;

end architecture;
