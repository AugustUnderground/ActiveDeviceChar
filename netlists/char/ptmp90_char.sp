* NMOS Characteristics

* Include Model Files
.include ./lib/90nm_PMOS_bulk15176.sp

* Set Ambient Temperature
.option TEMP=27C

* Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>
vd          drain               gnd                dc 0.0
vg          gate                gnd                dc 0.0
vb          bulk                gnd                dc 0.0

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mp0     drain   gate    gnd     gnd    ptmp        W=1u L=150n

* DC Sweep 0.0 ≤ V_DS ≤ 1.2 and 0.0 ≤ V_GS ≤ 1.2
.dc vd -1.2 0.0 0.01 vg -1.2 0.0 0.01

* Save all Operating Point Paramters
.save @mp0[W] @mp0[L]
+ @mp0[vds] @mp0[vgs] @mp0[vbs] @mp0[vth] @mp0[vdsat]
+ @mp0[id]  @mp0[gbs] @mp0[gbd] @mp0[gds] @mp0[gm] @mp0[gmbs]
+ @mp0[cbb] @mp0[csb] @mp0[cdb] @mp0[cgb]
+ @mp0[css] @mp0[csd] @mp0[csg] @mp0[cds]
+ @mp0[cdd] @mp0[cdg] @mp0[cbs] @mp0[cbd]
+ @mp0[cbg] @mp0[cgd] @mp0[cgs] @mp0[cgg]

* Simulation Control
.control
*    option numdgt=7
*    listing e

    set controlswait
    set filetype=ascii
    set wr_vecnames
    set wr_singlescale
    set appendwrite

    let init_w  = 1.0u
    let final_w = 5.0u
    let delta_w = 250n
    let curr_w  = 1.0u

    while curr_w <= final_w
        alter @mp0[w] curr_w

        let init_l  = 300n
        let final_l = 3.0u
        let delta_l = 150n
        let curr_l  = 300n

        while curr_l <= final_l
            alter @mp0[L] curr_l

            run

            wrdata ../data/ptmp90.out @mp0[W] @mp0[L]
            + @mp0[vds] @mp0[vgs] @mp0[vbs] @mp0[vth] @mp0[vdsat]
            + @mp0[id]  @mp0[gbs] @mp0[gbd] @mp0[gds] @mp0[gm] @mp0[gmbs]
            + @mp0[cbb] @mp0[csb] @mp0[cdb] @mp0[cgb]
            + @mp0[css] @mp0[csd] @mp0[csg] @mp0[cds]
            + @mp0[cdd] @mp0[cdg] @mp0[cbs] @mp0[cbd]
            + @mp0[cbg] @mp0[cgd] @mp0[cgs] @mp0[cgg]

            let curr_l = curr_l + delta_l
            unset wr_vecnames
        end
        
        let curr_w = curr_w + delta_w
    end

.endc

.end
