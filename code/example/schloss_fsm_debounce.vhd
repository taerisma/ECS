library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity schloss is 
port(
    rst     : in  std_logic;
    clk     : in  std_logic;
    input   : in  std_logic;
    en      : in  std_logic;
    output  : out std_logic);
end entity schloss;

architecture zahlenschloss of schloss is
    type state is (s0, s1, s2, s3, s4, s5, s6);
    signal current_state    : state;
    signal next_state       : state;
    signal input_meta       : std_logic_vector(1 downto 0);
    signal en_meta          : std_logic_vector(1 downto 0);
    signal en_deb           : std_logic;
    signal en_blank         : unsigned(19 downto 0);
    constant CLK_FRQ        : integer := 50_000_000;
    constant BLANKTIME_MS   : integer := 20;
    constant BLANKCNT       : integer := CLK_FRQ * BLANKTIME_MS / 1000 - 1; -- 20 ms
begin
    -- Metastabilitätsfilter für input
    input_meta_filt process (rst, clk)
    begin
        if rst = '1' then
            input_meta <= "00"
        elsif rising_edge(clk)
            input_meta(1) <= input_meta(0);
            input_meta(0) <= input;
        end if;
    end process input_meta_filt;

    -- Metastabilitätsfilter für en
    en_meta_filt process (rst, clk)
    begin
        if rst = '1' then
            en_meta <= "00"
        elsif rising_edge(clk)
            en_meta(1) <= en_meta(0);
            en_meta(0) <= en;
        end if;
    end process en_meta_filt;

    -- Debouncer und edge detection für en
    en_deb_edge process (rst, clk)
    begin
        if rst = '1' then
            en_deb <= '0';
            en_blank <= (others => '0');
        elsif rising_edge(clk) then
            if en_blank = 0 then
                if en_meta(2) and not en_meta(1) then
                    en_blank <= en_blank + 1;
                    en_deb <= '0';
                end if;
            else
                if en_blank > (to_unsigned(BLANKCNT,20) then
                    en_blank <= (others => '0');
                    en_deb <= '1';
                else
                    en_blank <= en_blank + 1;
                    en_deb <= '0';
                end if;
        end if;
    end process en_deb_edge;

    -- Kombinatorischer Prozess
    fsm_komb process (current_state, input)
    begin
        case current_state is
            when s0 =>
                if input_meta(1) = '1' then 
                    next_state <= s1;
                else
                    next_state <= s0;
                end if;
                output <= '0';
            when s1 =>
                if input_meta(1) = '0' then 
                    next_state <= s2;
                else
                    next_state <= s1;
                end if;
                output <= '0';
            when s2 =>
                if input_meta(1) = '1' then 
                    next_state <= s3;
                else
                    next_state <= s0;
                end if;
                output <= '0';
            when s3 =>
                if input_meta(1) = '0' then 
                    next_state <= s4;
                else
                    next_state <= s1;
                end if;
                output <= '0';
            when s4 =>
                if input_meta(1) = '1' then 
                    next_state <= s5;
                else
                    next_state <= s0;
                end if;
                output <= '0';
            when s5 =>
                if input_meta(1) = '1' then 
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
    end process fsm_komb;

    -- Sequentieller Prozess
    fsm_seq process (rst, clk)
    begin
        if rst = '1' then
            current_state <= s0;
        elsif rising_edge(clk) then
            if en_deb = '1'
            current_state <= next_state;
        end if;
    end process fsm_seq;
end architecture zahlenschloss;

