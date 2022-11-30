new_project \
         -name {aufgabe1} \
         -location {E:\OneDrive\Dokumente\200_Education\220_Study\222_Semester\S5\DISY\11_Projekte\01_Aufgabe\xwork\Aufgabe1\designer\aufgabe1\aufgabe1_fp} \
         -mode {chain} \
         -connect_programmers {FALSE}
add_actel_device \
         -device {M2S005} \
         -name {M2S005}
enable_device \
         -name {M2S005} \
         -enable {TRUE}
save_project
close_project
