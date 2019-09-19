#!/bin/sh

set -e

if [ -z "${INPUT_BINARY_PATH}" ]; then
    echo "Input binary_path is required."
    exit 1
fi

if [ -z "${INPUT_IMAGE_NAME}" ]; then
    echo "Input image_name is required."
    exit 1
fi

if [ -z "${INPUT_REGISTRY_ENDPOINT}" ]; then
    echo "Input registry_endpoint is required."
    exit 1
fi

if [ -z "${INPUT_REGISTRY_NAME}" ]; then
    echo "Input registry_name is required."
    exit 1
fi

if [ -z "${INPUT_REGISTRY_USERNAME}" ]; then
    echo "Input registry_username is required."
    exit 1
fi

if [ -z "${INPUT_REGISTRY_PASSWORD}" ]; then
    echo "Input registry_password is required."
    exit 1
fi

if [ -z "${INPUT_DOCKERFILE}" ]; then
    echo "Input dockerfile is required."
    exit 1
fi

echo "${INPUT_REGISTRY_PASSWORD}" | docker login -u "${INPUT_REGISTRY_USERNAME}" --password-stdin "https://${INPUT_REGISTRY_ENDPOINT}"

BRANCH=$(echo "${INPUT_BRANCH}" | sed 's#refs/heads/##g;s#refs/tags/##g;s#/#_#g' )
if [ "${BRANCH}" == "master" ]; then
    BRANCH="latest"
fi

GIT_COMMIT=$(git rev-parse --short HEAD)

IMAGE="${INPUT_REGISTRY_ENDPOINT}/${INPUT_REGISTRY_NAME}/${INPUT_IMAGE_NAME}"

TARGET=""
if [ ! -z "${INPUT_DOCKERFILE_TARGET}" ]; then
    TARGET="--target ${INPUT_DOCKERFILE_TARGET}"
fi

echo "Building image ${IMAGE}:${GIT_COMMIT}..."
docker build ${TARGET} -t "${IMAGE}:${GIT_COMMIT}" --build-arg binary_path="${INPUT_PATH}" -f "${INPUT_DOCKERFILE}" .

docker tag "${IMAGE}:${GIT_COMMIT}" "${IMAGE}:${BRANCH}"

docker push "${IMAGE}:${BRANCH}"
docker push "${IMAGE}:${GIT_COMMIT}"
