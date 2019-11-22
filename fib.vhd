----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/15/2019 08:06:05 PM
-- Design Name: 
-- Module Name: fib - beh
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
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fib is
  port (
    --Clocking and reset interface
    clk     : in  std_logic;
    reset   : in  std_logic;
    --Input data interface
    n_in    : in  std_logic_vector(5 downto 0);
    --Command interface
    start   : in  std_logic;
    --Output data interface
    fib_out : out std_logic_vector(42 downto 0);
    --Output status interface
    ready   : out std_logic);
end fib;

architecture beh of fib is
  type fsm_state_t is (idle, op, shift_reg);
  signal state_reg, state_next : fsm_state_t;
  signal n_reg, n_next         : unsigned(5 downto 0);
  signal r1_reg, r1_next       : unsigned(42 downto 0);
  signal r2_reg, r2_next       : unsigned(42 downto 0);
  signal r_reg, r_next         : unsigned(42 downto 0);
begin
  --State and data registers
  process (clk, reset) is
  begin
    if (reset = '1') then
      state_reg <= idle;
      n_reg     <= (others => '0');
      r1_reg    <= (others => '0');
      r2_reg    <= (others => '0');
      r_reg     <= (others => '0');
    elsif (clk'event and clk = '1') then
      state_reg <= state_next;
      n_reg     <= n_next;
      r1_reg    <= r1_next;
      r2_reg    <= r2_next;
      r_reg     <= r_next;
    end if;
  end process;

  --Combinatorial circuits
  process (start, state_reg, r1_reg, r2_reg, r_reg, n_reg) is
  begin
    --Default assignments
    state_next <= state_reg;
    n_next     <= n_reg;
    r1_next    <= r1_reg;
    r2_next    <= r2_reg;
    r_next     <= r_reg;
    ready      <= '0';

    case state_reg is
      when idle =>
        ready   <= '1';
        r2_next <= to_unsigned(0, r2_next'length);
        r1_next <= to_unsigned(1, r1_next'length);
        n_next  <= unsigned(n_in);
        if (start = '1') then
          if (n_next <= to_unsigned(1, n_reg'length)) then
            state_next <= idle;
            if (n_next = to_unsigned(0, n_reg'length)) then
              r_next <= (others => '0');
            else
              r_next <= to_unsigned(1, r_next'length);
            end if;
          else
            r_next     <= to_unsigned(0, r_next'length);
            state_next <= op;
          end if;
        else
          state_next <= idle;
        end if;

      when op =>
        r_next     <= r1_reg + r2_reg;
        n_next     <= n_reg - 1;
        state_next <= shift_reg;

      when shift_reg =>
        r2_next <= r1_reg;
        r1_next <= r_reg;
        if (n_reg /= to_unsigned(1, n_reg'length)) then
          state_next <= op;
        else
          state_next <= idle;
        end if;
    end case;
  end process;

  fib_out <= std_logic_vector(r_reg);

end beh;
