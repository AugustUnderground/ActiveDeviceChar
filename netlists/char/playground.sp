*** Playground / Sandbox for testing

* Include Model Files
*.include ../lib/45nm_NMOS_bulk33121.sp
*.include ../lib/45nm_PMOS_bulk63873.sp
.include ../lib/90nm_NMOS_bulk7675.sp
.include ../lib/90nm_PMOS_bulk17912.sp

* Set Ambient Temperature
.option TEMP=27C

* Voltage Sources
*vx..x <positive terminal> <negative terminal> <parameters>
vd          drain               gnd                 dc 1.2
vg          gate                gnd                 dc 0.6
vb          bulk                gnd                 dc 0.0

* Current Sources
iref 

* MOSFET
*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mn0     drain   gate    gnd     bulk         ptmn    W=1u L=300n


