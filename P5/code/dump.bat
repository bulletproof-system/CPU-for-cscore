@REM del tempCodeRunnerFile.v
@REM del /q submit
copy ALU.v /d submit
copy Controller.v /d submit
copy DM.v /d submit
copy Gobals.v /d submit
copy GRF.v /d submit
copy mips.v /d submit
copy Mux.v /d submit
copy IM.v /d submit
copy IM.v /d submit
cd submit
zip -r -9 "../submit.zip" "*.v"