#define STATE_NONE 0
#define STATE_REC 1
#define STATE_PLAY 2
#define STATE_WAIT_REC 4
#define STATE_WAIT_PLAY 8

#define BTN_L2 1
#define BTN_R2 2
#define BTN_R1 8

#define REC_COMBO (BTN_L2 | BTN_R1)
#define PLAY_COMBO (BTN_L2 | BTN_R2)

#define REPLAY_PATH ((const char*)0x4F63C0)
#define INPUTS ((unsigned int*)0x964A40)
#define BUTTONS ((unsigned int*)0x964AE0)
#define FRAME ((unsigned int*)0xA10710)
#define FD ((unsigned int*)0xAFFFF0)
#define OLDFRAME ((unsigned int*)0xAFFFF8)
#define STATE ((unsigned int*)0xAFFFFC)

#define CLOSE ((void (*)(unsigned int))0x64F1C4)
#define READ ((void (*)(unsigned int, unsigned int*, unsigned int, unsigned int*))0x64F1E4)
#define OPEN ((void (*)(const char*, unsigned int, unsigned int*, unsigned int, const void*, unsigned int))0x64F204)
#define WRITE ((void (*)(unsigned int, unsigned int*, unsigned int, unsigned int*))0x6500A4)

void dummy() {
    switch(*STATE) {
        case STATE_NONE: 
            if(*BUTTONS & REC_COMBO == REC_COMBO) *STATE = STATE_WAIT_REC;
            else if(*BUTTONS & PLAY_COMBO == PLAY_COMBO) *STATE = STATE_WAIT_PLAY;
            break;
        case STATE_WAIT_REC:
            if(*OLDFRAME == 0 && *FRAME > 0) {
                OPEN(REPLAY_PATH, 0x42, FD, 0, 0, 0);
                *STATE = STATE_REC;
            }
            break;
        case STATE_WAIT_PLAY:
            if(*OLDFRAME == 0 && *FRAME > 0) {
                OPEN(REPLAY_PATH, 0x42, FD, 0, 0, 0);
                *STATE = STATE_PLAY;
            }
            break;
        case STATE_REC:
            if(*FRAME < *OLDFRAME) {
                CLOSE(*FD);
                *STATE = STATE_NONE;
            }
            else {
                WRITE(*FD, INPUTS, 0x564, 0);
            }
            break;
        case STATE_PLAY:
            if(*FRAME < *OLDFRAME) {
                CLOSE(*FD);
                *STATE = STATE_NONE;
            }
            else {
                READ(*FD, INPUTS, 0x564, 0);
            }
    }

    *OLDFRAME = *FRAME;
}