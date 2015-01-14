-------------------------------------------------------------------------------
-- Entity: reak_test_rand_fsm
-- Author: Waj
-- Date  : 4-May-11, 8-May-12, 7-Apr-14
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 5)
-- Reaktionstester mit FSM (Mealy-Type)
-------------------------------------------------------------------------------
-- NOTE: The asynchronous input ROT_C is used unsynchronized as input to the 
-- FSM. In HW, the corresponding button exhibits occasinal erratic behavior. 
-- This is due to missing synchronization/debouncing of ROT_C!!!! 
-- (see slides Block 6)
-------------------------------------------------------------------------------
-- Total # of FFs: 88 + 8 + 3 = 99
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reak_test_rand_fsm is
  generic(
    CLK_FRQ : integer := 50_000_000 -- 50 MHz = 0x2FAF080 (26 bits)
    );
  port(
    rst   : in  std_logic; -- BTN_SOUTH
    clk   : in  std_logic;
    ROT_C : in  std_logic; -- not synchronized!!!!
    LED   : out std_logic_vector(7 downto 0)
    );
end reak_test_rand_fsm;

architecture rtl of reak_test_rand_fsm is

  -- timer constants 
  -- 1 sec = 1 * CLK_FRQ -1
  constant FIX_TME : unsigned(25 downto 0) := to_unsigned(CLK_FRQ-1,26); 
  -- 1/100 sec = CLK_FRQ / 100 
  constant CSC_TME : unsigned(25 downto 0) := to_unsigned(CLK_FRQ/100-1,26); 
  -- 1/200 sec = CLK_FRQ / 200 =  CSC_TME/2
  constant INT_TME : unsigned(25 downto 0) := to_unsigned(CLK_FRQ/200-1,26); 
  -- 1/8 sec = CLK_FRQ / 8 
  constant BLK_TME : unsigned(25 downto 0) := to_unsigned(CLK_FRQ/8-1,26);
  -- FSM state
  type state is (s_del_1s, s_del_rnd, s_measure, s_done, s_cheat, s_timeout);
  signal c_st, n_st : state;
  -- signals
  signal cnt_done  : std_logic;              -- enable-type signal 
  signal time_out  : std_logic;              -- enable-type signal 
  signal meas_done : std_logic;              -- enable-type signal 
  signal start_rnd : std_logic;              -- enable-type signal 
  signal start_meas: std_logic;              -- enable-type signal 
  signal start_blk : std_logic;              -- enable-type signal 
  signal com_cnt   : unsigned(25 downto 0);  -- common counter
  signal end_tme   : unsigned(25 downto 0);  -- end time for common counter
  signal meas_time : unsigned(7 downto 0);   -- measured time in 1/100 sec 
  signal led_out   : std_logic_vector(7 downto 0);
  -- NOTE:
  -- The following signal initilization is only relevant for simulation. It is
  -- required for simulation since no reset is used for the random counter.
  signal rnd_cnt   : unsigned(25 downto 0) := to_unsigned(CLK_FRQ/2-1,26);

begin
  
  -- output assignment
  LED <= led_out;

  -----------------------------------------------------------------------------
  -- sequential process: Common and random Counter
  -- # of FFs: 26 + 26 + 26 + + 8 + 1 + 1 = 88
  P_cnt: process(rst, clk)
  begin
    if rst = '1' then
      -- NOTE: no reset for rnd_cnt 
     end_tme   <= FIX_TME;
     com_cnt   <= (others => '0');
     meas_time <= (others => '0');
     cnt_done  <= '0';
     time_out  <= '0';
    elsif rising_edge(clk) then
      -- random counter without reset, always running... --
      if rnd_cnt < FIX_TME then
        rnd_cnt <= rnd_cnt + 1;
      else
        rnd_cnt  <= (others => '0');
      end if;
      -- common counter -----------------------------------
      cnt_done <= '0'; -- default for enable-type signal
      time_out <= '0'; -- default for enable-type signal
      com_cnt  <= (others => '0');
      if com_cnt < end_tme then
        -- count up
        com_cnt <= com_cnt + 1;
      elsif com_cnt = end_tme then
        -- end value reached
        cnt_done  <= '1';
        meas_time <= meas_time + 1;
        if meas_time = 254 then         -- time out
          time_out <= '1';
        end if;
      end if;
      -- store end value for counter ------------------------
      if start_rnd = '1' then
        end_tme <= rnd_cnt;
      elsif start_meas = '1' then
        com_cnt <= INT_TME; -- init to resolution/2 
        end_tme <= CSC_TME;
        meas_time <= (others => '0');
      elsif start_blk = '1' then
        end_tme <= BLK_TME;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: LED Control
  -- # of FFs: 8
  P_LED_ctrl: process(rst, clk)
  begin
    if rst = '1' then
      led_out <= (others => '0');
    elsif rising_edge(clk) then
      if start_meas = '1' then
        led_out <= ('1', others => '0');
      elsif start_blk = '1' then
        led_out <= not led_out;
      elsif meas_done = '1' then
        led_out <= std_logic_vector(meas_time);
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- FSM: Mealy-type
  -- Inputs : cnt_done, ROT_C, time_out
  -- Outputs: meas_done, start_rnd, start_meas, start_blk
  -----------------------------------------------------------------------------
  -- memoryless process
  p_fsm_com: process (c_st, cnt_done, ROT_C, time_out)
  begin
    -- default assignments
    n_st <= c_st; -- remain in current state
    meas_done  <= '0'; 
    start_rnd  <= '0'; 
    start_meas <= '0'; 
    start_blk  <= '0'; 
    -- specific assignments
    case c_st is
      when s_del_1s =>
        if ROT_C = '1' then
          start_blk <= '1';
          n_st      <= s_cheat;
        elsif cnt_done = '1' then
          start_rnd <= '1';
          n_st      <= s_del_rnd;
        end if;
      when s_del_rnd =>
        if ROT_C = '1' then
          start_blk <= '1';
          n_st      <= s_cheat;
        elsif cnt_done = '1' then 
          start_meas <= '1';
          n_st       <= s_measure;
        end if;
      when s_measure =>
        if ROT_C = '1' then 
          meas_done <= '1';
          n_st      <= s_done;
        elsif time_out = '1' then 
          meas_done <= '1';
          n_st      <= s_timeout;
        end if;
      when s_cheat =>
        if cnt_done = '1' then 
          start_blk <= '1';
        end if;
      when s_done =>
        null;           -- need reset to leave this state
      when s_timeout =>
        null;           -- need reset to leave this state
      when others =>
        n_st <= s_done; -- handle parasitic states
    end case;
  end process;
  ----------------------------------------------------------------------------- 
  -- sequential process
  -- # of FFs: 3 (assuming binary state encoding)
  P_fsm_seq: process(rst, clk)
  begin
    if rst = '1' then
      c_st <= s_del_1s;
    elsif rising_edge(clk) then
      c_st <= n_st;
    end if;
  end process;
  
end rtl;
