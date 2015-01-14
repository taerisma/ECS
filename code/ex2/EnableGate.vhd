library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity EnableGate is
    Port ( 	x 	: in  STD_LOGIC_VECTOR (3 downto 0);
      		en 	: in  STD_LOGIC;
      		y 	: out  STD_LOGIC_VECTOR (3 downto 0)
			);
end EnableGate;

-- concurrent signal assignment
architecture concurent_signal_assigment1 of EnableGate is
begin
	y(0) <= x(0) and en;
	y(1) <= x(1) and en;
	y(2) <= x(2) and en;
	y(3) <= x(3) and en;
end concurent_signal_assigment1;

-- concurrent signal assignment
architecture concurent_signal_assigment2 of EnableGate is
begin
	y <= x and (en, en, en, en);
end concurent_signal_assigment2;

-- process statement mit einem sequential signal assignment
architecture process_sequenziell_concurent_signal_assigment of EnableGate is
begin
	process(x, en)
		begin
			y(0) <= x(0) and en;
			y(1) <= x(1) and en;
			y(2) <= x(2) and en;
			y(3) <= x(3) and en;
		 end process;
end process_sequenziell_concurent_signal_assigment;


architecture process_concurent_signal_assigment3 of EnableGate is
begin
	process(x, en)
		begin
			y <= x and (en, en, en, en);
		end process;
end process_concurent_signal_assigment3;

--eine Schlaufe
architecture Process_for_loop of EnableGate is
begin
	process(x, en)
		begin
			for i in 0 to x'length-1 loop
				y(i) <= x(i) and en;
			end loop;
		end process;
end Process_for_loop;


-- eine when else Anweisung
--Die einzellnen Zuweisungen haben keine Abtrennung
-- erst am Ende kommt ein ;
architecture conditional_sig_assigment of EnableGate is
begin
	y <= x 	when en = '1'				--keine Abtrennung
				else (others => '0');
end;



architecture process_conditional_sig_assigment of EnableGate is
begin
	process(x, en)
		begin
			if en = '1' then			--kein ; kein,
				y <= x;					--wichtig ;
			else
				y <= (others => '0');--wichtig ;
			end if;						--wichtig ;
		end process;					--wichtig ;
end architecture;


architecture process_mit_case of EnableGate is
begin
	process(x, en)
		begin
			case en is
				when '1' 	=> y <= x;	--when en ='1' ist wird x nach y geschrieben
				when others => y <= (others => '0');
			end case;
		end process;
end process_mit_case;

--selecd Statmend
--wichtig y und x müssen vom selben typ sein
--der Verglecih rechts von when muss vom selben Typ sein wie en
architecture selected_sig_assigment of EnableGate is
begin
	with en select
		y <= x when '1',								--die Zuweisungen mit , abtrennen
				(others => '0') when others;		--erst am Ende kommt ein ;
end architecture selected_sig_assigment;
--------------------------------------------------------