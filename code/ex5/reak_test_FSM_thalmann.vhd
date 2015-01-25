library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

------
--FF = 99 = 88+8+0+3 =99FF
---------------------------
entity reak_test_random_fsm_mealy is
	generic(
			CLK_FRQ : integer :=50_000_000
			);
    Port ( rot_c 	: in  STD_LOGIC;
           rst 		: in  STD_LOGIC;
           clk 		: in  STD_LOGIC;
           led 		: out  STD_LOGIC_VECTOR (7 downto 0));
end reak_test_random_fsm_mealy;

architecture Behavioral of reak_test_random_fsm_mealy is
constant FIX_Time 		: unsigned(25 downto 0) := to_unsigned(CLK_FRQ-1,26);
constant hundertstel 	: unsigned(25 downto 0) := to_unsigned(CLK_FRQ/100-1,26); 
constant sec_div_200 	: unsigned(25 downto 0) := to_unsigned(CLK_FRQ/200-1,26); 
constant BLANK_TIME 	: unsigned(25 downto 0) := to_unsigned(CLK_FRQ/8-1,26);

type state is (start, warten, messen, fertig, cheat);
signal c_st, n_st : state;

signal counter_done : std_logic;
signal time_out : std_logic;
signal messung_done : std_logic;
signal start_zufall_zeit: std_logic;
signal start_messung : std_logic;
signal start_blank : std_logic;
signal counter : unsigned(25 downto 0);
signal t_max : unsigned(25 downto 0);
signal messung_zeit : unsigned(7 downto 0);
signal led_out : std_logic_vector(7 downto 0);

signal zufalls_counter : unsigned(25 downto 0) := to_unsigned(CLK_FRQ/2-1,26);
begin  
	led <= led_out;		--Ausgangszuweisung
	
	--sequenzieller Prozess macht FF (88)
	--26+26+8+1+1+26=88
	P_counter: process(rst, clk)
	begin
		if rst ='1' then
			t_max <= FIX_Time;						--26FF
			counter <= (others => '0');				--26FF
			messung_zeit <= (others => '0');		--8FF
			counter_done <= '0';					--1FF
			time_out <= '0';						--1FF
		elsif rising_edge(clk) then
			if zufalls_counter < FIX_TIME then		--26FF
				zufalls_counter <= zufalls_counter + 1;
			else
				zufalls_counter <= (others => '0');
			end if;
			
			counter_done <= '0';
			time_out <= '0';
			counter <= (others => '0');
			
		if counter < t_max then
			counter <= counter +1;
		elsif counter = t_max then
			counter_done <= '1';
			messung_zeit <= messung_zeit +1;
		if messung_zeit = 254 then
			time_out <= '1';
		end if;
	end if;
	
	if start_zufall_zeit ='1' then
		t_max <= zufalls_counter;
	elsif start_messung = '1' then
		counter <= sec_div_200;
		t_max <= hundertstel;
		messung_zeit <= (others => '0');
	elsif start_blank = '1' then
		t_max <= BLANK_TIME;
	end if;
	end if;
	end process;
	
	--sequenzieller process um LED zu 
	-- macht FF led_out Zuweisung macht 8FF
	P_LED: process(rst, clk)
		begin
			if rst = '1' then
				led_out <= (others => '0');
			elsif rising_edge(clk) then
				if start_messung ='1' then
					led_out <= ('1',others => '0');
				elsif start_blank = '1' then
					led_out <= not led_out;
				elsif messung_done = '1' then
					led_out <= std_logic_vector(messung_zeit);
				end if;
			end if;
		end process;
				
--fsm KEINE FF
P_FSM_combinatorisch: process(c_st, counter_done, rot_c, time_out)
begin
n_st <= c_st;
messung_done <= '0';
start_zufall_zeit<= '0';
start_messung <= '0';
start_blank <= '0';
	case c_st is
		when start =>
			if rot_c = '1' then 
				start_blank <= '1';
				n_st <= cheat;
			elsif counter_done ='1' then
				start_zufall_zeit <= '1';
				n_st <= warten;
			end if;
		when warten =>
			if rot_c = '1'then
				start_blank <= '1';
				n_st <= cheat;
			elsif counter_done ='1' then
				start_messung <= '1';
				n_st <= messen;
			end if;
		when messen =>
			if rot_c = '1' or time_out = '1' then
			messung_done <= '1';
			n_st <= fertig;
			end if;
		when cheat =>
			if counter_done = '1' then
			start_blank <= '1';
			end if;
		when fertig =>
			null;
		when others =>
			n_st <= start;
	end case;
end process;

--sequenziller Teil der FSM
--macht FF3 weil fünf Zustände brauchen 3FF= theoretisch 8
P_sequenziell: process(rst, clk)
begin
	if rst = '1' then
		c_st <= warten;
	elsif rising_edge(clk) then
		c_st <= n_st;
	end if;
end process;
end Behavioral;