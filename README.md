# racket science
WIP basic TAS tools for NPEA00385 (Ratchet & Clank) in PPC64 assembly, for fun.

Including messy assembly. The C is just for helping me get an overview of my code - it is never compiled.

# Info
## Capabilities
- Record input data to `/dev_hdd0/game/NPEA00385/USRDIR/`
- Replay input data from `dev_hdd0/game/NPEA00385/USRDIR/replay0.rtas`
- Prime for recording by pressing L2+R1, then it will continuously record, splitting each load into a different file
- Prime for replaying by pressing L2+R2, then it will replay from the next load, and end on the next one after that
- Additionally, hold L1 as you prime for replaying to immediately switch to recording mode once the replay finishes. This modifies the replay!
- End recording/replaying by pressing L2+L3+R3
- Not as many crashes as before!

## How to make
Need a way to run `powerpc64-linux-gnu-as` and `powerpc64-linux-gnu-ld`. I use WSL (`sudo apt install binutils-powerpc64-linux-gnu`).

You'll also need a decrypted `EBOOT.BIN` for NPEA00385, and a way to resign it.

- Clone
- Put `EBOOT.ELF` in this directory, and rename it to `EBOOT.ELF.bak`
- `./make.sh` to make the patch
- `python3 apply.py` to apply the patch according to `patch.txt`
- Resign `EBOOT.ELF`
- Replace the game's `EBOOT.BIN` with the new one
- Run on your PS3 or RPCS3