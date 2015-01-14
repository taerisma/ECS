-------------------------------------------------------------------------------
-- Entity: dimm
-- Author: Thm
-- Date  : see filename
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 8)
-------------------------------------------------------------------------------
-- Total # of FFs: 29 29
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dimm is
  generic(
    CLK_FRQ : integer := 50_000_000 -- 50 MHz = 0x2FAF080 (26 bits), not used
    );
  port(
    --BTN_WEST   : in  std_logic; -- 
	 --BTN_EAST   : in  std_logic; --
    BTN_SOUTH  : in  std_logic; -- BTN_SOUTH für Reset
     
    clk   	: in  std_logic;
    ROT_A	: in  std_logic;
    ROT_B	: in  std_logic;
    LED  	: out std_logic_vector(7 downto 0)
    );
end dimm;

architecture A_dimm of dimm is

 -- constants
 -- signals
  signal rst_gen		: std_logic;
  signal rst			: std_logic;					--reset
  signal rota_meta	: std_logic_vector(1 downto 0);
  signal rotb_meta	: std_logic_vector(1 downto 0);
  --Zustände der FSM
  type state is (active_st, idle_left_st, idle_right_st);
  signal fsm_cr_st, fsm_nx_st : state;
  
  signal ramp_cnt		: unsigned(15 downto 0);		-- bit 15 appr. 1kHz
  signal dim_val		: unsigned( 4 downto 0);		-- 32 values
  signal dim_v_nx		: unsigned( 4 downto 0);		-- 32 values

begin
 
 -- reset generator	2FF
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
   
-- all metastability filter 	4FF 
--rota_meta und rotb_meta benötigen je zwei FF 
p_meta_filter: process (rst, clk)
  begin
    if rst = '1' then
	  rota_meta <= (others => '0');
	  rotb_meta <= (others => '0');
    elsif rising_edge(clk) then
      rota_meta (0) <= ROT_A;
	  rota_meta(1) <= rota_meta(0);

      rotb_meta (0) <= ROT_B;
	  rotb_meta(1) <= rotb_meta(0);
    end if;
  end process;

-- FSM sequential process	5+2FF
p_fsm_seq: process(rst, clk)
  begin
    if rst = '1' then
      fsm_cr_st <= active_st;
	  dim_val   <= (others => '0');
   elsif rising_edge(clk) then
      fsm_cr_st <= fsm_nx_st;
	  dim_val   <= dim_v_nx;
   end if;
end process;

-- FSM combinaorial process
p_fsm_com: process (fsm_cr_st, rota_meta(1), rotb_meta(1), dim_val)	--all read signals!
begin
   -- default assignments
   fsm_nx_st <= fsm_cr_st;		-- remain in current state
   dim_v_nx <= dim_val;			-- usually: keep dim constant
   case fsm_cr_st is

     when active_st =>
       if rota_meta(1) = '0' and rotb_meta(1)='0' then	-- rotA_meta rotB_meta
		 fsm_nx_st <= idle_right_st;
	   end if;

	 when idle_right_st =>
       if rota_meta(1) = '1' and rotb_meta(1)='0'  then	-- 
		 fsm_nx_st <= idle_left_st;
	   elsif  rota_meta(1) = '1' and rotb_meta(1)='1' then	--AB=11
		 fsm_nx_st <= active_st;
		 if dim_val < 31 then			-- test for max
		   dim_v_nx <= dim_val + 1;		-- brighter
		 end if;
	   end if;	  

	 when idle_left_st => 
       if rota_meta(1) = '0' and rotb_meta(1)='1'  then	-- 
		   fsm_nx_st <= idle_right_st;
		elsif  rota_meta(1) = '1' and rotb_meta(1)='1' then	--AB=11
		  fsm_nx_st <= active_st;
		 if dim_val > 0 then			-- test for min
		   dim_v_nx <= dim_val - 1;		-- less bright
		 end if;
		  
		end if;	  
	  
      when others =>
         fsm_nx_st <= active_st;		-- handle parasitic states
   end case;
end process;

--	PWM Ramp Cnt			16FF
p_ramp_cnt: process (rst, clk)
  begin
  if rst = '1' then
    ramp_cnt <= (others => '0');
  elsif rising_edge(clk) then
    ramp_cnt <= ramp_cnt + 1;
  end if; --rising_edge(clk)
end process;

LED(7 downto 4) <= std_logic_vector(ramp_cnt(15 downto 12));
LED(3 downto 0) <= "1111" when ramp_cnt(15 downto 11) > dim_val else "0000";
end A_dimm;
--***********************************************************************

