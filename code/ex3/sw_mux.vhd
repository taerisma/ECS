library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sw_mux is
  port(
    BTN_NORTH : in  std_logic;
    BTN_EAST  : in  std_logic;
    BTN_SOUTH : in  std_logic;
    BTN_WEST  : in  std_logic;
    SW        : in  std_logic_vector(1 downto 0);
    LED       : out std_logic_vector(7 downto 0)
    );
end sw_mux;

architecture A of sw_mux is
  
begin
  
  LED(7 downto 1) <= (others => '0');

  with SW(1 downto 0) select
    LED(0) <= BTN_NORTH when "00",
              BTN_EAST  when "01",
              BTN_SOUTH when "10",
              BTN_WEST  when "11",
              '0'       when others;
end A;

