#!/bin/sh

set -e

function main() {
  GITHUB_DOCKER_REGISTRY=docker.pkg.github.com
  translateDockerTag

  GITHUB_DOCKER_IMAGE_NAME=${GITHUB_DOCKER_REGISTRY}/${GITHUB_REPOSITORY}/${INPUT_GITHUBNAME}:${IMAGE_TAG}

  echo ${GITHUB_TOKEN} | docker login -u ${GITHUB_ACTOR} --password-stdin ${GITHUB_DOCKER_REGISTRY}
  docker pull ${GITHUB_DOCKER_IMAGE_NAME}
  docker logout ${GITHUB_DOCKER_REGISTRY}

  echo ${INPUT_DOCKERHUBPASSWORD} | docker login -u ${INPUT_DOCKERHUBUSER} --password-stdin
  docker tag ${GITHUB_DOCKER_IMAGE_NAME} ${INPUT_DOCKERHUBNAME}:${IMAGE_TAG}
  docker push ${INPUT_DOCKERHUBNAME}
  docker logout
}

function translateDockerTag() {
  if isOnMaster; then
    IMAGE_TAG="latest"
  elif isOnReleaseBranch; then
    IMAGE_TAG=$(echo ${GITHUB_REF} | sed -e "s/refs\/heads\/release\///g")
  elif isGitTag; then
    IMAGE_TAG=$(echo ${GITHUB_REF} | sed -e "s/refs\/tags\/v\([[:digit:]]*.[[:digit:]]*\).[[:digit:]]*/\1/g")
  else
    IMAGE_TAG=$(echo ${GITHUB_REF} | sed -e "s/refs\/heads\///g" | sed -e "s/\//-/g")
  fi;
}

function isOnMaster() {
  [ "${GITHUB_REF}" = "refs/heads/master" ]
}

function isOnReleaseBranch() {
  [ $(echo "${GITHUB_REF}" | sed -e "s/refs\/heads\/release\///g") != "${GITHUB_REF}" ]
}

function isGitTag() {
  [ $(echo "${GITHUB_REF}" | sed -e "s/refs\/tags\///g") != "${GITHUB_REF}" ]
}

main
