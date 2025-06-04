LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY square IS
	PORT (
		clk_100MHz : IN STD_LOGIC; 
		half_period_ticks: IN UNSIGNED (23 DOWNTO 0);
		enable : IN STD_LOGIC;
		--pitchHz : IN UNSIGNED (14 DOWNTO 0); 
	data : OUT SIGNED (23 DOWNTO 0) := "000000000000000000000000");  -- signed square wave out
END square;

-- 12,289,160
-- 48004.53125

architecture Behavioral of square IS
    SIGNAL count : unsigned (23 DOWNTO 0) := "000000000000000000000000"; -- represents current phase of waveform
    SIGNAL current_signal : signed (23 DOWNTO 0) := "000000000000000000000000";
    SIGNAL max_signal : signed (23 DOWNTO 0) := "011111111111111111111111";
    SIGNAL min_signal : signed (23 DOWNTO 0) := "100000000000000000000000";
    SIGNAL min_or_max : STD_LOGIC := '0';
BEGIN

    process(clk_100MHz) 
    begin
        if rising_edge(clk_100MHz) then
            count <= count + 1;
            if count >= half_period_ticks then
                min_or_max <= not min_or_max;
                count <= "000000000000000000000000";
            end if;
                
            if enable = '1' then 
                if min_or_max = '1' then
                    current_signal <= max_signal;
                else
                    current_signal <= min_signal;
                end if;
            else 
                current_signal <= "000000000000000000000000";
            end if;
        end if;
    end process;
    
    data <= current_signal;
END Behavioral;



