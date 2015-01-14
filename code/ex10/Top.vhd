--Strukturiertes Design
--beid er Port map werden lediglich Kommas , zum Abtrennen gebraucht
----------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top is
	port(
		A : in std_logic;
		B : out std_logic
		);
end Top;
architecture Behavioral of Top is

	component SubX is 
	port(
		alpha : in std_logic;
		beta	: out std_logic
		);
	end component SubX;
	
	component SubY is 
	port(
		v : in std_logic;
		w : out std_logic);
	end component SubY;
	
signal temp1 : std_logic;
signal temp2 : std_logic;

begin
	SubX1 : SubX
		port map(
			alpha 	=> A,
			beta 	=> temp1);
	SubX2 : SubX
		port map(
			alpha	=> temp1,
			beta	=> temp2);
	SubY1 : SubY
		port map(
			v 		=> temp2,
			w 		=> B);
end Behavioral;