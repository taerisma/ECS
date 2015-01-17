-- Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sync_en is 
    port (
        clk : in    std_logic;
        inp : in    std_logic;
        en  : out   std_logic );
end sync_en;

architecture enable of sync_en is

signal inp_reg  : std_logic;

begin
    process (clk)
    begin
        if rising_edge(clk) then
            inp_reg <= inp;
            en <= '0';    -- default assignment
            if inp = '1' and inp_reg = '0' then
                en <= 1;
            end if;
        end if;
    end process;
end architecture enable;
