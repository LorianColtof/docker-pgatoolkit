# PGA Toolset and PSF Toolkit Docker scripts

These scripts give you the ability to run the PGA Toolset and PSF Toolkit 
on modern systems using Docker.

Requirements:
* docker
* xhost

Installation:

`./build.sh`

Run:

The `run.sh` script gives you a Bash prompt inside the Docker,
which allows you to run commands of the PGA Toolset and PSF Toolkit 
```bash
./run.sh
pga@b8db903adaae:~$ gensim ...
pga@b8db903adaae:~$ psf ...
```

