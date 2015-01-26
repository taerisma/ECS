--  in einer Architecture
--  FSM hat drei Zustände es werden 2 FF benötigt
--  1 Zustand ist parasitär und muss abgefangen werden

type state is (S0, S1, S2);
signal c_st, n_st : state;

--  Sequenzieller Prozess
--  Prozess macht FF
p_seq: process (rst, clk)
begin
    if rst = '1' then
        c_st <= S0; -- bei erst wird in den S0 gegangen
    elsif rising_edge(clk) then
        c_st <= n_st;
    end if;
end process;

--  kombinatorischer Prozess
--  macht keine FF
p_com: process (i, c_st)
begin
--  default assignments
    n_st <= c_st; -- remain in current state
    o    <= '1';  --  default Ausgangszuweisung
--  specific assignments
    case c_st is
          when S0 =>
          if    i = "00" then n_st <= S1; o <= '0';
          end if;
      when S1 =>
          if    i = "00" then n_st <= S2; o <= '1';
          elsif i = "10" then n_st <= S0; o <= '1';
          end if;
      when S2 =>
          if    i = "00" then n_st <= S2; o <= '1';
          elsif i = "10" then n_st <= S0; o <= '0';
          elsif i = "11" then n_st <= S1; o <= '1';
          end if;
      when others =>
          n_st <= S0; -- für die parasitären Zustände
    end case;
end process;
