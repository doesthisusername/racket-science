# racket science
WIP basic TAS tools for NPEA00385 (Ratchet & Clank) in PPC64 assembly, for fun.

Including messy assembly.

# Info
## Capabilities
- Record input data to `/dev_hdd0/game/NPEA00385/USRDIR/replay.rtas`
- Start recording with L2+R2; end it with L2+R1
- Easy crashes

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