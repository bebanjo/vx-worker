#!/bin/bash

set -e

PACKAGE_NAME="vx-worker"

GIT_LAST_LOG=$(git log -n1 --format=oneline)
GIT_BUILD_NUMBER=$(git rev-list HEAD | wc -l | sed -e 's/ *//g' | xargs -n1 printf %04d)
GIT_LAST_TAG=$(git describe --abbrev=0 --tags)
GIT_VERSION=$(echo $GIT_LAST_TAG | sed -e "s/^v//g")
GIT_DATE=$(git log -n1 --format="%aD")

RELEASE_VERSION=$(echo $GIT_VERSION | ruby -e "puts Gem::Version.new(STDIN.read).release.to_s")
RELEASE_SHORT_VERSION=$(echo $GIT_VERSION | ruby -e "puts Gem::Version.new(STDIN.read).release.to_s.split('.')[0..1].join('.')")

VERSION="${RELEASE_VERSION}.rev${GIT_BUILD_NUMBER}"
PACKAGE_NAME_AND_VERSION="${PACKAGE_NAME}_${VERSION}"
WORKDIR=".tmp/${PACKAGE_NAME_AND_VERSION}"

function notice() {
  echo " ---> $1"
}

function git_export () {
  rm -rf .tmp
  mkdir -p $WORKDIR
  notice "export code to $WORKDIR"
  git archive master | tar -x -C $WORKDIR
}

function package_gems () {
  notice "packaging gems"
  (cd $WORKDIR && bundle package > /dev/null)
}

function generate_debian () {
  notice "generating debian scripts"

  dst=${WORKDIR}/debian
  src=dist/debian

  pushd .tmp > /dev/null
    tar -czf "${PACKAGE_NAME_AND_VERSION}.orig.tar.gz" ${PACKAGE_NAME_AND_VERSION}
  popd > /dev/null

  cp -r $src $dst

  cat $dst/control.mk | sed -e "s/%PACKAGE_NAME%/${PACKAGE_NAME}/g" > $dst/control
  cat $dst/changelog.mk | sed -e "s/%VERSION%/${VERSION}/g" | sed -e "s/%DATE%/${GIT_DATE}/g" > $dst/changelog
}

function run_vagrant () {
  notice "run build in vagrant"

  cat > .tmp/build.sh <<EOF
set -e
set -x

(cd ${PACKAGE_NAME_AND_VERSION} && debuild -i -us -uc -S)

mv ${PACKAGE_NAME_AND_VERSION} work
EOF
  vagrant up
  vagrant provision
}


function build () {
  notice "Building ${PACKAGE_NAME_AND_VERSION}"

  git_export
  package_gems
  generate_debian
  run_vagrant
}

build
