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

---
### Modulo 2^14 Counter [Frequency divider]
At this logic element the most effort was spent cause it could be implemented on several ways.
It is needed to reduce the input clock frequency from 50MHz to 3kHz.

First it was implemented as a linear incremented modulo counter like seen below:

    p1: PROCESS (rst, clk) IS
        BEGIN
            IF rst=RSTDEF THEN
                cnt     <= 0;
                strb    <= '0';
            ELSIF rising_edge(clk) THEN
                strb <= '0';
                IF cnt=N-1 THEN
                    cnt  <= 0;
                    strb <= '1';
                ELSE
                    cnt <= cnt + 1;
                END IF;
            END IF;
    END PROCESS p1;
    
  The seen code works fine but needs a lot of logic cells cause the order of the counter is linear incremented with "i + 1".
  To reduce the amount of logic cells and because the counting order does not matter here it was reimplemented as a modulo counter with a so called LSFR (Linear Feedback Shift Register) that is realized with a shift register and XOR gates. As a generator polynomial a primitive polynomial of degree 14 was chosen. The primitive polynomial is a polynomial of degree 14 with coefficients 1 and 0, which has 2^14 - 1 distinct roots in the field of 2 elements. The polynomial used was: 
  
      x^14 + x^8 + x^6 + x^1 + 1
  
  The new implementation is shown below:
  
      p1: PROCESS (rst, clk) IS
      BEGIN
          IF rst=RSTDEF THEN
              strb    <= '0';
              reg     <= (OTHERS => '1');
          ELSIF rising_edge(clk) THEN
              
              strb <= '0';
              
              -- If the counter reaches the final value, the enable signal is set
              -- for one clock cycle transforming the clk into a 3kHz signal
              IF reg=RES THEN
                  strb <= '1';                    
              END IF;
         
              reg(13 DOWNTO 9)    <= reg(12 DOWNTO 8);
              reg(8)              <= reg(7) XOR reg(13);
              reg(7)              <= reg(6);
              reg(6)              <= reg(5) XOR reg(13);
              reg(5 DOWNTO 2)     <= reg(4 DOWNTO 1);
              reg(1)              <= reg(0) XOR reg(13);
              reg(0)              <= reg(13);
              
          END IF;
      END PROCESS;

  It is recommended, that the counter should count every clock cycle, therefore the polynomial definition must not be in the else case! 
  Also it should not be reset to a fix value cause we do not now the next value of the counter when he reaches the final count (probably not 
  "0000000000000" cause it counts like the counter above with i + 1).
  
  With this implementation the counter needs only the following amount of recourses:
  
      4LUT:        27
      Est. Freq:   489,3 MHz
      
  Further i tested several other polynomials but they would not "fits" better or even be worse. Further tested polynomials:
    
    -- Polynom: x^14 + x^10 + x^6 + x^1 + 1 --------------------------------
       reg(13 DOWNTO 11)   <= reg(12 DOWNTO 10);
       reg(10)             <= reg(9) XOR reg(13);
       reg(9 DOWNTO 7)     <= reg(8 DOWNTO 6);
       reg(6)              <= reg(5) XOR reg(13);
       reg(5 DOWNTO 2)     <= reg(4 DOWNTO 1);
       reg(1)              <= reg(0) XOR reg(13);
       reg(0)              <= reg(13);
  <br>
  
    -- Polynom: x^14 + x^11 + x^9 + x^6 + x^5 + x^2 + 1 --------------------
       reg(13 DOWNTO 12)   <= reg(12 DOWNTO 11);
       reg(11)             <= reg(10) XOR reg(13);
       reg(10 DOWNTO 10)   <= reg(9 DOWNTO 9);
       reg(9)              <= reg(8) XOR reg(13);
       reg(8 DOWNTO 7)     <= reg(7 DOWNTO 6);
       reg(6)              <= reg(5) XOR reg(13);
       reg(5)              <= reg(4) XOR reg(13);
       reg(4 DOWNTO 3)     <= reg(3 DOWNTO 2);
       reg(2)              <= reg(1) XOR reg(13);
       reg(1)              <= reg(0) XOR reg(13);
       reg(0)              <= reg(13);
---
## Modulo 4 counter
This modulo counter is later used to select which digit of the 4-digit seven segment display is 
currently active. It generates the select signal for all other components seen on the circuit diagram above.
Because the counting order is relevant here it is a linear counter. The counter is reset by the reset signal

    p2: PROCESS (rst, clk) IS 
        BEGIN
        
            IF rst=RSTDEF THEN
                sel <= "00";                                --    reset mod4 output signal
    
            ELSIF rising_edge(clk) THEN
                IF sel="11" THEN                            --    reset mod4 output signal
                    IF strb='1' THEN                        --    wait till strb is one to reset
                        sel <= "00";
                    END IF;
                ELSE
                    sel <= sel + strb;                      --    add srb{01,10,11}
                END IF;
            END IF;
    
        END PROCESS;

---
## 1 from 4 dekoder [Phase-Generator]
This decoder sets the enable signal for the active segment. It is titled as "cc" in 
the circuit diagram above. Because the segments should turn off when holding the 
reset button, it is compared to the reset signal and output as the "ena" signal.

    WITH sel SELECT
            cc <=   "0001" WHEN "00",
                    "0010" WHEN "01",
                    "0100" WHEN "10",
                    "1000" WHEN "11",
                    "1111" WHEN OTHERS;
                    
            ena <= cc   WHEN rst/=RSTDEF
                        ELSE (OTHERS => '0');
                    
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
