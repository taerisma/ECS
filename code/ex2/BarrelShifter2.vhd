library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity BarrelShifter2 is
    port ( 
			dataIn 	: in  STD_LOGIC_VECTOR 	(7 downto 0);
			dataOut : out  STD_LOGIC_VECTOR (7 downto 0);
			shift 	: in  STD_LOGIC_VECTOR 	(3 downto 0));
end BarrelShifter2;

architecture Behavioral of BarrelShifter2 is
begin
  process(dataIn, shift)
  variable barrel: std_logic_vector(23 downto 0);
  begin 
    barrel := (others => '0');
    barrel(to_integer(signed(shift))+15 downto to_integer(signed(shift))+8) := dataIn(7 downto 0);
	 dataOut <= barrel(15 downto 8);
  end process;
end Behavioral;