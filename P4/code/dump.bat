copy .\\control\\Controller.v /d .\\submit
copy .\\datapath\\*.v /d .\\submit
copy .\\mips.v  /d .\\submit
cd .\\submit
zip -r -9 "../submit.zip" "*.v"