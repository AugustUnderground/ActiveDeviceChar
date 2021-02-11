* PMOS Characteristics

* Include Model Files
.include ../lib/90nm_PMOS_bulk15176.sp

* Set Ambient Temperature
.option TEMP=27C

* Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>
vd          drain               gnd                 dc 0.0
vg          gate                gnd                 dc 0.0
vb          bulk                gnd                 dc 0.0

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mp0     drain   gate    gnd     bulk        ptmp    W=1u L=300n

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

    compose widths  log=10 start=100n stop=100.0u
    compose lengths log=10 start=100n stop=10.0u
    compose bulks   start=0.0 stop=1.0 step=0.1

    let counter = 0

    foreach wid $&widths
        alter @mp0[w] = $wid

        foreach len $&lengths
            alter @mp0[l] = $len

            foreach blk $&bulks
                alter vb dc = $blk
                
                run

                wrdata ../../data/ptmp90.out @mp0[W] @mp0[L]
                + @mp0[vds] @mp0[vgs] @mp0[vbs] @mp0[vth] @mp0[vdsat]
                + @mp0[id]  @mp0[gbs] @mp0[gbd] @mp0[gds] @mp0[gm] @mp0[gmbs]
                + @mp0[cbb] @mp0[csb] @mp0[cdb] @mp0[cgb]
                + @mp0[css] @mp0[csd] @mp0[csg] @mp0[cds]
                + @mp0[cdd] @mp0[cdg] @mp0[cbs] @mp0[cbd]
                + @mp0[cbg] @mp0[cgd] @mp0[cgs] @mp0[cgg]

                unset wr_vecnames
                
                let counter = counter + 1
                echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~
                echo Iteration $&counter Complete
                echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~
            end
        end
    end

.endc

.end
