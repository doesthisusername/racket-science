# racket science
WIP basic TAS tools for NPEA00385 (Ratchet & Clank) in PPC64 assembly, for fun.

Including messy assembly. The C is just for helping me get an overview of my code - it is never compiled.

# Info
## Capabilities
- Record/replay input data to/from `/dev_hdd0/game/NPEA00385/USRDIR/replay.rtas`
- Prime for recording by pressing L2+R1, then it will record from the next planet load, and end on the next one after that
- Prime for replaying by pressing L2+R2, then it will replay from the next planet load, and end on the next one after that
- Crash when ending recording or playback

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