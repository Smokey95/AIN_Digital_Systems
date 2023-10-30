new_project \
         -name {aufgabe2} \
         -location {E:\00_Git\02_Study\DISY\02-Aufgabe\xwork\Aufgabe2\designer\aufgabe2\aufgabe2_fp} \
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
