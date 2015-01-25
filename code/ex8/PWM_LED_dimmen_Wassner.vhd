--vermutlich wassner
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_led is
  generic(
    N : integer :=  8; -- DAC resolution in bits
    S : integer := 16 -- number of brightness levels
    );
  port(
    rst   : in  std_logic;
    clk   : in  std_logic;
    ROT_A : in  std_logic;
    ROT_B : in  std_logic;
    LED   : out std_logic_vector(7 downto 0));
end pwm_led;

architecture A of pwm_led is

  -- FSM state
  type     state is (s_idle_left, s_idle_right, s_active);
  signal   c_st, n_st : state;
  -- signals
  type   t_sync_ar is array (0 to 1) of std_logic_vector(1 downto 0);
  signal sync_rot : t_sync_ar;
  signal left, right : std_logic;
  signal dig_in   : unsigned(N-1 downto 0);
  signal ref_cnt  : unsigned(N-1 downto 0);
  -- constant: steps per ROT click for given resolution and brightness levels
  constant STP    : integer := 2**N/S; -- uses truncation!
  
begin
  -----------------------------------------------------------------------------
  -- sequential process: Synchronization of ROT_A/B
  -- # of FFs: 4
  P_sync_rot : process(rst, clk)
  begin
    if rst = '1' then
      sync_rot <= (others => (others => '0'));
    elsif rising_edge(clk) then
      -- sync FFs for ROT inputs
      sync_rot(0)(1) <= ROT_A;
      sync_rot(0)(0) <= ROT_B;
      sync_rot(1)    <= sync_rot(0);
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- FSM: Mealy-type
  -- Inputs : sync_rot
  -- Outputs: qua_rot
  -----------------------------------------------------------------------------
  -- memoryless process
  p_fsm_com : process (c_st, sync_rot)
  begin
    -- default assignments
    n_st  <= c_st;                    -- remain in current state
    left  <= '0';
    right <= '0';
    -- specific assignments
    case c_st is
      when s_idle_left =>
        if sync_rot(1) = "11" then      -- AB = 11 
          n_st <= s_active;
          left <= '1';
        elsif sync_rot(1) = "01" then   -- AB = 01 
          n_st <= s_idle_right;
        end if;
      when s_idle_right =>
        if sync_rot(1) = "11" then      -- AB = 11 
          n_st  <= s_active;
          right <= '1';
        elsif sync_rot(1) = "10" then   -- AB = 10
          n_st <= s_idle_left;
        end if;
      when s_active =>
        if sync_rot(1) = "00" then      -- AB = 00
          n_st <= s_idle_left;          -- or s_idle_right
        end if;
      when others =>
        n_st <= s_active;               -- handle parasitic states
    end case;
  end process;
  ----------------------------------------------------------------------------- 
  -- FSM memorizing process
  -- # of FFs: 2 (assuming binary state encoding)
  P_fsm_seq : process(rst, clk)
  begin
    if rst = '1' then
      c_st <= s_active;
    elsif rising_edge(clk) then
      c_st <= n_st;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: Accumulating ROT_A/B and PWM_DAC
  -- # of FFs: 8 + N + N = 2*N + 8
  -- NOTE: log2(STP) out of the RES FF of signal dig_in will be optimized away!
  P_acc_dac : process(rst, clk)
  begin
    if rst = '1' then
      led <= (others => '0');
      dig_in <= to_unsigned(0,N);
      ref_cnt <= (others => '0');
    elsif rising_edge(clk) then
      -- Accumulator
      if left = '1' and dig_in > STP-1 then
        dig_in <= dig_in - STP;
      elsif right = '1' and dig_in < 2**N-STP then
        dig_in <= dig_in + STP;
      end if;
      -- PWM-DAC
      ref_cnt <= ref_cnt + 1;                  -- counts modulo 2^N
      led <= (led'left => '1', others => '0'); -- MSB: 100% brightness
      if ref_cnt < dig_in then  
        led <= (others => '1');
      end if;
    end if;
  end process; 
end A;
