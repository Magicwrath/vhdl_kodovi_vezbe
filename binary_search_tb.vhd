----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/05/2021 05:59:10 PM
-- Design Name: 
-- Module Name: binary_search_tb - Behavioral
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

entity binary_search_tb is
--  Port ( );
end binary_search_tb;

architecture Behavioral of binary_search_tb is
    signal clk, rst : std_logic;
    signal key_in, left_in, right_in : std_logic_vector(7 downto 0);
    signal arr_data_in : std_logic_vector(7 downto 0);
    signal start, arr_write : std_logic;
    signal pos_out : std_logic_vector(7 downto 0);
    signal el_found_out, ready : std_logic;
    
    -- declare DUV
    component binary_search
    port (
        clk : in std_logic;
        rst : in std_logic;
        key_in : in std_logic_vector(7 downto 0);
        left_in : in std_logic_vector(7 downto 0);
        right_in : in std_logic_vector(7 downto 0);
        arr_data_in : in std_logic_vector(7 downto 0);
        start : in std_logic;
        arr_write : in std_logic;
        pos_out : out std_logic_vector(7 downto 0);
        el_found_out : out std_logic;
        ready : out std_logic
    );
    end component binary_search;
begin
    -- instantiate DUV
    BS_1 : binary_search
        port map (
            clk => clk,
            rst => rst,
            key_in => key_in,
            left_in => left_in,
            right_in => right_in,
            arr_data_in => arr_data_in,
            start => start,
            arr_write => arr_write,
            pos_out => pos_out,
            el_found_out => el_found_out,
            ready => ready
        );
    
    
    -- clock generating process
    clk_gen: process
    begin
        clk <= '0', '1' after 100ns;
        wait for 200ns;
    end process clk_gen;
    
    -- stimulus generating process
    stim_gen: process
    begin
        rst <= '0', '1' after 50ns;
        -- start writing to RAM after 50ns
        arr_write <= '0', '1' after 50ns, '0' after 950ns;
        arr_data_in <= std_logic_vector(to_unsigned(3, 8)),
                       std_logic_vector(to_unsigned(5, 8)) after 200ns,
                       std_logic_vector(to_unsigned(6, 8)) after 400ns,
                       std_logic_vector(to_unsigned(7, 8)) after 600ns,
                       std_logic_vector(to_unsigned(10, 8)) after 800ns;
        
        start <= '0', '1' after 950ns, '0' after 1150ns;
        key_in <= std_logic_vector(to_unsigned(0, 8)),
                  std_logic_vector(to_unsigned(7, 8)) after 950ns;
        left_in <= std_logic_vector(to_unsigned(0, 8)),
                   std_logic_vector(to_unsigned(2, 8)) after 950ns;
        right_in <= std_logic_vector(to_unsigned(0, 8)),
                    std_logic_vector(to_unsigned(4, 8)) after 950ns;    
        wait;   
    end process stim_gen;
end Behavioral;
