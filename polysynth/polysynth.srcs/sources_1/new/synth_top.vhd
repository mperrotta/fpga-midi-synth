
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.common.ALL;

entity synth_top is
    PORT(
    clk_100MHz : IN STD_LOGIC;
    midi_data_bit  : IN STD_LOGIC;
    SEG        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    AN         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  
    DP         : OUT STD_LOGIC;
    dac_MCLK : OUT STD_LOGIC; -- outputs to PMODI2L DAC
	dac_LRCK : OUT STD_LOGIC;
	dac_SCLK : OUT STD_LOGIC;
	dac_SDIN : OUT STD_LOGIC;
    o_clk31250 : OUT STD_LOGIC
    );
end synth_top;

architecture Behavioral of synth_top is
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
                clk_100MHz : IN STD_LOGIC;
                clk31250  :  IN  STD_LOGIC;    
                input_signal: IN STD_LOGIC;  
                o_status_byte : OUT UNSIGNED(7 DOWNTO 0);
                o_data_byte1: OUT UNSIGNED(7 DOWNTO 0);     
                o_data_byte2: OUT UNSIGNED(7 DOWNTO 0);                            
                o_data_rx_signal : OUT STD_LOGIC
                );
    END COMPONENT;
    
    COMPONENT midi_decoder IS
            PORT (   
            clk_100MHz : IN STD_LOGIC;
            midi_rx_signal: IN STD_LOGIC;  
            i_status_byte : IN UNSIGNED(7 DOWNTO 0);  
            i_data_byte1: IN UNSIGNED(7 DOWNTO 0);     
            i_data_byte2: IN UNSIGNED(7 DOWNTO 0);      
            o_frequency : OUT UNSIGNED(15 DOWNTO 0);
            o_half_period_clk_cycles :  OUT UNSIGNED(23 DOWNTO 0);
            o_midi_cmd : out t_midi_cmd
            );
     END COMPONENT;
        
     COMPONENT clk_12_28mhz
        PORT(
            clk_in1     :  IN STD_LOGIC  := '0';
            clk_out1    :  OUT STD_LOGIC);
    END COMPONENT;
--	COMPONENT square IS
--		PORT (
--			clk_100MHz : IN STD_LOGIC;
--			half_period_ticks: IN UNSIGNED (23 DOWNTO 0);
--			enable : IN STD_LOGIC;
--			data : OUT SIGNED (23 DOWNTO 0)
--		);
--	END COMPONENT;
	COMPONENT voice_mixer
	PORT  (clk_100MHz : IN STD_LOGIC; 
           half_period_ticks: IN UNSIGNED (23 DOWNTO 0);
           midi_cmd : IN t_midi_cmd;
           midi_note_number: IN unsigned (7 downto 0); 
           midi_rx_signal: IN STD_LOGIC;
           o_data : OUT SIGNED (23 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT i2s_transceiver IS
	        GENERIC(
            mclk_sclk_ratio :  INTEGER := 4;    --number of mclk periods per sclk period
            sclk_ws_ratio   :  INTEGER := 64;   --number of sclk periods per word select period
            d_width         :  INTEGER := 24);  --data width
		PORT (
            reset_n    :  IN   STD_LOGIC;                             --asynchronous active low reset
            mclk       :  IN   STD_LOGIC;                             --master clock
            sclk       :  OUT  STD_LOGIC;                             --serial clock (or bit clock)
            ws         :  OUT  STD_LOGIC;                             --word select (or left-right clock)
            sd_tx      :  OUT  STD_LOGIC;                             --serial data transmit
            sd_rx      :  IN   STD_LOGIC;                             --serial data receive
            l_data_tx  :  IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --left channel data to transmit
            r_data_tx  :  IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --right channel data to transmit
            l_data_rx  :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --left channel data received
            r_data_rx  :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)); --right channel data received
	END COMPONENT;

    signal lrck, sclk, mclk, sdin, reset_n: STD_LOGIC;
	SIGNAL audio_data:  SIGNED (23 DOWNTO 0);
        
    SIGNAL clk31250 : STD_LOGIC := '0';
    SIGNAL midi_status, midi_data1, midi_data2 : UNSIGNED(7 DOWNTO 0)  := (others => '0'); 
    SIGNAL cnt_31250 : integer range 0 to 16000 := 0;
    SIGNAL half_period_clk_cycles : UNSIGNED(23 DOWNTO 0) := (others => '0'); 
    SIGNAL midi_signal : STD_LOGIC := '0';
    SIGNAL midi_bytes : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0'); 
    SIGNAL square_enable : STD_LOGIC := '0';
    SIGNAL midi_cmd : t_midi_cmd := UNKNOWN;
begin


    reset_n <= '1';
	
	i2s_clock: clk_12_28mhz
    PORT MAP(clk_in1 => clk_100MHz, clk_out1 => mclk);
    
    dac: i2s_transceiver PORT MAP(
		sclk => sclk, -- instantiate parallel to serial DAC interface
		mclk => mclk,
		ws => lrck,
		sd_tx => sdin,
		sd_rx => '0',
		l_data_tx => std_logic_vector(audio_data),
		r_data_tx => std_logic_vector(audio_data),
		reset_n => reset_n
		);
	
--	tgen : square
--	PORT MAP(
--		clk_100MHz => clk_100MHz, 
--		half_period_ticks => half_period_clk_cycles,
--		enable => square_enable,
--		data => audio_data
--		);
		
		
	voices : voice_mixer
	PORT MAP(
		clk_100MHz => clk_100MHz, 
		half_period_ticks => half_period_clk_cycles,
		midi_cmd => midi_cmd,
		midi_note_number => midi_data1,
		midi_rx_signal => midi_signal, 
		o_data => audio_data
		);


	dac_MCLK <= mclk;
	dac_LRCK <= lrck;
	dac_SCLK <= sclk;
	dac_SDIN <= sdin;
	
	sevenseg: seg7decimal PORT MAP(
     clk => clk_100MHz,
     x => midi_bytes, 
     seg => SEG,
     an => AN,
     dp => DP
    );
    
    midiin: midi_in PORT MAP(
        clk_100MHz => clk_100MHz,
        clk31250 => clk31250,
        input_signal => midi_data_bit,
        o_status_byte => midi_status,
        o_data_byte1 => midi_data1,
        o_data_byte2 => midi_data2,
        o_data_rx_signal => midi_signal
    );
    
    mididecoder : midi_decoder PORT MAP(
        clk_100MHz => clk_100MHz,
        midi_rx_signal => midi_signal,
        i_status_byte =>  midi_status,  
        i_data_byte1 => midi_data1,     
        i_data_byte2 => midi_data2,      
        o_frequency => open,
        o_half_period_clk_cycles => half_period_clk_cycles,
        o_midi_cmd => midi_cmd
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
    
    process(clk_100MHz, midi_signal)
    begin
        if rising_edge(clk_100MHz) then
            if midi_signal = '1' then
                midi_bytes(23 downto 16) <= std_logic_vector(midi_status);
                midi_bytes(15 downto 8) <= std_logic_vector(midi_data1);
                midi_bytes(7 downto 0) <= std_logic_vector(midi_data2);
            end if;
        end if;
    end process;
    
end Behavioral;
