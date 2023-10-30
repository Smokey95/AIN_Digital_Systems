LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE lfsr_lib IS

   FUNCTION lfsr(arg: std_logic_vector; poly: std_logic_vector; din: std_logic) RETURN std_logic_vector;
   FUNCTION exec(poly: std_logic_vector; size: natural) RETURN std_logic_vector;

END lfsr_lib;

PACKAGE BODY lfsr_lib IS

   FUNCTION lfsr(arg: std_logic_vector; poly: std_logic_vector; din: std_logic) RETURN std_logic_vector IS
      CONSTANT N:   natural := poly'LENGTH;
      CONSTANT M:   natural := arg'LENGTH;
      CONSTANT ply: std_logic_vector(N DOWNTO 1) := poly;
      VARIABLE stg: std_logic_vector(M DOWNTO 1) := arg;
      VARIABLE tmp: std_logic_vector(M DOWNTO 1);
      VARIABLE inv: std_logic;
   BEGIN
      ASSERT ply(N)='1' REPORT "MSB in polynom is not set" SEVERITY error;
      inv := stg(M) XOR din;
      FOR i IN M DOWNTO 2 LOOP
         tmp(i) := stg(i-1) XOR (inv AND ply(i));
      END LOOP;
      tmp(1) := inv AND ply(1);
      RETURN tmp;
   END FUNCTION lfsr;
   
   FUNCTION exec(poly: std_logic_vector; size: natural) RETURN std_logic_vector IS
      CONSTANT N:   natural := poly'LENGTH;
      VARIABLE tmp: std_logic_vector(N-1 DOWNTO 1) := (OTHERS => '1');
   BEGIN
      FOR i IN 1 TO size-1 LOOP
         tmp := lfsr(tmp, poly, '0');
      END LOOP;
      RETURN tmp;
   END FUNCTION exec;
   
END PACKAGE BODY;