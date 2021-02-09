* Single-Ended Two-Stage OTA

*** Setup ********************************************************************
* Include Model Files
.include ../lib/90nm_NMOS_bulk89211.sp
.include ../lib/90nm_PMOS_bulk15176.sp

* Set Ambient Temperature
.option TEMP=27C

* Design Paramters
.param VDD  = 1.2
.param VSS  = 0.0
.param L12  = 340n
.param L346 = 340n
.param L578 = 340n
.param W12  = 2.1u
.param W34  = 6.3u
.param W58  = 6.6u
.param W6   = 62u
.param W7   = 50u
.param VICM = 0.6
.param VOCM = 0.6
.param IREF = 15u
.param CL   = 10p

*** Netlist ******************************************************************

* Current/Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>

vdd         DD                  gnd                 {VDD}
vip         ICMP                gnd                 {VICM} ac   0.0
vin         ICMN                gnd                 {VICM} ac   180.0

*vicm        ICM                 gnd                 VICM
*vocm        OCM                 gnd                 {VOCM}

iref        REF                 gnd                 {IREF}

* MOSFETs
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>

* Differential Pair
mn1     Y       ICMN    X       gnd     ptmn        w=W12 l=L12
mn2     Z       ICMP    X       gnd     ptmn        w=W12 l=L12

* Current Mirror
mp3     Y       Y       DD      DD      ptmp        w=W34 l=L346
mp4     Z       Y       DD      DD      ptmp        w=W34 l=L346

* Reference Current Mirror
mn5     X       REF     gnd     gnd     ptmn        w=W58 l=L578
mn8     REF     REF     gnd     gnd     ptmn        w=W58 l=L578

* Output Stage
mp6     OCM    Z        DD      DD      ptmp        w=W6  l=L346
mn7     OCM    REF      gnd     gnd     ptmn        w=W7  l=L578

* Load Capacitance
*cx..x <positive terminal> <negative terminal> <parameters>
cload       OCM                gnd                 {CL}

*** Simulation ***************************************************************
.control

* AC Analysis 10 points per decade from 1Hz to 100GHz
ac dec 10 1Hz 100GHz
run 

* Convert rad -> deg
let phase = 180 / PI * vp(OCM)

* Gain Margin: Find value of V_o,CM in dB when phase == 0
meas ac gm_db find vdb(OCM) when vp(OCM) = 0

* Phase Margin: Find value of phase when V_O == 0dB
meas ac pm_deg find phase when vdb(OCM) = 0

* DC Gain: Find gain in dB at f = 1Hz
meas ac dc_gain find vdb(OCM) at = 1

* Unity Gain Frequency: Find f when V_O crosses 0dB
meas ac zdb_f when vdb(OCM) = 0

* 3dB Cut Off Frequency: Find f when V_O crosses -3dB
let cutoff = dc_gain - 3
meas ac cdb_f when vdb(OCM) = cutoff

plot vdb(OCM) ph(OCM)
*print gm_db pm_deg zdb_f cdb_f dc_gain

* Save Results
*set controlswait
*set filetype = ascii
*set wr_vecnames
*set wr_singlescale
*unset appendwrite
*option numdgt = 7
*wrdata ./single-output-2-stage-ota.raw gm_db,pm_deg,zdb_f,cdb_f,dc_gain
.endc

.end
