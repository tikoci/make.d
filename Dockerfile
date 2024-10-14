FROM alpine

ENV HOSTNAME=make1
ENV TERM=xterm
ENV EDITOR=nano

# ARG BUILDKIT_CONTEXT_KEEP_GIT_DIR=1

# By convention, using /app to store container-specific files
WORKDIR /app

# Install the absolute mininum packages in Dockerfile
# Since packages may be install, keep a package index
RUN apk update && apk add make git nano 

# install the Makefile "init" system 
COPY Makefile /app/Makefile
COPY README.md /app/readme.md
COPY make.d/* /app/make.d/
COPY VERSION /VERSION 

# install a curated set of Alpine packages
# basically some "inetd" things, common
RUN make -f /app/make.d/__init.mk


# initialize git in /app to track changes
RUN git init --initial-branch=main

# not used by RouterOS but suggest something to Docker
EXPOSE 22
EXPOSE 80
EXPOSE 443
EXPOSE 3000
EXPOSE 8080


# IMPORTANT: CMD and ENTRYPOINT must use array syntax - otherwise args don't work

# make is entrypoint - see README.md for details on this approach 
ENTRYPOINT ["make", "--debug=a", "--jobs=1024", "--no-builtin-rules", "--warn-undefined-variables"]
# note: the "-j 10" is the job limit for parallel jobs, by default its 2
#       but as an "init" process

# cmd= is the <target>: in Makefile to run
CMD ["run"]
