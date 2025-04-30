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

echo "Cleaning up previous environment and sources..."
rm -rf "${PYENV_DIR}" "conan-${CONAN_VERSION}"

echo "Creating Python virtual environment..."
/usr/bin/python3 -m venv "${PYENV_DIR}"
echo "Activating virtual environment..."
source "${PYENV_DIR}/bin/activate"

echo "Python version in venv:"
python --version

echo "Updating pip and wheel..."
python -m pip install --upgrade pip wheel

echo "Installing setuptools version ${SETUPTOOLS_VERSION}..."
python -m pip install --force-reinstall "setuptools==${SETUPTOOLS_VERSION}"

echo "Listing installed pip, setuptools, wheel versions:"
pip list | grep -E '(pip|setuptools|wheel)'

echo "Downloading Conan ${CONAN_VERSION} sources..."
curl -LO "${UPSTREAM_URL}"
echo "Extracting sources..."
tar -zxf "${UPSTREAM_TARBALL_NAME}"
rm "${UPSTREAM_TARBALL_NAME}"

echo "Changing to conan-${CONAN_VERSION} source directory..."
cd "conan-${CONAN_VERSION}"

echo "Installing Conan in editable mode..."
pip install -v -e .

echo "Installing PyInstaller..."
pip install pyinstaller

echo "Running PyInstaller script..."
python pyinstaller.py

echo "--- Build with Setuptools ${SETUPTOOLS_VERSION} completed successfully ---"
