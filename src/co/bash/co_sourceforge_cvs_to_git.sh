#!/bin/sh

## cvsps & 'git cvsimport' divergence
## see also: http://pkp.sfu.ca/wiki/index.php/HOW-TO_import_and_export_to_and_from_Git_and_CVS

## This script runs an initial checkout of the upstream CVS repository, for purpose of generating a `cvsps` patchset/changeset log file. Subsequently, this script creates a new Git repostiroy using git-csimnport and the generate patchet log.

## primary parameters:
##  * NAME - typically, a SourceForge project name, e.g. clorb
## additional parameters:
##  * UPSTREAM_CVS - may be derived from NAME
##  * CVSPS_LOG
##  * LOCAL_CVS
##  * LOCAL_GIT



## NAME=clorb

error() {
    echo $0: $@ 1>&2
    exit 1
}

if [ -z "${NAME}" ]; then
    error "Must specify environment variable NAME as name of SourceForge projet"
fi


UPSTREAM_CVS=":pserver:anonymous@${NAME}.cvs.sourceforge.net:/cvsroot/${NAME}"

LOCAL_CVS="${PWD}/${NAME}_orig"

CVSPS_LOG="${LOCAL_CVS}/../${NAME}_cvsps.out"

LOCAL_GIT="${PWD}/${NAME}"


if [ -a "${LOCAL_GIT}" ]; then
    error "File exists: ${LOCAL_GIT}"
fi


# export CVSROOT="${UPSTREAM_CVS}"

{ cvs -z3 co -d "${UPSTREAM_CVS}" -P clorb "${LOCAL_CVS}" || 
  error "Error during initial CVS checkout"; } &&
  { cd "${LOCAL_CVS}" || error "Cannot cd to ${LOCAL_CVS}"; } &&
  { cvsps -x --norc -u -A clorb > "${CVSPS_LOG}" || 
    error "Error when generating cvsps patchet ${CVSPS_LOG}"; } &&
  { git cvsimport -C "${LOCAL_GIT}" -d "${UPSTREAM_CVS}" -v -a -P "${CVSPS_LOG}" ||
    error "Error during git cvsimport"; }

