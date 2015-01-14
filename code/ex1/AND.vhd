--*******************************
--AND
--x und y sind Eingänge
--z ist ein Ausgang
--x und y werden lgisch verknüpft
--und z zgewiesen
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MyAnd is
	port(	x : in std_logic;
			y : in std_logic;
			z : out std_logic);
end MyAnd;

architecture Behavioral of MyAnd is

begin
	z<= x and y;
end Behavioral;
--*******************************