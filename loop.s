# states: 0 = none; 1 = playing; 2 = recording
replay_path:    .string     "/dev_hdd0/game/NPEA00385/USRDIR/replay.rtas"

cmpwi   r28, 4              # check if inputs were actually updated
bge     exit
li      r3, 0xA0            # input buttons
lis     r5, 0xB0            # saved inputs
lis     r7, 0xA1            # current_time@h
lwz     r8, -0x04(r5)       # load tas state
lwzx    r4, r31, r3         # load buttons
andi.   r6, r4, 9           # BTN_L2 | BTN_R1
cmpwi   cr1, r8, 2          # in recording state?
cmpwi   r6, 9
crand   2, 6, 2             # recording && (buttons & (BTN_L2 | BTN_R1) == 9)
beq     stop                # close file
andi.   r4, r4, 3           # BTN_L2 | BTN_R2
cmpwi   r4, 3
lwz     r3, -0x10(r5)       # load fd
cmpwi   cr2, r3, 0          # is fd null?
cror    10, 6, 10           # state != 2 || fd != 0
bne     cr2, run            # skip file open if fd already not null or if not recording
lis     r3, 0x4F
addi    r3, r3, 0x63C0      # replay_path
li      r4, 0x42            # oflags (O_CREAT | O_RDWR)
addi    r5, r5, -0x10       # fd
li      r6, 0
li      r7, 0
bla     0x64F204            # _sys_fs_cellFsOpen
ld      r2, 0x28(r1)        # restore r2

run:
lis     r5, 0xB0
lwz     r3, -0x10(r5)
cror    2, 6, 2             # either condition true
cmpwi   cr1, r3, 0          # is fd null?
crand   2, 5, 2             # (recording || buttons & (BTN_L2 | BTN_R2) == 3) && (fd > 0)
bne     exit
li      r4, 2               # recording state
stw     r4, -0x04(r5)       # set state to recording state
mr      r4, r31             # buf
li      r5, 0x100           # size
li      r6, 0               # written
bla     0x6500A4            # _sys_fs_cellFsWrite
ld      r2, 0x28(r1)        # restore r2
b       exit

stop:
lwz     r3, -0x10(r5)       # load fd
bla     0x64F1C4            # _sys_fs_cellFsClose
ld      r2, 0x28(r1)        # restore r2
li      r3, 0              
stw     r3, -0x10(r5)       # fd is now null
stw     r3, -0x04(r5)       # state is now none

exit:     
ld      r0, 0xA0(r1)        # original
ba      0x11E3A4            # branch back to the end of update_inputs
