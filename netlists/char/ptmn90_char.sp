* NMOS Characteristics

* Include Model Files
.include ../lib/90nm_NMOS_bulk7675.sp

* Set Ambient Temperature
.option TEMP=27C

* Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>
vd          drain               gnd                 dc 1.2
vg          gate                gnd                 dc 0.6
vb          bulk                gnd                 dc 0.0

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mn0     drain   gate    gnd     gnd         ptmn    W=1u L=150n

* DC Sweep 0.0 ≤ V_DS ≤ 1.2 and 0.0 ≤ V_GS ≤ 1.2
.dc vd 0 1.2 0.01 vg 0 1.2 0.01

* Save all Operating Point Paramters
.save @mn0[W] @mn0[L]
+ @mn0[vds] @mn0[vgs] @mn0[vbs] @mn0[vth] @mn0[vdsat]
+ @mn0[id]  @mn0[gbs] @mn0[gbd] @mn0[gds] @mn0[gm] @mn0[gmbs]
+ @mn0[cbb] @mn0[csb] @mn0[cdb] @mn0[cgb]
+ @mn0[css] @mn0[csd] @mn0[csg] @mn0[cds]
+ @mn0[cdd] @mn0[cdg] @mn0[cbs] @mn0[cbd]
+ @mn0[cbg] @mn0[cgd] @mn0[cgs] @mn0[cgg]

* Simulation Control
.control
*    option numdgt=7
*    listing e

    set controlswait
    set filetype=ascii
    set wr_vecnames
    set wr_singlescale
    set appendwrite

    let init_w  = 500n
    let final_w = 5u
    let delta_w = 100n
    let curr_w  = 500n

    while curr_w <= final_w
        alter @mn0[w] curr_w

        let init_l  = 150n
        let final_l = 1.5u
        let delta_l = 100n
        let curr_l  = 150n

        while curr_l <= final_l
            alter @mn0[L] curr_l

            run

            wrdata ../../data/ptmn45.out @mn0[W] @mn0[L]
            + @mn0[vds] @mn0[vgs] @mn0[vbs] @mn0[vth] @mn0[vdsat]
            + @mn0[id]  @mn0[gbs] @mn0[gbd] @mn0[gds] @mn0[gm] @mn0[gmbs]
            + @mn0[cbb] @mn0[csb] @mn0[cdb] @mn0[cgb]
            + @mn0[css] @mn0[csd] @mn0[csg] @mn0[cds]
            + @mn0[cdd] @mn0[cdg] @mn0[cbs] @mn0[cbd]
            + @mn0[cbg] @mn0[cgd] @mn0[cgs] @mn0[cgg]

            let curr_l = curr_l + delta_l
            unset wr_vecnames
        end
        
        let curr_w = curr_w + delta_w
    end

.endc

.end
