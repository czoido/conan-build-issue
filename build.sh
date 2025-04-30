#!/bin/bash

set -euo pipefail

if [[ -z "${SETUPTOOLS_VERSION}" ]]; then
  echo "Error: SETUPTOOLS_VERSION environment variable is not set."
  exit 1
fi
echo "--- Starting build with Setuptools version: ${SETUPTOOLS_VERSION} ---"

readonly PROJECT_ROOT=$(cd $(dirname "${BASH_SOURCE[0]}") && /bin/pwd -P)
readonly DEPLOY_DIR="${PROJECT_ROOT}/_deploy"
readonly PYENV_DIR="${PROJECT_ROOT}/_pyenv"

readonly CONAN_VERSION=2.16.1

readonly UPSTREAM_TARBALL_NAME="${CONAN_VERSION}.tar.gz"
readonly UPSTREAM_URL="https://github.com/conan-io/conan/archive/refs/tags/${CONAN_VERSION}.tar.gz"

cd "${PROJECT_ROOT}"

rm -rf "${PYENV_DIR}" "conan-${CONAN_VERSION}"
/usr/bin/python3 -m venv "${PYENV_DIR}"
source "${PYENV_DIR}/bin/activate"

python --version

python -m pip install --force-reinstall "setuptools==${SETUPTOOLS_VERSION}"

pip list

curl -LO "${UPSTREAM_URL}"
tar -zxf "${UPSTREAM_TARBALL_NAME}"
rm "${UPSTREAM_TARBALL_NAME}"

cd "conan-${CONAN_VERSION}"

pip install -e .
pip install pyinstaller
python pyinstaller.py

echo "--- Build with Setuptools ${SETUPTOOLS_VERSION} completed successfully ---"
