# Probe Debounce
In this exercise you will have to create several architectures for debounce a button switch.
Therefore we will have three .vhd files

---

## std_counter.vhd
Definition of the counter which will count up and down regarding to the input. Also he has to determine if there 
was a overflow (incrementing from "FFFF" to "0000" or decrement the other way down.)

The Entity is given as follow:

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

The following table describes how input will be processed:

| rst | clk | swrst | en  | load | dec | inc | Aktion |
|:----|:----|:------|:----|:-----|:----|:----|:-------|
| V   | -   | -     | -   | -    | -   | -   | cnt := 000..0, asynchrone reset |
| N   | r   | V     | -   | -    | -   | -   | cnt := 000..0, synchrone  reset |
| N   | r   | N     | 0   | -    | -   | -   | no change                  |  
| N   | r   | N     | 1   | 1    | -   | -   | cnt := din, parallel load     |
| N   | r   | N     | 1   | 0    | 1   | -   | cnt := cnt - 1, decrement   |
| N   | r   | N     | 1   | 0    | 0   | 1   | cnt := cnt + 1, increment   |
| N   | r   | N     | 1   | 0    | 0   | 0   | no change                |

To solve the task regarding to the overflow it is possible to define a Vector which is one bit longer than the 
original count vector:

    SIGNAL cnt: STD_LOGIC_VECTOR(CNTLEN DOWNTO 0);
    
To reset the HSB (High Significant Bit) of the counter we can use the following code:

    cnt <= ('0' & cnt(CNTLEN - 1 DOWNTO 0)) - 1;
    
which sets the HSB to 0 and decrement bits HSB - 1 to Bit 0

---

## sync_buffer.vhd
Definition of a synchronous buffer which will be used to debounce the button switch.

The Entity is given as follow:

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

The implementation is down like shown in the lecture slides using three flip-flops and a hysteresis.

---

## sync_module.vhd

The sync module is finally used to reduce the 50MHz frequency to 1-2 kHz and defines three sinc-buffer instances for the three buttons.

The Entity is defined as follow:

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
    
To reduce the frequency we could use the same code like in the task before but we could also use a general function which will be provided over the moodle course. This shortens the implementation down to:

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
    
With the following constants and signals

    CONSTANT    LENDEF: natural := 15;
    CONSTANT    POLY: std_logic_vector(LENDEF DOWNTO 0)   := "1000000000000011";    -- Polynom: x^15 + x^1 + 1
    CONSTANT    RES:  std_logic_vector(LENDEF-1 DOWNTO 0) := "111111111111111";     -- mod (2^15 - 1)
    
    SIGNAL      strb: std_logic;    -- enable signal for mod15 counter
    SIGNAL      reg:  std_logic_vector(LENDEF-1 DOWNTO 0);

Note that the needed polynomial is given as a Bit-Vector where every 1 represents a term of the polynomial. The RES vectore is needed to define the final count, so it is possible to handle bigger polynomial than needed. In our case it is completely filled with ones (note that this vector is one bit shorter)

The button instances can be done like shown below:

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