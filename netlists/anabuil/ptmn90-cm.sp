* NMOS Current Mirror

* Include Model Files
.include ../lib/90nm_NMOS_mc.sp

* Set Ambient Temperature
.option TEMP=27C

* Output Voltage
vout        out                 gnd                 dc 0.6

* Bias Current
ibias       gnd                 in                 dc 25u

* Current Mirror
mn0     in      in      gnd     gnd     ptmn    W=2u L=300n
mn1     out     in      gnd     gnd     ptmn    W=2u L=300n

* DC Sweep 0.0 ≤ V_DS ≤ 1.2 and 0.0 ≤ V_GS ≤ 1.2
*.dc ibias 5u 50u 0.1u vout 0 1.2 0.01 
.op
.save all

.control
    define agauss ( nom , avar , sig ) ( nom + avar / sig * sgauss (0))

    let default_toxe    = @mn0[toxe]
    let default_u0      = @mn0[u0]
    let default_vth     = @mn0[vth]
    let var_percent     = 10

    altermod @mn0[toxe] = AGAUSS(default_toxe, default_toxe, var_percent)
    altermod @mn0[u0]   = AGAUSS(default_u0, default_u0, var_percent)
    altermod @mn0[vth]  = AGAUSS(default_vth, default_vth, var_percent)

    run

    let idiff = @mn0[id] - @mn1[id]
    print idiff

* Variables
*    let mc_runs = 10
*    let run = 0
*
* Distribution Sampling Functions
*   define unif ( nom , var ) ( nom + nom * var * sunif (0))
*   define aunif ( nom , avar ) ( nom + avar * sunif (0))
*   define gauss ( nom , var , sig ) ( nom + nom * var / sig * sgauss (0))
*   define agauss ( nom , avar , sig ) ( nom + avar / sig * sgauss (0))
*
*    dowhile run < mc_runs
*        run
*        let idiff = @mn0[id] - @mn1[id]
*        print idiff
*        wrdata ../data/ptmn90-cm.out 
*
*        let run = run + 1
*    end
*
.endc

.end
