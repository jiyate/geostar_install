####################################################
# The Makefile for installing libraries 
####################################################
VPATH = ./make

# The path to the repo
repo_source = $(CURDIR)

# Information for download the geostar_libraries
fileid="1f_PRYm5eUBqVJBZw9_X3Bx6h1gr-l8oF"
filename="geostar_libraries.tar.gz"

all: geostar

# 0.
install_dependence:
	mkdir -p $(VPATH)
	sudo apt-get install libpixman-1-dev
	sudo apt-get install libfontconfig1-dev
	sudo apt-get install m4
	sudo apt-get install libpango1.0-dev
	touch $(VPATH)/$@

# 1.
prepare_src: install_dependence
	mkdir -p ~/geostar
	curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
	curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $$NF}' ./cookie`&id=${fileid}" -o ${filename}
	curl -L -o geostar_src.tar.gz "https://drive.google.com/uc?export=download&id=1ULCmhzbj0EXatO0rFErZUlEIJZQlIy2G"
	rm ./cookie
	touch $(VPATH)/$@

# 2.
unzip_repo: prepare_src
	cd ~/geostar; \
	tar xvzf $(repo_source)/geostar_libraries.tar.gz; \
	tar xvzf $(repo_source)/geostar_src.tar.gz
	touch $(VPATH)/$@

# 3.
install_cmake: unzip_repo
	cd ~/geostar/libraries; \
	tar xvzf cmake-3.12.0-rc2-Linux-x86_64.tar.gz
	touch $(VPATH)/$@

# 4. (takes 20 minutes)
boost: install_cmake
	cd ~/geostar/libraries; \
	tar xvzf boost_1_65_0.tar.gz; \
	cd ./boost_1_65_0; \
	./bootstrap.sh --prefix=`pwd`; \
	./b2
	touch $(VPATH)/$@

# 5.
eigen-eigen: boost
	cd ~/geostar/libraries; \
	tar xvzf eigen-eigen-5a0156e40feb.tar.gz
	touch $(VPATH)/$@

# 6.
fftw: eigen-eigen
	cd ~/geostar/libraries; \
	tar xvzf fftw-3.3.7.tar.gz; \
	cd ./fftw-3.3.7; \
	./configure --prefix=`pwd`; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 7.
zlib: fftw
	cd ~/geostar/libraries; \
	tar xvzf zlib-1.2.11.tar.gz; \
	cd ./zlib-1.2.11; \
	./configure --prefix=`pwd`; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 8. (takes 5-10 minutes)
hdf5: zlib
	cd ~/geostar/libraries; \
	tar xvzf hdf5-1.10.0-patch1.tar.gz; \
	cd hdf5-1.10.0-patch1; \
	./configure --enable-cxx --prefix=`pwd`; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 9. (takes about 75 minutes)
gdal: hdf5
	cd ~/geostar/libraries; \
	tar xvzf gdal-2.3.0.tgz; \
	cd gdal-2.3.0; \
	./configure --prefix=`pwd`; \
	$(MAKE) clean; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 10.
create_gais-gis_dir: gdal
	cd ~/geostar/libraries; \
	mkdir gaia-gis
	touch $(VPATH)/$@

# 11.
freexl: create_gais-gis_dir
	cd ~/geostar/libraries/gaia-gis; \
	tar xvzf ../freexl-1.0.2.tar.gz; \
	cd ./freexl-1.0.2; \
	./configure --prefix=`pwd`/../installdir; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 12.
geos: freexl
	cd ~/geostar/libraries/gaia-gis; \
	tar xvzf ../geos-3.5.0.tgz; \
	cd geos-3.5.0; \
	./configure --prefix=`pwd`/../installdir; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 13.
openjpeg: geos
	cd ~/geostar/libraries/gaia-gis; \
	tar xvzf ../openjpeg-master.tgz; \
	cd openjpeg-master; \
	rm CMakeCache.txt; \
	mkdir build; \
	cd build; \
	cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=on -DCMAKE_INSTALL_PREFIX=`pwd` -DCMAKE_SHARED_LINKER_FLAGS=-L`pwd`/../installdir/lib -DCMAKE_C_FLAGS=-I`pwd`/../installdir/include; \
	$(MAKE); \
	$(MAKE) install
	# which will fail...yeah...can't figure it out
	# Please do 'touch ./make/openjpeg' manually

# 13.5.
fix_openjpeg: openjpeg
	cd ~/geostar/libraries/gaia-gis/openjpeg-master/build; \
	cp -r include/openjpeg-2.3 ../../installdir/include; \
	cp -r lib/* ../../installdir/lib
	touch $(VPATH)/$@

# 14.
proj: fix_openjpeg
	cd ~/geostar/libraries/gaia-gis; \
	tar xvzf ../proj-4.9.2.tar.gz; \
	cd proj-4.9.2; \
	./configure --prefix=`pwd`/../installdir; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 15.
sqlite: proj
	cd ~/geostar/libraries/gaia-gis; \
	tar xvzf ../sqlite-autoconf-3110100.tar.gz; \
	cd sqlite-autoconf-3110100; \
	export "CFLAGS=-DSQLITE_TEMP_STORE=3 -DSQLITE_ENABLE_LOCKING_STYLE=0 -DSQLITE_ENABLE_RTREE=1 -DSQLITE_ENABLE_LOCKING_STYLE=0 -DSQLITE_ENABLE_RTREE=1 -DSQLITE_ENABLE_STAT3=1 -DSQLITE_ENABLE_TREE_EXPLAIN=1 -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1 -DSQLITE_ENABLE_COLUMN_METADATA=1"; \
	./configure --prefix=`pwd`/../installdir; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 16.
libspatialite: sqlite
	cd ~/geostar/libraries/gaia-gis; \
	tar xvzf ../libspatialite.tgz; \
	cd libspatialite; \
	export "CFLAGS=-I`pwd`/../../zlib-1.2.11/include -I`pwd`/../installdir/include"; \
	export "LDFLAGS=-L`pwd`/../../zlib-1.2.11/lib -L`pwd`/../installdir/lib"; \
	export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu; \
	$(MAKE) clean; \
	./configure --prefix=`pwd`/../installdir --with-geosconfig=`pwd`/../installdir/bin/geos-config; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 17.
libsqlitecpp: libspatialite
	cd ~/geostar/libraries; \
	tar xvzf libsqlitecpp.tgz; \
	cd libsqlitecpp/src; \
	sed -i 's|^GEOSTAR=.*$|GEOSTAR='"$(dirname $(dirname $(dirname `pwd`)))"'|g' Makefile; \
	$(MAKE) clean; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 18.
simpleFeatures: libsqlitecpp
	cd ~/geostar/libraries; \
	tar xvzf simpleFeatures.tgz
	touch $(VPATH)/$@

# 19.
libspatialitecpp: simpleFeatures
	cd ~/geostar/libraries; \
	tar xvzf libspatialitecpp.tgz; \
	cd libspatialitecpp/src; \
	sed -i 's|^GEOSTAR=.*$|GEOSTAR='"$(dirname $(dirname $(dirname `pwd`)))"'|g' Makefile; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 20.
ifile_cpplib: libspatialitecpp
	cd ~/geostar/libraries; \
	tar xvzf ifile_cpplib.tgz; \
	cd ifile_cpplib; \
	sed -i 's|^GEOSTAR_HOME=.*$|GEOSTAR_HOME='"$(dirname $(dirname `pwd`))"'|g' Makefile; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 21.
cairo: ifile_cpplib
	cd ~/geostar/libraries; \
	tar xvjf cairo-1.14.12.tar.xz; \
	cd cairo-1.14.12; \
	./configure --prefix=`pwd`; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 22.
libsigc++: cairo
	cd ~/geostar/libraries; \
	tar xvjf libsigc++-2.10.0.tar.xz; \
	cd libsigc++-2.10.0; \
	sed -e '/^libdocdir =/ s/$(book_name)/libsigc++-2.10.0/' -i docs/Makefile.in; \
	./configure --prefix=`pwd` --with-boost-libdir=`pwd`/../boost_1_65_0/libs; \
	$(MAKE); \
	$(MAKE) install; \
	cp sigc++config.h include/sigc++-2.0
	touch $(VPATH)/$@

# 23.
cairomm: libsigc++
	cd ~/geostar/libraries; \
	tar xvzf cairomm-1.12.2.tar.gz; \
	cd cairomm-1.12.2; \
	sed -e '/^libdocdir =/ s/$(book_name)/cairomm-1.12.2/' -i docs/Makefile.in; \
	./configure --prefix=`pwd` --with-boost=`pwd`/../boost_1_65_0 PKG_CONFIG_PATH=`pwd`/../libsigc++-2.10.0/lib/pkgconfig:`pwd`/../cairo-1.14.12/lib/pkgconfig; \
	$(MAKE); \
	$(MAKE) install; \
	cp cairommconfig.h include/cairomm-1.0
	touch $(VPATH)/$@

# 24.
plplot: cairomm
	cd ~/geostar/libraries; \
	tar xvzf plplot-5.13.0.tar.gz; \
	cd plplot-5.13.0; \
	export PKG_CONFIG_PATH=`pwd`/../cairo-1.14.12/lib/pkgconfig:/usr/lib/x86_64-linux-gnu; \
	mkdir build_dir; \
	cd build_dir; \
	../../cmake-3.12.0-rc2-Linux-x86_64/bin/cmake  -DCMAKE_INCLUDE_PATH=`pwd`/../cairo-1.14.12/include -DCMAKE_LIBRARY_PATH=`pwd`/../cairo-1.14.12/lib -DCMAKE_INSTALL_PREFIX:PATH=`pwd` -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_DOX_DOC:BOOL=ON ../ >& cmake.out; \
	$(MAKE); \
	$(MAKE) install
	touch $(VPATH)/$@

# 25.
modify_path: plplot
	cd ~/geostar/src; \
	sed -i 's|^GEOSTAR_HOME=.*$|GEOSTAR_HOME='"$(dirname `pwd`)"'|g' Makefile; \
	make clean; \
	export LD_LIBRARY_PATH=../libraries/gdal-2.3.0/lib:../libraries/gaia-gis/installdir/lib:../libraries/libsqlitecpp/lib:../libraries/libspatialitecpp/lib; \
	touch $(VPATH)/$@


# Final
geostar: modify_path
	@echo "You have finished all installations."
	@echo "Test it by typing 'make test'"
	touch $(VPATH)/$@

##########################################################################
# Test part
test_ifile:
	cd ~/geostar/src; \
	make test_ifile_new; \
	rm a2.h5; \
	./test_ifile_new
	touch $(VPATH)/$@

test_sql:
	cd ~/geostar/src; \
	make test_sql_new; \
	rm a2.h5; \
	./test_sql_new
	touch $(VPATH)/$@

testcppvector:
	cd ~/geostar/src; \
	make testcppvector_new; \
	./testcppvector_new
	touch $(VPATH)/$@

test: test_ifile test_sql testcppvector
	@echo "Congratulations! You pass the test and is all done."
	touch $(VPATH)/$@

##########################################################################

# To be honest, I don't know how to nuke it... I guess it's just clean
clean:
	rm -rf ~/geostar
	rm -rf $(repo_source)/make


