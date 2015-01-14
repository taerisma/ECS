--Auswahlcode für MEP
---------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
---------------------------------
--wie muss diese Entity definiert sein?
entity MEP is 
	port(
	
	);
end MEP;


--von welchem type ist stud?
--von welchem type ist mep?
--von welchem type sind die Noten
--und wie werden die Noten definiert?
-------------------------------------------------------------

--eine select Anweisung
Architecture A1 of MEP is
type grade_type is (A, B, C, D, E, F);
signal mep : grade_type;
begin
	with mep select
	stud <= happyhappy 	when mep =	A,
			happy 		when mep >= C,
			satisfied 	when mep >= E,
			sad			when others;
end A1;

Architecture A2 of Ferien is
type grade_type is (A, B, C, D, E, F);
signal mep : grade_type;

begin
stud <= happyhappy	when mep =	A else
		happy 		when mep >= C else
		satisfied 	when mep >= E else
		sad;
end A2;

--Process mit einer if else if else end if Anweisung
Architecture A3 of Ferien is
begin 
type grade_type is (A, B, C, D, E, F);
signal mep : grade_type;
	process(mep)
	begin
		if 		mep = A then
					stud <= happyhappy;
		else if	mep >= C then
					stud <= happy;
		else if	mep >= E then
					stud <= satisfied;
		else 
					stud <= sad;
		end if;
	end process;
end A3;

--Process mit Case Anweisung
Architecture A4 of Ferien is
begin 
type grade_type is (A, B, C, D, E, F);
signal mep : grade_type;
	process(mep)
	begin
		case mep is
			when A 		=> stud <= happyhappy;
			when (C|B)	=> stud <= happy;
			when (D|E)	=> stud <= satisfied;
			when others => stud <= sad;
		end case;
	end process;
end A4;