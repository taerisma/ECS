-------------------------------------------------------------------------------
-- Entity: Proc
-- Author: Waj
-- Date  : 15-May-11
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 7)
-- Data processing and display unit for "Taschenrechner"
-------------------------------------------------------------------------------
-- Total # of FFs: 16
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Proc is
  port(
    rst   : in std_logic;
    clk   : in std_logic;
    SW    : in std_logic_vector(3 downto 0);
    op1   : in std_logic;
    op2   : in std_logic;
    plus  : in std_logic;
    minus : in std_logic;
    mult  : in std_logic;        
    LED   : out std_logic_vector(7 downto 0));
end Proc;

architecture rtl of Proc is

  signal reg1, reg2 : signed(3 downto 0);

begin

  -----------------------------------------------------------------------------
  -- sequential process: LED Control
  -- # of FFs: 8 + 4 + 4 = 16
  P_LED_ctrl: process(rst, clk)
  begin
    if rst = '1' then 
      LED     <= (others => '0');
      reg1    <= (others => '0');
      reg2    <= (others => '0');
    elsif rising_edge(clk) then
      if op1 = '1'  then
        reg1            <= signed(SW);
        LED(3 downto 0) <= SW;
      elsif op2 = '1'  then
        reg2            <= signed(SW);
        LED(3 downto 0) <= SW;
      elsif plus = '1' then
        if reg1(3) = '1' then
          -- sign-extension of operand 1 to 8 bits
          LED <= std_logic_vector(("1111" & reg1) + reg2);
        else
          LED <= std_logic_vector(("0000" & reg1) + reg2);
        end if;
      elsif minus = '1' then
        if reg1(3) = '1' then
          -- sign-extension of operand 1 to 8 bits
          LED <= std_logic_vector(("1111" & reg1) - reg2);
        else
          LED <= std_logic_vector(("0000" & reg1) - reg2);
        end if;
      elsif mult = '1' then
        -- result of multiplication will have 8 bits 
        LED <= std_logic_vector(reg1 * reg2);
      end if;
    end if;
  end process;
  
end rtl;
