-------------------------------------------------------------------------------
-- Entity: reak_test
-- Author: ThM
-- Date  : see Filename
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 4, Aufgabe 2)
-- Random = länge des BTN_SOUTH = 1, wird auch für Reset verwendet
-- 
-- 
-- 
-- 
-- 
-------------------------------------------------------------------------------
-- Total # of FFs: 42
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reak_test is
  generic(
    CLK_FRQ : integer := 50_000_000 -- 50 MHz = 0x2FAF080 (26 bits)
    );
  port(
    BTN_SOUTH   : in  std_logic; -- BTN_SOUTH für Reset
    clk   	: in  std_logic;
    ROT_C	: in  std_logic;
    LED  	: out std_logic_vector(7 downto 0)
    );
end reak_test;

architecture A_reak_test of reak_test is

  -- constants
  constant WAIT_PRD : integer := 2;		-- wait period in seconds
  constant MAX_CNT : unsigned(26 downto 0):= to_unsigned(CLK_FRQ*WAIT_PRD-1,27);	-- to_unsigned(,27 bit)
 -- signals
  signal rst		: std_logic;	--reset
  signal LED_I	  	: std_logic_vector(7 downto 0);
  signal del_done	: std_logic; 	-- enable type
  signal meas_done	: std_logic; 	-- enable type
 -- signal meas_time	: std_logic_vector(7 downto 0);
  signal cnt 		: unsigned(26 downto 0);
  signal rst_meta	: std_logic_vector(2 downto 0);
  signal rst_gen	: std_logic_vector(1 downto 0);

begin
 
 -- reset generator
 -- 2 FF
 P_rst_del: process(clk)
  begin
    if rising_edge(clk) then	-- reset lenght 1-2 Clk cylces
     rst_gen(0) <= BTN_SOUTH;	-- FF without Reset :-(
     rst_gen(1) <= rst_gen(0);	-- FF without Reset :-(
    end if; --clk
  end process;
  rst <= '1' when (BTN_SOUTH = '1' and rst_gen(1) = '0') else '0';	-- pulse, rising edge = BTN_SOUTH pressed
  
 -- metastability filter + edge detect
 -- 3 FF
 P_rst_meta: process(rst, clk)
  begin
    if rst = '1' then
	   rst_meta <= (others => '0');
    elsif rising_edge(clk) then
      rst_meta(0) <= ROT_C;
	  rst_meta(1) <= rst_meta(0);
	  rst_meta(2) <= rst_meta(1);
    end if; -- clk
  end process;
 
  -- sequential process: Delay Counter
  -- 28 FF
  P_del_cnt: process(rst, clk)
  begin
    if rst = '1' then
	  cnt <= (others => '0');
      del_done <= '0';
    elsif rising_edge(clk) then
   
      if rst_meta(2) = '1' and rst_meta(1)='0' then -- falling edge = BTN_SOUTH release
		-- idea:  for better randomness mirror cnt LSB <-> MSB (or use LFSR)
	    if cnt>CLK_FRQ then	-- if <1 sec: +1sec
		  cnt <= cnt - CLK_FRQ;	-- would be nicer to mask some MSBs
		else
		  cnt <= cnt;	-- can be omitted but looks more complete
		end if;
	  else
	    if cnt < MAX_CNT then	
          cnt <= cnt + 1;		-- 27 FF = ~2sec
	      del_done <= '0';		-- 1 FF
        else
         cnt <= (others => '0');
         del_done <= '1';
        end if; --cnt
      end if; --rst_meta
	  
    end if; --clk
  end process;
  
  -- sequential process: Time Measurement
  -- 1 FF
  P_time_meas: process(rst, clk)
  begin
    if rst = '1' then
      meas_done <= '0';
    elsif rising_edge(clk) then
	
      if  rst_meta(1)='1' then
	    meas_done <= '1';	-- 1FF
 	  end if; -- rst_meta(1)
	  
    end if; -- clk
  end process;
  
  -- sequential process: LED Control
  -- 8 FF
  P_LED_ctrl: process(rst, clk)
  begin
    if rst = '1' then
	  LED_I <= (others => '0');
	  --LED_I<="01010101";	-- debug printif ;-)
    elsif rising_edge(clk) then
	
	  if del_done='1' and LED_I="00000000" then	-- start 10000000
	    LED_I <= "10000000";		-- 8FF
      elsif del_done='1' and LED_I="10000000" then -- too late
	    LED_I <= "11111111";
	  elsif meas_done='1' and LED_I="10000000" then -- falls zufällig 1000000 => 10000001
	    LED_I <= std_logic_vector(cnt(27 downto 20)); --500k=1/100=0x7A10, 7FFFF=524k
	  elsif meas_done='1' and (LED_I="00000000" or LED_I="01010101" or LED_I="10101010") then	-- too early
	    LED_I(7) <=  cnt(23);
		LED_I(6) <=  not cnt(23);
		LED_I(5) <=  cnt(23);
		LED_I(4) <=  not cnt(23);
		LED_I(3) <=  cnt(23);
		LED_I(2) <=  not cnt(23);
		LED_I(1) <=  cnt(23);
		LED_I(0) <=  not cnt(23);	    
	  end if; -- meas_done
	  
    end if; -- clk
  end process;
  
  LED <= LED_I;
end A_reak_test;

