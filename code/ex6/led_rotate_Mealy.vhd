-------------------------------------------------------------------------------
-- Entity: led_rotate
-- Author: Waj
-- Date  : 27-May-11, 13-May-12, 8-Apr-13
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 6)
-- LED rotieren lassen mit Drehgeber und Tastern
-------------------------------------------------------------------------------
-- Total # of FFs: 8 + 53 + 2 + 11 = 74
-------------------------------------------------------------------------------
--*************************3
-- ich komme auf 5 und der von Xilinx synthetisierte Code ergibt auch 75 
-- ich vermute ein Fehler ist beim p4 debounce Prozess vergessen gegangen
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_rotate is
  generic(
    CLK_FRQ : integer := 50_000_000     -- 50 MHz = 0x2FAF080 (26 bits)
		);
  port(
    rst      : in  std_logic;           -- BTN_SOUTH
    clk      : in  std_logic;
    ROT_A    : in  std_logic;
    ROT_B    : in  std_logic;
    BTN_EAST : in  std_logic;
    BTN_WEST : in  std_logic;
    LED      : out std_logic_vector(7 downto 0));
end led_rotate;

architecture rtl of led_rotate is

  -- timer constants 
  -- 1/10 sec = CLK_FRQ / 10 = 100 ms 
  constant BLANK_TME  : unsigned(23 downto 0) := to_unsigned(CLK_FRQ/10-1, 24);
  -- FSM state 3 Zustände es werden 2FF benötigt ein Zustand ist ungenutzt
  type     state is (s_idle_left, s_idle_right, s_active);
  signal   c_st, n_st : state;
  -- signals
  signal   led_rot  : signed(2 downto 0);
  signal   qua_rot  : signed(1 downto 0);
  signal   btn_rot  : signed(1 downto 0);
  signal   led_out  : std_logic_vector(7 downto 0);
  signal   east_cnt : unsigned(23 downto 0);
  signal   west_cnt : unsigned(23 downto 0);
  signal   debncd_east, debncd_east_reg : std_logic;
  signal   debncd_west, debncd_west_reg : std_logic;
  -- sync signals
  type   t_sync_ar is array (0 to 1) of std_logic_vector(3 downto 0);
  signal sync_ar              : t_sync_ar;
  signal sync_east, sync_west : std_logic;
  signal sync_rot             : std_logic_vector(1 downto 0);

begin
  -- output assignment
  LED <= led_out;

  -----------------------------------------------------------------------------
  -- sequential process: Synchronization of ROT and switch button inputs
  -- # of FFs: 8
  -- jede zuweisunszeile nach rising_edge macht ein flankensenitiver Speicher FF
  P1_sync : process(rst, clk)
  begin
    if rst = '1' then
      sync_ar <= (others => (others => '0'));
    elsif rising_edge(clk) then
      -- first stage sync FFs
      sync_ar(0)(0) <= BTN_EAST;
      sync_ar(0)(1) <= BTN_WEST;
      sync_ar(0)(2) <= ROT_B;
      sync_ar(0)(3) <= ROT_A;
      -- second stage sync FFs
      sync_ar(1)    <= sync_ar(0);
    end if;
  end process;
  sync_east <= sync_ar(1)(0);
  sync_west <= sync_ar(1)(1);
  sync_rot  <= sync_ar(1)(3 downto 2);
 
  -----------------------------------------------------------------------------
  -- FSM: Mealy-type
  -- Inputs : sync_rot
  -- Outputs: qua_rot
  -----------------------------------------------------------------------------
  -- memoryless process
  P2_fsm_com : process (c_st, sync_rot)
  --machte keine FF ist ein kombinatorischer Prozess ohne rst und clk
  begin
    -- default assignments
    n_st    <= c_st;                    -- remain in current state
    qua_rot <= (others => '0');
    -- specific assignments
    case c_st is
      when s_idle_left =>
        if sync_rot = "11" then      -- AB = 11 
          n_st    <= s_active;
          qua_rot <= "11";              -- rotate left (-1)
        elsif sync_rot = "01" then   -- AB = 01 
          n_st <= s_idle_right;
        end if;
      when s_idle_right =>
        if sync_rot = "11" then      -- AB = 11 
          n_st    <= s_active;
          qua_rot <= "01";              -- rotate right (+1)
        elsif sync_rot = "10" then   -- AB = 10
          n_st <= s_idle_left;
        end if;
      when s_active =>
        if sync_rot = "00" then      -- AB = 00
          n_st <= s_idle_left;          -- or s_idle_right
        end if;
      when others =>
        n_st <= s_active;               -- handle parasitic states
    end case;
  end process;
  ----------------------------------------------------------------------------- 
  -- FSM memorizing process
  -- # of FFs: 2 (assuming binary state encoding)
  P3_fsm_seq : process(rst, clk)
  begin
    if rst = '1' then
      c_st <= s_active;
    elsif rising_edge(clk) then
      c_st <= n_st;			-- die Zustandszuweisung macht ein FF
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: Debouncing and encoding of switch button inputs
  -- # of FFs: 24 + 24 + 3 + 2 = 53
  -- ich komme auf 54FF? 
  P4_deb : process(rst, clk)
  begin
    if rst = '1' then
      east_cnt        <= (others => '0');-- diese cnt Singnale sind 24ig wertig
      west_cnt        <= (others => '0');--diese cnt Signale sind 24ig wertig 
      debncd_east     <= '0';
      debncd_east_reg <= '0';
      debncd_west     <= '0';
      debncd_west_reg <= '0';
      btn_rot         <= "00";
    elsif rising_edge(clk) then
      -- Debouncing EAST (blanking) ---------------------------
      if east_cnt = 0 and (sync_east xor debncd_east) = '1' then 
        -- input changed: start blank time counter
        east_cnt    <= east_cnt + 1;								-- +24FF
        debncd_east <= sync_east;									-- +1 FF
      elsif east_cnt > 0 and east_cnt < BLANK_TME then
        -- blank time counter active
        east_cnt <= east_cnt + 1;
      else
        -- end of blank time: reset counter
        east_cnt <= (others => '0');
      end if;
      -- Debouncing WEST (undersampling) -----------------------
      if west_cnt < BLANK_TME then          
        west_cnt <= west_cnt + 1;									
      else
        -- reset counter and sample input signal
        west_cnt    <= (others => '0');								-- +24FF
        debncd_west <= sync_west;									-- +1FF
      end if;
      -- encode switch buttons ---------------------------------
      debncd_east_reg <= debncd_east;								-- +1FF
      debncd_west_reg <= debncd_west;								--+1FF
      btn_rot <= "00";                  -- no rotation (default)	--+2FF
      if debncd_west = '1' and debncd_west_reg = '0' then
        btn_rot <= "11";                -- rotate left (-1)
      elsif debncd_east = '1'and debncd_east_reg = '0' then
        btn_rot <= "01";                -- rotate right (+1)
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: LED Control
  -- # of FFs: 8 + 3 = 11
  -- led out macht 8 FF und led_rot 3FF
  P5_LED : process(rst, clk)
  begin
    if rst = '1' then
      led_out <= X"18";
      led_rot <= "000";
    elsif rising_edge(clk) then
      -- calculate total rotate from indiv. rotate controls
      if qua_rot < 0 then
        -- sign extension
        led_rot <= ('1' & qua_rot) + btn_rot;
      else
        led_rot <= ('0' & qua_rot) + btn_rot;			--+3FF
      end if;
      -- LED rotation
      if led_rot = 2 then
        led_out(7)          <= led_out(1);
        led_out(6)          <= led_out(0);
        led_out(5 downto 0) <= led_out(7 downto 2);
      elsif led_rot = 1 then
        -- rotate one position to the right
        led_out(7)          <= led_out(0);
        led_out(6 downto 0) <= led_out(7 downto 1);
      elsif led_rot = -1 then
        -- rotate one position to the left
        led_out(0)          <= led_out(7);
        led_out(7 downto 1) <= led_out(6 downto 0);
      elsif led_rot = -2 then
        -- rotate two positions to the left
        led_out(1)          <= led_out(7);
        led_out(0)          <= led_out(6);
        led_out(7 downto 2) <= led_out(5 downto 0);
      end if;
    end if;
  end process;

end rtl;
