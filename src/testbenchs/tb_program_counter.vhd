library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_program_counter is
end entity;

architecture sim of tb_program_counter is

  -- DUT signals
  signal clk      : std_logic := '0';
  signal rst      : std_logic := '0';
  signal we       : std_logic := '0';
  signal addr_in  : std_logic_vector(31 downto 0) := (others => '0');
  signal addr_out : std_logic_vector(31 downto 0);

begin

  -- Instantiate DUT
  uut: entity work.program_counter
    port map (
      clk => clk,
      rst => rst,
      we => we,
      addr_in => addr_in,
      addr_out => addr_out
    );

  -- Clock generator (10 ns period)
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
    end loop;
  end process;

  -- Test process
  test_proc : process
  begin

    --------------------------------------------------
    -- TEST 1: RESET
    --------------------------------------------------
    rst <= '1';
    we  <= '0';

    wait until rising_edge(clk);
    wait until rising_edge(clk); -- give time to propagate

    assert addr_out = x"00000000"
      report "FAIL: Reset did not clear PC"
      severity error;

    --------------------------------------------------
    -- TEST 2: WRITE
    --------------------------------------------------
    rst <= '0';
    we  <= '1';
    addr_in <= x"00000010";

    wait until rising_edge(clk);

    assert addr_out = x"00000010"
      report "FAIL: Write failed"
      severity error;

    --------------------------------------------------
    -- TEST 3: HOLD (we = 0)
    --------------------------------------------------
    we <= '0';
    addr_in <= x"FFFFFFFF";

    wait until rising_edge(clk);

    assert addr_out = x"00000010"
      report "FAIL: Value changed when WE=0"
      severity error;

    --------------------------------------------------
    -- TEST 4: OVERWRITE
    --------------------------------------------------
    we <= '1';
    addr_in <= x"00000020";

    wait until rising_edge(clk);

    assert addr_out = x"00000020"
      report "FAIL: Overwrite failed"
      severity error;

    --------------------------------------------------
    -- ALL PASSED
    --------------------------------------------------
    report "ALL TESTS PASSED" severity note;

    wait;
  end process;

end architecture;
