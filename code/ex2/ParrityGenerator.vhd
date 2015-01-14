-- Bei einer geraden Anzahl von 1 in dem vier Bit data Vektor
-- wird das Parrity Bit 1
-- bei einer ungeraden Anzahl ist das Parrity Bit 0
--**************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity ParityGenerator is
    port ( 	data 	: in  STD_LOGIC_VECTOR (3 downto 0);
			parity 	: out  STD_LOGIC
		);
end ParityGenerator;
--!!achtung die letzte Anweisung der port hat kein ;
---------------------------------------------------------------
architecture A1 of ParityGenerator is
begin 
	process(data)
		variable onesCount : integer range 0 to data'length;
		begin
		onesCount := 0;
			for i in 0 to data'length-1 loop
				if data(i) = '1' then
					onesCount := onesCount +1;
				end if;
			end loop;
			if onesCount mod 2 = 0 then
				parity <= '1';
			else
				parity <= '0';
			end if;
	end process;
end A1;
--der Zählervariable onesCount zählt die 1er im Data Vektor
--onesCount wird durch modulo 2 geteilt
--eine gerade Zahl geteilduch modulo 2 gibt 0
--in diesem Fall wird das Parrity Bit = 1
--ungerade Zahl würde mit mod 2 nicht 0 ergeben
--somit wird für ungerade Anzahl 1er ein 0 in das parrity geschriben
-----------------------------------------------------------------

architecture A2 of ParityGenerator is
begin
	process(data)
	variable v_odd_parity : std_logic;
		begin
			v_odd_parity := '1';
			for i in 0 to data'length-1 loop
			if data(i) = '1' then
				v_odd_parity := not v_odd_parity;	
			end if;
		end loop;
		parity <= v_odd_parity;
	end process;
end A2;
--solange keine 1 im Datenwort vorkommt ist das Parity Bit = 1
--be jedem 1 im Datenwort kippt das Parrity Bit
--Am Schluss wird die Variable v_odd_parity auf das parity Signal geschrieben