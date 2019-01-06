#define STATE_NONE 0
#define STATE_REC 1
#define STATE_PLAY 2
#define STATE_WAIT_REC 3
#define STATE_WAIT_PLAY 4

#define FLAG_NONE 0
#define FLAG_PLAY_LAST 1            // TODO
#define FLAG_PLAY_REC_AFTER 2

#define BTN_L2 1
#define BTN_R2 2
#define BTN_L1 4
#define BTN_R1 8
#define BTN_L3 0x200
#define BTN_R3 0x400

#define REC_COMBO (BTN_L2 | BTN_R1)
#define PLAY_COMBO (BTN_L2 | BTN_R2)
#define STOP_COMBO (BTN_L2 | BTN_L3 | BTN_R3)

#define REPLAY_PATH ((const char*)0x4F63C0)
#define INPUTS ((unsigned int*)0x964A40)
#define BUTTONS ((unsigned int*)0x964AE0)
#define FRAME ((unsigned int*)0xA10710)
#define FORMATTED_PATH ((char*)0xAFFFA0)
#define NREAD ((unsigned long long*)0xAFFFE8)
#define FD ((unsigned int*)0xAFFFF0)
#define OLDFRAME ((unsigned int*)0xAFFFF8)
#define FLAGS ((unsigned char*)0xAFFFFE)
#define STATE ((unsigned char*)0xAFFFFF)

#define SPRINTF ((int (*)(char*, const char*, ...))0x5CD2A8)
#define TIME ((unsigned long long (*)(void))0x650684)
#define CLOSE ((void (*)(unsigned int))0x64F1C4)
#define READ ((unsigned int (*)(unsigned int, unsigned int*, unsigned int, unsigned int*))0x64F1E4)
#define OPEN ((void (*)(const char*, unsigned int, unsigned int*, unsigned int, const void*, unsigned int))0x64F204)
#define WRITE ((void (*)(unsigned int, unsigned int*, unsigned int, unsigned int*))0x6500A4)

void entry() {
    switch(*STATE) {
        case STATE_NONE: 
            if(*BUTTONS & REC_COMBO == REC_COMBO) *STATE = STATE_WAIT_REC;
            else if(*BUTTONS & PLAY_COMBO == PLAY_COMBO) {
                if(*BUTTONS & BTN_L1) *FLAGS = FLAG_PLAY_REC_AFTER;
                *STATE = STATE_WAIT_PLAY;
            }
            break;
        case STATE_WAIT_REC:
            if(*BUTTONS & STOP_COMBO == STOP_COMBO) {
                *STATE = STATE_NONE;
                *FLAGS = FLAG_NONE;
            }
            else if(*OLDFRAME == 0 && *FRAME > 0) {
                SPRINTF(FORMATTED_PATH, REPLAY_PATH, TIME());
                OPEN(REPLAY_PATH, 0x42, FD, 0, 0, 0);
                *STATE = STATE_REC;
                entry();
            }
            break;
        case STATE_WAIT_PLAY:
            if(*BUTTONS & STOP_COMBO == STOP_COMBO) {
                *STATE = STATE_NONE;
                *FLAGS = FLAG_NONE;
            }
            else if(*OLDFRAME == 0 && *FRAME > 0) {
                SPRINTF(FORMATTED_PATH, REPLAY_PATH, 0);
                OPEN(FORMATTED_PATH, 0x42, FD, 0, 0, 0);
                *STATE = STATE_PLAY;
                entry();
            }
            break;
        case STATE_REC:
            if(*FRAME < *OLDFRAME || *BUTTONS & STOP_COMBO == STOP_COMBO) {
                CLOSE(*FD);
                if(*BUTTONS & STOP_COMBO == STOP_COMBO) *STATE = STATE_NONE;
                else *STATE = STATE_WAIT_REC;
                *FLAGS = FLAG_NONE;
            }
            else {
                WRITE(*FD, INPUTS, 0x564, 0);
            }
            break;
        case STATE_PLAY:
            if(*FRAME < *OLDFRAME || *BUTTONS & STOP_COMBO == STOP_COMBO) {
                CLOSE(*FD);
                *STATE = STATE_NONE;
                *FLAGS = FLAG_NONE;
            }
            else {
                READ(*FD, INPUTS, 0x564, NREAD);
                if(NREAD == 0) {
                    if(*FLAGS == FLAG_PLAY_REC_AFTER) {
                        *STATE = STATE_REC;
                        *FLAGS = FLAG_NONE;
                        entry();
                    }
                    else {
                        CLOSE(*FD);
                    }
                }
            }
    }

    *OLDFRAME = *FRAME;
}