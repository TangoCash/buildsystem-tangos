# buildsystem-tangos

## Quick Building for e.g. Mut@nt/AX HD51:


----------


 1. `git clone https://github.com/TangoCash/buildsystem-tangos.git ~/BTC`
 2. `cd ~/BTC`
 3. `sudo ./prepare-for-bs.sh`

 4. `./make.sh hd51`
 5. `make flashimage`


----------


## Quick Building for e.g. Mut@nt/AX HD60:


----------


 1. `git clone https://github.com/TangoCash/buildsystem-tangos.git ~/BTC`
 2. `cd ~/BTC`
 3. `sudo ./prepare-for-bs.sh`

 4. `./make.sh hd60`
 5. `make flashimage`


----------


alternate boxtypes to use with `./make.sh`
 - `osmini4k osmio4k osmio4kplus`
 - `hd51 bre2ze4k h7`
 - `hd60 hd61`
 - `vuzero4k vusolo4k vuuno4k vuuno4kse vuduo4k vuultimo4k`
 - `vuduo vuduo2`
 - `osnino osninoplus osninopro`
 - `gb800se`


----------


alternate targets
 - `make neutrino`
 - `make ofgimage`
 - `make online-image`


----------


- to view verbose messages use: `./makev <target>`
- to create extended logfile use `./makelog <target>`


