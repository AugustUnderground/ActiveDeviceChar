* PMOS Differential Pair

.subckt PDP inn inp outn outp ref dd w=1u l=150n

.include ../lib/45nm_PMOS_bulk63873.sp

*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mpn     outn    inn      ref      dd       ptmp    W=w L=l
mpp     outp    inp      ref      dd       ptmp    W=w L=l

.ends PDP
