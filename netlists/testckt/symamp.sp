* Symmetrical Amplifier

*** Setup ************************************************************************
* Include Model Files 90nm
*.include ../lib/90nm_NMOS_bulk89211.sp
*.include ../lib/90nm_PMOS_bulk15176.sp

* Include Model Files 45nm
.include ../lib/45nm_NMOS_bulk33121.sp
.include ../lib/45nm_PMOS_bulk63873.sp

* Set Ambient Temperature
.option TEMP=27C

* Design Paramters
.param VDD  = 1.2
.param VSS  = 0.0
.param VICM = 0.6
.param VOCM = 0.6
.param IREF = 10u
.param CL   = 10p

*$$$$$$$$$$$$$$$$$$$$$$$ 90 NM
* A₀dB  =  4.8000e+01
* f₀    =  9.3505e+03
* SR    =  1.0000e+06
* gds6  =  3.2767e-07
* gds8  =  2.5984e-07
* gm1   =  3.6894e-05
* fug12 =  5.0408e+08
* fug34 =  1.5297e+08
* fug78 =  5.2248e+08
*.param L12 =  1.1120e-06
*.param L34 =  9.5176e-07
*.param L78 =  1.6483e-06
*.param L90 =  8.0000e-07
*.param W12 =  1.0307e-06
*.param W34 =  1.7752e-06
*.param W56 =  7.1719e-06
*.param W78 =  1.0754e-06
*.param W9  =  1.5757e-06
*.param W0  =  2.9180e-06
*$$$$$$$$$$$$$$$$$$$$$$$$$$$$
 
*$$$$$$$$$$$$$$$$$$$$$$$ 45 NM
* A0dB => 48.0086
* f0   => 9385.11
* SR   => 1.0e6
* gm1  => 3.70671e-5
* gds8 => 2.54527e-7
* gds6 => 3.35157e-7
.param L12  = 8.85509e-7
.param L34  = 6.97961e-7
.param L78  = 1.31558e-6
.param L90  = 5.0e-7
.param W12  = 1.00365e-6
.param W34  = 1.79338e-6
.param W56  = 7.24527e-6
.param W78  = 1.00725e-6
.param W9   = 1.36712e-6
.param W0   = 2.5317e-6
*$$$$$$$$$$$$$$$$$$$$$$$$$$$$

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

* TRAN
*vinpulse    INP                 gnd                 PULSE(0.2 1.2 0 0 0 2.5u 5u)
*vout        INN                 OUT                 0.0

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
let pdb = (180 / PI) * (ph(OUT) - ph(INN))

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
*set controlswait
*set filetype = ascii
*set wr_vecnames
*set wr_singlescale
*unset appendwrite
*option numdgt=7
*wrdata ./symamp.raw gm_db,pm_deg,zdb_f,cdb_f,dc_gain,adb,pdb
.endc

** DC Simulation **************************************************************
*.control
**dc va 0.0 1.2 0.01
*op
*
*let rout = 1 / (@mn8[gds] + @mp6[gds])
*let A0dB = 20 * log10(4 * @mn1[gm] * rout)
*let f3dB = 1 / (2 * PI * 10p * rout)
*let SR = @mp6[id] / 10p
*
*let fug1 = @mn1[gm] / (2 * PI * @mn1[cgg])
*let fug2 = @mn2[gm] / (2 * PI * @mn2[cgg])
*let fug3 = @mp3[gm] / (2 * PI * @mp3[cgg])
*let fug4 = @mp4[gm] / (2 * PI * @mp4[cgg])
*let fug5 = @mp5[gm] / (2 * PI * @mp5[cgg])
*let fug6 = @mp6[gm] / (2 * PI * @mp6[cgg])
*let fug7 = @mn7[gm] / (2 * PI * @mn7[cgg])
*let fug8 = @mn8[gm] / (2 * PI * @mn8[cgg])
*let fug9 = @mn9[gm] / (2 * PI * @mn9[cgg])
*let fug0 = @mn0[gm] / (2 * PI * @mn0[cgg])
*
*print fug1 fug2 fug3 fug4 fug5 fug6 fug7 fug8 fug9 fug0
*
*print @mn1[vdsat] @mn2[vdsat] @mp3[vdsat] @mp4[vdsat] @mp5[vdsat] @mp6[vdsat] 
*print @mn7[vdsat] @mn8[vdsat] @mn9[vdsat] @mn0[vdsat]
*
*print @mn1[gds] @mn2[gds] @mp3[gds] @mp4[gds] @mp5[gds] @mp6[gds] 
*print @mn7[gds] @mn8[gds] @mn9[gds] @mn0[gds]
*
*print @mn0[id] @mn9[id] @mn2[id] @mp4[id] @mp6[id] @mn8[id] 
*print A0dB f3dB SR
*print (@mn1[gm] / @mn1[id]) @mp6[vdsat] @mn8[vdsat] @mn9[vdsat]
*
*print @mp6[gds] @mn8[gds] @mn1[gm]
*.endc

*** TRAN Simulation ************************************************************
*.control
*tran 100n 10u
*
*meas tran outmax max v(out) from=0u to=5u
*meas tran outmin min v(out) from=1u to=5u
*
*let upper = 0.8 * outmax
*let lower = 1.2 * outmin
*
*meas tran risetime TRIG v(out) VAL=lower RISE=1 TARG v(out) VAL=upper RISE=1
*meas tran falltime TRIG v(out) VAL=upper FALL=1 TARG v(out) VAL=lower FALL=1
*
*let slewrate = (risetime + falltime) / 2
*
*print slewrate
*.endc

.end
