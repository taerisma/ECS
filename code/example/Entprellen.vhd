    -----------------------------------------------------------------------------
    -- sequential process: Debouncing and encoding of switch button inputs
    -- # of FFs: 24 + 24 + 3 + 2 = 53
    P4_deb : process(rst, clk)
    begin
        if rst = '1' then
            east_cnt        <= (others => '0');
            west_cnt        <= (others => '0');
            debncd_east     <= '0';
            debncd_east_reg <= '0';
            debncd_west     <= '0';
            debncd_west_reg <= '0';
            btn_rot         <= "00";
        elsif rising_edge(clk) then
            -- Debouncing EAST (blanking) ----------blanken-----------
            if east_cnt = 0 and (sync_east xor debncd_east) = '1' then 
                -- input changed: start blank time counter
                east_cnt    <= east_cnt + 1;
                debncd_east <= sync_east;
            elsif east_cnt > 0 and east_cnt < BLANK_TME then
                -- blank time counter active
                east_cnt <= east_cnt + 1;
            else
                -- end of blank time: reset counter
                east_cnt <= (others => '0');
            end if;
            -- Debouncing WEST (undersampling) -----undersampling------
            if west_cnt < BLANK_TME then          
                west_cnt <= west_cnt + 1;
            else
                -- reset counter and sample input signal
                west_cnt    <= (others => '0');
                debncd_west <= sync_west;
            end if;
            -- encode switch buttons ---------------------------------
            debncd_east_reg <= debncd_east;
            debncd_west_reg <= debncd_west;
            btn_rot <= "00";                  -- no rotation (default)
            if debncd_west = '1' and debncd_west_reg = '0' then
                btn_rot <= "11";                -- rotate left (-1)
            elsif debncd_east = '1'and debncd_east_reg = '0' then
                btn_rot <= "01";                -- rotate right (+1)
            end if;
        end if;
    end process;
