
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY std_counter IS
   GENERIC(RSTDEF: std_logic := '1';
           CNTLEN: natural   := 4);
   PORT(rst:   IN  std_logic;  -- reset,           RSTDEF active
        clk:   IN  std_logic;  -- clock,           rising edge
        en:    IN  std_logic;  -- enable,          high active
        inc:   IN  std_logic;  -- increment,       high active
        dec:   IN  std_logic;  -- decrement,       high active
        load:  IN  std_logic;  -- load value,      high active
        swrst: IN  std_logic;  -- software reset,  RSTDEF active
        cout:  OUT std_logic;  -- carry,           high active        
        din:   IN  std_logic_vector(CNTLEN-1 DOWNTO 0);
        dout:  OUT std_logic_vector(CNTLEN-1 DOWNTO 0));
END std_counter;

--
-- Funktionstabelle
-- rst clk swrst en  load dec inc | Aktion
----------------------------------+-------------------------
--  V   -    -    -    -   -   -  | cnt := 000..0, asynchrones Reset
--  N   r    V    -    -   -   -  | cnt := 000..0, synchrones  Reset
--  N   r    N    0    -   -   -  | keine Aenderung
--  N   r    N    1    1   -   -  | cnt := din, paralleles Laden
--  N   r    N    1    0   1   -  | cnt := cnt - 1, dekrementieren
--  N   r    N    1    0   0   1  | cnt := cnt + 1, inkrementieren
--  N   r    N    1    0   0   0  | keine Aenderung
--
-- Legende:
-- V = valid, = RSTDEF
-- N = not valid, = NOT RSTDEF
-- r = rising egde
-- din = Dateneingang des Zaehlers
-- cnt = Wert des Zaehlers
--


-- --------------------------------------------------------- First version
--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity std_counter implementiert werden
--
ARCHITECTURE verhalten OF std_counter IS

    -- Defines a vector with one bit more than the counter length to detect an overflow
    SIGNAL cnt: STD_LOGIC_VECTOR(CNTLEN DOWNTO 0);
    -- SIGNAL cntOld: STD_LOGIC_VECTOR(CNTLEN DOWNTO 0);
    
    -- SIGNAL cntOnes: STD_LOGIC_VECTOR(CNTLEN DOWNTO 0) := (OTHERS => '1'); 
    -- cntOnes <= (OTHERS => '1');
    
    -- SIGNAL cntZero: STD_LOGIC_VECTOR(CNTLEN DOWNTO 0) := (OTHERS => '0');
    -- cntZero <= (OTHERS => '0');
    
    --SIGNAL overflow: STD_LOGIC;

BEGIN

-- The funktions defined in the Funktionstabelle must be implemented
-- Test how to save logic gates and how to save the number of flip-flops

        p1: PROCESS(clk, rst) is
        BEGIN
            IF rst=RSTDEF THEN
                cnt <= (OTHERS => '0');
            ELSIF rising_edge(clk) THEN
                
                IF en='1' THEN
                    
                    IF load='1' THEN

                        cnt(CNTLEN) <= '0';                 -- clear HSB (overflow bit)  
                        cnt(CNTLEN-1 DOWNTO 0) <= din;
                        
                    ELSIF dec='1' THEN
                        
                        cnt <= ('0' & cnt(CNTLEN - 1 DOWNTO 0)) - 1;
                        
                    ELSIF inc='1' THEN

                        cnt <= ('0' & cnt(CNTLEN - 1 DOWNTO 0)) + 1;
                        
                    END IF;
                
                END IF;
                
                IF swrst=RSTDEF THEN
                    cnt <= (OTHERS => '0');
                END IF;
            
            END IF;
        
        END PROCESS p1;
        
        -- Not with extra overflow flip flop (see figure on paper)
        cout <= cnt(CNTLEN);                                -- Return the value of the overflow
        dout <= cnt(CNTLEN-1 DOWNTO 0);                     -- Return the value of the CNTLEN counter bits
        
        
END verhalten;

-- --------------------------------------------------------- Seccond version
--ARCHITECTURE verhalten OF std_counter IS
--
    --SIGNAL cnt: STD_LOGIC_VECTOR((CNTLEN - 1) DOWNTO 0);
    --SIGNAL overflow: STD_LOGIC;
    --SIGNAL detect: STD_LOGIC_VECTOR((CNTLEN - 1) DOWNTO 0);
--BEGIN
--
---- The funktions defined in the Funktionstabelle must be implemented
---- Test how to save logic gates and how to save the number of flip-flops
--
    --detect <= (OTHERS => '0');
                --
    --p1: PROCESS(clk, rst) is
    --BEGIN
        --IF rst=RSTDEF THEN
                --cnt <= (OTHERS => '0');
        --ELSIF rising_edge(clk) THEN
                --
            --IF swrst=RSTDEF THEN
                --cnt <= (OTHERS => '0');
            --ELSIF en='1' THEN
                --IF load='1' THEN
                    --cnt <= din;
                --ELSIF dec='1' THEN
                    --cnt <= cnt - 1;         -- Improvement when using cnt <= cnt - dec
                --ELSIF inc='1' THEN
                    --cnt <= cnt + 1;
                --END IF;
            --END IF;
        --END IF;
    --END PROCESS p1;
--
     --dout <= cnt;                                        -- Return the value of the counter
        --
--END verhalten;
