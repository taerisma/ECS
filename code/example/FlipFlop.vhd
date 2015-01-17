-- Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ff is 
    port (
        rst : in    std_logic;
        clk : in    std_logic;
        D   : in    std_logic;
        Q   : out   std_logic );
end ff;

architecture flipflop of ff is
begin
    process (rst, clk)
    begin
        if rst = '1' then
            Q <= '0';
        elsif rising_edge(clk) then
            Q <= D;
        end if;
    end process;
end architecture flipflop;
