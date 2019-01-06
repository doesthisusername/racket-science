# states: 0 = STATE_NONE; 1 = STATE_REC; 2 = STATE_PLAY; 3 = STATE_WAIT_REC; 4 = STATE_WAIT_PLAY
replay_path:    .string         "/dev_hdd0/game/NPEA00385/USRDIR/replay%llu.rtas"

entry:
    cmpwi   r28, 4
    bge     exit
    lis     r4, 0xB0
    lbz     r5, -0x01(r4)
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
    andi.   r7, r6, 9           # L2, R1
    cmpwi   r7, 9
    beq     add_wait_rec
    andi.   r7, r6, 7           # L2, R2, (L1)
    cmpwi   r7, 7
    bne     skip_flag_rec_after
    li      r7, 2
    stb     r7, -0x02(r4)
    b       add_wait_play
skip_flag_rec_after:
    cmpwi   r7, 3
    beq     add_wait_play
    b       exit

add_wait_rec:
    li      r7, 3
    stb     r7, -0x01(r4)
    b       exit

add_wait_play:
    li      r7, 4
    stb     r7, -0x01(r4)
    b       exit

cond_activate:
    lwz     r6, 0xA0(r31)
    andi.   r6, r6, 0x601
    cmpwi   r6, 0x601
    bne     skip_reset
    li      r3, 0
    sth     r3, -0x02(r4)       # nice optimization
    b       exit 
skip_reset:
    lis     r6, 0xA1
    lwz     r6, 0x0710(r6)
    cmpwi   r6, 1
    ble     exit
    lwz     r8, -0x08(r4)
    cmpwi   r8, 1
    bne     exit
    addi    r7, r5, -2
    cmpwi   r7, 1               # rec
    li      r3, 0               # "default" time
    stb     r7, -0x01(r4)
    bne     skip_time
    bla     0x650684            # sys_time_get_system_time
    ld      r2, 0x28(r1)        # restore r2
skip_time:
    lis     r4, 0x4F
    mr      r5, r3              # va arg
    lis     r3, 0xB0
    addi    r4, r4, 0x63C0      # format
    addi    r3, r3, -0x60       # dst
    bla     0x5CD2A8            # sprintf
    lis     r5, 0xB0
    addi    r3, r5, -0x60       # formatted_path
    addi    r5, r5, -0x10       # fd
    li      r4, 0x42            # oflags (O_CREAT | O_RDWR)
    li      r6, 0
    li      r7, 0
    bla     0x64F204            # _sys_fs_cellFsOpen
    ld      r2, 0x28(r1)        # restore r2
    b       entry               # start recording on frame 1 instead of 2

state_rec:
    lis     r6, 0xA1
    lwz     r8, 0xA0(r31)
    andi.   r8, r8, 0x601       # L2, L3, R3
    cmpwi   cr1, r8, 0x601
    lwz     r6, 0x0710(r6)
    lwz     r7, -0x08(r4)
    cmpw    r6, r7
    cror    0, 0, 6
    blt     close
    lwz     r3, -0x10(r4)       # fd
    li      r5, 0x564           # size
    mr      r4, r31             # buf
    li      r6, 0               # nwritten
    bla     0x6500A4            # _sys_fs_cellFsWrite
    ld      r2, 0x28(r1)        # restore r2
    b       exit

state_play:
    lis     r6, 0xA1
    lwz     r8, 0xA0(r31)
    andi.   r8, r8, 0x601       # L2, L3, R3
    cmpwi   cr1, r8, 0x601
    lwz     r6, 0x0710(r6)
    lwz     r7, -0x08(r4)
    cmpw    r6, r7
    cror    0, 0, 6
    blt     close
    lwz     r3, -0x10(r4)       # fd
    li      r5, 0x564           # size
    addi    r6, r4, -0x18       # nread
    mr      r4, r31             # buf
    bla     0x64F1E4            # _sys_fs_cellFsRead
    ld      r2, 0x28(r1)        # restore r2
    lis     r4, 0xB0
    ld      r3, -0x18(r4)
    cmpdi   r3, 0
    bne     exit
    lbz     r6, -0x02(r4)
    cmpwi   r6, 2
    bne     close
    li      r3, 1
    li      r5, 0
    stb     r3, -0x01(r4)       # STATE_REC
    stb     r5, -0x02(r4)       # FLAG_NONE
    b       entry

close:
    lwz     r3, -0x10(r4)       # load fd
    bla     0x64F1C4            # _sys_fs_cellFsClose
    ld      r2, 0x28(r1)        # restore r2
    lis     r4, 0xB0
    lbz     r5, -0x01(r4)
    lwz     r6, 0xA0(r31)
    andi.   r6, r6, 0x601       # L2, L3, R3
    cmpwi   cr1, r6, 0x601
    li      r3, 3               # STATE_WAIT_REC
    cmpwi   r5, 1
    crandc  2, 2, 6
    beq     skip_rec
    li      r3, 0               # STATE_NONE
skip_rec:
    stb     r3, -0x01(r4)       # set state
    li      r3, 0               # FLAG_NONE
    stb     r3, -0x02(r4)       # set flags

exit:
    lis     r4, 0xB0
    lis     r6, 0xA1
    lwz     r6, 0x0710(r6)
    stw     r6, -0x08(r4)
    ld      r0, 0xA0(r1)
    ba      0x11E3A4
