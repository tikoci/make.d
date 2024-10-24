FROM alpine

ARG DOCKER_ADDITIONAL_TARGETS=help

ENV HOSTNAME=maked
ENV DOMAINNAME=home.arpa
ENV TERM=xterm
ENV EDITOR=nano
ENV DOCKER_ADDITIONAL_TARGETS=${DOCKER_ADDITIONAL_TARGETS}

# ARG BUILDKIT_CONTEXT_KEEP_GIT_DIR=1

# By convention, using /app to store container-specific files
WORKDIR /app

# Install the absolute mininum packages in Dockerfile
# Since packages may be install, keep a package index
RUN apk update && apk add make git nano curl

# install the Makefile "init" system
COPY Makefile /app/Makefile
COPY README.md /app/readme.md
COPY make.d/* /app/make.d/
COPY VERSION /VERSION
COPY .gitignore /app/.gitignore

# install a curated set of Alpine packages
# basically some "inetd" things, common
RUN make -d --warn-undefined-variables -f /app/make.d/__init.mk
# include any "extra packages", like "install-all", using make.d Makefile 
RUN make -C /app --debug=bjv --warn-undefined-variables -j 64 ${DOCKER_ADDITIONAL_TARGETS}
# todo: keeping 2nd RUN seperate to see in build to debug, but should be combined with && above

# IMPORTANT: CMD and ENTRYPOINT must use array syntax - otherwise args don't work

# make is entrypoint - see README.md for details on this approach
ENTRYPOINT ["make", "--debug=bjv", "--jobs=512", "--warn-undefined-variables"]
# note: the "-j 10" is the job limit for parallel jobs, by default its 2
#       but as an "init" process

# cmd= is the <target>: in Makefile to run
CMD ["run"]
