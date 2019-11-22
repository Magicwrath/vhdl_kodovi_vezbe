----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2019 12:17:14 PM
-- Design Name: 
-- Module Name: sqrt_tb - Behavioral
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
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sqrt_tb is
--  Port ( );
end sqrt_tb;

architecture Behavioral of sqrt_tb is
  constant WIDTH : positive := 32;
  signal clk     : std_logic;
  signal reset   : std_logic;
  signal x_in    : std_logic_vector(WIDTH-1 downto 0);
  signal start   : std_logic;
  signal y_out   : std_logic_vector(WIDTH-1 downto 0);
  signal ready   : std_logic;
begin
  sqrt_1 : entity work.sqrt
    generic map (
      WIDTH => WIDTH)
    port map (
      clk   => clk,
      reset => reset,
      x_in  => x_in,
      start => start,
      y_out => y_out,
      ready => ready);

  clk_gen: process is
  begin  -- process clk_gen
    clk <= '0', '1' after 100ns;
    wait for 200ns;
  end process clk_gen;

  sim_gen: process is
  begin  -- process sim_gen
    reset <= '1', '0' after 50ns;
    x_in <= std_logic_vector(to_unsigned(169, WIDTH));
    start <= '1', '0' after 200ns;
    wait;
  end process sim_gen;

end Behavioral;
