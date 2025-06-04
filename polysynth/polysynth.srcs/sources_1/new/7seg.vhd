library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity seg7decimal is
    PORT (
    clk  :  IN  STD_LOGIC;                         
    x    :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0) ;                           
    seg  :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
    an   :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
    dp   :  OUT  STD_LOGIC
    );
end seg7decimal;

architecture Behavioral of seg7decimal is
    SIGNAL s : unsigned(2 DOWNTO 0) := "000";
    SIGNAL digit : unsigned(3 DOWNTO 0) := "0000";
    SIGNAL aen : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111";
    SIGNAL clkdiv : unsigned(19 DOWNTO 0) := "00000000000000000000"; 
begin
    s <= clkdiv(19 downto 17);
    dp <= '1';
    
    process(clk)
    begin
        if rising_edge(clk) then
            clkdiv <= clkdiv + 1;
        end if;
    end process;
    
    process(clk)
    begin

        if rising_edge(clk) then
            clkdiv <= clkdiv + 1;
            
            case to_integer(s) is
                when 0 => digit <= unsigned(x(3 downto 0));
                when 1 => digit <= unsigned(x(7 downto 4));
                when 2 => digit <= unsigned(x(11 downto 8));
                when 3 => digit <= unsigned(x(15 downto 12));
                when 4 => digit <= unsigned(x(19 downto 16));
                when 5 => digit <= unsigned(x(23 downto 20));
                when 6 => digit <= unsigned(x(27 downto 24));
                when 7 => digit <= unsigned(x(31 downto 28));
                
                when others => digit <= unsigned(x(3 downto 0));
            end case; 
    
        end if;
    end process;

    process(all)
    begin
        an <= "11111111";
        if aen(to_integer(s)) = '1' then 
            an(to_integer(s)) <= '0';
        end if;
    end process;

    process(all)
    begin
        
        case to_integer(digit) is
            when 0 => seg <= "1000000"; -- 0000
            when 1 => seg <= "1111001"; -- 0001
            when 2 => seg <= "0100100"; -- 0010
            when 3 => seg <= "0110000"; -- 0011
            when 4 => seg <= "0011001";
            when 5 => seg <= "0010010";
            when 6 => seg <= "0000010";
            when 7 => seg <= "1111000";
            when 8 => seg <= "0000000"; -- 1000
            when 9 => seg <= "0010000";
            when 16#A# => seg <= "0001000";
            when 16#B# => seg <= "0000011";
            when 16#C# => seg <= "1000110";
            when 16#D# => seg <= "0100001";
            when 16#E# => seg <= "0000110";
            when 16#F# => seg <= "0001110";
            when others => seg <= "0000000";
        end case;
        --case(digit)


--//////////<---MSB-LSB<---
--//////////////gfedcba////////////////////////////////////////////           a
--0:seg = 7'b1000000;////0000												   __					
--1:seg = 7'b1111001;////0001												f/	  /b
--2:seg = 7'b0100100;////0010												  g
--//                                                                       __	
--3:seg = 7'b0110000;////0011										 	 e /   /c
--4:seg = 7'b0011001;////0100										       __
--5:seg = 7'b0010010;////0101                                            d  
--6:seg = 7'b0000010;////0110
--7:seg = 7'b1111000;////0111
--8:seg = 7'b0000000;////1000
--9:seg = 7'b0010000;////1001
--'hA:seg = 7'b0001000; 
--'hB:seg = 7'b0000011; 
--'hC:seg = 7'b1000110;
--'hD:seg = 7'b0100001;
--'hE:seg = 7'b0000110;
--'hF:seg = 7'b0001110;

--default: seg = 7'b0000000; // U

--endcase
    end process;
    

    
end Behavioral;

