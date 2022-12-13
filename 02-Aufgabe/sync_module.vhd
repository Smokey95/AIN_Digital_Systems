
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.lfsr_lib.ALL;          -- Include bib to realize LFSR

ENTITY sync_module IS
   GENERIC(RSTDEF: std_logic := '1');
   PORT(rst:   IN  std_logic;  -- reset, active RSTDEF
        clk:   IN  std_logic;  -- clock, risign edge
        swrst: IN  std_logic;  -- software reset, active RSTDEF
        BTN1:  IN  std_logic;  -- push button -> load
        BTN2:  IN  std_logic;  -- push button -> dec
        BTN3:  IN  std_logic;  -- push button -> inc
        load:  OUT std_logic;  -- load,      high active
        dec:   OUT std_logic;  -- decrement, high active
        inc:   OUT std_logic); -- increment, high active
END sync_module;

--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity sync_module implementiert werden.
--

ARCHITECTURE verhalten OF sync_module IS
    
    -- Auch ohne COMPONENT m�glich? Mittels Import �hnlicher anweisung?
    COMPONENT sync_buffer IS
		GENERIC(RSTDEF : STD_LOGIC);
		PORT(
			rst : IN STD_LOGIC; -- reset, RSTDEF active
			clk : IN STD_LOGIC; -- clock, rising edge
			en : IN STD_LOGIC; -- enable, high active
			swrst : IN STD_LOGIC; -- software reset, RSTDEF active
			din : IN STD_LOGIC; -- data bit, input
			dout : OUT STD_LOGIC; -- data bit, output
			redge : OUT STD_LOGIC; -- rising  edge on din detected
			fedge : OUT STD_LOGIC); -- falling edge on din detected
	END COMPONENT;
    
    CONSTANT LENDEF: natural := 15;
    -- Polynom: x^15 + x^1 + 1
    CONSTANT    POLY: std_logic_vector(LENDEF DOWNTO 0) := "1000000000000011";
    -- Check if RES is correct
    CONSTANT    RES:  std_logic_vector := "111111111111111";                       -- mod (2^15 - 1)
    
    SIGNAL      strb: std_logic;    -- enable signal for mod15 counter
    SIGNAL      reg:  std_logic_vector(LENDEF-1 DOWNTO 0);
    
BEGIN

    -- Modulo-2^15-Counter -----------------------------------------------------
    -- Reduce input frequence from 50MHz to a lower value
    -- The value depends on the RES vector. If the RES vector is 111111111111111
    -- the counter will count up to 2^15-1 therefore reducing the input frequency
    -- to round about 1,525 kHz
    -- CHECK WITH LLECTURER IF THIS IS CORRECT OR NOT
    ----------------------------------------------------------------------------
    p1: PROCESS(rst, clk) IS
    BEGIN
        IF rst = RSTDEF THEN
            strb <= '0';
            reg     <= (OTHERS => '1');
        ELSIF rising_edge(clk) THEN
            
            strb <= '0';
            
            -- Use bib function to realize LFSR this time
            reg <= lfsr(reg, POLY, '0');
            
            IF reg=RES THEN
                strb <= '1';
            END IF;
            
        END IF;
    END PROCESS;
    
    -- Synchronizer -----------------------------------------------------------
    
    -- Syncbuffer for BTN1
    buf1: sync_buffer
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(   rst => rst,
                clk => clk,
                en  => strb,
                swrst => swrst,
                din => BTN1,
                dout => OPEN,
                redge => OPEN,
                fedge => inc);
    
    -- Syncbuffer for BTN2
    buf2: sync_buffer
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(   rst => rst,
                clk => clk,
                en  => strb,
                swrst => swrst,
                din => BTN2,
                dout => OPEN,
                redge => OPEN,
                fedge => dec);
                
    -- Syncbuffer for BTN3
    -- CHECK IF redge IS CORRECT
    buf3: sync_buffer
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(   rst => rst,
                clk => clk,
                en  => strb,
                swrst => swrst,
                din => BTN3,
                dout => OPEN,
                redge => load,
                fedge => OPEN);

END verhalten;