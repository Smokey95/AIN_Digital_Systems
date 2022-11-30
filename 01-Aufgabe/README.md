# BCD Transcoder

In this excise you have to implement a four-digit BCD-Counter to display on a four-digit seven segment display.
The interface of the seven segment display is given as following:
  
    ENTITY hex4x7seg IS
      GENERIC(RSTDEF: std_logic := '0');
        PORT(rst:   IN  std_logic;                       -- reset
             clk:   IN  std_logic;                       -- clock (rising edge)
             data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input
             dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point
             cc:    OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable signals
            dp:    OUT std_logic;                       -- 1 decimal point output
            seg:   OUT std_logic_vector( 7 DOWNTO 1));  -- 7 connections to display
    END hex4x7seg;
    
-> All files can be removed only the 3 vhd, the one pdc and the work and xwork directory are needed    

---
## 1 from 4 dekoder [phase generator]
This decoder sets the enable 

---
## 1 from 4 multiplexer [Dot Select]
This multiplexer is used to select which decimal dot is displayed when the associated switch is pressed

    WITH sel SELECT
        dp <=   dpin(0) WHEN "00",                          -- dot right display
                dpin(1) WHEN "01",                          -- dot second display from right  
                dpin(2) WHEN "10",                          -- select second display from left
                dpin(3) WHEN OTHERS;                        -- select left display

---
## 1 from 4 multiplexer [Segment Select]
This logic-element multiplexes the signal needed to select the current 7-segment-display. As the input clock (clk) frequenz (50 MHz) is transferred down to 3kHz the supplied segement is switched every 0.33ms (therefore each segment will be supplied with current for 0.33ms every 1.32ms). This multiplexer was implemented like seen below:

    WITH sel SELECT
		    seg_sel <=  data( 3 downto 0 ) when "00",   -- select right display
                    data( 7 downto 4 ) when "01",           -- select second display from right
                    data(11 downto 8 ) when "10",           -- select second display from left
                    data(15 downto 12) when others;         -- select left display

---    
## 7 from 4 decocder
This logic-element decodes the 4 digit binary number into a 7 bit binary number to drive the 7 segment display. It was implemented like seen below:
    
    WITH seg_sel SELECT
        seg <=  "0111111" WHEN "0000",          	        -- 0
                "0000110" WHEN "0001",          	        -- 1
                "1011011" WHEN "0010",          	        -- 2
                "1001111" WHEN "0011",          	        -- 3
                "1100110" WHEN "0100",          	        -- 4
                "1101101" WHEN "0101",          	        -- 5
                "1111101" WHEN "0110",          	        -- 6
                "0000111" WHEN "0111",          	        -- 7
                "1111111" WHEN "1000",          	        -- 8
                "1101111" WHEN "1001",          	        -- 9
                "1110111" WHEN "1010",          	        -- A
                "1111100" WHEN "1011",          	        -- B
                "0111001" WHEN "1100",          	        -- C
                "1011110" WHEN "1101",          	        -- D
                "1111001" WHEN "1110",          	        -- E
                "1110001" WHEN "1111",          	        -- F
                "0000000" WHEN OTHERS;          	        -- default
