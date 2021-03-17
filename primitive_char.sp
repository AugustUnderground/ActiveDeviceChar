* Primitive Device Characterisation

* Include Model Files
.include ./lib/90nm_NMOS_bulk89211.sp
*.include ./lib/90nm_PMOS_bulk15176.sp
*.include ./lib/45nm_NMOS_bulk33121.sp
*.include ./lib/45nm_PMOS_bulk63873.sp

* Change to Device Type Accordingly
.param nmos=1 pmos=0

* Set Ambient Temperature
.option TEMP=27C

* Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>
vd          drain               gnd                 dc 0.0
vg          gate                gnd                 dc 0.0
vb          bulk                gnd                 dc 0.0

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
.if(pmos==1)
m0     drain   gate    gnd     bulk        pmos    W=1u L=300n
.dc vd -1.2 0.0 0.01 vg -1.2 0.0 0.01 $ DC Sweep 0.0 ≤ V_DS ≤ 1.2 and 0.0 ≤ V_GS ≤ 1.2
.else
m0     drain   gate    gnd     bulk        nmos    W=1u L=300n
.dc vd 0.0 1.2 0.01 vg 0.0 1.2 0.01 $ DC Sweep 0.0 ≤ V_DS ≤ 1.2 and 0.0 ≤ V_GS ≤ 1.2
.endif

* Save all Operating Point Paramters
.save @m0[W] @m0[L]
+ @m0[vds] @m0[vgs] @m0[vbs] @m0[vth] @m0[vdsat]
+ @m0[id]  @m0[gbs] @m0[gbd] @m0[gds] @m0[gm] @m0[gmbs]
+ @m0[cbb] @m0[csb] @m0[cdb] @m0[cgb]
+ @m0[css] @m0[csd] @m0[csg] @m0[cds]
+ @m0[cdd] @m0[cdg] @m0[cbs] @m0[cbd]
+ @m0[cbg] @m0[cgd] @m0[cgs] @m0[cgg]

* Simulation Control
.control
*option numdgt=7
*listing e
set controlswait
* set filetype=ascii
set filetype=binary
set wr_vecnames
set wr_singlescale
set appendwrite

compose widths  log=10 start=100n stop=100.0u
compose lengths log=10 start=100n stop=10.0u
compose bulks   start=0.0 stop=-1.0 step=-0.1

let counter = 0

foreach wid $&widths
    alter @m0[w] = $wid

    foreach len $&lengths
        alter @m0[l] = $len

        foreach blk $&bulks
            alter vb dc = $blk

            run

            let L = @m0[l]
            let W = @m0[w]
            let Vds = @m0[vds]
            let Vgs = @m0[vgs]
            let Vbs = @m0[vbs]

            let gm = @m0[gm]
            let gbd = @m0[gbd]
            let gbs = @m0[gbs]
            let gds = @m0[gds]
            let gmbs = @m0[gmbs]
            let id = @m0[id]
            let fug = @m0[gm] / (2 * PI * @m0[cgg])
            let vdsat = @m0[vdsat]
            let vth = @m0[vth]

            let m = 6
            let n = 7
            let k = length(@m0[cgs])

            compose A values (2/7) (-3/14) (2/7) (-3/14) (3/14) (-2/7) (3/14) (2/7) (-3/14) (-3/14) (2/7) (3/14) (3/14) (-2/7) (2/7) (2/7) (-3/14) (-3/14) (-2/7) (3/14) (3/14) (-3/14) (2/7) (2/7) (-3/14) (3/14) (3/14) (-2/7) (-3/14) (2/7) (-3/14) (2/7) (3/14) (-2/7) (3/14) (-3/14) (-3/14) (2/7) (2/7) (-2/7) (3/14) (3/14)
            reshape A [$&m] [$&n]

            let b = vector(n * k)
            reshape b [$&n][$&k]

            let b[0] = @m0[cgs] 
            let b[1] = @m0[css] 
            let b[2] = @m0[cdd] 
            let b[3] = @m0[cbb] 
            let b[4] = @m0[cgs] + @m0[css] + @m0[csg] + @m0[cgs] 
            let b[5] = @m0[cgg] + @m0[cdd] + @m0[cgd] + @m0[cdg] 
            let b[6] = @m0[cgg] + @m0[cbb] + @m0[cbg] + @m0[cgb]

            let x = vector(m * k)
            reshape x [$&m][$&k]

            let mm = m - 1
            let nn = n - 1

            compose msweep start=0 stop=$&mm step=1
            compose nsweep start=0 stop=$&nn step=1

            foreach midx $&msweep
                foreach nidx $&nsweep
                    let x[$midx] = x[$midx] + (A[$midx][$nidx] * b[$nidx])
                end
            end

            let cgd = x[0]
            let cgb = x[1]
            let cgs = x[2]
            let cds = x[3]
            let csb = x[4]
            let cdb = x[5]

            write ../../data/ptmn90.raw W L vds vgs vbs vth vdsat fug id gbs gbd gds gm gmbs cgd cgb cgs cds csb cdb
* write ../../data/ptmn90.raw @m0[W] @m0[L] @m0[vds] @m0[vgs] @m0[vbs] @m0[vth] @m0[vdsat] @m0[fug] @m0[id] @m0[gbs] @m0[gbd] @m0[gds] @m0[gm] @m0[gmbs] @m0[cgd] @m0[cgb] @m0[cgs] @m0[cds] @m0[csb] @m0[cdb]

            unset wr_vecnames
        end
    end
end

.endc

.end
