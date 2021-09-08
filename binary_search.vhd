library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

entity binary_search is
  port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    -- Ulazni interface
    key_in       : in  std_logic_vector(7 downto 0);
    left_in      : in  std_logic_vector(7 downto 0);
    right_in     : in  std_logic_vector(7 downto 0);
    arr_data_in  : in  std_logic_vector(7 downto 0);
    -- Komandni interfejs
    start        : in  std_logic;
    arr_write    : in  std_logic;
    -- Izlazni interfejs
    pos_out      : out std_logic_vector(7 downto 0);
    -- Statusni interfejs
    el_found_out : out std_logic;
    ready        : out std_logic
    );
end binary_search;

architecture beh of binary_search is
  type ram_type_t is array (0 to (2**8 - 1)) of std_logic_vector(7 downto 0);
  type fsm_state_t is (idle, search);

  -- Signali RAM memorije sa jednim pristupom za citanje i za upis
  signal mem_data_in_s  : std_logic_vector(7 downto 0);
  signal mem_data_out_s : std_logic_vector(7 downto 0);
  signal rw_in_s        : std_logic;
  signal addr_in_s      : std_logic_vector(7 downto 0);
  signal ram_mem_s      : ram_type_t;

  -- Registri
  signal state_reg, state_next       : fsm_state_t;
  signal n_reg, n_next               : unsigned(7 downto 0);
  signal key_reg, key_next           : unsigned(7 downto 0);
  signal middle_reg, middle_next     : unsigned(7 downto 0);
  signal left_reg, left_next         : unsigned(7 downto 0);
  signal right_reg, right_next       : unsigned(7 downto 0);
  signal pos_reg, pos_next           : unsigned(7 downto 0);
  signal el_found_reg, el_found_next : std_logic;

  -- izlazni signal polusabiraca
  signal adder_out_s      : unsigned(7 downto 0);
  -- izlazni signal komparatora
  signal left_lte_right_s : std_logic;
begin
  -- Ovaj proces modeluje sinhroni upis u RAM memoriju
  write_ram : process (clk)
  begin
    if clk'event and clk = '1' then
      if(rw_in_s = '1') then
        ram_mem_s(to_integer(unsigned(addr_in_s))) <= mem_data_in_s;
      end if;
    end if;
  end process write_ram;

  -- Ovaj iskaz modeluje asinhrono citanje iz RAM memorije
  mem_data_out_s <= ram_mem_s(to_integer(unsigned(addr_in_s))) when rw_in_s = '0' else
                    (others => '0');
  -- Port ulaznih podataka RAM memorije je povezan na primarni ulaz arr_data_in
  -- preko koga se mogu upisivati clanovi niza na sekvencijalne pozicije u RAM
  -- memoriji
  mem_data_in_s <= arr_data_in;
  -- Selekcija citanja/upisa u RAM je povezana na primarni ulaz arr_write
  -- Ukoliko je arr_write=1 vrsi se upis, u suprotnom se cita iz memorije
  rw_in_s       <= arr_write;

  -- proces koji modeluje registre u sistemu
  -- Registri left, right, middle i key cuvaju promenljive koje se koriste
  -- tokom rada algoritma
  -- Registri pos i el_found cuvaju rezultat rada algoritma
  -- Registar n sluzi za indeksiranje RAM memorije prilikom upisa clanova niza,
  -- da bi clanovi bili na sekvencijalnim lokacijama pocevsi od adrese 0
  ram_process : process (clk, rst)
  begin
    if rst = '0' then  -- asinhroni reset (aktivan na niskom nivou)
      state_reg    <= idle;
      n_reg        <= (others => '0');
      key_reg      <= (others => '0');
      middle_reg   <= (others => '0');
      left_reg     <= (others => '0');
      right_reg    <= (others => '0');
      pos_reg      <= (others => '0');
      el_found_reg <= '0';
    elsif clk'event and clk = '1' then  -- rastuca ivica
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

  -- proces koji modeluje kombinacionu logiku
  -- tacnije, modeluje funkciju prelaza stanja i izlaznu funkciju konacnog automata
  -- Konacni automat ima dva stanja: idle i search
  -- Tokom idle stanja se moze vrsiti upis u RAM memoriju (sa arr_write = '1')
  -- Algoritam krece sa radom kada se postavi start='1' (u RAM se vise ne mogu
  -- upisivati podaci dok se algoritam ne zavrsi)
  comb_logic : process (start, arr_write, left_in, right_in, key_in, arr_data_in, adder_out_s, state_next, state_reg,
                        n_reg, n_next, key_reg, key_next, left_reg, left_next, right_reg, right_next, pos_reg, pos_next, middle_reg, middle_next,
                        addr_in_s, rw_in_s, left_lte_right_s, el_found_reg, el_found_next, ram_mem_s, mem_data_out_s)
  begin
    -- Podrazumevane vrednosti
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

    case state_reg is
      -- stanje "idle" konacnog automata
      when idle =>
        -- izlazni signal koji indicira da je sistem spreman
        -- da krene sa radom
        ready <= '1';

        -- ukoliko je arr_write='1' vrsi se upis u RAM (arr_data_in se upisuje
        -- na lokaciju na koju pokazuje registar n, koji se inkrementira nakon
        -- svakog upisa u RAM)
        -- ukoliko je start='1', registar n se resetuje i sistem pocinje sa radom
        -- (prelazi u stanje search) pri cemu pamti ulaze left, right i key u
        -- istoimenim registrima
        if (arr_write = '1') then
          addr_in_s <= std_logic_vector(n_reg);
          n_next    <= n_reg + to_unsigned(1, n_reg'length);
        elsif (start = '1') then
          n_next     <= (others => '0');
          left_next  <= unsigned(left_in);
          right_next <= unsigned(right_in);
          key_next   <= unsigned(key_in);
          state_next <= search;
        end if;

      -- stanje "search"
      -- Algoritam iterira kroz while petlju dok se pojavi uslov izlaza
      -- da je vrednost u left registru veca od vrednosti u right registru
      -- Algoritam funkcionise tako sto mu se zadaju leva i desna granica
      -- indeksa niza u cijem opsegu se trazi element sa vrednoscu "key"
      -- Izracuna se srednji indeks izmedju levog i desnog (middle registar)
      -- Zatim se u odnosu na trazenu vrednost "key" proverava vrednost clana
      -- niza na indeksu middle "x[middle]"
      -- Posto je niz sortiran, ukoliko je x[middle] > key, potrebno je desnu
      -- granicu pomeriti na middle - 1, a ukoliko je x[middle] < key,
      -- potrebno je levu granicu indeksa pomeriti na middle + 1
      -- Algoritam zavrsava uspesno ako se dobije x[middle] = key (sto se
      -- signalizira sa el_found, a rezultantni indeks se cuva u pos)
      -- A ako je left > right, algoritam se zavrsava bez pronadjenog indeksa
      -- (el_found = '0')
      when search =>
        -- rezultat sabiranja left i right indeksa (adder_out_s) je potrebno
        -- podeliti sa 2 da bi se dobio middle index, a to se vrsi sa logickim
        -- pomeranjem bita udesno
        middle_next <= '0' & adder_out_s(7 downto 1);
        -- ovim se cita RAM memorija, odnosno niz, na indeksu middle (x[middle])
        addr_in_s   <= std_logic_vector(middle_next);

        if (mem_data_out_s = std_logic_vector(key_reg)) then
          -- slucaj key = x[middle], kraj algoritma, resenje je nadjeno
          pos_next      <= middle_next;
          state_next    <= idle;
          el_found_next <= '1';
        elsif (mem_data_out_s > std_logic_vector(key_reg)) then
          -- slucaj kada je x[middle] > key, pomeri desni granicni indeks right
          -- na middle - 1
          right_next <= middle_next - 1;

          -- provera uslova while petlje
          -- ako je left <= right, nastavi algoritam, u suprotnom stani jer
          -- element nije pronadjen
          if (left_lte_right_s = '1') then
            state_next <= search;
          else
            state_next    <= idle;
            el_found_next <= '0';
          end if;
        else
          -- identican slucaj kao prethodni, samo sto je x[middle] < key,
          -- pomeri indeks left na middle + 1
          left_next <= middle_next + 1;

          -- provera uslova while petlje (odnosno provera uslova za kraj algoritma)
          if (left_lte_right_s = '1') then
            state_next <= search;
          else
            state_next    <= idle;
            el_found_next <= '0';
          end if;
        end if;
    end case;
  end process comb_logic;

  -- sabirac koji racuna sumu prilikom racunanja vrednosti "middle" indeksa
  -- po formuli middle = (left + right) / 2;
  adder_out_s      <= left_reg + right_reg;
  -- komparator koji proverava da li je levi indeks manji ili jednak desnom
  -- (left <= right)
  left_lte_right_s <= '1' when left_next <= right_next else '0';

  -- povezivanje izlaza el_found i pos registara na izlazne signale
  -- el_found_out i pos_out
  pos_out      <= std_logic_vector(pos_reg);
  el_found_out <= el_found_reg;
end architecture beh;
