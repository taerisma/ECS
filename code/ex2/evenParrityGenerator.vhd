-- Bei einer geraden Anzahl von 1 in dem vier Bit data Vektor
-- wird das Parrity Bit 0
-- bei einer ungeraden Anzahl ist das Parrity Bit 1
--data="0000" dann wird parity 0
--data="0001" dann wird parity 1
--data="0010" dann wird parity 1
--data="0011" dann wird parity 0
--data="1111" dann wird parity 0
--gerade Anzahl von 1 im Datenwort so wird das evenparityBit = 0
--**************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity evenParityGenerator is
    port ( 	data 	: in  STD_LOGIC_VECTOR (3 downto 0);
			even_parity 	: out  STD_LOGIC);
end evenParityGenerator;
--!!achtung die letzte Anweisung der port hat kein ;
---------------------------------------------------------------
architecture A1 of evenParityGenerator is
begin 
	process(data)
		variable onesCount : integer range 0 to data'length;
		begin
		onesCount := 1;
			for i in 0 to data'length-1 loop
				if data(i) = '1' then
					onesCount := onesCount +1;
				end if;
			end loop;
			if onesCount mod 2 = 0 then
				even_parity <= '0';
			else
				even_parity <= '1';
			end if;
	end process;
end A1;
--der Zählervariable onesCount zählt die 1er im Data Vektor
--onesCount wird durch modulo 2 geteilt
--eine gerade Zahl geteilduch modulo 2 gibt 0
--in diesem Fall wird das Parrity Bit = 0
--ungerade Zahl würde mit mod 2 nicht 0 ergeben
--somit wird für ungerade Anzahl 1er ein 1 in das parrity geschriben
-----------------------------------------------------------------

architecture A2 of evenParityGenerator is
begin
	process(data)
	variable v_even_parity : std_logic;
		begin
			v_even_parity := '0';
			for i in 0 to data'length-1 loop
			if data(i) = '1' then
				v_even_parity := not v_even_parity;	
			end if;
		end loop;
		even_parity <= v_even_parity;
	end process;
end A2;
--datenwort ="0000" parity ist 0
--sobald keine 1 im Datenwort vorkommt ist das Parity Bit = 1
--ist die Anzahl der 1 im Datenwort gerade also durch 2 ohne Rest teilbar so wird das ParityBit = 0
--be jedem 1 im Datenwort kippt das Parrity Bit
--Am Schluss wird die Variable v_even_parity auf das parity Signal geschrieben