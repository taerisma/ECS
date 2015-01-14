
--Übung 3 Decoder
--zwei Schalter (1 und 0)
--entsprechen den Zuständen 00 01 10 11
--diese vier Zustände werden auf die LED gegeben
--***************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Decoder_SW_to_LED is
    Port ( 
		SW : in  STD_LOGIC_VECTOR (1 downto 0);
		LED : out  STD_LOGIC_VECTOR (7 downto 0)
		);
end Decoder_SW_to_LED;

architecture Behavioral of Decoder_SW_to_LED is

begin
	process(sw)
		begin
			led(7 downto 0) <= (others => '0');
			led(to_integer(unsigned(sw(1 downto 0)))) <= '1';
	end process;
end Behavioral;