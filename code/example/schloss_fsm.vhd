library IEEE;
use IEEE.std_logic_1164.all

entity schloss is 
port(
    rst     : in  std_logic;
    clk     : in  std_logic;
    input   : in  std_logic;
    output  : out std_logic);
end entity schloss;

architecture zahlenschloss of schloss is
    type state is (s0, s1, s2, s3, s4, s5, s6);
    signal current_state : state;
    signal next_state    : state;
begin
    -- Kombinatorischer Prozess
    process (current_state, input)
    begin
        case current_state is
            when s0 =>
                if input = '1' then 
                    next_state <= s1;
                else
                    next_state <= s0;
                end if;
                output <= '0';
            when s1 =>
                if input = '0' then 
                    next_state <= s2;
                else
                    next_state <= s1;
                end if;
                output <= '0';
            when s2 =>
                if input = '1' then 
                    next_state <= s3;
                else
                    next_state <= s0;
                end if;
                output <= '0';
            when s3 =>
                if input = '0' then 
                    next_state <= s4;
                else
                    next_state <= s1;
                end if;
                output <= '0';
            when s4 =>
                if input = '1' then 
                    next_state <= s5;
                else
                    next_state <= s0;
                end if;
                output <= '0';
            when s5 =>
                if input = '1' then 
                    next_state <= s6;
                else
                    next_state <= s4;
                end if;
                output <= '0';
            when s6 =>
                next_state <= s6;
                output <= '1';
            when others =>
                next_state <= s0;
                output <= '0';
    end process;

    -- Sequentieller Prozess
    process (rst, clk)
    begin
        if rst = '1' then
            current_state <= s0;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
end architecture zahlenschloss;

