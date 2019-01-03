# states: 0 = STATE_NONE; 1 = STATE_REC; 2 = STATE_PLAY; 3 = STATE_WAIT_REC; 4 = STATE_WAIT_PLAY
replay_path:    .string         "/dev_hdd0/game/NPEA00385/USRDIR/replay.rtas"

entry:
    lis     r4, 0xB0
    lwz     r5, -0x04(r4)
    cmpwi   r5, 0
    beq     state_none
    cmpwi   r5, 1
    beq     state_rec
    cmpwi   r5, 2
    beq     state_play
    cmpwi   r5, 3
    beq     cond_activate
    cmpwi   r5, 4
    beq     cond_activate
    b       exit

state_none:
    lwz     r6, 0xA0(r31)
    andi.   r7, r6, 9
    cmpwi   r7, 9
    beq     add_wait_rec
    andi.   r7, r6, 3
    cmpwi   r7, 3
    beq     add_wait_play
    b       exit

add_wait_rec:
    li      r7, 3
    stw     r7, -0x04(r4)
    b       exit

add_wait_play:
    li      r7, 4
    stw     r7, -0x04(r4)
    b       exit

cond_activate:
    lis     r6, 0xA1
    lwz     r6, 0x0710(r6)
    cmpwi   r6, 1
    ble     exit
    lwz     r8, -0x08(r4)
    cmpwi   r8, 1
    bne     exit
    addi    r7, r5, -2
    stw     r7, -0x04(r4)
    lis     r3, 0x4F
    addi    r3, r3, 0x63C0      # replay_path
    addi    r5, r4, -0x10       # fd
    li      r4, 0x42            # oflags (O_CREAT | O_RDWR)
    li      r6, 0
    li      r7, 0
    bla     0x64F204            # _sys_fs_cellFsOpen
    ld      r2, 0x28(r1)        # restore r2
    b       exit

state_rec:
    lis     r6, 0xA1
    lwz     r6, 0x0710(r6)
    lwz     r7, -0x08(r4)
    cmpw    r6, r7
    blt     close
    lwz     r3, -0x10(r4)       # fd
    li      r5, 0x564           # size
    mr      r4, r31             # buf
    li      r6, 0               # written
    bla     0x6500A4            # _sys_fs_cellFsWrite
    ld      r2, 0x28(r1)        # restore r2
    b       exit

state_play:
    lis     r6, 0xA1
    lwz     r6, 0x0710(r6)
    lwz     r7, -0x08(r4)
    cmpw    r6, r7
    blt     close
    lwz     r3, -0x10(r4)       # fd
    li      r5, 0x564           # size
    mr      r4, r31             # buf
    li      r6, 0               # written
    bla     0x64F1E4            # _sys_fs_cellFsRead
    ld      r2, 0x28(r1)        # restore r2
    b       exit

close:
    lwz     r3, -0x10(r4)       # load fd
    bla     0x64F1C4            # _sys_fs_cellFsClose
    ld      r2, 0x28(r1)        # restore r2
    li      r3, 0               
    stw     r3, -0x04(r4)       # state is now STATE_NONE

exit:
    lis     r4, 0xB0
    lis     r6, 0xA1
    lwz     r6, 0x0710(r6)
    stw     r6, -0x08(r4)
    ld      r0, 0xA0(r1)
    ba      0x11E3A4
