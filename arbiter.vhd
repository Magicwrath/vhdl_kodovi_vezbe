----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/25/2019 05:07:25 PM
-- Design Name: 
-- Module Name: arbiter - behav
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity arbiter is
  Port ( clk : in STD_LOGIC;
         reset : in STD_LOGIC;
           r0 : in STD_LOGIC;
           r1 : in STD_LOGIC;
           g0 : out STD_LOGIC;
           g1 : out STD_LOGIC);
end arbiter;

architecture behav of arbiter is
    type fsm_state_type is (waitr, grant0, grant1);
    signal state_reg, state_next : fsm_state_type;
    signal counter_n, counter_r : STD_LOGIC_VECTOR(2 downto 0);
begin

sync_state: process (clk) is
begin
  
        if (rising_edge(clk)) then
          if (reset = '1') then
            state_reg <= waitr;
            counter_r <= "000";
          else
            state_reg <= state_next;
            counter_r <= counter_n;
          end if;
        end if;
    end process;
     
new_state: process (r0, r1, counter_r) is
    begin
        g0 <= '0';
        g1 <= '0';
        state_next <= waitr;
        case state_reg is
            when waitr =>
                if (r1 = '1') then
                    state_next <= grant1;
                elsif (r1 = '0' and r0 = '1') then
                    state_next <= grant0;
                else
                    state_next <= waitr;
                end if;
            when grant0 =>
                g0 <= '1';
                if (r0 = '1' and counter_r /= "101") then
                    state_next <= grant0;
                else
                    state_next <= waitr;
                end if;
            when grant1 =>
                g1 <= '1';
                if (r1 = '1' and counter_r /= "101") then
                    state_next <= grant1;
                else
                    state_next <= waitr;
                end if;
            end case;
    end process;
    
new_counter: process (counter_r) is
    begin
        if (counter_n < "101") then
            counter_n <= std_logic_vector(unsigned(counter_r) + 1);
        else
            counter_n <= "000";
        end if;
    end process;
        
end behav;
