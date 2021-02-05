* Miller OpAmp

*** Setup ***********************************************************************
* Include Model Files
.include ../lib/90nm_NMOS_bulk7675.sp
.include ../lib/90nm_PMOS_bulk17912.sp

* Set Ambient Temperature
.option TEMP=27C

*** Netlist **********************************************************************
* Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>
Vdd         DD                  gnd                 1.2
Vip         INP                 gnd                 0.6 ac 1.0
Vin         INN                 gnd                 0.6 ac -1.0
Iref        REF                 gnd                 50u

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>

* Input Current Mirror
M8      REF     REF    gnd      gnd     ptmn        W=2u L=300n
M5      X       REF    gnd      gnd     ptmn        W=2u L=300n
M7      O       REF    gnd      gnd     ptmn        W=2u L=300n

* Differential Pair
M1      U       INP     X       gnd     ptmn        W=2u L=300n
M2      W       INN     X       gnd     ptmn        W=2u L=300n

* Current Mirror
M3      U       U       DD      DD      ptmp        W=2u L=300n
M4      W       U       DD      DD      ptmp        W=2u L=300n

* Output
M6      O       W       DD      DD      ptmp        W=2u L=300n

* Load Capacitance
*cx..x <positive terminal> <negative terminal> <parameters>
CL          O                   gnd                 10p

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
wrdata ./miller.raw gm_db,pm_deg,zdb_f,cdb_f,dc_gain
.endc
.end
