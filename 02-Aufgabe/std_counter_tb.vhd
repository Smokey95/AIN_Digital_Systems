ENTITY std_counter_tb IS
   -- empty
END std_counter_tb;

USE std.textio.ALL;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL; 
USE ieee.std_logic_arith.ALL;

ARCHITECTURE verhalten OF std_counter_tb IS

   CONSTANT RSTDEF: std_logic := '1';
   CONSTANT CNTLEN: natural   := 8;

   CONSTANT  SW:    std_logic := RSTDEF;
   CONSTANT nSW:    std_logic := NOT SW;

   CONSTANT FRQ: natural := 50E6;
   CONSTANT tpd: time := 1 sec / FRQ;
   
   TYPE tFrame IS RECORD
      en:    std_logic;
      inc:   std_logic;
      dec:   std_logic;
      load:  std_logic;
      swrst: std_logic;
      din:   integer;
      cout:  std_logic;
      dout:  integer;
   END RECORD;
   
   TYPE tFrames IS ARRAY(positive RANGE <>) OF tFrame;

   CONSTANT tab1: tFrames := (
   --  en   inc   dec   load   swrst   din cout, dout
      ('0', '0',  '0',  '0',   nSW,    1,  '0',  0),
      ('1', '0',  '0',  '0',   nSW,    2,  '0',  0),
      ('1', '0',  '0',  '0',   nSW,    3,  '0',  0),
      ('0', '1',  '0',  '0',   nSW,    4,  '0',  0),
      ('0', '1',  '0',  '0',   nSW,    5,  '0',  0),
      ('0', '0',  '1',  '0',   nSW,    6,  '0',  0),
      ('0', '0',  '1',  '0',   nSW,    7,  '0',  0),
      ('0', '0',  '0',  '1',   nSW,    8,  '0',  0),
      ('0', '0',  '0',  '1',   nSW,    9,  '0',  0),
      ('0', '0',  '0',  '0',   nSW,    0,  '0',  0)
   );
   
   CONSTANT tab2: tFrames := (
   --  en   inc   dec   load   swrst   din cout, dout
      ('0', '0',  '0',  '0',   SW,     3,  '0',  0),
      ('1', '1',  '0',  '0',   SW,     3,  '0',  0),
      ('1', '0',  '1',  '0',   SW,     3,  '0',  0),
      ('1', '0',  '0',  '1',   SW,     3,  '0',  0),
      ('0', '0',  '0',  '0',   nSW,    0,  '0',  0)
   );
   
      CONSTANT tab3: tFrames := (
   --  en   inc   dec   load   swrst   din cout,  dout
      ('0', '0',  '0',  '0',   SW,      0,  '0',   0),
      ('1', '0',  '0',  '1',   nSW,     1,  '0',   1),
      ('0', '0',  '0',  '1',   nSW,     2,  '0',   1),
      ('1', '0',  '0',  '1',   nSW,     3,  '0',   3),
      ('0', '0',  '0',  '1',   nSW,     4,  '0',   3),
      ('1', '0',  '0',  '1',   nSW,     5,  '0',   5),
      ('0', '0',  '0',  '1',   nSW,    -1,  '0',   5),
      ('1', '0',  '0',  '1',   nSW,    -2,  '0',  -2),
      ('0', '0',  '0',  '1',   nSW,    -3,  '0',  -2),
      ('1', '0',  '0',  '1',   nSW,    -4,  '0',  -4),
      ('0', '0',  '0',  '1',   nSW,    -5,  '0',  -4),   
      ('1', '0',  '0',  '1',   nSW,     0,  '0',   0), 
      ('0', '0',  '0',  '0',   nSW,     0,  '0',   0) 
   );

      CONSTANT tab4: tFrames := (
   --  en   inc   dec   load   swrst   din cout,  dout
      ('0', '0',  '0',  '0',   SW,      0,  '0',   0),
      ('1', '0',  '0',  '1',   nSW,    -3,  '0',  -3),
      ('1', '1',  '0',  '0',   nSW,    -3,  '0',  -2),
      ('1', '1',  '0',  '0',   nSW,    -3,  '0',  -1),
      ('1', '1',  '0',  '0',   nSW,    -3,  '1',   0),
      ('1', '1',  '0',  '0',   nSW,    -3,  '0',   1),
      ('1', '1',  '0',  '0',   nSW,    -3,  '0',   2),
      ('1', '1',  '0',  '0',   nSW,    -3,  '0',   3),
      ('0', '0',  '0',  '0',   nSW,     0,  '0',   3) 
   );

      CONSTANT tab5: tFrames := (
   --  en   inc   dec   load   swrst   din cout,  dout
      ('0', '0',  '0',  '0',   SW,      0,  '0',   0),
      ('1', '0',  '0',  '1',   nSW,     3,  '0',   3),
      ('1', '0',  '1',  '0',   nSW,     3,  '0',   2),
      ('1', '0',  '1',  '0',   nSW,     3,  '0',   1),
      ('1', '0',  '1',  '0',   nSW,     3,  '0',   0),
      ('1', '0',  '1',  '0',   nSW,     3,  '1',  -1),
      ('1', '0',  '1',  '0',   nSW,     3,  '0',  -2),
      ('1', '0',  '1',  '0',   nSW,     3,  '0',  -3),
      ('0', '0',  '0',  '0',   nSW,     0,  '0',  -3) 
   );
   
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

   SIGNAL rst:    std_logic := RSTDEF;
   SIGNAL clk:    std_logic := '0';
   SIGNAL en:     std_logic := '0';
   SIGNAL inc:    std_logic := '0';
   SIGNAL dec:    std_logic := '0';
   SIGNAL load:   std_logic := '0';
   SIGNAL swrst:  std_logic := NOT RSTDEF;
   SIGNAL cout:   std_logic := '0';
   SIGNAL din:    std_logic_vector(CNTLEN-1 DOWNTO 0) := (OTHERS => '0');
   SIGNAL cnt:    std_logic_vector(CNTLEN-1 DOWNTO 0) := (OTHERS => '0');

BEGIN

   u1: std_counter
   GENERIC MAP(RSTDEF => RSTDEF,
               CNTLEN => CNTLEN)
   PORT MAP(rst   => rst,
            clk   => clk,
            en    => en,
            inc   => inc,
            dec   => dec,
            load  => load,
            swrst => swrst,
            cout  => cout,
            din   => din,
            dout  => cnt);

   PROCESS
      
      PROCEDURE clock(n: natural) IS
      BEGIN
         FOR i IN 1 TO n LOOP
            WAIT FOR tpd/2-0.2*tpd;
            clk <= '0';
            WAIT FOR tpd/2;
            clk <= '1';
         END LOOP;
      END PROCEDURE;
      
      PROCEDURE rst_test IS
      BEGIN
         rst <= RSTDEF;
         WAIT FOR 0.2*tpd;
         ASSERT cnt=0 REPORT "reset: wrong value" SEVERITY error;
         rst <= NOT RSTDEF;
         clock(1);
      END PROCEDURE;

      PROCEDURE test(nr: positive; tab: tFrames) IS
         VARIABLE tmp: std_logic_vector(1 TO cnt'LENGTH);
      BEGIN
         REPORT "test " & integer'image(nr) & " ..." SEVERITY note;
         FOR i IN tab'RANGE LOOP
            tmp   := cnt;
            en    <= tab(i).en;
            inc   <= tab(i).inc;
            dec   <= tab(i).dec;
            load  <= tab(i).load;
            swrst <= tab(i).swrst;
            din   <= conv_std_logic_vector(tab(i).din, din'LENGTH);
            WAIT FOR 0.1*tpd;
            ASSERT cnt=tmp REPORT "wrong new value, line " & integer'image(i)  SEVERITY error;
            clock(1);
            WAIT FOR 0.1*tpd;
            ASSERT conv_integer(signed(cnt))=tab(i).dout REPORT "wrong cnt value, line " & integer'image(i) SEVERITY error;
            ASSERT cout=tab(i).cout REPORT "wrong cout value, line " & integer'image(i) SEVERITY error;
         END LOOP;
      END PROCEDURE;

   BEGIN
      rst_test;
      test(1, tab1);
      test(2, tab2);
      test(3, tab3);
      test(4, tab4);
      test(5, tab5);
      WAIT;
   END PROCESS;

END verhalten;

