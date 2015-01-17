library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- synchrones RAM mit "Read before Write"
entity RAM_RbW is
generic(
	AW : integer := 4; 
	DW : integer := 8
	);
port(
		clk 	:in std_logic;
		we 	:in std_logic;
		addr 	:in std_logic_vector(AW-1 downto 0);
		Din 	:in std_logic_vector(DW-1 downto 0);
		Dout 	:out std_logic_vector(DW-1 downto 0)
);
end entity RAM_RbW;
architecture A1 of RAM_RbW is
type t_ram is array(0 to (2**AW)-1) of std_logic_vector(DW-1 downto 0);
signal ram : t_ram;
signal r_addr :std_logic_vector(AW-1 downto 0);
begin
	P_ram:process(clk)
		begin
			if rising_edge(clk) then
				if we = '1' then
					ram(to_integer(unsigned(addr))) <= Din;
				end if;
			r_addr <= addr;
            -- Read before write
            Dout <= ram(to_integer(unsigned(r_addr)));
			end if;
	end process;
end architecture A1;
