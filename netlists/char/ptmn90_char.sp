* NMOS Charateristics

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
mn0     drain   gate    gnd     bulk        ptmn    W=1u L=150n

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

    let final_w = 10.0u
    let delta_w = 0.5u
    let curr_w  = 1.0u

    while curr_w <= final_w
        alter @mn0[w] = curr_w

        let final_l = 3.0u
        let delta_l = 250n
        let curr_l  = 250n

        while curr_l <= final_l
            alter @mn0[l] = curr_l

            let final_b = -1.2
            let delta_b = 0.1
            let curr_b  = 0.0

            while curr_b >= final_b
                alter vb dc = curr_b

                run

                wrdata ../../data/ptmn90.out @mn0[W] @mn0[L]
                + @mn0[vds] @mn0[vgs] @mn0[vbs] @mn0[vth] @mn0[vdsat]
                + @mn0[id]  @mn0[gbs] @mn0[gbd] @mn0[gds] @mn0[gm] @mn0[gmbs]
                + @mn0[cbb] @mn0[csb] @mn0[cdb] @mn0[cgb]
                + @mn0[css] @mn0[csd] @mn0[csg] @mn0[cds]
                + @mn0[cdd] @mn0[cdg] @mn0[cbs] @mn0[cbd]
                + @mn0[cbg] @mn0[cgd] @mn0[cgs] @mn0[cgg]

                let curr_b = curr_b - delta_b
                unset wr_vecnames
            end

            let curr_l = curr_l + delta_l
        end
        
        let curr_w = curr_w + delta_w
    end

.endc

.end
