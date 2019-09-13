#!/bin/bash
############################################
# Script Name :
# Description :
#
# Args        :
#
#-------------------------------------------
# Script
#-------------------------------------------
# Default variables

readonly INPUT=$1
readonly DATE=$(date '+%Y-%m-%d')

TITLE=${INPUT//" "/-}

PRE="---
layout: post
title:
subtitle:
---"

echo -e "$PRE" > "$DATE"-"$TITLE".md
