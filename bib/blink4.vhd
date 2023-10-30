
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.lfsr_lib.ALL;

ENTITY blink4 IS
   GENERIC(RSTDEF: std_logic := '1';
           OUTDEF: std_logic := '1');
   PORT(rst:  IN  std_logic;  -- reset, RSTDEF active
        clk:  IN  std_logic;  -- clock, rising edge active
        ena:  IN  std_logic;  -- enable, high active
        led:  OUT std_logic); -- led, high active
END blink4;

ARCHITECTURE verhalten OF blink4 IS

   -- das Modul beinhaltet einen Frequenzteiler von 1.0 MHz auf 1.0 Hz
   -- und ist mit Hilfe eines LFSR mit einem primitiven Polynom aufgebaut.
   CONSTANT CNTMAX: natural := 1_000_000 / 2;
   CONSTANT LENDEF: natural := 19; -- natural(LOG2(CNTMAX));
   -- Polynom: x^19 + x^5 + x^2 + x^1 + 1
   CONSTANT POLY:   std_logic_vector(LENDEF   DOWNTO 0) := "10000000000000100111";
   CONSTANT RES:    std_logic_vector(LENDEF-1 DOWNTO 0) :=  "1101100111100101110"; -- exec(POLY, CNTMAX);
 
   SIGNAL dff: std_logic_vector(1 TO 3);
   SIGNAL reg: std_logic_vector(LENDEF-1 DOWNTO 0);
   
BEGIN

   led <= dff(1);
      
   PROCESS (rst, clk) IS
   BEGIN
      IF rst=RSTDEF THEN
         dff <= OUTDEF & OUTDEF & NOT OUTDEF;
         reg <= (OTHERS => '1');
      ELSIF rising_edge(clk) THEN
         IF ena='1' THEN
            reg <= lfsr(reg, POLY, '0');
            IF reg=RES THEN
               dff <= dff(2 TO 3) & dff(1);
               reg <= (OTHERS => '1');
            END IF;
         END IF;
      END IF;
   END PROCESS;

END verhalten;