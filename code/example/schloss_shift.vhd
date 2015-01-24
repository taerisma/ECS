library IEEE;
use IEEE.std_logic_1164.all

entity schloss is 
generic(
    WIDTH : integer := 6;
);
port(
    rst     : in  std_logic;
    clk     : in  std_logic;
    en      : in  std_logic;
    input   : in  std_logic;
    output  : out std_logic);
end entity schloss;

architecture zahlenschloss of schloss is
    constant CODE : std_logic_vector((WIDTH-1) downto 0) := "101011"
    signal shiftreg : std_logic_vector((WIDTH-1) downto 0);
begin
    process (rst, clk)
    begin
        if rst = '1' then
            shiftreg <= (others => '0');
            output <= '0';
        elsif rising_edge(clk) then
            if en = '1' then
                shiftreg <= input & shiftreg((WIDTH-1) downto 1);
                output <= '1' when shiftreg = CODE else '0';
            end if;
        end if;
    end process;
end architecture zahlenschloss;

