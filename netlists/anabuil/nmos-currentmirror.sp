* NMOS Current Mirror

.subckt NCM in out ref w=1u l=150n m=2

.include ../lib/45nm_NMOS_bulk33121.sp

.param w0 = w
.param w1 = {m * w0}

*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mn0     in      in      ref      ref         ptmn    W=w0 L=l
mn1     out     in      ref      ref         ptmn    W=w1 L=l

.ends NCM
