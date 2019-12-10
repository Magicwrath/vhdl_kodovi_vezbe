----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/09/2019 11:59:11 AM
-- Design Name: 
-- Module Name: booth_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity booth_tb is
--  Port ( );
end booth_tb;

architecture Behavioral of booth_tb is
  signal clk   : std_logic;
  signal reset : std_logic;
  signal a_in  : std_logic_vector(7 downto 0);
  signal b_in  : std_logic_vector(7 downto 0);
  signal start : std_logic;
  signal res   : std_logic_vector(15 downto 0);
  signal ready : std_logic;
begin

  booth_multiplier_1 : entity work.booth_multiplier
    port map (
      clk   => clk,
      reset => reset,
      a_in  => a_in,
      b_in  => b_in,
      start => start,
      res   => res,
      ready => ready);

  clk_gen : process is
  begin  -- process clk_gen
    clk <= '0', '1' after 100ns;
    wait for 200ns;
  end process clk_gen;

  sim_Gen : process is
  begin  -- process sim_Gen
    reset <= '0', '1' after 50ns;
    start <= '1', '0' after 200ns;
    a_in  <= "11111011";                -- minus 5 in 2's complement
    b_in  <= "11111101";                -- minus 3 in 2's complement
    wait;
  end process sim_Gen;


end Behavioral;
