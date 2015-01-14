--**********************************
--NAND
--Kombination von Inverter und AND
--Achtung am Ende der Port kein ;
--port map nur mit , abtrennen
--**********************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MyNand is
	port(	a : in std_logic;
			b : in std_logic;
			c : out std_logic);
--achtung am Ende der Port kein ;
end MyNand;

architecture Behavioral of MyNand is
	component MyAnd is
		port(	x:in std_logic;
				y:in std_logic;
				z:out std_logic);
	end component MyAnd;	
--achtung am Ende der Port kein ;	
	component MyInv is
		port( 	x: in std_logic;
				y: out std_logic);
	end component MyInv;
--achtung am Ende der Port kein ;	
signal temp : std_logic;
begin
	and1:MyAnd
		port map(	x => a,
					y => b,
					z => temp);
--achtung am Ende der Port kein ;
	inv1: MyInv
		port map(	x => temp,
					y => c);
--achtung am Ende der Port kein ;
end Behavioral;