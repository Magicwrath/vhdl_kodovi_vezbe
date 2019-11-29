----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/29/2019 05:35:49 PM
-- Design Name: 
-- Module Name: booth_multiplier - Behavioral
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

entity booth_multiplier is
  port (
    -- Clock and reset interface
    clk   : in  std_logic;
    reset : in  std_logic;
    -- Input data interface
    a_in  : in  std_logic_vector(7 downto 0);
    b_in  : in  std_logic_vector(7 downto 0);
    -- Command interface
    start : in  std_logic;
    -- Output data interface
    res   : out std_logic_vector(15 downto 0);
    -- Status interface
    ready : out std_logic
    );
end booth_multiplier;

architecture Behavioral of booth_multiplier is
  signal a_in_comp             : unsigned(7 downto 0);
  signal not_a                 : unsigned(7 downto 0);
  type fsm_state_t is (idle, op);
  signal state_reg, state_next : fsm_state_t;
  signal i_reg, i_next         : unsigned(3 downto 0);
  signal a_reg, a_next         : unsigned(16 downto 0);
  signal s_reg, s_next         : unsigned(16 downto 0);
  signal p_reg, p_next         : unsigned(16 downto 0);
  signal temp_reg, temp_next   : unsigned (16 downto 0);
begin
  registers : process (clk, reset) is
  begin  -- process registers
    if (reset = '0') then                 -- asynchronous reset (active low)
      state_reg <= idle;
      i_reg     <= (others => '0');
      a_reg     <= (others => '0');
      s_reg     <= (others => '0');
      p_reg     <= (others => '0');
      temp_reg  <= (others => '0');
    elsif (clk'event and clk = '1') then  -- rising clock edge
      state_reg <= state_next;
      i_reg     <= i_next;
      a_reg     <= a_next;
      s_reg     <= s_next;
      p_reg     <= p_next;
      temp_reg  <= temp_next;
    end if;
  end process registers;

  comb_logic : process (a_in, b_in, start, i_next, i_reg, a_next, a_reg, s_next, s_reg, p_next, p_reg, state_reg, state_next, temp_reg, temp_next) is
  begin  -- process comb_logic
    a_next <= a_reg;
    s_next <= s_reg;
    p_next <= p_reg;
    i_next <= i_reg;
    temp_next <= temp_reg;
    ready <= '0';
    case state_reg is
      when idle =>
        ready     <= '1';
        a_next    <= unsigned(a_in) & "000000000";
        s_next    <= a_in_comp(7 downto 0) & "000000000";
        p_next    <= "00000000" & unsigned(b_in) & "0";
        i_next    <= (others => '0');
        temp_next <= (others => '0');
        if (start = '1') then
          state_next <= op;
        else
          state_next <= idle;
        end if;

      when op =>
        case (p_reg(1 downto 0)) is
          when "00" =>
            temp_next <= p_reg;
          when "01" =>
            temp_next <= p_reg + a_reg;
          when "10" =>
            temp_next <= p_reg + s_reg;
          when others =>
            temp_next <= p_reg;
        end case;

        p_next <= temp_next(0) & temp_next(16 downto 1);  -- arithmetic shift right
        i_next <= i_reg + 1;
        if (i_next = to_unsigned(8, i_next'length)) then
          state_next <= idle;
        else
          state_next <= op;
        end if;
    end case;

  end process comb_logic;

  res <= std_logic_vector(p_reg(16 downto 1));
  not_a <= unsigned (not a_in);
  a_in_comp <= (not_a + 1);

end Behavioral;
