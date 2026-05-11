#!/bin/bash

ENV_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

export VM_SIZE=4G

export NR_CPU=4

export KERNEL_REPO_NAME=mm

export ROOT_DIR=$(dirname $(dirname $ENV_DIR))
export ARCHIVE=$ROOT_DIR/kernel-archive/
export DEVELOP=$ROOT_DIR/kernel-develop/
export BUILD=$ROOT_DIR/kernel-build/
export TEST=$ROOT_DIR/kernel-test/

export KERNEL_SOURCE=$DEVELOP/$KERNEL_REPO_NAME
