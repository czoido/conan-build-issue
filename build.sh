#!/bin/bash

set -euo pipefail

readonly PROJECT_ROOT=$(cd $(dirname "${BASH_SOURCE[0]}") && /bin/pwd -P)
readonly DEPLOY_DIR="${PROJECT_ROOT}/_deploy"
readonly PYENV_DIR="${PROJECT_ROOT}/_pyenv"

readonly CONAN_VERSION=2.16.1

readonly UPSTREAM_TARBALL_NAME="${CONAN_VERSION}.tar.gz"
readonly UPSTREAM_URL="https://github.com/conan-io/conan/archive/refs/tags/${UPSTREAM_TARBALL_NAME}"

cd "${PROJECT_ROOT}"

rm -rf "${PYENV_DIR}" conan-${CONAN_VERSION}

/usr/bin/python3 -m venv "${PYENV_DIR}"
source "${PYENV_DIR}/bin/activate"

curl -LO "${UPSTREAM_URL}"
tar -zxf "${UPSTREAM_TARBALL_NAME}"
rm "${UPSTREAM_TARBALL_NAME}"

cd conan-${CONAN_VERSION}

pip install -e .
pip install pyinstaller

python pyinstaller.py
