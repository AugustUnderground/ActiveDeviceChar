* L C Filter test

Vi 1 0 dc 0 ac 1

Rs 1 2 50
C1 2 3 22p
C2 3 0 2.2p
L1 3 0 100n
C3 3 4 10p
C4 4 0 2.2p
L4 4 0 100n
C5 4 5 22p
RL 5 0 50

.control
ac dec 10 1Hz 200MEGHz

save all
.endc
.end
