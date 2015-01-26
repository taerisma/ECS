--Multiplexer
--S hat zwei Leitungen
--Hat vier Zustände
--S steuert welcher Eingang zum Ausgang O geschalten wird
----------------------------------------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity mux4to1 is
    Port ( A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           C : in  STD_LOGIC;
           D : in  STD_LOGIC;
           S : in  STD_LOGIC_VECTOR (1 downto 0);
           O : out  STD_LOGIC
           );
end mux4to1;
--------------------------------------------------------------------------------
--Mux mit einer if elsif else end if Anweisung
--Die einzellen Anweisungen werden mit ; Semikolon abgetrennt
architecture A1 of mux4to1 is
begin
Process(S,A,B,C,D)
variable temp : std_logic;      // variable declaration
begin
	if(S="00")		then
		temp:=A;
	elsif(S="01")	then           // note that it is 'elsif' not 'elsif' of C
		temp:=B;
	elsif(S="10")	then
		temp:=C;
	else
		temp:=D;
	end if;                     // used to terminate the if statement
	O<=temp;                    // passing on the value of the variable
end Process;
end A1;
----------------------------------------------------------------------------------
--Mux mit case 
--verwende ; zur Abtrennunge der Anweiungen
Architecture A2 of mux4to1 is
begin
Process(S,A,B,C,D)
variable temp:std_logic;
	Begin
		case S is
			when "00" => temp:=A;
			when "01" => temp:=B;
			when "10" => temp:=C;
			when Others => temp:=D;
end case;
O<=temp;
end Process;
end A2;
----------------------------------------------------------------------------------
--Mux mit when else statement
--wichtig es ibt keine Abtrennung zwischen den Anweisungen
Architecture A3 of mux4to1 is
Begin
O<= A when (S1='0' and S2='0') else
    B when (S1='0' and S2='1') else
    C when (S1='1' and S2='0') else
    D;
end A3;
----------------------------------------------------------------------------------
--Mux mit with ... select 
--zum Abtrennen der Anweisungen werden , Komma verwendet
Architecture behavioral of mux4to1 is
begin
with S select
O<= A when "00",
    B when "01",
    C when "10",
    D when others;
end behavioral;
----------------------------------------------------------------------------------
