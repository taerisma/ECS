-- Moore FSM
-- 3 Zustände also 2 FF also 1 parasitärer Zustand

type state is (S0, S1, S2);
signal c_st, n_st : state;

-- sequenzieller Prozess
-- macht 3 FF
-- wenn rst high dann geht die FSM in den S0
p_seq: process (rst, clk)
begin
  if rst = '1' then
    c_st <= S0;
  elsif rising_edge(clk) then
    c_st <= n_st;
  end if;
end process;

-- kombinatorischer Prozess keine FF
p_com: process (i, c_st)
begin
  -- default assignments
  n_st <= c_st; -- remain in current state
  o    <= '1';  -- most frequent value

  case c_st is
    when S0 =>
      if i = "00" then n_st <= S1;
      end if;
    when S1 =>
      if    i = "00" then n_st <= S2;
      elsif i = "10" then n_st <= S0;
      end if;
      o <= '0'; -- uncondit. output assignment
    when S2 =>
      if    i = "10" then n_st <= S0;
      elsif i = "11" then n_st <= S1;
      end if;
    when others =>
      n_st <= S0; -- handle parasitic states
  end case;
end process;