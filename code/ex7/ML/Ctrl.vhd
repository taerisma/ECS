-------------------------------------------------------------------------------
-- Entity: Ctrl
-- Author: Waj
-- Date  : 15-May-11
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 7)
-- Synchronization, Debouncing and Controller-FSM of "Taschenrechner"
-------------------------------------------------------------------------------
-- Total # of FFs: 34 + 2 = 36
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ctrl is
  generic(
    CLK_FRQ : integer := 50_000_000 -- 50 MHz = 0x2FAF080 (26 bits)
    );
  port(
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
    mult     : out std_logic
    );
end Ctrl;

architecture rtl of Ctrl is

  -- timer constants 
  -- 1/5 sec = CLK_FRQ / 5 = 200 ms
  constant BLANK_TME  : unsigned(23 downto 0) := to_unsigned(CLK_FRQ/5-1, 24);
  -- FSM state
  type state is (s_idle, s_op1, s_op2, s_done);
  signal c_st, n_st : state;
  -- ROT_C synchronization signals
  signal sync_ROT_C : std_logic_vector(2 downto 0);    
  signal sync_WEST  : std_logic_vector(1 downto 0);    
  signal sync_EAST  : std_logic_vector(1 downto 0);    
  signal sync_NORTH : std_logic_vector(1 downto 0);    
  signal ROT_C_deb  : std_logic;
  signal blank_cnt  : unsigned(23 downto 0);

begin
  
  ----------------------------------------------------------------------------- 
  -- sequential process: synchronization and de-bouncing
  -- All button inputs are synchronized but only ROT_C is debounced. No debouncing
  -- for other buttons is ncessary because of the special FSM structure.
  -- In front of the 200 ms (!!) debouncer, there is (rising) edge dedection for
  -- ROT_C in order to prevent "running through" the FSM states if the user
  -- presses ROT_C for a long time.
  -- # of FFs: 3 + 2 + 2 + 2 + 24 + 1 = 34
  P_syn_deb: process(rst, clk)
  begin
    if rst = '1' then
      sync_ROT_C <= (others => '0');
      sync_WEST  <= (others => '0');
      sync_EAST  <= (others => '0');
      sync_NORTH <= (others => '0');
      blank_cnt  <= (others => '0');
      ROT_C_deb  <= '0';
    elsif rising_edge(clk) then
      -- synchronization of ROT_C
      sync_ROT_C(0) <= ROT_C;
      sync_ROT_C(1) <= sync_ROT_C(0);
      sync_ROT_C(2) <= sync_ROT_C(1);
      -- synchronization of BTN_WEST
      sync_WEST(0) <= BTN_WEST;
      sync_WEST(1) <= sync_WEST(0);
      -- synchronization of BTN_EAST
      sync_EAST(0) <= BTN_EAST;
      sync_EAST(1) <= sync_EAST(0);
      -- synchronization of BTN_WEST
      sync_NORTH(0) <= BTN_NORTH;
      sync_NORTH(1) <= sync_NORTH(0);
      -- debouncing of ROT_C
      ROT_c_deb <= '0';                 -- default assignments
      blank_cnt <= (others => '0');
      if blank_cnt = 0 and sync_ROT_C(1) = '1' and sync_ROT_C(2) = '0' then
        -- start blank time counter at rising edge of synchronized ROT_C
        blank_cnt <= blank_cnt + 1;
        ROT_C_deb <= '1';
      elsif blank_cnt > 0 and blank_cnt < BLANK_TME then
        -- blank time counter active, ignore rising edges on synchr. Rot_C
        blank_cnt <= blank_cnt + 1;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- FSM: Mealy-type
  -- Inputs : sync_EAST, sync_WEST, sync_NORTH, ROT_C_deb
  -- Outputs: op1, op2, plus, minus, mult (all Mealy-type)
  -----------------------------------------------------------------------------
  -- memoryless process
  p_fsm_com: process (c_st, ROT_C_deb, sync_EAST, sync_WEST, sync_NORTH)
  begin
    -- default assignments
    n_st  <= c_st; -- remain in current state
    op1   <= '0'; 
    op2   <= '0';  
    plus  <= '0'; 
    minus <= '0';
    mult  <= '0';
    -- specific assignments
    case c_st is
      when s_idle =>
        if ROT_C_deb = '1' then
          op1  <= '1';
          n_st <= s_op1;
        end if;
      when s_op1 =>
        if ROT_C_deb = '1' then
          op2  <= '1';
          n_st <= s_op2;
        end if;
      when s_op2 =>
        if sync_EAST(1) = '1' then
          minus <= '1';
          n_st  <= s_done;
        elsif sync_WEST(1) = '1' then
          plus <= '1';
          n_st <= s_done;
        elsif sync_NORTH(1) = '1' then
          mult <= '1';
          n_st <= s_done;
        end if;
      when s_done =>
        null;           -- need reset to leave this state
      when others =>
        n_st <= s_idle; -- handle parasitic states
    end case;
  end process;
  ----------------------------------------------------------------------------- 
  -- sequential process
  -- # of FFs: 2 (assuming binary state encoding)
  P_fsm_seq: process(rst, clk)
  begin
    if rst = '1' then
      c_st <= s_idle;
    elsif rising_edge(clk) then
      c_st <= n_st;
    end if;
  end process;
  
end rtl;
