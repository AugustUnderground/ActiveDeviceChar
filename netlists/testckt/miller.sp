* Single-Ended Two-Stage Miller OTA

*** Setup ********************************************************************
* Include Model Files
.include ../lib/90nm_NMOS_bulk89211.sp
.include ../lib/90nm_PMOS_bulk15176.sp

* Set Ambient Temperature
.option TEMP=27C

* Design Paramters
.param VDD  = 1.2
.param VSS  = 0.0
.param L12  = 300n
.param L346 = 300n
.param L578 = 300n
.param W12  = 4.0u
.param W34  = 4.0u
.param W58  = 4.0u
.param W6   = 4.0u
.param W7   = 4.0u
.param VICM = 0.6
.param VOCM = 0.6
.param IREF = 50u
.param CL   = 10p
.param CC   = 3p

*** Netlist ******************************************************************

* Current/Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>

vdd         DD                  gnd                 {VDD}
iref        gnd                 REF                 {IREF}

* AC
*vip         INP                 gnd                 {VICM}
*vin         INN                 E                   0.0 ac -1.0
*ein         E   gnd     OUT     gnd                 1.0

* DC
vocm        OUT                 gnd                 {VOCM}
vincm       INN                 gnd                 {VICM}
vipcm       INP                 gnd                 {VICM}

* MOSFETs
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>

* Differential Pair
mn1     Y       INN    X        gnd     ptmn        w={W12} l={L12}
mn2     Z       INP    X        gnd     ptmn        w={W12} l={L12}

* Current Mirror
mp3     Y       Y       DD      DD      ptmp        w={W34} l={L346}
mp4     Z       Y       DD      DD      ptmp        w={W34} l={L346}

* Reference Current Mirror
mn5     X       REF     gnd     gnd     ptmn        w={W58} l={L578}
mn8     REF     REF     gnd     gnd     ptmn        w={W58} l={L578}

* Output Stage
mp6     OUT    Z        DD      DD      ptmp        w={W6}  l={L346}
mn7     OUT    REF      gnd     gnd     ptmn        w={W7}  l={L578}

* Compensation
ccomp       Z                   OUT                 {CC}

* Load Capacitance
*cx..x <positive terminal> <negative terminal> <parameters>
cload       OUT                 gnd                 {CL}

*** Simulation ***************************************************************
.control
*** AC Analysis 10 points per decade from 1Hz to 100GHz
*ac dec 10 1Hz 100GHz
*run 
*
** Convert rad -> deg
*let pdb = 180 / PI * vp(OUT)
*let adb = vdb(OUT) - vdb(INN)
*
** Gain Margin: Find value of V_o,CM in dB when pdb == 0
*meas ac gm_db find adb when pdb = 0
*
** Phase Margin: Find value of pdb when V_O == 0dB
*meas ac pm_deg find pdb when adb = 0
*
** DC Gain: Find gain in dB at f = 1Hz
*meas ac dc_gain find adb at = 1
*
** Unity Gain Frequency: Find f when V_O crosses 0dB
*meas ac zdb_f when adb = 0
*
** 3dB Cut Off Frequency: Find f when V_O crosses -3dB
*let cutoff = dc_gain - 3
*meas ac cdb_f when adb = cutoff

*plot vdb(OUT) ph(OUT)
*print gm_db pm_deg zdb_f cdb_f dc_gain

** Save Results
*set controlswait
*set filetype = ascii
*set wr_vecnames
*set wr_singlescale
*unset appendwrite
*option numdgt = 7
*wrdata ./single-output-2-stage-ota.raw gm_db,pm_deg,zdb_f,cdb_f,dc_gain

*** DC Operating Point Analysis
**dc va 0.0 1.2 0.01
op

let rds24 = 1 / (@mn2[gds] + @mp4[gds])
let rds67 = 1 / (@mn7[gds] + @mp6[gds])

let A0 = @mn1[gm] * rds24 * @mp6[gm] * rds67
let A0dB = 20 * log10(A0)
let f3dB = 1 / (2 * PI * rds24 * @mp6[gm] * rds67 * 3p)

print A0dB f3dB

.endc

.end
