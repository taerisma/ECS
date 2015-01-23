--Auswahlcode für Ferien
---------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
---------------------------------

--von welchem type ist season?
--signal oder array oder Eingang?
--von welchem type sind die Jahreszeiten ...summer, winter,  spring
--und wie werden die Ferien definiert?.... skiing, seaside, 
-------------------------------------------------------------
entity Ferien is 
	port(
	
	);
end Ferien;

Architecture A1 of Ferien is
    type season_type is (summer, winter, spring);
    signal season : season_type;
    type holiday_type is (seaside, skiing, none);
    signal holiday : holiday_type;

begin

--eine select Anweisung
with season select
holiday <= 		seaside when summer,
			skiing 	when winter | spring,
			none	when others;
end A1;

Architecture A2 of Ferien is
    type season_type is (summer, winter, spring);
    signal season : season_type;
    type holiday_type is (seaside, skiing, none);
    signal holiday : holiday_type;

begin
holiday <= 		seaside when season = summer else
			skiing 	when season = (winter | spring) else
			none;
end A2;
--wichtig!!! die when else Anweisung hat keine Abtrennung

--Process mit einer if else if else end if Anweisung
Architecture A3 of Ferien is
    type season_type is (summer, winter, spring);
    signal season : season_type;
    type holiday_type is (seaside, skiing, none);
    signal holiday : holiday_type;

begin
	process(season)
	begin
		if 		season = summer then
					holiday <= seaside;
		elsif		season = winter | spring then
					holiday <= skiing;
		else 
					holiday <= none;
		end if;
	end process;
end A3;

--Process mit einer Auswahl mit einer case Anweisung
Architecture A4 of Ferien is
    type season_type is (summer, winter, spring);
    signal season : season_type;
    type holiday_type is (seaside, skiing, none);
    signal holiday : holiday_type;

begin
	process(season)
	begin
		case season is
			when summer 			=> holiday <= seaside;
			when (winter | spring) 	=> holiday <= skiing;
			when others 			=> holiday <= none;
		end case;
	end process;
end A4;
