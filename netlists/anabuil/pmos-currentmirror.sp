* PMOS Current Mirror

.subckt PCM in out ref w=1u l=150n m=2

.include ../lib/45nm_PMOS_bulk63873.sp

.param w0 = w
.param w1 = {m * w0}

*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mp0     in      in      ref      ref         ptmp    W=w0 L=l
mp1     out     in      ref      ref         ptmp    W=w1 L=l

.ends PCM
