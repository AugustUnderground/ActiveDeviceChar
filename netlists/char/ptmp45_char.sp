* NMOS Characteristics

* Include Model Files
.include ../lib/45nm_PMOS_bulk63873.sp

* Set Ambient Temperature
.option TEMP=27C

* Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>
vd          drain               gnd                 dc -1.2
vg          gate                gnd                 dc -0.6
vb          bulk                gnd                 dc 0.0

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mp0     drain   gate    gnd     gnd     ptmp        W=1u L=150

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

    let final_w = 10.0u
    let delta_w = 0.5u
    let curr_w  = 0.5u

    while curr_w <= final_w
        alter @mp0[w] = curr_w

        let final_l = 500n
        let delta_l = 50n
        let curr_l  = 50n

        while curr_l <= final_l
            alter @mp0[L] = curr_l
            
            let final_b = 1.2
            let delta_b = 0.1
            let curr_b  = 0.0

            while curr_b <= final_b
                alter vb dc = curr_b
 
                run

                wrdata ../../data/ptmp45.out @mp0[W] @mp0[L]
                + @mp0[vds] @mp0[vgs] @mp0[vbs] @mp0[vth] @mp0[vdsat]
                + @mp0[id]  @mp0[gbs] @mp0[gbd] @mp0[gds] @mp0[gm] @mp0[gmbs]
                + @mp0[cbb] @mp0[csb] @mp0[cdb] @mp0[cgb]
                + @mp0[css] @mp0[csd] @mp0[csg] @mp0[cds]
                + @mp0[cdd] @mp0[cdg] @mp0[cbs] @mp0[cbd]
                + @mp0[cbg] @mp0[cgd] @mp0[cgs] @mp0[cgg]
            
                let curr_b = curr_b + delta_b
                unset wr_vecnames
            end

            let curr_l = curr_l + delta_l
            unset wr_vecnames
        end
        
        let curr_w = curr_w + delta_w
    end

.endc

.end
