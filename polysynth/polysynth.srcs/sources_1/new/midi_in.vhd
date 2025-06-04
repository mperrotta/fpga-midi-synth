
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity midi_in is
    PORT (
    clk_100MHz : IN STD_LOGIC;
    clk31250  :  IN  STD_LOGIC;    
    input_signal: IN STD_LOGIC;  
    o_status_byte : OUT UNSIGNED(7 DOWNTO 0);
    o_data_byte1: OUT UNSIGNED(7 DOWNTO 0);     
    o_data_byte2: OUT UNSIGNED(7 DOWNTO 0);                            
    o_data_rx_signal : OUT STD_LOGIC
    );
    
end midi_in;

architecture Behavioral of midi_in is
    SIGNAL cnt :  integer range 0 to 9 := 0;
    SIGNAL in_sync : boolean := false;
    SIGNAL idle_ticks: integer range 0 to 12 := 0;
    SIGNAL datacur :  UNSIGNED(7 DOWNTO 0) := "00000000";
    SIGNAL status_byte : UNSIGNED(7 DOWNTO 0) := "00000000";
    SIGNAL data_byte1 : UNSIGNED(7 DOWNTO 0) := "00000000"; 
    SIGNAL data_byte2 : UNSIGNED(7 DOWNTO 0) := "00000000"; 
    SIGNAL data_rx_signal : STD_LOGIC := '0';
    SIGNAL started : STD_LOGIC := 'U';
    SIGNAL new_data : boolean := false;
    --SIGNAL stopped : boolean := true;
    SIGNAL cnt_data_bytes_received : integer range 0 to 2 :=0;
  
    constant idle_cycles : integer := 12;
begin

    PROCESS(clk31250)
    BEGIN

        if rising_edge(clk31250) then
        
            -- idle reset
            if input_signal = '1' and idle_ticks < idle_cycles then
                idle_ticks <= idle_ticks + 1;   
                if idle_ticks >= idle_cycles-1 then
                    in_sync <= true;
                    --started <= false;
                    --datacur <= "00000000";
                end if;
            elsif input_signal = '0' then
                idle_ticks <= 0; 
            end if;
            
            if in_sync then
             
                if cnt >= 9 then
                    cnt <= 0;
                else
                    cnt <= cnt + 1;
                end if;
                        
                if input_signal = '0' and started /= '1' then 
                    started <= '1';
                    cnt <= 1;
                    datacur <= "00000000";
                end if;
                    
                if started = '1' then 
                    case cnt is
                        when 0 => null;
                        when 1 => datacur(0) <= input_signal;
                        when 2 => datacur(1) <= input_signal;
                        when 3 => datacur(2) <= input_signal;
                        when 4 => datacur(3) <= input_signal;
                        when 5 => datacur(4) <= input_signal;
                        when 6 => datacur(5) <= input_signal;
                        when 7 => datacur(6) <= input_signal;
                        when 8 => datacur(7) <= input_signal;
                        when 9 => started <= '0';
 
                    end case;
                end if;
               

             end if;
        end if;
    end process;

    --stopped <= not started;
    process(clk_100MHz, started)
    begin
        if rising_edge(clk_100MHz) then
            if data_rx_signal = '1' then
                data_rx_signal <= '0';
            end if;
            
            if started = '0' and new_data then
                if in_sync then
                    new_data <= false;
                    if datacur(7) = '1' then -- status message
                        status_byte <= datacur;
                        data_byte1 <= "00000000";
                        data_byte2 <= "00000000";
                        cnt_data_bytes_received <= 0;
                        data_rx_signal <= '0';
                    else -- data byte
                        cnt_data_bytes_received <= cnt_data_bytes_received + 1;
                        
                        if cnt_data_bytes_received = 0 then
                            data_byte1 <= datacur;
                        elsif cnt_data_bytes_received = 1 then
                            data_byte2 <= datacur;
                        end if;
                         
                        if status_byte >= 16#80# and status_byte <= 16#9F# then -- note on/off
                            if cnt_data_bytes_received = 1 then 
                                data_rx_signal <= '1';
                            end if;
                        elsif status_byte >= 16#A0# and status_byte <= 16#AF# then -- poly after
                            if cnt_data_bytes_received = 1 then 
                                data_rx_signal <= '1';
                            end if;
                        elsif status_byte >= 16#B0# and status_byte <= 16#BF# then -- control/mode change
                            if cnt_data_bytes_received = 1 then 
                                data_rx_signal <= '1';
                            end if;
                        elsif status_byte >= 16#C0# and status_byte <= 16#CF# then -- program change  
                            if cnt_data_bytes_received = 0 then 
                                data_rx_signal <= '1';
                            end if;
                        elsif status_byte >= 16#D0# and status_byte <= 16#DF# then  -- channel after
                            if cnt_data_bytes_received = 0 then 
                                data_rx_signal <= '1';
                            end if;
                        elsif status_byte >= 16#E0# and status_byte <= 16#EF# then  -- pitch bend
                            if cnt_data_bytes_received = 1 then 
                                data_rx_signal <= '1';
                            end if;
                        else
                            data_byte1 <= "11111111";
                            data_byte2 <= "11111111";
                            data_rx_signal <= '1';
                        end if;
                    end if; --if datacur(7) = '1' then -- status message
                end if; -- in_sync
            elsif started = '1' then
                new_data <= true;
            end if; -- if started
        end if;
    end process;
        
    o_data_byte1 <= data_byte1;
    o_data_byte2 <= data_byte2;
    o_status_byte <= status_byte;
    o_data_rx_signal <= data_rx_signal;
    
end Behavioral;
