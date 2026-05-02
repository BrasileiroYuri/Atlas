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
  
  -- Memória de registradores genérica, inicializada a zero.
  signal mem : memory_t := (others => (others => '0'));
begin
  -- READ (combinational) - O registrador 0 (x0) retorna sempre 0, independentemente da memória
  Out1 <= (others => '0') when R1 = "00000" else
            in_data when (we = '1' and R1 = in_addr) else
            mem(to_integer(unsigned(R1)));
  
    Out2 <= (others => '0') when R2 = "00000" else
            in_data when (we = '1' and R2 = in_addr) else
            mem(to_integer(unsigned(R2)));

  -- WRITE (synchronous)
  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' and in_addr /= "00000" then -- Bloqueia a escrita no x0
        mem(to_integer(unsigned(in_addr))) <= in_data;
      end if;
    end if;
  end process;
end architecture;
