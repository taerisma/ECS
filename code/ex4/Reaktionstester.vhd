--**************************************************
--eine alte Wassner Lösung mit angepassten Namen
--von ZF Alex Winiger
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

--FF=64

entity raktions_tester is
--generic
	generic(CLK_FRQ : integer := 50_000_000);
    port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           rot_c : in  STD_LOGIC;
           led : out  STD_LOGIC_VECTOR (7 downto 0)
			  );
end raktions_tester;

architecture Behavioral of raktions_tester is
--constants
constant DELAY_TIME : unsigned(26 downto 0) 			:= to_unsigned(2*CLK_FRQ-1,27);
constant ZAELER_AUFLOESUNG : unsigned(18 downto 0) := to_unsigned(CLK_FRQ/100-1,19);
constant ZUFALLS_ZEIT : unsigned(18 downto 0) 		:= to_unsigned(CLK_FRQ/200-1,19);
--singnals
signal delay_abgelaufen	: std_logic;
signal messung_fertig	: std_logic;
signal delay_zaehler		: unsigned(26 downto 0);
signal zaehler				: unsigned(18 downto 0);
signal gemessene_zeit	: unsigned(7 downto 0);
signal led_out				: std_logic_vector(7 downto 0);

begin
--Ausgangs zuweisung
led<= led_out;
	--sequenzieller Prozess
	process_delay_counter: process(rst,clk) --sequenziell
	-- # of FFs: 27 + 1 = 28
	begin
		if rst = '1' then
			delay_zaehler <= (others => '0');
			delay_abgelaufen <= '0';
		elsif rising_edge(clk) then
			if delay_zaehler < DELAY_TIME then
					delay_zaehler <= delay_zaehler + 1;
			else
        delay_abgelaufen <= '1';
      end if;
		end if;
	end process;
	--sequenzieller Prozess
	-- sequential process: Time Measurement
  -- # of FFs: 19 + 8 + 1 = 28
	process_zeit_Messung: process(rst,clk)
	begin
		if rst = '1' then
			zaehler <= ZUFALLS_ZEIT;
			gemessene_zeit <= (others => '0');
			messung_fertig <= '0';
			elsif rising_edge(clk) then
				if rot_c ='1' then
				messung_fertig <= '1';
				end if;
			if ((delay_abgelaufen = '1') and (messung_fertig = '0')) then
				if zaehler < ZAELER_AUFLOESUNG then
				zaehler <= zaehler + 1;
				else
				zaehler <= (others => '0');
				gemessene_zeit <= gemessene_zeit +1;
				end if;
			end if;
		end if;
	end process;
	--sequenzieller Prozess
	-- # of FFs: 8
	process(rst,clk)
	begin
		if rst = '1' then
			led_out <= (others => '0');
		elsif rising_edge(clk) then
			if delay_abgelaufen ='1' and messung_fertig = '0' then
				led_out(7) <= '1';
			elsif messung_fertig = '1' then
				led_out <= std_logic_vector(gemessene_zeit);		
			end if;
		end if;		
	end process;
end Behavioral;

