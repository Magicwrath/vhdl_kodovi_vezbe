----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2019 04:47:08 PM
-- Design Name: 
-- Module Name: generic_counter - Behavioral
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
--use IEEE.STD_LOGIC_ARITH.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
 use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity generic_counter is
  generic (M : natural := 0;
           N : natural := 15);
  port (clk   : in  std_logic;
        reset : in  std_logic;
        q     : out std_logic_vector(3 downto 0));
end generic_counter;

architecture Behavioral of generic_counter is
  signal q_reg  : std_logic_vector(3 downto 0);
  signal q_next : std_logic_vector(3 downto 0);
begin

  counter_process : process (clk) is
  begin
    if (clk'event and clk = '1') then
      if (reset = '1') then
        q_reg <= std_logic_vector(to_unsigned(M, q_reg'length));
      else
        q_reg <= q_next;
      end if;
    end if;
  end process;

  comb_logic : process (q_reg) is
  begin
    if (q_reg < std_logic_vector(to_unsigned(N, q_reg'length))) then
      q_next <= std_logic_vector(unsigned(q_reg) + 1);
    else
      q_next <= std_logic_vector(to_unsigned(M, q_reg'length));
    end if;
  end process;

  q <= q_reg;

end Behavioral;
