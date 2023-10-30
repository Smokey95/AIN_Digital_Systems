set_device -family {SmartFusion2} -die {M2S005} -speed {STD}
read_vhdl -mode vhdl_2008 {E:\00_Git\02_Study\DISY\02-Aufgabe\std_counter.vhd}
read_vhdl -mode vhdl_2008 {E:\00_Git\02_Study\DISY\bib\lfsr_lib.vhd}
read_vhdl -mode vhdl_2008 {E:\00_Git\02_Study\DISY\02-Aufgabe\sync_buffer.vhd}
read_vhdl -mode vhdl_2008 {E:\00_Git\02_Study\DISY\02-Aufgabe\sync_module.vhd}
read_vhdl -mode vhdl_2008 {E:\00_Git\02_Study\DISY\01-Aufgabe\hex4x7seg.vhd}
read_vhdl -mode vhdl_2008 {E:\00_Git\02_Study\DISY\02-Aufgabe\aufgabe2.vhd}
set_top_level {aufgabe2}
map_netlist
check_constraints {E:\00_Git\02_Study\DISY\02-Aufgabe\xwork\Aufgabe2\constraint\synthesis_sdc_errors.log}
write_fdc {E:\00_Git\02_Study\DISY\02-Aufgabe\xwork\Aufgabe2\designer\aufgabe2\synthesis.fdc}
