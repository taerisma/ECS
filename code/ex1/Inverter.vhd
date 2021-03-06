--*******************************
--Inverter
--x ist ein Eingagn
--y der invertierte Ausgang von x
--*******************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MyInv is
	port(	x : in std_logic;
			y : out std_logic);
end MyInv;

architecture Behavioral of MyInv is
begin
	y <= not x;
end Behavioral;