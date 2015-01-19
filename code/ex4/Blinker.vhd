--Uebung4
--Blinker
--*****************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Blinker is
  generic(
    CLK_FRQ : integer := 50_000_000 -- 50 MHz = 0x2FAF080 (26 bits)
    );
  port(
    rst   : in  std_logic;
    clk   : in  std_logic;
    blink : out std_logic_vector(7 downto 0));--Ausgangsvektor mit 8 Stellen 
----!!!!!! Achtung Semikolon am Ende der Port Anweisung
end Blinker;

architecture A of Blinker is

  constant BLK_PER : integer := 4; -- half of a blink period in fractions of sec
  constant MAX_CNT : unsigned(25 downto 0):= to_unsigned(CLK_FRQ/BLK_PER-1,26);
  -- signals
  signal cnt : unsigned(25 downto 0);
  signal blk : std_logic_vector(7 downto 0); --wird für die Ausgangszuweisung beötigt
  
begin
  -- output assignments
  blink <= blk;
  
  -- sequential process
  -- ergiebt blk 8FF + cnt 26FF = 34 FF
  P1_seq: process(rst, clk)
  begin
    if rst = '1' then
      blk <= (others => '0');
      cnt <= (others => '0');
    elsif rising_edge(clk) then
      if cnt < MAX_CNT then
        cnt <= cnt + 1;
      else
        cnt <= (others => '0');
        blk <= not blk;
      end if;
    end if;
  end process;
end A;