*** Playground / Sandbox for testing

* Include Model Files
*.include ./lib/45nm_NMOS_bulk33121.sp
*.include ./lib/45nm_PMOS_bulk63873.sp
.include ./lib/90nm_NMOS_bulk89211.sp
.include ./lib/90nm_PMOS_bulk15176.sp

* Set Ambient Temperature
.option TEMP=27C

* Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>
vg          gate                gnd                 dc 0.0
vd          drain               gnd                 dc 0.0
*vb          bulk                gnd                 dc 0.0

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mp0     drain   gate    gnd     gnd         ptmp    W=2u L=300n
*mn0     drain   gate    gnd     gnd         ptmn    W=2u L=300n

.probe dc v(*) i(*)

*.dc vg -1.2 0.0 0.01 vd -1.2 0.0 0.01
.dc vd -1.2 0.0 0.01 vg -1.2 0.0 0.01

*.dc vg 0.0 1.2 0.1 vd 0.0 1.2 0.01
*.dc vd 0.0 1.2 0.01 vg 0.0 1.2 0.1

.save all
*.control
*.endc

.end
