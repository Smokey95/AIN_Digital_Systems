
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sync_buffer IS
   GENERIC(RSTDEF:  std_logic := '1');
   PORT(rst:    IN  std_logic;  -- reset, RSTDEF active
        clk:    IN  std_logic;  -- clock, rising edge
        en:     IN  std_logic;  -- enable, high active
        swrst:  IN  std_logic;  -- software reset, RSTDEF active
        din:    IN  std_logic;  -- data bit, input
        dout:   OUT std_logic;  -- data bit, output
        redge:  OUT std_logic;  -- rising  edge on din detected
        fedge:  OUT std_logic); -- falling edge on din detected
END sync_buffer;

--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity sync_buffer implementiert werden.
--

ARCHITECTURE verhalten OF sync_buffer IS
    SIGNAL q1:  std_logic;
    SIGNAL q2:  std_logic;
    SIGNAL q3:  std_logic;
BEGIN

    -- First D-flip Flowp realised with the 1-Process Method
    flipFlop1: PROCESS(clk, rst) IS
    BEGIN
        IF rst=RSTDEF THEN
            q1 <= '0';
        ELSIF rising_edge(clk) THEN
            -- @TODO: Better without IF ELSE (see repo odsource)
            IF swrst = RSTDEF THEN
                q1 <= '0';
            ELSE
                q1 <= din;
            END IF;
        END IF;
    END PROCESS flipFlop1;
    
    -- Second D-flip Flowp realised with the 1-Process Method
    flipFlop2: PROCESS(clk, rst) IS
    BEGIN
        IF rst=RSTDEF THEN
            q2 <= '0';
        ELSIF rising_edge(clk) THEN
            -- @TODO: Better without IF ELSE (see repo odsource)
            IF swrst = RSTDEF THEN
                q2 <= '0';
            ELSE
                q2 <= q1;
            END IF;
        END IF;
    END PROCESS flipFlop2;

END verhalten;