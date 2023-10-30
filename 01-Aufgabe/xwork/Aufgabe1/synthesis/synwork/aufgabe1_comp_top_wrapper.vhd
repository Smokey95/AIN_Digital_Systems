--
-- Synopsys
-- Vhdl wrapper for top level design, written on Wed Nov 23 14:19:59 2022
--
library ieee;
use ieee.std_logic_1164.all;

entity wrapper_for_aufgabe1 is
   port (
      rst : in std_logic;
      clk : in std_logic;
      btn : in std_logic_vector(4 downto 1);
      sw : in std_logic_vector(8 downto 1);
      digi : out std_logic_vector(4 downto 1);
      seg : out std_logic_vector(7 downto 1);
      dp : out std_logic
   );
end wrapper_for_aufgabe1;

architecture struktur of wrapper_for_aufgabe1 is

component aufgabe1
 port (
   rst : in std_logic;
   clk : in std_logic;
   btn : in std_logic_vector (4 downto 1);
   sw : in std_logic_vector (8 downto 1);
   digi : out std_logic_vector (4 downto 1);
   seg : out std_logic_vector (7 downto 1);
   dp : out std_logic
 );
end component;

signal tmp_rst : std_logic;
signal tmp_clk : std_logic;
signal tmp_btn : std_logic_vector (4 downto 1);
signal tmp_sw : std_logic_vector (8 downto 1);
signal tmp_digi : std_logic_vector (4 downto 1);
signal tmp_seg : std_logic_vector (7 downto 1);
signal tmp_dp : std_logic;

begin

tmp_rst <= rst;

tmp_clk <= clk;

tmp_btn <= btn;

tmp_sw <= sw;

digi <= tmp_digi;

seg <= tmp_seg;

dp <= tmp_dp;



u1:   aufgabe1 port map (
		rst => tmp_rst,
		clk => tmp_clk,
		btn => tmp_btn,
		sw => tmp_sw,
		digi => tmp_digi,
		seg => tmp_seg,
		dp => tmp_dp
       );
end struktur;
