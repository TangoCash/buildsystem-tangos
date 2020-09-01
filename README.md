# buildsystem-tangos

##Quick Building for e.g. Mut@nt/AX HD51:


----------


 1.1. `git clone https://github.com/TangoCash/buildsystem-tangos.git ~/BTC`
 1.2. `cd ~/BTC`
 1.3. `sudo ./prepare-for-bs.sh`

 2.1. `./make.sh hd51`
 2.2 `make flashimage`

alternate targets:
 1. `make neutrino`
 2. `make ofgimage`
 3. `make online-image`


----------


to view verbose messages use: `./makev <target>`
to create extended logfile use `./makelog <target>`


