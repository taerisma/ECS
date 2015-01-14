-------------------------------------------------------------------------------
-- Entity: led_rotate
-- Author: Thm
-- Date  : 2012
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 6)
-- LED rotieren lassen mit Drehgeber und Tastern
-------------------------------------------------------------------------------
--*********
--Syntese und von Hand gezählte FF sind 42 :-) lustig was den sonnst
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reak_test is
  generic(
    CLK_FRQ : integer := 50_000_000 -- 50 MHz = 0x2FAF080 (26 bits)
		);
  port(
    BTN_WEST   	: in  std_logic; -- 
    BTN_SOUTH   : in  std_logic; -- BTN_SOUTH für Reset
    BTN_EAST   	: in  std_logic; -- 
    clk   		: in  std_logic;
    ROT_A		: in  std_logic;
    ROT_B		: in  std_logic;
    LED  		: out std_logic_vector(7 downto 0)	--kein Semikolon
    );
end reak_test;
architecture A_reak_test of reak_test is

 -- constants
  constant blank_cnt_max	: integer	:= 1000000;	-- blanking lenght
-- signals
  signal rst_gen	: std_logic;
  signal rst		: std_logic;					--reset
  signal led_i	  	: std_logic_vector(7 downto 0);
  signal led_next 	: std_logic_vector(7 downto 0);
  signal rota_meta 	: std_logic_vector(1 downto 0);
  signal rotb_meta 	: std_logic_vector(1 downto 0);
  --drei Zustände brauchen 2FF das bedeutet es muss einen ungenutzten Zustand geben
  type state is (active_st, idle_left_st, idle_right_st);
  signal fsm_cr_st, fsm_nx_st : state;
  
  signal blank_cnt	: unsigned(19 downto 0);	-- needs to include blank_cnt_max
  signal btn_west_meta : std_logic_vector(2 downto 0);
  signal btn_east_meta : std_logic_vector(2 downto 0);
  signal led_next2 	: std_logic_vector(7 downto 0);

begin
 -- reset generator
 --FF=1+1=2 je eines für rst_gen und rst
 P_rst_del: process(BTN_SOUTH, clk)
  begin
   if BTN_SOUTH = '1' then
	 rst_gen <= '1';				-- asynchronous reset start
	 rst <= '1';
   elsif rising_edge(clk) then
     rst_gen <= '0';				-- synchronous reset relaease
     rst <= rst_gen;				-- reset lengt 1-2 Clk cylces
    end if; --clk
  end process;
   
-- all metastability filter 
--FF =3+2+2+3=10 die beiden Button brauchen je 3 FF und die Drehgeber je 2FF
p_meta_filter: process (rst, clk)
  begin
    if rst = '1' then
      btn_west_meta <= (others => '0');
	  rota_meta 	<= (others => '0');
	  rotb_meta 	<= (others => '0');
	  btn_east_meta <= (others => '0');
  elsif rising_edge(clk) then
		--vom Drehgeber
      rota_meta(0) 	<= ROT_A;
	  rota_meta(1) 	<= rota_meta(0);
		--vom Drehgeber
      rotb_meta (0) <= ROT_B;
	  rotb_meta(1) 	<= rotb_meta(0);
	  
      btn_west_meta(0) <= BTN_WEST;
	  btn_west_meta(1) <= btn_west_meta(0);
	  btn_west_meta(2) <= btn_west_meta(1);	-- for edge detection
	  
      btn_east_meta(0) <= BTN_EAST;
	  btn_east_meta(1) <= btn_east_meta(0);
	  btn_east_meta(2) <= btn_east_meta(1); -- for edge detection
  end if;
end process;

-- FSM sequential process
--FF=2+8=10= 2 für den Zustand der FSM und 8 für die LED Zuweisung
p_fsm_seq: process(rst, clk)
  begin
    if rst = '1' then
      fsm_cr_st <= active_st;
	  led_i <= "00011000";			-- LED pattern
   elsif rising_edge(clk) then
      fsm_cr_st <= fsm_nx_st;
	  led_i <= led_next2;
   end if;
end process;

-- FSM combinaorial process
--keine FF kein rst kein clk
p_fsm_com: process (fsm_cr_st, led_i, rota_meta(1), rotb_meta(1))	--all read signals!
begin
   -- default assignments
   fsm_nx_st <= fsm_cr_st;		-- remain in current state
   led_next <= led_i;			-- usually: keep display
   case fsm_cr_st is

     when active_st =>
       if rota_meta(1) = '0' and rotb_meta(1)='0' then	-- 
		 fsm_nx_st <= idle_right_st;
	   end if;

	 when idle_right_st =>
       if rota_meta(1) = '1' and rotb_meta(1)='0'  then	-- 
		 fsm_nx_st <= idle_left_st;
	   elsif  rota_meta(1) = '1' and rotb_meta(1)='1' then
		 fsm_nx_st <= active_st;
		 led_next(6 downto 0) <=  led_i(7 downto 1);
		 led_next(7) <= led_i(0);
	   end if;	  

	 when idle_left_st => 
       if rota_meta(1) = '0' and rotb_meta(1)='1'  then	-- 
		   fsm_nx_st <= idle_right_st;
		elsif  rota_meta(1) = '1' and rotb_meta(1)='1' then
		  fsm_nx_st <= active_st;
		  led_next(7 downto 1) <=  led_i(6 downto 0);
		  led_next(0) <= led_i(7);
		end if;	  
	  
      when others =>
         fsm_nx_st <= active_st;		-- handle parasitic states
   end case;
end process;

p_blank_cnt: process (rst, clk)
--FF=20 für den blank_cnt
  begin
    if rst = '1' then				--bei rst wird der blank_cnt mit Null abgefüllt
      blank_cnt <= (others => '0');
  elsif rising_edge(clk) then
     if blank_cnt = 0 then
       if ((btn_west_meta(2) /= btn_west_meta(1)) or
	       (btn_east_meta(2) /= btn_east_meta(1))) then	-- edge
         blank_cnt <= blank_cnt + 1;		--hoch zählen
	   end if;
	 else
	   if blank_cnt > blank_cnt_max then
	     blank_cnt <= (others => '0');
	   else
	     blank_cnt <= blank_cnt + 1;
	   end if;
	 end if;
   end if; --rising_edge(clk)
end process;

p_rotate: process (btn_west_meta, btn_east_meta, blank_cnt, led_next, led_i)
--keine FF kein rst kein clk
  begin
    if btn_west_meta(2)='0' and btn_west_meta(1)='1' and blank_cnt=0 then	-- fallig edge
	   led_next2(7 downto 1) <=  led_i(6 downto 0);
	   led_next2(0) <= led_i(7);
	elsif btn_east_meta(2)='0' and btn_east_meta(1)='1' and blank_cnt=0 then	-- fallig edge
	   led_next2(6 downto 0) <=  led_i(7 downto 1);
	   led_next2(7) <= led_i(0);
	else
	   led_next2 <= led_next;
	end if;
end process;

LED <= led_i;
end A_reak_test;