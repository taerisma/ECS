--Übung 4
--Reaktionstester mit einer Zufallszeit
--Wassner
--********************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity reak_test_rand is
	generic(CLK_FRQ : integer := 50_000_000);
    	Port ( 	rst : in  STD_LOGIC;
           	clk : in  STD_LOGIC;
           	rot_c : in  STD_LOGIC;
           	led : out  STD_LOGIC_VECTOR (7 downto 0));
end reak_test_rand;

architecture Behavioral of reak_test_rand is
 
  constant FIX_TME : unsigned(25 downto 0) := to_unsigned(CLK_FRQ-1,26);  	--1 sec = 1 * CLK_FRQ -1
  constant CSC_TME : unsigned(18 downto 0) := to_unsigned(CLK_FRQ/100-1,19);  	--1/100 sec = CLK_FRQ / 100 
  constant INT_TME : unsigned(18 downto 0) := to_unsigned(CLK_FRQ/200-1,19);   	--1/200 sec = CLK_FRQ / 200 =  CSC_TME/2
  constant BLK_TME : unsigned(22 downto 0) := to_unsigned(CLK_FRQ/8-1,23);   	--1/8 sec = CLK_FRQ / 8 
  
  -- signals
  signal del_done  : std_logic;              -- state type control signal 
  signal meas_done : std_logic;              -- state type control signal
  signal too_early : std_logic;              -- state type control signal
  signal rnd_tme   : unsigned(26 downto 0);  -- random number
  signal del_cnt   : unsigned(26 downto 0);  -- delay counter
  signal csc_cnt   : unsigned(18 downto 0);  -- 1/100 sec counter
  signal meas_time : unsigned(7 downto 0);   -- measured time in 1/100 sec 
  signal blk_cnt   : unsigned(22 downto 0);  -- 1/8 sec counter
  signal led_out   : std_logic_vector(7 downto 0);
  -- NOTE:
  -- The following signal initilization is only relevant for simulation. It is
  -- required for simulation since no reset is used for the random counter.

  signal rnd_cnt   : unsigned(25 downto 0) := to_unsigned(CLK_FRQ/7-333,26);

begin
  LED <= led_out;
    -----------------------------------------------------------------------------
  -- sequential process: Delay Counter
  -- # of FFs: 26 + 27 + 27 + 1 = 81
  --
  -- *** IMPORTANT NOTE ***
  -- One might think that simply assigning rnd_cnt as reset value to rnd_tme is
  -- a more elegant solution than the add operation below. But in fact it is
  -- not, because this would violate our synchronous design principle as reset
  -- and data signals are getting mixed. So, do NOT do this!
  P_del_cnt: process(rst, clk)
  begin
    if rst = '1' then
      -- NOTE: no reset for rnd_cnt 
     rnd_tme  <= (others => '0'); -- could be skipped too, because always
                                  -- assigned before being read
     del_cnt  <= (others => '0');
     del_done <= '0';
    elsif rising_edge(clk) then
      -- random counter without reset, always running...
      if rnd_cnt < FIX_TME then
        rnd_cnt <= rnd_cnt + 1;
      else
        rnd_cnt  <= (others => '0');
      end if;
      -- delay counter
      if del_cnt < FIX_TME-1 then
        -- count up to one clock cycle before 1 sec
        del_cnt <= del_cnt + 1;
      elsif del_cnt = FIX_TME-1 then
        -- get random delay number one clock cycle before 1 sec just in case
        -- rnd_cnt is zero
        rnd_tme <= ('0' & FIX_TME) + ('0' & rnd_cnt);
        del_cnt <= del_cnt + 1;
      elsif del_cnt <= rnd_tme then
        -- count up to random time between 1 and 2 sec
        del_cnt <= del_cnt + 1;
      else
        del_done <= '1';
      end if;
    end if;
  end process;
  -----------------------------------------------------------------------------
  -- sequential process: Time Measurement
  -- # of FFs: 19 + 8 + 1 + 1 = 29
  P_time_meas: process(rst, clk)
  begin
    if rst = '1' then
      csc_cnt   <= INT_TME; -- init to resolution/2 for -0.5 <= error < 0.5 
      meas_time <= (others => '0');
      meas_done <= '0';
      too_early <= '0';
    elsif rising_edge(clk) then
      -- meas_done generation
      if ROT_C = '1' and del_done = '0' then
        -- pressed button too early 
        too_early <= '1';
      elsif ROT_C = '1' or meas_time = 255 then
        -- end of measurement (button pressed or time out)
        meas_done <= '1';
      end if;
      -- meas_time generation
      if del_done = '1' and meas_done = '0' then
        -- measure time betwenn delay expiration and ROT_C pressed
        if csc_cnt < CSC_TME then
          csc_cnt <= csc_cnt + 1;
        else 
          csc_cnt   <= (others => '0');
          meas_time <= meas_time + 1;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: LED Control
  -- # of FFs: 23 + 8 = 31
  P_LED_ctrl: process(rst, clk)
  begin
    if rst = '1' then
      blk_cnt <= (others => '0');
      led_out <= (others => '0');
    elsif rising_edge(clk) then
      if too_early = '1' then
        -- button pressed too early 
        if blk_cnt < BLK_TME then
          blk_cnt <= blk_cnt + 1;
        else 
          blk_cnt <= (others => '0');
          led_out <= not led_out;
        end if;
      elsif del_done = '1' and meas_done = '0' then
        -- delay time expired but ROT_C not pressed yet
        led_out(7) <= '1';
      elsif meas_done = '1' then
        -- ROT_C pressed, display measured time
        led_out <= std_logic_vector(meas_time);
      end if;
    end if;
  end process;
end Behavioral;
