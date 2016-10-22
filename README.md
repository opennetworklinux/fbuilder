# fbuilder - the FBOSS build container

A docker file that creates a container based on Debian 8. The docker image pulls a copy of [FBOSS](https://github.com/facebook/fboss)
and builds the dependencies such as [Folly](https://github.com/facebook/folly) and [FBThrift](https://github.com/facebook/fbthrift).
It creates packages of the dependencies and puts them in the /fboss/packages directory.  The FBOSS binary is in /fboss/build as 
normal.

Clone the repository, edit the Makefile to match your own repository (it defaults to mine, sonn), change to the fbuilder directory and run "make build" to build FBOSS. To log in and get the packages run "docker run -i -t sonn/fbuilder:1.0 /bin/bash"
