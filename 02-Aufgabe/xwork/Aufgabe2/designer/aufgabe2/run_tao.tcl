set_device -family {SmartFusion2} -die {M2S005} -speed {STD}
read_vhdl -mode vhdl_2008 {C:\Users\ds-09\Desktop\DISY\Digital_Systems\02-Aufgabe\std_counter.vhd}
read_vhdl -mode vhdl_2008 {C:\Users\ds-09\Desktop\DISY\Digital_Systems\02-Aufgabe\sync_buffer.vhd}
read_vhdl -mode vhdl_2008 {C:\Users\ds-09\Desktop\DISY\Digital_Systems\bib\lfsr_lib.vhd}
read_vhdl -mode vhdl_2008 {C:\Users\ds-09\Desktop\DISY\Digital_Systems\02-Aufgabe\sync_module.vhd}
read_vhdl -mode vhdl_2008 {C:\Users\ds-09\Desktop\DISY\Digital_Systems\01-Aufgabe\hex4x7seg.vhd}
read_vhdl -mode vhdl_2008 {C:\Users\ds-09\Desktop\DISY\Digital_Systems\02-Aufgabe\aufgabe2.vhd}
set_top_level {aufgabe2}
map_netlist
check_constraints {C:\Users\ds-09\Desktop\DISY\Digital_Systems\02-Aufgabe\xwork\Aufgabe2\constraint\synthesis_sdc_errors.log}
write_fdc {C:\Users\ds-09\Desktop\DISY\Digital_Systems\02-Aufgabe\xwork\Aufgabe2\designer\aufgabe2\synthesis.fdc}
