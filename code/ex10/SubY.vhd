library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SubY is
	port(
		v : in std_logic;
		w : out std_logic);
end SubY;

architecture Behavioral of SubY is
	component SubSubY is
		port(
			x : in std_logic;
			y : out std_logic);
	end component SubSubY;

begin
	SubSub1: SubSubY
		port map(
			x =>v,
			y =>w);
end Behavioral;  