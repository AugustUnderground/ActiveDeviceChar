* NMOS Differential Pair

.subckt NDP inn inp outn outp ref ss w=1u l=150n

.include ../lib/45nm_NMOS_bulk33121.sp

*mx..x <drain> <gate> <source> <bulk> <model name> <parameters>
mnn     outn    inn      ref      ss       ptmn    W=w L=l
mnp     outp    inp      ref      ss       ptmn    W=w L=l

.ends NDP
