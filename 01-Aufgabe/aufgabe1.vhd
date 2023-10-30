
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY aufgabe1 IS
   PORT(rst:  IN  std_logic;                     -- system reset (active low)
        clk:  IN  std_logic;                     -- 50 MHz crystal oscillator, clock source
        btn:  IN  std_logic_vector(4 DOWNTO 1);  -- user push buttons: BTN4 BTN3 BTN2 BTN1 (active low)
        sw:   IN  std_logic_vector(8 DOWNTO 1);  -- 8 slide switches: SW8 SW7 SW6 SW5 SW4 SW3 SW2 SW1 (active low)
        digi: OUT std_logic_vector(4 DOWNTO 1);  -- 4 digit enable (common cathode) signals (active high)
        seg:  OUT std_logic_vector(7 DOWNTO 1);  -- 7 connections to seven-segment display (active high)
        dp:   OUT std_logic);                    -- 1 connection to digit point (active high)
END aufgabe1;

ARCHITECTURE struktur OF aufgabe1 IS

   CONSTANT RSTDEF: std_logic := '0';

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

   SIGNAL data: std_logic_vector(15 DOWNTO 0);
   SIGNAL dpin: std_logic_vector( 3 DOWNTO 0);
    
BEGIN

   data <= NOT(sw & sw);
   dpin <= NOT(btn);

   u1: hex4x7seg
   GENERIC MAP(RSTDEF => RSTDEF)
   PORT MAP(rst   => rst,
            clk   => clk,
            data  => data,
            dpin  => dpin,
            ena   => digi,
            dp    => dp,
            seg   => seg);

END struktur;
