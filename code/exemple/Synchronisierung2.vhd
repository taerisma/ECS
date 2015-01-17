--Synchronisierung von asynchronen Signalen
--Zwei FF in serie
process(rst, clk)
begin
	if rst = ’1’then
		sync <= "00";
	elsif rising_edge(clk) then
		sync(0) <= async;
		sync(1) <= sync(0);
	end if;
end process; 
--********************
--Synchronisierung mit Flankendetektion
--enb ist ein Singal
enb <= sync(1)and not sync(2);
process(rst, clk)
	begin
		if rst = ’1’ then
			sync <= "000";
		elsif rising_edge(clk) then
			sync(0) <= async;
			sync(1) <= sync(0);
			sync(2) <= sync(1);
		end if;
end process;