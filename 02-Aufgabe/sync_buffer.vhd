
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.lfsr_lib.ALL;          -- Include bib to realize LFSR

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
    SIGNAL q1:  std_logic;      -- output Q from Flip Flop 1
    SIGNAL q2:  std_logic;      -- output Q from Flip Flop 2
    SIGNAL q3:  std_logic;      -- output Q from Flip Flop 3
    SIGNAL qH:  std_logic;      -- output Q from Hysteresis
    
    TYPE TState IS (S0, S1);
    SIGNAL state: TState;
    
    -- @TODO Change from linear counter do LFSR???
    SIGNAL cnt: integer range 0 to 31; 
   
    CONSTANT LENDEF: natural := 5;
    -- Polynom x^5 + x^2 + 1
    CONSTANT CNTMAX: natural:= 31;
    CONSTANT POLY:   std_logic_vector(LENDEF   DOWNTO 0) := "100101";
    CONSTANT RES:    std_logic_vector(LENDEF-1 DOWNTO 0) := "11101";    -- exec(POLY, CNTMAX);
    SIGNAL   reg:    std_logic_vector(LENDEF-1 DOWNTO 0);
    
BEGIN

    -- First D-flip Flowp realised with the 1-Process Method
    flipFlop1: PROCESS(clk, rst) IS
    BEGIN
        IF rst=RSTDEF THEN
            q1 <= '0';
        ELSIF rising_edge(clk) THEN
            q1 <= din;                -- default output
            IF swrst = RSTDEF THEN
                q1 <= '0';
            END IF;
        END IF;
    END PROCESS flipFlop1;
    
    
    -- Second D-flip Flowp realised with the 1-Process Method
    flipFlop2: PROCESS(clk, rst) IS
    BEGIN
        IF rst=RSTDEF THEN
            q2 <= '0';
        ELSIF rising_edge(clk) THEN
            q2 <= q1;
            IF swrst = RSTDEF THEN
                q2 <= '0';
            END IF;
        END IF;
    END PROCESS flipFlop2;
    
    
    -- Hysteresis
    hysteresis: PROCESS(clk, rst) IS
    BEGIN
        IF rst=RSTDEF THEN
            state   <= S0;
            qH      <= '0';
            cnt     <= 0;
            --reg <= (OTHERS => '1');
        ELSIF rising_edge(clk) THEN
            IF en = '1' THEN
				CASE state IS
					WHEN S0 =>
						qH <= '0';
						IF q2 = '1' THEN
							IF cnt < 31 THEN
								cnt <= cnt + 1;
							ELSE
								state <= S1;
							END IF;
						ELSE
							IF cnt > 0 THEN
								cnt <= cnt - 1;
							END IF;
						END IF;
                        --IF q2 = '1' THEN
							--IF reg /= RES THEN
								--reg <= lfsr(reg, POLY, '1');
							--ELSE
								--state <= S1;
							--END IF;
						--ELSE
							--IF reg > 0 THEN
								--reg <= lfsr(reg, POLY, '0');
							--END IF;
						--END IF;
					WHEN S1 =>
						qH <= '1';
						IF q2 = '1' THEN
							IF cnt < 31 THEN
								cnt <= cnt + 1;
							END IF;
					    ELSE
							IF cnt > 0 THEN
								cnt <= cnt - 1;
							ELSE
								state <= S0;
							END IF;
						END IF;
                        --IF q2 = '1' THEN
							--IF reg /= RES THEN
								--reg <= lfsr(reg, POLY, '1');
							--END IF;
					    --ELSE
							--IF reg > 0 THEN
								--reg <= lfsr(reg, POLY, '0');
							--ELSE
								--state <= S0;
							--END IF;
						--END IF;
				END CASE;
			END IF;
            
			IF swrst = RSTDEF THEN
                state   <= S0;
				qH      <= '0';
				cnt     <= 0;
                --reg <= (OTHERS => '1');
			END IF;
        END IF;
    END PROCESS hysteresis;
    
    
    -- Third D-flip Flowp realised with the 1-Process Method
    flipFlop3: PROCESS(clk, rst) IS
    BEGIN
        IF rst=RSTDEF THEN
            q3 <= '0';
        ELSIF rising_edge(clk) THEN
            q3 <= qH;
            IF swrst = RSTDEF THEN
                q3 <= '0';
            END IF;
        END IF;
    END PROCESS flipFlop3;
    
    
    -- Set Output of sync_buffer
    -- See circuit diagram in task description
    fedge   <= NOT qH AND q3;
    dout    <= q3;
    redge   <= qH AND NOT q3;

END verhalten;