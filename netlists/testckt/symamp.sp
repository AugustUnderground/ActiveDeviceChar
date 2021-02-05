* Symmetrical Amplifier

*** Setup ***********************************************************************
* Include Model Files
.include ../lib/90nm_NMOS_bulk89211.sp
.include ../lib/90nm_PMOS_bulk15176.sp

* Set Ambient Temperature
.option TEMP=27C

*** Netlist **********************************************************************
* Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>
vdd         DD                  gnd                 1.2
vip         INP                 gnd                 0.6 ac 1.0
vin         INN                 gnd                 0.6 ac -1.0
iref        REF                 gnd                 50u

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>

* Reference Current Mirror
mn0     REF     B       gnd     gnd     ptmn        W=8u L=300n
mn1     W       B       gnd     gnd     ptmn        W=4u L=300n

* Differential Pair
mn2     X       INN     W       W       ptmn        W=8u L=300n
mn3     Y       INP     W       W       ptmn        W=8u L=300n

* PMOS Current Mirrors
mp4     X       X       DD      DD      ptmp        W=3u L=300n
mp6     Z       X       DD      DD      ptmp        W=12u L=300n
mp5     Y       Y       DD      DD      ptmp        W=3u L=300n
mp7     O       Y       DD      DD      ptmp        W=12u L=300n

* NMOS Current Mirror
mn8     Z       Z       gnd     gnd     ptmn        W=2u L=300n
mn9     O       Z       gnd     gnd     ptmn        W=2u L=300n

* Load Capacitance
*cx..x <positive terminal> <negative terminal> <parameters>
cL          O                   gnd                 10p

*** Simulation ********************************************************************
.control

* AC Analysis 10 points per decade from 1Hz to 100GHz
ac dec 10 1Hz 100GHz
run

* Convert rad -> deg
let phase=180/PI*vp(O)

* Gain Margin: Find value of V_O in dB when phase == 0
meas ac gm_db find vdb(O) when vp(O)=0

* Phase Margin: Find value of phase when V_O == 0dB
meas ac pm_deg find phase when vdb(O)=0

* DC Gain: Find gain in dB at f = 1Hz
meas ac dc_gain find vdb(O) at=1

* Unity Gain Frequency: Find f when V_O crosses 0dB
meas ac zdb_f when vdb(O)=0

* 3dB Cut Off Frequency: Find f when V_O crosses -3dB
let co = dc_gain - 3
meas ac cdb_f when vdb(O)=co

*plot vdb(vout) phase
*plot vdb(O) ph(O)
*print gm_db pm_deg zdb_f cdb_f dc_gain

* Save Results
set controlswait
set filetype = ascii
set wr_vecnames
set wr_singlescale
unset appendwrite
option numdgt=7
wrdata ./symamp.raw gm_db,pm_deg,zdb_f,cdb_f,dc_gain
.endc
.end
