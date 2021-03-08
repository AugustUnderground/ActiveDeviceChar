* Single-Ended Two-Stage Miller OTA

*** Setup ********************************************************************
* Include Model Files
.include ../lib/90nm_NMOS_bulk89211.sp
.include ../lib/90nm_PMOS_bulk15176.sp

* Include Model Files 45nm
*.include ../lib/45nm_NMOS_bulk33121.sp
*.include ../lib/45nm_PMOS_bulk63873.sp

* Set Ambient Temperature
.option TEMP=27C

* Design Paramters
.param VDD  = 1.2
.param VSS  = 0.0
.param VICM = 0.6
.param VOCM = 0.6
.param IREF = 10u
.param CL   = 10p
.param CC   = 3p

*$$$$$$$$$$$$$$$$$$$$$$$ 90 NM
* A₀dB     =  8.4000e+01
* f₀       =  2.3387e+02
* SR       =  1.6667e+07
* gds1     =  2.0240e-07
* gds4     =  2.6173e-07
* gds7     =  1.7894e-06
* gds6     =  2.4956e-06
* gm1      =  6.9866e-05
* gm6      =  4.5115e-04
* fug12    =  6.6871e+08
* fug346   =  9.2861e+08
.param L12     =  9.7997e-07
.param L346    =  4.2799e-07
.param L578    =  8.0000e-07
.param W12     =  1.7989e-06
.param W34     =  1.4413e-06
.param W5      =  3.0166e-06
.param W6      =  1.3854e-05
.param W7      =  1.5083e-05
.param W8      =  2.9006e-06
*$$$$$$$$$$$$$$$$$$$$$$$$$$$$
 
*$$$$$$$$$$$$$$$$$$$$$$$ 45 NM
* A0dB = 84.1937
* f0   = 249.656
* SR   = 1.66667e7
* gm1  = 7.62656e-5
* gm6  = 0.000431692
* gds1 = 1.82738e-7
* gds4 = 2.57176e-7
* gds7 = 2.07488e-6
* gds6 = 2.54308e-6
*.param L12      = 7.79861e-7
*.param L346     = 3.18997e-7
*.param L578     = 5.0e-7
*.param W12      = 1.75056e-6
*.param W34      = 1.57174e-6
*.param W5       = 2.54792e-6
*.param W6       = 1.53945e-5
*.param W7       = 1.27396e-5
*.param W8       = 2.44992e-6
*$$$$$$$$$$$$$$$$$$$$$$$$$$$$

****************** 90 nm ************************
* A₀dB     =  8.4000e+01
* f₀       =  2.3613e+02
* SR       =  1.6667e+07
* gds1     =  2.1404e-07
* gds4     =  2.5880e-07
* gds7     =  1.7894e-06
* gds6     =  2.4643e-06
* gm1      =  7.0542e-05
* gm6      =  4.5190e-04
* fug12    =  8.1492e+08
* fug346   =  8.9120e+08
*.param L12     =  8.6424e-07
*.param L346    =  4.3444e-07
*.param L578    =  8.0000e-07
*.param W12     =  1.6150e-06
*.param W34     =  1.4660e-06
*.param W5      =  3.0111e-06
*.param W6      =  1.4122e-05
*.param W7      =  1.5056e-05
*.param W8      =  2.8953e-06
************************************************

****************** 45 nm ************************
* A₀dB     =  8.4000e+01
* f₀       =  2.5468e+02
* SR       =  1.6667e+07
* gds1     =  1.8587e-07
* gds4     =  2.5989e-07
* gds7     =  2.0749e-06
* gds6     =  2.5752e-06
* gm1      =  7.6084e-05
* gm6      =  4.3178e-04
* fug12    =  7.4489e+08
* fug346   =  9.5985e+08
*.param L12     =  7.3556e-07
*.param L346    =  3.1313e-07
*.param L578    =  5.0000e-07
*.param W12     =  1.6612e-06
*.param W34     =  1.5429e-06
*.param W5      =  2.5411e-06
*.param W6      =  1.5078e-05
*.param W7      =  1.2706e-05
*.param W8      =  2.4434e-06
************************************************

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
mn5     X       REF     gnd     gnd     ptmn        w={W5} l={L578}
mn8     REF     REF     gnd     gnd     ptmn        w={W8} l={L578}

* Output Stage
mp6     OUT    Z        DD      DD      ptmp        w={W6}  l={L346}
mn7     OUT    REF      gnd     gnd     ptmn        w={W7}  l={L578}

* Compensation
ccomp       Z                   OUT                 {CC}

* Load Capacitance
*cx..x <positive terminal> <negative terminal> <parameters>
cload       OUT                 gnd                 {CL}

*** Simulation ***************************************************************
*** AC Analysis 10 points per decade from 1Hz to 100GHz
*.control
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
*
**plot vdb(OUT) ph(OUT)
**print gm_db pm_deg zdb_f cdb_f dc_gain
*
** Save Results
**set controlswait
**set filetype = ascii
**set wr_vecnames
**set wr_singlescale
**unset appendwrite
**option numdgt = 7
**wrdata ./miller.raw gm_db,pm_deg,zdb_f,cdb_f,dc_gain,adb,pdb
*.endc

*** DC Operating Point Analysis
.control
**dc va 0.0 1.2 0.01
op

print @mn8[id] @mn5[id] @mn1[id]

let rds24 = 1 / (@mn2[gds] + @mp4[gds])
let rds67 = 1 / (@mn7[gds] + @mp6[gds])

let A0 = @mn1[gm] * rds24 * @mp6[gm] * rds67
let A0dB = 20 * log10(A0)
let f3dB = 1 / (2 * PI * rds24 * @mp6[gm] * rds67 * 3p)

let fug1 = @mn1[gm] / (2 * PI * @mn1[cgg])
let fug2 = @mn2[gm] / (2 * PI * @mn2[cgg])
let fug3 = @mp3[gm] / (2 * PI * @mp3[cgg])
let fug4 = @mp4[gm] / (2 * PI * @mp4[cgg])
let fug5 = @mn5[gm] / (2 * PI * @mn5[cgg])
let fug6 = @mp6[gm] / (2 * PI * @mp6[cgg])
let fug7 = @mn7[gm] / (2 * PI * @mn7[cgg])
let fug8 = @mn8[gm] / (2 * PI * @mn8[cgg])

print fug1 fug2 fug3 fug4 fug5 fug6 fug7 fug8

print @mn1[vdsat] @mn2[vdsat] @mp3[vdsat] @mp4[vdsat] @mn5[vdsat] @mp6[vdsat] 
print @mn7[vdsat] @mn8[vdsat]

print @mn1[gds] @mn2[gds] @mp3[gds] @mp4[gds] @mn5[gds] @mp6[gds] 
print @mn7[gds] @mn8[gds]

print @mp6[gm] @mn1[gm]

print @mn2[gds] @mp4[gds] @mp6[gds] @mn7[gds]

print (@mn1[gm] / @mn1[id])
print @mp4[vdsat]
print @mn5[vdsat]
print @mp6[vdsat]
print @mn7[vdsat]

print A0dB f3dB 

.endc

.end
