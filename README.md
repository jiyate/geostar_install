# geostar_install

This is the installation repository for Dr. Leland Pierce's remote sensing environment. The full installation would take at least 4 hours to complete.

## Files

* Makefile
* geostar_libraries.tgz
* geostar_src.tgz

## Install

### Steps

* Open a terminal in your Linux 
* Clone the repository to a desired location:
* Enter the geostar_install directory
* Install the environment

```
git clone git@github.com:jiyate/geostar_install.git
cd geostar_install
make geostar
```

If by any chance you hit a problem and the installation stalls, just fix the problem and hit

```
make geostar
```

again to resume installing. (I use VPATH to keep track of the process)

### Note

* Only tested in bash shell with gcc 5.4.0 in ubuntu 16.04 LTS
* Some steps may require root permission (e.g. sudo blah)
* If you want to repeat certain step, delete the corresponding file in the ./make folder first
* type will run make geostar, so you have to type make test yourself
* Since the tar files are very huge... I could not even put them into the git FLS (if I don't pay a penny), I put them in my google drive and access it via a public link using wget. Hope there is nothing wrong with it.
* If you want to reinstall certain libraries, remove the correponding file in the make folder and type make library_you_wanna_reinstall

### !!!!!Step13 will fail and please do the following!!!!!

```
touch ./make/openjpeg
make
```

## Test

After you have finish the installations, you could run the following code to test the result. 

```
make test
```

Each test could be done individually. Check the Makefile for details.

## Tips

### Absent Library

If encounter problems involving missing libs, try search the flag with 

```
sudo apt-cache search flag_name
```

The library needed is usually in format "libflagname-dev" and download it with apt should work

### Modify Path

If you have the file and the bash complain about missing library, you could try

* Reinstall the library using the make file
* Use -L to tell the compiler where to look for the library (e.g. -L/path/to/somewhere)
* Use export LD_LIBRARY_PATH=/path/to/library/directory:/another/path:/and/another (no space around the equal sign)

## Uninstall

```
make nuke
```

## Fork me!

Please help me to make it better!
Feel free to add more 'sudo apt-get install ...'' code in the install_dependence
Here is the link for Fork: https://guides.github.com/activities/forking/
Thank you all.