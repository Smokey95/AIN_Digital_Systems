
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY aufgabe2 IS
   PORT(rst:  IN  std_logic;                     -- system reset (active low)
        clk:  IN  std_logic;                     -- 50 MHz crystal oscillator, clock source
        btn:  IN  std_logic_vector(4 DOWNTO 1);  -- user push buttons: BTN4 BTN3 BTN2 BTN1 (active low)
        sw:   IN  std_logic_vector(8 DOWNTO 1);  -- 8 slide switches: SW8 SW7 SW6 SW5 SW4 SW3 SW2 SW1 (active low)
        digi: OUT std_logic_vector(4 DOWNTO 1);  -- 4 digit enable (common cathode) signals (active high)
        seg:  OUT std_logic_vector(7 DOWNTO 1);  -- 7 connections to seven-segment display (active high)
        dp:   OUT std_logic;                     -- 1 connection to digit point (active high)
        LD1:  OUT std_logic;                     -- 1 FPGA connection to LD1 (carry output)
        LD2:  OUT std_logic);                    -- dummy
END aufgabe2;

ARCHITECTURE structure OF aufgabe2 IS

   CONSTANT RSTDEF: std_logic := '0';
   CONSTANT CNTLEN: natural   := 16;

   COMPONENT sync_module IS
      GENERIC(RSTDEF: std_logic);
      PORT(rst:   IN  std_logic;  -- reset, active RSTDEF
           clk:   IN  std_logic;  -- clock, risign edge
           swrst: IN  std_logic;  -- software reset, active RSTDEF
           BTN1:  IN  std_logic;  -- push button -> load
           BTN2:  IN  std_logic;  -- push button -> dec
           BTN3:  IN  std_logic;  -- push button -> inc
           load:  OUT std_logic;  -- load,      high active
           dec:   OUT std_logic;  -- decrement, high active
           inc:   OUT std_logic); -- increment, high active
   END COMPONENT;

   COMPONENT std_counter IS
      GENERIC(RSTDEF: std_logic;
              CNTLEN: natural);
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
   END COMPONENT;

   COMPONENT hex4x7seg IS
      GENERIC(RSTDEF: std_logic);
      PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
           clk:   IN  std_logic;                       -- clock,           rising edge
           data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      active high
           dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
           ena:   OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable signals,                 active high
           seg:   OUT std_logic_vector( 7 DOWNTO 1);   -- 7 connections to seven-segment display, active high
           dp:    OUT std_logic);                      -- decimal point output,                   active high
   END COMPONENT;

   SIGNAL swrst:  std_logic;
   SIGNAL inc:    std_logic;
   SIGNAL dec:    std_logic;
   SIGNAL load:   std_logic;
   SIGNAL BTN1:   std_logic;
   SIGNAL BTN2:   std_logic;
   SIGNAL BTN3:   std_logic;
   SIGNAL BTN4:   std_logic;
   SIGNAL cnt:    std_logic_vector(CNTLEN-1 DOWNTO 0);
   SIGNAL din:    std_logic_vector(CNTLEN-1 DOWNTO 0);

BEGIN

   swrst <= NOT RSTDEF;
   LD2   <= BTN4;

   (BTN4, BTN3, BTN2, BTN1) <= NOT btn;
    
   din <= "00000000" & NOT sw;

   u1: sync_module
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst   => rst,
            clk   => clk,
            swrst => swrst,
            BTN1  => BTN1,
            BTN2  => BTN2,
            BTN3  => BTN3,
            load  => load,
            dec   => dec,
            inc   => inc);

   u2: std_counter
   GENERIC MAP(RSTDEF => RSTDEF,
               CNTLEN => CNTLEN)
   PORT MAP(rst   => rst,
            clk   => clk,
            en    => '1',
            inc   => inc,
            dec   => dec,
            load  => load,
            swrst => swrst,
            cout  => LD1,
            din   => din,
            dout  => cnt);

   u3: hex4x7seg
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst   => rst,
            clk   => clk,
            data  => cnt,
            dpin  => "0000",
            ena   => digi,
            dp    => dp,
            seg   => seg);

END structure;
