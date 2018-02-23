## buildsystem-ddt

#Quick Building for e.g. Mutant HD51:

- 1.) git clone github.com/TangoCash/buildsystem-ddt.git ~/DDT
- 2.) cd ~/DDT
- 3.) sudo ./prepare-for-bs.sh
- 4.) ./make.sh 51 1 1 1 1 4 3
		optional:
		4.1.) echo FFMPEG_EXPERIMENTAL=1 >> config
- 5.) make neutrino-mp-plugins

- 6.) make flashimage
- oder
- 6.) make ofgimage
- oder
- 6.) make online-image 
