#!/bin/bash

set -e

# to help users determine their LMHostID
lmutil lmhostid

lmgrd -z $@
