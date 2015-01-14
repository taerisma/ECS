-------------------------------------------------------------------------------
-- Entity: led_rotate
-- Author: ThM
-- Date  : see filename
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 7)
-- Simpler Taschenrechner
-------------------------------------------------------------------------------

--Summer aller FF = 42 juheeeee
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calc is
  generic(
    CLK_FRQ : integer := 50_000_000 -- 50 MHz = 0x2FAF080 (26 bits)
    );
  port(
    BTN_NORTH 	: in  std_logic; -- Multiply
	BTN_WEST  	: in  std_logic; -- Add
    BTN_SOUTH 	: in  std_logic; -- BTN_SOUTH für Reset
    BTN_EAST  	: in  std_logic; -- Subtract
    clk   		: in  std_logic;
    ROT_C		: in  std_logic; -- read number 1 or 2
	SW			: in std_logic_vector(3	downto 0); -- input number 1 or 2
    LED  		: out std_logic_vector(7 downto 0)--kein Semikolon
    );
end calc;

architecture A_calc of calc is

 -- constants
 --zum entprellen wird für eine 50zigstel einer Sekunde = 20 ms das signal nicht ausgewertet
  constant blank_cnt_max	: integer	:= 1000000;	-- blanking lenght
-- signals
  signal rst_gen	: std_logic;
  signal rst		: std_logic;					--reset
  signal led_i	  	: std_logic_vector(7 downto 0);
   
  signal blank_cnt	    : unsigned(19 downto 0);	-- needs to include blank_cnt_max
  signal btn_north_meta : std_logic_vector(1 downto 0);	--2 level synchronizer
  signal btn_west_meta  : std_logic_vector(1 downto 0);	--2 level synchronizer
  signal btn_east_meta  : std_logic_vector(1 downto 0);	--2 level synchronizer
  signal rot_c_meta     : std_logic_vector(2 downto 0);	--2 level synchronizer + edge
 
 --7 Zustände bruchen 3 FF ein Zustand ist ungenutzt
  type state is (reset_st, sto1_st, wait1_st, sto2_st, mul_st, add_st, sub_st);
  signal fsm_cr_st, fsm_nx_st : state; 
  
  signal sto1	: std_logic;
  signal show1	: std_logic;
  signal sto2	: std_logic;
  signal show2	: std_logic;
  signal mul	: std_logic;
  signal add	: std_logic;
  signal sub	: std_logic;
  
  --die Werte der SW(3 downto 0) erden in die Operanden op 1 und op2 geladen
  signal op1 : signed (3 downto 0);
  signal op2 : signed (3 downto 0);
  --op 1 und op2 müssen vom selben type sein wie die Swicht sw
  
begin
 
 -- reset generator
 P_rst_del: process(BTN_SOUTH, clk)
 --dieser rst Prozess macht zwei 2FF									--+2FF
  begin
   if BTN_SOUTH = '1' then
	 rst_gen <= '1';				-- asynchronous reset start
	 rst <= '1';
   elsif rising_edge(clk) then
     rst_gen <= '0';				-- synchronous reset release
     rst <= rst_gen;				-- reset length 1-2 Clk cycles
    end if; --clk
  end process;
   
-- all metastability filter 
--dieser rst und clk sensitive Prozess filtert die asynchronen Eingänge 
--es werden 9FF gemacht  
p_meta_filter: process (rst, clk)										--+9FF
  begin
    if rst = '1' then
      btn_north_meta <= (others => '0');	--2 level
      btn_west_meta <= (others => '0');		--2 level
	  btn_east_meta <= (others => '0');		--2 level
	  rot_c_meta <= (others => '0');		--2 + edge = 3 level
  elsif rising_edge(clk) then
      btn_north_meta(0) <= BTN_North;
	  btn_north_meta(1) <= btn_north_meta(0);
	  
      btn_west_meta(0) <= BTN_WEST;
	  btn_west_meta(1) <= btn_west_meta(0);
	  
      btn_east_meta(0) <= BTN_EAST;
	  btn_east_meta(1) <= btn_east_meta(0);
	----von riging_edge bis hier wurden +6 FF also auf jeder Zeile bei jeder Zuweisung +1FF
      rot_c_meta(0) <= ROT_C;
	  rot_c_meta(1) <= rot_c_meta(0);
	  rot_c_meta(2) <= rot_c_meta(1);	-- + edge detection
	  ---plus 3FF
  end if;
end process;

p_blank_cnt: process (rst, clk)
--die Zuweisung von blank_cnt wird 20 FF erzeugen
--bis blank_cnt > den max Wert übersteigt vergehen mindestens 20ms
  begin
    if rst = '1' then
      blank_cnt <= (others => '0');
  elsif rising_edge(clk) then
     if blank_cnt=0 then
	   if rot_c_meta(1) /= rot_c_meta(2) then  -- edge
         blank_cnt <= blank_cnt + 1;
	   end if;
	 else
	   if blank_cnt > blank_cnt_max then
	     blank_cnt <= (others => '0'); 
	   else
	     blank_cnt <= blank_cnt + 1;								--+20FF
	   end if;
	 end if;
   end if; --rising_edge(clk)
end process;

-- FSM sequential process
--die Zustandszuweisung wird 3 FF machen
--Moore Maschine, denn die Ausgangszuweisung seht ausserhalb der if endif Anweisung
p_fsm_seq: process(rst, clk)
  begin
    if rst = '1' then
      fsm_cr_st <= reset_st;
   elsif rising_edge(clk) then
      fsm_cr_st <= fsm_nx_st;										--+3FF
   end if;
end process;

-- FSM combinaorial process
p_fsm_com: process (fsm_cr_st, rot_c_meta(2), blank_cnt, btn_north_meta(1), 
                    btn_west_meta(1), btn_east_meta(1))	--all read signals!
begin
   -- default assignments
   fsm_nx_st <= fsm_cr_st;		-- remain in current state
   sto1 <= '0'; 
   show1 <= '0';
   sto2 <= '0';
   show2 <= '0';
   add <= '0';
   sub <= '0';
   mul <= '0';
   
   case fsm_cr_st is

     when reset_st =>
       if rot_c_meta(2)='1' and blank_cnt=0 then	-- wait until rot_c pressed
		 fsm_nx_st <= sto1_st;
	   end if;
	   --                   first line solution as specified
	   sto1 <= '1';	--      second line improved visibility

	 when sto1_st =>
	   if rot_c_meta(2)='0' and blank_cnt=0 then	--  wait until rot_c released
		  fsm_nx_st <= wait1_st;
	   end if;
	   --sto1 <= '1';
	   show1 <= '1';

	 when wait1_st => 
       if rot_c_meta(2)='1' and blank_cnt=0 then	--  wait until rot_c pressed 2nd
		 fsm_nx_st <= sto2_st;
	   end if;
	   --show1 <= '1';
	   sto2 <= '1';
	   
	 when sto2_st => 
       if btn_north_meta(1)='1' then	-- 
		 fsm_nx_st <= mul_st;
	   elsif btn_west_meta(1)='1' then	-- 
		 fsm_nx_st <= add_st;
	   elsif btn_east_meta(1)='1' then	-- 
		 fsm_nx_st <= sub_st;
	   end if;
	   --sto2 <= '1';
	   show2 <= '1';

	 when add_st => 
	   add <= '1';
	 when sub_st =>
	   sub <= '1';
	 when mul_st =>
	   mul <= '1';

      when others =>
         fsm_nx_st <= reset_st;		-- handle parasitic states
   end case;
end process;

-- operand store sequential process
--die Zuweisung der Operanden wird je vier also im ganzen Prozess 8FF machen
p_store_seq: process(rst, clk)
  begin
    if rst = '1' then
      op1 <= (others => '0');		--unsigned assignemtn
      op2 <= (others => '0');
   elsif rising_edge(clk) then
     if sto1='1' then
	    op1 <= signed(SW);										--+4FF
	 elsif sto2='1' then
        op2 <= signed(SW);										--+4FF
     end if;		
   end if; --clk
end process;

p_calc: process (add, sub, mul, sto1, sto2, show1, show2, op1, op2)	--all inputs!
  begin
    led_i <= (others => '0');--led_i wird mit Nullen überschrieben
    if add='1' then
	  led_i(7 downto 0) <= std_logic_vector(to_signed(0,8) + op1 + op2); --Trick17: auto sign extension
	elsif sub='1' then
	  led_i(7 downto 0) <= std_logic_vector(to_signed(0,8) + op1 - op2);
	elsif mul='1' then
	  led_i(7 downto 0) <= std_logic_vector(op1 * op2);
	elsif sto1='1' or show1='1' then
	   led_i(7 downto 0) <= "0000" & std_logic_vector(op1);
	elsif sto2='1' or show2='1' then
	   led_i(7 downto 0) <= "0000" & std_logic_vector(op2);
	else
	   led_i(7 downto 0) <= (others => '0');
	end if;
end process;

LED <= led_i;
end A_calc;

