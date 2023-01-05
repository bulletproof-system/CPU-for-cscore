@REM del tempCodeRunnerFile.v
@REM del /q submit
copy fpga_top.v /d submit\\code\\
copy mips.v /d submit\\code\\
copy Bridge.v /d submit\\code\\
copy P7_standard_timer_2019.v /d submit\\code\\
copy UART.v /d submit\\code\\
copy Controller.v /d submit\\code\\
copy PC_Calc.v /d submit\\code\\
copy GRF.v /d submit\\code\\
copy ALU.v /d submit\\code\\
copy MulDivUnit.v /d submit\\code\\
copy Mux.v /d submit\\code\\
copy Gobals.v /d submit\\code\\
copy init.coe /d submit\\code\\
copy P8.asm /d submit\\code\\
copy dump.py /d submit\\code\\
copy dump.bat /d submit\\code\\
copy ..\\fpga_top.bit /d submit
copy ..\\P8.xise /d submit
copy ..\\ipcore_dir\\IM.xise /d submit\\ipcore_dir
copy ..\\ipcore_dir\\IM.xco /d submit\\ipcore_dir
copy ..\\ipcore_dir\\DM.xise /d submit\\ipcore_dir
copy ..\\ipcore_dir\\DM.xco /d submit\\ipcore_dir
cd submit
zip -r -9 "../submit.zip" "*.*"