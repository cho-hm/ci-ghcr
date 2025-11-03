#!/bin/bash

echo "TRIGGER_TYPE=signed-tag" >> "$GITHUB_OUTPUT"
echo "TRIGGER_BRANCH=" >> "$GITHUB_OUTPUT"
echo "DOCKER_FILE_PATH=./.github/Dockerfile" >> "$GITHUB_OUTPUT"
echo "BUILD_COMMAND=./gradlew clean test bootJar --no-daemon --refresh-dependencies -i" >> "$GITHUB_OUTPUT"
echo "IMAGE_PLATFORM=linux/amd64,linux/arm64" >> "$GITHUB_OUTPUT"
echo "IMAGE_NAME_SUFFIX=trigger-type:tag:branch:sha:short-sha:latest" >> "$GITHUB_OUTPUT"
echo "GPG_REPO_URL=" >> "$GITHUB_OUTPUT"
echo "GPG_REPO_GPG_PATH=keys/gpg" >> "$GITHUB_OUTPUT"
echo "GPG_REPO_ASC_PATH=keys/asc" >> "$GITHUB_OUTPUT"
echo "GPG_REPO_BRANCH=master" >> "$GITHUB_OUTPUT"
