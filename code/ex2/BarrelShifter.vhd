library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity BarrelShifter is
    port ( 
			dataIn 	: in  STD_LOGIC_VECTOR 	(7 downto 0);
			dataOut 	: out  STD_LOGIC_VECTOR (7 downto 0);
			shift 	: in  STD_LOGIC_VECTOR 	(3 downto 0)
			  );
end BarrelShifter;

-- process statement with sequential signal ass. and for
architecture BarrelShifter_1 of BarrelShifter is
begin
  process(dataIn, shift)
  variable barrel: std_logic_vector(23 downto 0);
  begin 
    barrel := (others => '0');
    barrel(to_integer(signed(shift))+15 downto to_integer(signed(shift))+8) := dataIn(7 downto 0);
	 dataOut <= barrel(15 downto 8);
  end process;
end architecture BarrelShifter_1;

architecture BarrelShifter_2 of BarrelShifter is
begin
	process(dataIn, shift)
		variable v_ashft : integer range 0 to  + 2**(shift'length-1)-1;
		begin
			v_ashft := abs(to_integer(signed(shift)));
			dataOut <= (others => '0');
			if shift (shift'length -1) = '1' then 
				dataOut(dataOut'high - v_ashft downto 0) <= dataIn(dataIn'high downto v_ashft);
			else
				dataOut(dataOut'high downto v_ashft) <= dataIn(dataIn'high - v_ashft downto 0);
			end if;
	end process;
end architecture;