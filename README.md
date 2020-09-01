## buildsystem-tangos

#Quick Building for e.g. Mut@nt/AX HD51:

- 1.) git clone https://github.com/TangoCash/buildsystem-tangos.git ~/BTC
- 2.) cd ~/BTC
- 3.) sudo ./prepare-for-bs.sh


- 4.) ./make.sh hd51
- 5.) make neutrino

- 6.) make flashimage
- or
- 6.) make ofgimage
- or
- 6.) make online-image

- to view verbose messages use ./makev <target>
- to create extended logfile use ./makelog <target>

