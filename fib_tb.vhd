----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/15/2019 08:45:08 PM
-- Design Name: 
-- Module Name: fib_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fib_tb is
--  Port ( );
end fib_tb;

architecture Behavioral of fib_tb is
  signal clk     : std_logic;
  signal reset   : std_logic;
  signal n_in    : std_logic_vector(5 downto 0);
  signal start   : std_logic;
  signal fib_out : std_logic_vector(42 downto 0);
  signal ready   : std_logic;
begin
  fib_1: entity work.fib
    port map (
      clk     => clk,
      reset   => reset,
      n_in    => n_in,
      start   => start,
      fib_out => fib_out,
      ready   => ready);

  clk_gen: process is
  begin  -- process clk_gen
    clk <= '0', '1' after 100ns;
    wait for 200ns;
  end process clk_gen;

  sim_gen: process is
  begin  -- process sim_gen
    reset <= '1', '0' after 50ns;
    n_in <= (others => '1');
    start <= '0', '1' after 50ns, '0' after 200ns;
    wait;
  end process sim_gen;
end Behavioral;
