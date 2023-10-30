set_device -family {SmartFusion2} -die {M2S005} -speed {STD}
read_vhdl -mode vhdl_2008 {E:\OneDrive\Dokumente\200_Education\220_Study\222_Semester\S5\DISY\11_Projekte\01_Aufgabe\hex4x7seg.vhd}
read_vhdl -mode vhdl_2008 {E:\OneDrive\Dokumente\200_Education\220_Study\222_Semester\S5\DISY\11_Projekte\01_Aufgabe\aufgabe1.vhd}
set_top_level {aufgabe1}
map_netlist
check_constraints {E:\OneDrive\Dokumente\200_Education\220_Study\222_Semester\S5\DISY\11_Projekte\01_Aufgabe\xwork\Aufgabe1\constraint\synthesis_sdc_errors.log}
write_fdc {E:\OneDrive\Dokumente\200_Education\220_Study\222_Semester\S5\DISY\11_Projekte\01_Aufgabe\xwork\Aufgabe1\designer\aufgabe1\synthesis.fdc}
