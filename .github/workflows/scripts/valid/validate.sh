#!/bin/bash

. "${valid_path}/valid-first-commit.sh"

if(( $? != 0 )); then return $?; fi

