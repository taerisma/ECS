--asynchrones ROM/look-uptable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity Rom is
	generic(
			AW : integer := 3; 
			DW : integer := 8
			);
	port(
			addr :in std_logic_vector(AW-1 downto 0);
			Dout :out std_logic_vector(DW-1 downto 0));
end Rom;

architecture A1 of Rom is
	type t_rom is array(0 to (2**AW)-1)of std_logic_vector(DW-1 downto 0);
	constant rom : t_rom := (X"1A", X"1B", X"1C", X"1D", X"2A", X"2B", X"2C", X"2D");
begin
	Dout <= rom(to_integer(unsigned(addr)));
end architecture A1;