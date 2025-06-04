

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity voice_mixer is
	PORT (
		clk_100MHz : IN STD_LOGIC; 
		half_period_ticks: IN UNSIGNED (23 DOWNTO 0);
		midi_cmd : IN t_midi_cmd;
		midi_note_number: IN unsigned (7 downto 0); 
		midi_rx_signal: IN STD_LOGIC; 
	    o_data : OUT SIGNED (23 DOWNTO 0));
end voice_mixer;

architecture Behavioral of voice_mixer is
    COMPONENT square IS
		PORT (
			clk_100MHz : IN STD_LOGIC;
			half_period_ticks: IN UNSIGNED (23 DOWNTO 0);
			enable : IN STD_LOGIC;
			data : OUT SIGNED (23 DOWNTO 0)
		);
	END COMPONENT;
    signal voice_enable : std_logic_vector(7 downto 0) := (others => '0'); 
    type t_voice_to_data  is array (0 to 7) of signed(23 downto  0);
    type t_voice_to_ticks  is array (0 to 7) of UNSIGNED(23 downto  0);
    type t_note_to_voice  is array (0 to 127) of signed(3 downto 0); 
    signal voice_to_data : t_voice_to_data := (others => "000000000000000000000000"); 
    signal voice_to_half_period_ticks : t_voice_to_ticks := (others => "000000000000000000000000"); 
    signal note_to_voice: t_note_to_voice := (others => "1111");
    signal themix : SIGNED(25 downto 0) := "00000000000000000000000000";
begin
    voice0: square 
	PORT MAP(
		clk_100MHz => clk_100MHz, 
		half_period_ticks => voice_to_half_period_ticks(0),
		enable => voice_enable(0),
		data => voice_to_data(0)
		);
		
	voice1: square 
	PORT MAP(
		clk_100MHz => clk_100MHz, 
		half_period_ticks => voice_to_half_period_ticks(1),
		enable => voice_enable(1),
		data => voice_to_data(1)
		);
		
    voice2: square 
	PORT MAP(
		clk_100MHz => clk_100MHz, 
		half_period_ticks => voice_to_half_period_ticks(2),
		enable => voice_enable(2),
		data => voice_to_data(2)
		);
		
	voice3: square 
	PORT MAP(
		clk_100MHz => clk_100MHz, 
		half_period_ticks => voice_to_half_period_ticks(3),
		enable => voice_enable(3),
		data => voice_to_data(3)
		);
		
	voice4: square 
	PORT MAP(
		clk_100MHz => clk_100MHz, 
		half_period_ticks => voice_to_half_period_ticks(4),
		enable => voice_enable(4),
		data => voice_to_data(4)
		);
		
	voice5: square 
	PORT MAP(
		clk_100MHz => clk_100MHz, 
		half_period_ticks => voice_to_half_period_ticks(5),
		enable => voice_enable(5),
		data => voice_to_data(5)
		);
		
	voice6: square 
	PORT MAP(
		clk_100MHz => clk_100MHz, 
		half_period_ticks => voice_to_half_period_ticks(6),
		enable => voice_enable(6),
		data => voice_to_data(6)
		);
		
	voice7: square 
	PORT MAP(
		clk_100MHz => clk_100MHz, 
		half_period_ticks => voice_to_half_period_ticks(7),
		enable => voice_enable(7),
		data => voice_to_data(7)
		);
		
	process(clk_100MHz, midi_cmd)
	begin
	   if rising_edge(clk_100MHz) then
          -- if midi_cmd'event then
               case midi_cmd is
                   when UNKNOWN => null;
                   when NOTE_ON => 
                       if note_to_voice(to_integer(midi_note_number)) = -1 then
                           if voice_enable(0) = '0' then
                               voice_enable(0) <= '1';
                               voice_to_half_period_ticks(0) <= half_period_ticks;
                               note_to_voice(to_integer(midi_note_number)) <= "0000";
                           elsif  voice_enable(1) = '0' then
                               voice_enable(1) <= '1';
                               voice_to_half_period_ticks(1) <= half_period_ticks;
                               note_to_voice(to_integer(midi_note_number)) <= "0001";
                           elsif  voice_enable(2) = '0' then
                               voice_enable(2) <= '1';
                               voice_to_half_period_ticks(2) <= half_period_ticks;
                               note_to_voice(to_integer(midi_note_number)) <= "0010";
                           elsif  voice_enable(3) = '0' then
                               voice_enable(3) <= '1';
                               voice_to_half_period_ticks(3) <= half_period_ticks;
                               note_to_voice(to_integer(midi_note_number)) <= "0011";
                           elsif  voice_enable(4) = '0' then
                               voice_enable(4) <= '1';
                               voice_to_half_period_ticks(4) <= half_period_ticks;
                               note_to_voice(to_integer(midi_note_number)) <= "0100";
                           elsif  voice_enable(5) = '0' then
                               voice_enable(5) <= '1';
                               voice_to_half_period_ticks(5) <= half_period_ticks;
                               note_to_voice(to_integer(midi_note_number)) <= "0101";
                           elsif  voice_enable(6) = '0' then
                               voice_enable(6) <= '1';
                               voice_to_half_period_ticks(6) <= half_period_ticks;
                               note_to_voice(to_integer(midi_note_number)) <= "0110";
                           elsif  voice_enable(7) = '0' then
                               voice_enable(7) <= '1';
                               voice_to_half_period_ticks(7) <= half_period_ticks;
                               note_to_voice(to_integer(midi_note_number)) <= "0111";
                           end if;
                       end if;
                   when NOTE_OFF => 
                        if note_to_voice(to_integer(midi_note_number)) /= -1 then
                           voice_enable(to_integer(note_to_voice(to_integer(midi_note_number)))) <= '0';
                           note_to_voice(to_integer(midi_note_number)) <= "1111";
                        end if;                     
               end case;
          -- end if;
       end if;
	end process;

    process (voice_to_data(0), voice_to_data(1), voice_to_data(3), voice_to_data(4), voice_to_data(5),
             voice_to_data(6), voice_to_data(7))
    begin
--        themix <= ("00" & voice_to_data(0)) + ("00" & voice_to_data(1)) + ("00" & voice_to_data(2)) + ("00" & voice_to_data(3)) + ("00" & voice_to_data(4)) 
--            + ("00" & voice_to_data(5)) + ("00" & voice_to_data(6)) + ("00" & voice_to_data(7));    
           themix <= resize(voice_to_data(0), themix'length) + resize(voice_to_data(1), themix'length) + resize(voice_to_data(2), themix'length)
                + resize(voice_to_data(3), themix'length) + resize(voice_to_data(4), themix'length) + resize(voice_to_data(5), themix'length) 
                + resize(voice_to_data(6), themix'length) +  resize(voice_to_data(7), themix'length);
    end process;
    
    o_data <= themix(25 downto 2);
end Behavioral;
