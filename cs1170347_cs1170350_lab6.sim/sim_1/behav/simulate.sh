#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2016.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim memoryInt_behav -key {Behavioral:sim_1:Functional:memoryInt} -tclbatch memoryInt.tcl -view /home/btech/cs1170347/cs1170347_cs1170350_lab6/memoryInt_behav.wcfg -log simulate.log
