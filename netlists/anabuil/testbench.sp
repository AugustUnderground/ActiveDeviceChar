* Universal ANABUIL Testbench *

* Include MOSFETS
.include ../lib/45nm_NMOS_bulk33121.sp
.include ../lib/45nm_PMOS_bulk63873.sp

*** Include anabuil sub circuits
.include ./nmos-currentmirror.sp
.include ./pmos-currentmirror.sp
.include ./nmos-differentialpair.sp
.include ./pmos-differentialpair.sp

*** Target: Symmetrical Amplifier
.subckt SYMAMP ref inp inn outn outp dd ss
Xncm1   ref     w       ss      NCM     m=2
Xndp1   inn     inp     y       x       w       ss      NDP 
Xpcm1   x       z       dd      PCM     m=4
Xpcm2   y       outn    dd      PCM     m=4
Xndp2   z       outn    ss      NCM     m=1
.ends SYMAMP

*** Test Bench
* Voltage Sources
*vx..x <+ terminal> <- terminal> <params>
Vdd         dd          gnd         dc 1.2
Vin         inn         gnd         dc 0.0 ac -1.0
Vip         inp         gnd         dc 0.0 ac 1.0

* Current Sources
*ix..x <+ terminal> <- terminal> <params>
Iref        ref          dd         dc 25u ac 1u

* Load
*[c|r]x..x <+ terminal> <- terminal> <params>
CL          out         gnd         10p
*RL          out         gnd         5k

* DUT <ref>     <in+>   <in->   <out+>  <out->  <dd>    <ss>
Xdut    ref     inp     inn     gnd     out     dd      gnd     SYMAMP

*** Simulation
* Simulator Options
*.options savecurrents
*.options method=gear

*** Batch-Mode Execution
.control
    save all
    ac dec 10 1Hz 10GHz
*noise v(out) Iref dec 10 1kHz 100MEG
*dc Iref 0 50u 1u
    let phase = 180/PI*vp(out)
    
*meas ac gm_db find vdb(out) when vp(out)=0
    meas ac pm_deg find phase when vdb(out)=0
    meas ac fug when vdb(out)=0
    meas ac A0dB find vdb(out) at=1

    write ./acanalysis.raw
    quit
.endc

.end
