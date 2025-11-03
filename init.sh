#!/bin/bash

mkdir -p .github
rsync -a --checksum ./ci-ghcr/.github/ ./.github