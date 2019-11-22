----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2019 11:04:43 AM
-- Design Name: 
-- Module Name: sqrt - beh
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

entity sqrt is
  generic (WIDTH : positive := 32);
  port (
    --Clocking and reset interface
    clk   : in  std_logic;
    reset : in  std_logic;
    --Input data interface
    x_in  : in  std_logic_vector(WIDTH-1 downto 0);
    --Command interface
    start : in  std_logic;
    --Output data interface
    y_out : out std_logic_vector(WIDTH-1 downto 0);
    --Status interface
    ready : out std_logic);
end sqrt;

architecture beh of sqrt is
  type fsm_state_t is (idle, l1, l2, l2op, l2c);
  signal state_reg, state_next : fsm_state_t;
  signal op_reg, op_next       : unsigned(WIDTH-1 downto 0);
  signal res_reg, res_next     : unsigned(WIDTH-1 downto 0);
  signal one_reg, one_next     : unsigned(WIDTH-1 downto 0);
  signal temp_reg, temp_next   : unsigned(WIDTH-1 downto 0);
begin
  --State and data registers
  process (clk, reset) is
  begin
    if (reset = '1') then
      state_reg <= idle;
      op_reg    <= (others => '0');
      res_reg   <= (others => '0');
      one_reg   <= (others => '0');
      temp_reg  <= (others => '0');
    elsif (clk'event and clk = '1') then
      state_reg <= state_next;
      op_reg    <= op_next;
      res_reg   <= res_next;
      one_reg   <= one_next;
      temp_reg  <= temp_next;
    end if;
  end process;

  --Combinatorial circuits
  process (start, state_reg, op_reg, res_reg, one_reg, temp_reg, op_next, res_next, one_next, temp_next, x_in) is
  begin
    --Default assignments
    state_next <= state_reg;
    op_next    <= op_reg;
    res_next   <= res_reg;
    one_next   <= one_reg;
    temp_next  <= temp_reg;
    ready      <= '0';

    case state_reg is
      when idle =>
        ready <= '1';
        if (start = '1') then
          op_next    <= unsigned(x_in);
          res_next   <= (others => '0');
          one_next   <= X"40000000";
          state_next <= l1;
        else
          state_next <= idle;
        end if;

      when l1 =>
        one_next <= to_unsigned(0, 2) & one_reg(WIDTH-1 downto 2);
        if (one_next > op_reg) then
          state_next <= l1;
        else
          state_next <= l2;
        end if;

      when l2 =>
        temp_next <= one_reg + res_reg;
        if (op_reg >= temp_next) then
          state_next <= l2op;
        else
          state_next <= l2c;
        end if;

      when l2op =>
        op_next    <= op_reg - temp_reg;
        res_next   <= res_reg + one_reg + one_reg;
        state_next <= l2c;

      when l2c =>
        res_next <= '0' & res_reg(WIDTH-1 downto 1);
        one_next  <= to_unsigned(0, 2) & one_reg(WIDTH-1 downto 2);
        if (one_next /= to_unsigned(0, WIDTH)) then
          state_next <= l2;
        else
          state_next <= idle;
        end if;
    end case;
  end process;

  y_out <= std_logic_vector(res_reg);

end beh;
