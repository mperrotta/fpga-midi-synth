
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.common.ALL;

entity midi_decoder is
    PORT (   
    clk_100MHz : IN STD_LOGIC; 
    midi_rx_signal: IN STD_LOGIC;  
    i_status_byte : IN UNSIGNED(7 DOWNTO 0);  
    i_data_byte1: IN UNSIGNED(7 DOWNTO 0);     
    i_data_byte2: IN UNSIGNED(7 DOWNTO 0);      
    o_frequency : OUT UNSIGNED(15 DOWNTO 0);
    o_half_period_clk_cycles : OUT UNSIGNED(23 DOWNTO 0);
    o_midi_cmd : out t_midi_cmd := UNKNOWN
    );
end midi_decoder;

architecture Behavioral of midi_decoder is
    SIGNAL frequency : UNSIGNED(15 DOWNTO 0) := "0000000000000000";
    SIGNAL half_period_clk_cycles : UNSIGNED(23 DOWNTO 0) := "000000000000000000000000";
    type t_midi_to_data  is array (0 to 127) of integer;
    SIGNAL midi_cmd : t_midi_cmd := UNKNOWN;
    signal note_to_half_period_cycles : t_midi_to_data := (6112469,
5773672,
5446623,
5144033,
4854369,
4582951,
4325260,
4081633,
3852080,
3636364,
3431709,
3240441,
3058104,
2886836,
2724796,
2570694,
2427184,
2290426,
2162630,
2040816,
1926040,
1818182,
1715854,
1619695,
1529052,
1443001,
1362027,
1285678,
1213592,
1145475,
1081081,
1020408,
963206,
909091,
858074,
809848,
764409,
721501,
681013,
642839,
606722,
572672,
540541,
510204,
481556,
454545,
429037,
404957,
382234,
360776,
340530,
321419,
303380,
286352,
270270,
255102,
240790,
227273,
214519,
202478,
191110,
180388,
170265,
160705,
151685,
143172,
135139,
127551,
120395,
113636,
107259,
101239,
95557,
90192,
85131,
80354,
75843,
71586,
67568,
63776,
60197,
56818,
53629,
50619,
47778,
45097,
42566,
40176,
37922,
35793,
33784,
31888,
30098,
28409,
26815,
25310,
23889,
22548,
21283,
20088,
18961,
17897,
16892,
15944,
15049,
14205,
13407,
12655,
11945,
11274,
10641,
10044,
9480,
8948,
8446,
7972,
7525,
7102,
6704,
6327,
5972,
5637,
5321,
5022,
4740,
4474,
4223,
3986
);
begin
    process (clk_100MHz, midi_rx_signal)
    begin
        if rising_edge(clk_100MHz) then
            if midi_rx_signal = '1' then
                if i_status_byte >= 16#90# and  i_status_byte <= 16#9F# then 
                    half_period_clk_cycles <= to_unsigned(note_to_half_period_cycles(to_integer(i_data_byte1)), half_period_clk_cycles'length);
                    midi_cmd <= NOTE_ON;
                elsif i_status_byte >= 16#80# and  i_status_byte <= 16#8F# then 
                    midi_cmd <= NOTE_OFF;
                    half_period_clk_cycles <= "000000000000000000000000";
                end if;
             else 
                midi_cmd <= UNKNOWN;
             end if;
        end if;
    end process;

o_frequency <= frequency;
o_midi_cmd <= midi_cmd;
o_half_period_clk_cycles <= half_period_clk_cycles;

end Behavioral;
