* NMOS Characteristics

* Include Model Files
.include ../lib/90nm_NMOS_bulk89211.sp

* Set Ambient Temperature
.option TEMP=27C

* Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>
vd          drain               gnd                 dc 1.2
vg          gate                gnd                 dc 0.6
vb          bulk                gnd                 dc 0.0

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mn0     drain   gate    gnd     gnd         ptmn    W=2u L=300n

* DC Sweep 0.0 ≤ V_DS ≤ 1.2 and 0.0 ≤ V_GS ≤ 1.2
*.dc vd 0 1.2 0.01 vg 0 1.2 0.01

.control
* Variables
    let mc_runs = 10
    let run = 0
    set curplot = new
    set scratch = $curplot

* Distribution Sampling Functions
    define unif ( nom , var ) ( nom + nom * var * sunif (0))
    define aunif ( nom , avar ) ( nom + avar * sunif (0))
    define gauss ( nom , var , sig ) ( nom + nom * var / sig * sgauss (0))
    define agauss ( nom , avar , sig ) ( nom + avar / sig * sgauss (0))

    dowhile run < mc_runs
        alter @mn0[u0] gauss()
        alter @mn0[vth0] gauss()

        ac dec 10 0.01 1G
    end

.endc

.end
