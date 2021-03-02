* Symmetrical Amplifier

*** Setup ************************************************************************
* Include Model Files
.include ../lib/90nm_NMOS_bulk89211.sp
.include ../lib/90nm_PMOS_bulk15176.sp

* Set Ambient Temperature
.option TEMP=27C

* Design Paramters
.param VDD  = 1.2
.param VSS  = 0.0
.param L12  = 600n
.param L34  = 900n
.param L78  = 500n
.param L90  = 700n
.param W12  = 2.7u
.param W34  = 8.5u
.param W56  = 35u
.param W78  = 1.5u
.param W9   = 4.8u
.param W0   = 8.8u
.param VICM = 0.6
.param VOCM = 0.6
.param IREF = 50u
.param CL   = 10p

*** Netlist **********************************************************************
* Voltage Sources
vdd         DD                  gnd                 {VDD}
iref        gnd                 REF                 {IREF}

* AC
vip         INP                 gnd                 {VICM}
vin         INN                 E                   0.0 ac -1.0
ein         E   gnd     OUT     gnd                 1.0

* DC
*vocm       OUT                  gnd                 {VOCM}
*vipcm      INP                  gnd                 {VICM}
*vincm      INN                  gnd                 {VICM}

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>

* Reference Current Mirror
mn9     A       REF     gnd     gnd     ptmn        W={W9} L={L90}
mn0     REF     REF     gnd     gnd     ptmn        W={W0} L={L90}

* Differential Pair
mn1     C       INN     A       gnd     ptmn        W={W12} L={L12} 
mn2     B       INP     A       gnd     ptmn        W={W12} L={L12} 

* PMOS Current Mirrors
mp3     C       C       DD      DD      ptmp        W={W34} L={L34} 
mp4     B       B       DD      DD      ptmp        W={W34} L={L34} 
mp5     D       C       DD      DD      ptmp        W={W56} L={L34} 
mp6     OUT     B       DD      DD      ptmp        W={W56} L={L34}

* NMOS Current Mirror
mn7     D       D       gnd     gnd     ptmn        W={W78} L={L78} 
mn8     OUT     D       gnd     gnd     ptmn        W={W78} L={L78} 

* Load Capacitance
*cx..x <positive terminal> <negative terminal> <parameters>
cL          OUT                   gnd                 {CL}

*** AC Simulation ***************************************************************
.control
AC Analysis 10 points per decade from 1Hz to 100GHz
ac dec 10 1Hz 100GHz
run

* Convert rad -> deg
let pdb = (180 / PI) * ph(OUT)

* Get Gain
let adb = vdb(OUT) - vdb(INN)

* Gain Margin: Find value of V_O in dB when phase == 0
* meas ac gm_db find vdb(OUT) when vp(OUT)=0
meas ac gm_db find adb when pdb = 0

* Phase Margin: Find value of phase when V_O == 0dB
meas ac pm_deg find pdb when adb = 0

* DC Gain: Find gain in dB at f = 1Hz
meas ac dc_gain find adb at = 1

* Unity Gain Frequency: Find f when V_O crosses 0dB
meas ac zdb_f when adb = 0

* 3dB Cut Off Frequency: Find f when V_O crosses -3dB
let co = dc_gain - 3
meas ac cdb_f when adb = co

*plot -vdb(INN) 
*plot (180 / PI) * ph(OUT)
*plot -vdb(INN) ph(INN)
*print gm_db pm_deg zdb_f cdb_f dc_gain

* Save Results
set controlswait
set filetype = ascii
set wr_vecnames
set wr_singlescale
unset appendwrite
option numdgt=7
wrdata ./symamp.raw gm_db,pm_deg,zdb_f,cdb_f,dc_gain,adb,pdb
.endc

*** DC Simulation **************************************************************
*.control
***dc va 0.0 1.2 0.01
*op
*
*let rout = 1 / (@mn8[gds] + @mp6[gds])
*let A0dB = 20 * log10(4 * @mn1[gm] * rout)
*let f3dB = 1 / (2 * PI * 10p * rout)
*
*print @mn0[id] @mn9[id] @mn2[id] @mp4[id] @mp6[id] @mn8[id] A0dB f3dB
*.endc

.end
