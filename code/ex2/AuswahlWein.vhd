--Auswahl für Wein
---------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
---------------------------------
entity Wein is 
	port(
	
	);
end Wein;
Architecture A1 of Wein is
type wine_type is (white, rose, red);
signal amarone: wine_type;
signal rioja : wine_type;
begin

end A1;