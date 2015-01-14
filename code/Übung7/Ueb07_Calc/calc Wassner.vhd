-------------------------------------------------------------------------------
-- Entity: Calc
-- Author: Waj
-- Date  : 15-May-11
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 7)
-- Top-level entity "Taschenrechner"
-------------------------------------------------------------------------------
-- Total # of FFs: 0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Calc is
  generic(
    CLK_FRQ : integer := 50_000_000 -- 50 MHz = 0x2FAF080 (26 bits)
    );
  port(
    rst       : in  std_logic; -- BTN_SOUTH
    clk       : in  std_logic;
    ROT_C     : in  std_logic;
    BTN_EAST  : in  std_logic;
    BTN_WEST  : in  std_logic;
    BTN_NORTH : in  std_logic;
    SW        : in  std_logic_vector(3 downto 0);
    LED       : out std_logic_vector(7 downto 0)
    );
end Calc;

architecture rtl of Calc is

  -- component declarations
  component Proc
    port (
      rst   : in  std_logic;
      clk   : in  std_logic;
      SW    : in  std_logic_vector(3 downto 0);
      op1   : in  std_logic;
      op2   : in  std_logic;
      plus  : in  std_logic;
      minus : in  std_logic;
      mult  : in  std_logic;
      LED   : out std_logic_vector(7 downto 0));
  end component;

  component Ctrl
  generic(
    CLK_FRQ : integer := CLK_FRQ 
    );
    port (
      rst      : in  std_logic;
      clk      : in  std_logic;
      ROT_C    : in  std_logic;
      BTN_EAST : in  std_logic;
      BTN_WEST : in  std_logic;
      BTN_NORTH: in  std_logic;
      op1      : out std_logic;
      op2      : out std_logic;
      plus     : out std_logic;
      minus    : out std_logic;
      mult     : out std_logic);
  end component;

  -- signal declarations
  signal op1, op2, plus, minus, mult : std_logic;

begin
  
  -- instance "Proc_1"
  Proc_1: Proc
    port map (
      rst   => rst,
      clk   => clk,
      SW    => SW,
      op1   => op1,
      op2   => op2,
      plus  => plus,
      mult  => mult,
      minus => minus,
      LED   => LED);

  -- instance "Ctrl_1"
  Ctrl_1: Ctrl
    port map (
      rst      => rst,
      clk      => clk,
      ROT_C    => ROT_C,
      BTN_EAST => BTN_EAST,
      BTN_WEST => BTN_WEST,
      BTN_NORTH=> BTN_NORTH,
      op1      => op1,
      op2      => op2,
      plus     => plus,
      minus    => minus,
      mult     => mult);
  
end rtl;
