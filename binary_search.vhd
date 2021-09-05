library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

entity binary_search is
  port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    -- Input interface
    key_in       : in  std_logic_vector(7 downto 0);
    left_in      : in  std_logic_vector(7 downto 0);
    right_in     : in  std_logic_vector(7 downto 0);
    arr_data_in  : in  std_logic_vector(7 downto 0);
    -- Command interface
    start        : in  std_logic;
    arr_write    : in  std_logic;
    -- Output interface
    pos_out      : out std_logic_vector(7 downto 0);
    -- Status interface
    el_found_out : out std_logic;
    ready        : out std_logic
    );
end binary_search;

architecture beh of binary_search is
  type ram_type_t is array (0 to (2**8 - 1)) of std_logic_vector(7 downto 0);
  type fsm_state_t is (idle, search);

  -- RAM signals
  signal mem_data_in_s  : std_logic_vector(7 downto 0);
  signal mem_data_out_s : std_logic_vector(7 downto 0);
  signal rw_in_s        : std_logic;
  signal addr_in_s      : std_logic_vector(7 downto 0);
  signal ram_mem_s      : ram_type_t;

  -- Registers
  signal state_reg, state_next       : fsm_state_t;
  signal n_reg, n_next               : unsigned(7 downto 0);
  signal key_reg, key_next           : unsigned(7 downto 0);
  signal middle_reg, middle_next     : unsigned(7 downto 0);
  signal left_reg, left_next         : unsigned(7 downto 0);
  signal right_reg, right_next       : unsigned(7 downto 0);
  signal pos_reg, pos_next           : unsigned(7 downto 0);
  signal el_found_reg, el_found_next : std_logic;

  -- adder signal
  signal adder_out_s      : unsigned(7 downto 0);
  -- comparator signal
  signal left_lte_right_s : std_logic;
begin
  -- synchronous RAM write process
  write_ram : process (clk)
  begin  -- process write_ram
    if clk'event and clk = '1' then
      if(rw_in_s = '1') then
        ram_mem_s(to_integer(unsigned(addr_in_s))) <= mem_data_in_s;
      end if;
    end if;
  end process write_ram;

  -- asynchronous RAM read
  mem_data_out_s <= ram_mem_s(to_integer(unsigned(addr_in_s))) when rw_in_s = '0' else
                    (others => '0');
  -- RAM connections
  mem_data_in_s <= arr_data_in;
  rw_in_s <= arr_write;
  
  -- sequential logic
  ram_process : process (clk, rst)
  begin  -- process ram_process
    if rst = '0' then                   -- asynchronous reset (active low)
      state_reg    <= idle;
      n_reg        <= (others => '0');
      key_reg      <= (others => '0');
      middle_reg   <= (others => '0');
      left_reg     <= (others => '0');
      right_reg    <= (others => '0');
      pos_reg      <= (others => '0');
      el_found_reg <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      state_reg    <= state_next;
      n_reg        <= n_next;
      key_reg      <= key_next;
      middle_reg   <= middle_next;
      left_reg     <= left_next;
      right_reg    <= right_next;
      pos_reg      <= pos_next;
      el_found_reg <= el_found_next;
    end if;
  end process ram_process;

  -- combinational logic
  comb_logic : process (start, arr_write, left_in, right_in, key_in, arr_data_in, adder_out_s, state_next, state_reg,
    n_reg, n_next, key_reg, key_next, left_reg, left_next, right_reg, right_next, pos_reg, pos_next, middle_reg, middle_next,
    addr_in_s, rw_in_s, left_lte_right_s, el_found_reg, el_found_next, ram_mem_s, mem_data_out_s)
  begin  -- process comb_logic
    -- Defaults
    n_next        <= n_reg;
    middle_next   <= middle_reg;
    key_next      <= key_reg;
    right_next    <= right_reg;
    left_next     <= left_reg;
    state_next    <= state_reg;
    pos_next      <= pos_reg;
    el_found_next <= el_found_reg;
    ready         <= '0';
    addr_in_s     <= (others => '0');

    -- states
    case state_reg is
      when idle =>
        ready <= '1';

        if (arr_write = '1') then
          -- write into RAM
          addr_in_s     <= std_logic_vector(n_reg);
          n_next        <= n_reg + to_unsigned(1, n_reg'length);
        elsif (start = '1') then
          n_next     <= (others => '0');
          left_next  <= unsigned(left_in);
          right_next <= unsigned(right_in);
          key_next   <= unsigned(key_in);
          state_next <= search;
        end if;

      when search =>
        middle_next <= '0' & adder_out_s(7 downto 1);
        addr_in_s   <= std_logic_vector(middle_next);

        if (mem_data_out_s = std_logic_vector(key_reg)) then
          pos_next      <= middle_next;
          state_next    <= idle;
          el_found_next <= '1';
        elsif (mem_data_out_s > std_logic_vector(key_reg)) then
          right_next <= middle_next - 1;

          if (left_lte_right_s = '1') then
            state_next <= search;
          else
            state_next    <= idle;
            el_found_next <= '0';
          end if;
        else
          left_next <= middle_next + 1;

          if (left_lte_right_s = '1') then
            state_next <= search;
          else
            state_next    <= idle;
            el_found_next <= '0';
          end if;
        end if;
    end case;
  end process comb_logic;

  -- adder
  adder_out_s      <= left_reg + right_reg;
  -- comparator
  left_lte_right_s <= '1' when left_next <= right_next else '0';

  -- output connections
  pos_out <= std_logic_vector(pos_reg);
  el_found_out <= el_found_reg;
end architecture beh;
