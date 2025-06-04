
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity test_midi is
PORT(
clk_100MHz : IN STD_LOGIC;
midi_data_bit  : IN STD_LOGIC;
SEG        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
AN         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  
DP         : OUT STD_LOGIC;
o_clk31250 : OUT STD_LOGIC
);
end test_midi;

architecture Behavioral of test_midi is
	COMPONENT seg7decimal IS
        PORT (
        clk  :  IN  STD_LOGIC;                         
        x    :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0) ;                           
        seg  :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
        an   :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);  
        dp   :  OUT  STD_LOGIC 
        );
	END COMPONENT;
	
	COMPONENT midi_in IS
             PORT (
                clk31250  :  IN  STD_LOGIC;    
                input_signal: IN STD_LOGIC;  
                o_status_byte : OUT UNSIGNED(7 DOWNTO 0);
                o_data_byte1: OUT UNSIGNED(7 DOWNTO 0);     
                o_data_byte2: OUT UNSIGNED(7 DOWNTO 0);                            
                o_data_rx_signal : OUT STD_LOGIC
                );
    END COMPONENT;
        
    SIGNAL clk31250 : STD_LOGIC := '0';
    SIGNAL midi_status, midi_data1, midi_data2 : UNSIGNED(7 DOWNTO 0)  := (others => '0'); 
    SIGNAL cnt_31250 : integer range 0 to 16000 := 0;
    SIGNAL midi_signal : STD_LOGIC := '0';
    SIGNAL midi_bytes : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0'); 
begin
    
    sevenseg: seg7decimal PORT MAP(
     clk => clk_100MHz,
     x => midi_bytes, 
     seg => SEG,
     an => AN,
     dp => DP
    );
    
    midiin: midi_in PORT MAP(
        clk31250 => clk31250,
        input_signal => midi_data_bit,
        o_status_byte => midi_status,
        o_data_byte1 => midi_data1,
        o_data_byte2 => midi_data2,
        o_data_rx_signal => midi_signal
    );

    process(clk_100MHz)
    begin
        if rising_edge(clk_100MHz) then
            if cnt_31250 >= 1599 then
                cnt_31250 <= 0;
                clk31250 <= not clk31250;
            else 
                cnt_31250 <= cnt_31250 + 1;
            end if;
        end if;
    end process;

    o_clk31250 <= clk31250;
    process(midi_signal)--midi_signal)
    begin
        if rising_edge(midi_signal) then
            midi_bytes(23 downto 16) <= std_logic_vector(midi_status);
            midi_bytes(15 downto 8) <= std_logic_vector(midi_data1);
            midi_bytes(7 downto 0) <= std_logic_vector(midi_data2);
        end if;
    end process;
end Behavioral;


