--Übung 3 
--ein Multiplexer
--eine when else Anweisung in einem Prozess
--********************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Multiplexer is
    Port ( BTN_NORTH 	: in  STD_LOGIC;
           BTN_EAST 	: in  STD_LOGIC;
           BTN_SOUTH 	: in  STD_LOGIC;
           BTN_WEST 	: in  STD_LOGIC;
           ROT_A 	: in  STD_LOGIC;
           ROT_B 	: in  STD_LOGIC;
           ROT_CENTER 	: in  STD_LOGIC;
	   SW 		: in  STD_LOGIC_VECTOR (2 downto 0);
           LED 		: out  STD_LOGIC_VECTOR (7 downto 0));--Semikolon am Schluss
end Multiplexer;

architecture Behavioral of Multiplexer is

begin
--die obersten drei LED bleiben immer aus
	LED(7 downto 5) <= (others=>'0');
	LED(1)<=SW(2);
	LED(2)<=ROT_A;
	LED(3)<=ROT_B;
	LED(4)<=ROT_CENTER;

	LED(0)<= 		'1' when((sw(1 downto 0) = "00") and BTN_NORTH='1')	else
				'1' when((sw(1 downto 0) = "01") and BTN_WEST='1')	else
				'1' when((sw(1 downto 0) = "10") and BTN_SOUTH='1')	else
				'1' when((sw(1 downto 0) = "11") and BTN_EAST='1')	else
				'0';

end Behavioral;
--keine Abtrennung zwischen den else
--wichtig ein Null zum Abfangen