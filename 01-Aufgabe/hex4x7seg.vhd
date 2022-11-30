
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY hex4x7seg IS
   GENERIC(RSTDEF: std_logic := '0');
   PORT(rst:   IN  std_logic;                                                   -- reset,                                   active RSTDEF
        clk:   IN  std_logic;                                                   -- clock,                                   rising edge
        data:  IN  std_logic_vector(15 DOWNTO 0);                               -- data input,                              active high
        dpin:  IN  std_logic_vector( 3 DOWNTO 0);                               -- 4 decimal point,                         active high
        ena:   OUT std_logic_vector( 3 DOWNTO 0);                               -- 4 digit enable  signals,                 active high
        seg:   OUT std_logic_vector( 7 DOWNTO 1);                               -- 7 connections to seven-segment display,  active high
        dp:    OUT std_logic);                                                  -- decimal point output,                    active high
END hex4x7seg;

ARCHITECTURE struktur OF hex4x7seg IS
    
    -- Definition of used signals and constants

    CONSTANT RES:   std_logic_vector := "11111111111111";                       -- mod (2^14 - 1)
    SIGNAL   reg:   std_logic_vector(13 DOWNTO 0);                              -- mod 2^14 Counter (Polynom: x^14 + x^8 + x^6 + x^1 + 1)
    
    SIGNAL strb:    std_logic;                                                  -- enable signal for mod4 counter
    
    SIGNAL sel:     std_logic_vector(1 DOWNTO 0);                               -- mod 4 counter output (select signal)

    SIGNAL cc:      std_logic_vector(3 DOWNTO 0);
    
    SIGNAL seg_sel: std_logic_vector(3 DOWNTO 0);

BEGIN
    -- Modulo-2^14-Counter -----------------------------------------------------
    -- Reduce input frequence from 50MHz to 3kHz and generate periocal enable 
    -- signals for the Modulo-4 counter (in 328 us)
    -- >>> Implemented like seen in lecture 1, slide 25 <<<
    ----------------------------------------------------------------------------
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
            
            -- Counter should count every clock cycle, therefore the polynomial 
            -- definition must not be in the else case! Also it should not be 
            -- reset to a fix value cause we do not now the next value of the 
            -- counter when he reaches the final count (probably not 
            -- "0000000000000" cause it counts not lineal
            
            -- Polynom: x^14 + x^8 + x^6 + x^1 + 1 -----------------------------                
            reg(13 DOWNTO 9)    <= reg(12 DOWNTO 8);
            reg(8)              <= reg(7) XOR reg(13);
            reg(7)              <= reg(6);
            reg(6)              <= reg(5) XOR reg(13);
            reg(5 DOWNTO 2)     <= reg(4 DOWNTO 1);
            reg(1)              <= reg(0) XOR reg(13);
            reg(0)              <= reg(13);
            
        END IF;
    END PROCESS;
    
   
    -- Modulo-4-Counter --------------------------------------------------------
    -- clk also needed (see block diagramm)
    -- >>> Implemented like seen in lecture 3, slide 62 <<<
    ----------------------------------------------------------------------------
    p2: PROCESS (rst, clk) IS 
    BEGIN
    
        IF rst=RSTDEF THEN
            sel <= "00";                                                        -- reset mod4 output signal

        ELSIF rising_edge(clk) THEN
            IF sel="11" THEN                                                    -- reset mod4 output signal
                IF strb='1' THEN                                                -- wait till strb is one to reset
                    sel <= "00";
                END IF;
            ELSE
                sel <= sel + strb;                                              -- add srb{01,10,11}
            END IF;
        END IF;

    END PROCESS;
    

    -- 1-aus-4-Dekoder als Phasengenerator -------------------------------------
    -- >>> Implemented like seen in lecture 2, slide 52 <<<
    ----------------------------------------------------------------------------
    WITH sel SELECT
        cc <=   "0001" WHEN "00",
                "0010" WHEN "01",
                "0100" WHEN "10",
                "1000" WHEN "11",
                "1111" WHEN OTHERS;
        ena <= cc   WHEN rst/=RSTDEF
                    ELSE (OTHERS => '0');
    
       
    -- 1-aus-4-Multiplexer (for decimal points) --------------------------------
    -- >>> Implemented like seen in lecture 2, slide 51 <<<
    ----------------------------------------------------------------------------
    WITH sel SELECT
        dp <=   dpin(0) WHEN "00",
                dpin(1) WHEN "01",
                dpin(2) WHEN "10",
                dpin(3) WHEN OTHERS;


    -- 1-aus-4-Bit-Multiplexer -------------------------------------------------
    -- >>> Implemented like seen in lecture 2, slide 51 <<<
    ----------------------------------------------------------------------------
    WITH sel SELECT
		seg_sel <=  data( 3 downto 0 ) when "00",                               -- right display
                    data( 7 downto 4 ) when "01",                               -- sec. from right
                    data(11 downto 8 ) when "10",                               -- sec. from left
                    data(15 downto 12) when others;                             -- left display
        

    -- 7-aus-4-Dekoder ---------------------------------------------------------
    -- >>> Implemented like seen in lecture 2, slide 52 <<<
    ----------------------------------------------------------------------------
    WITH seg_sel SELECT
        seg <=  "0111111" WHEN "0000",                                          -- 0
                "0000110" WHEN "0001",                                          -- 1
                "1011011" WHEN "0010",                                          -- 2
                "1001111" WHEN "0011",                                          -- 3
                "1100110" WHEN "0100",                                          -- 4
                "1101101" WHEN "0101",                                          -- 5
                "1111101" WHEN "0110",                                          -- 6
                "0000111" WHEN "0111",                                          -- 7
                "1111111" WHEN "1000",                                          -- 8
                "1101111" WHEN "1001",                                          -- 9
                "1110111" WHEN "1010",                                          -- A
                "1111100" WHEN "1011",                                          -- B
                "0111001" WHEN "1100",                                          -- C
                "1011110" WHEN "1101",                                          -- D
                "1111001" WHEN "1110",                                          -- E
                "1110001" WHEN "1111",                                          -- F
                "0000000" WHEN OTHERS;                                          -- default    

END struktur;