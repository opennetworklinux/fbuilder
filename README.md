# fbuilder - the FBOSS build container

A docker file that creates a container based on Debian 8. The docker image pulls a copy of [FBOSS](https://github.com/facebook/fboss)
and builds the dependencies such as [Folly](https://github.com/facebook/folly) and [FBThrift](https://github.com/facebook/fbthrift).
It creates packages of the dependencies and puts them in the /fboss/packages directory.  The FBOSS binary is in /fboss/build as 
normal.
