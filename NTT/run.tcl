#compile mytb and NTTConv.cpp
vlog mytb.sv ./verification/NTTConv.cpp
#simulate (show class instances)
vsim work.mytb -classdebug
run -all