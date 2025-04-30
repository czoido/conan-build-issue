#!/bin/bash

set -euo pipefail

# --- Validate environment variables ---
if [[ -z "${PIP_VERSION}" ]]; then
  echo "Error: PIP_VERSION environment variable is not set."
  exit 1
fi
if [[ -z "${SETUPTOOLS_VERSION}" ]]; then
  echo "Error: SETUPTOOLS_VERSION environment variable is not set."
  exit 1
fi
echo "--- Starting build with Pip: ${PIP_VERSION}, Setuptools: ${SETUPTOOLS_VERSION} ---"
# --- End Validation ---

readonly PROJECT_ROOT=$(cd $(dirname "${BASH_SOURCE[0]}") && /bin/pwd -P)
readonly DEPLOY_DIR="${PROJECT_ROOT}/_deploy"
readonly PYENV_DIR="${PROJECT_ROOT}/_pyenv"

readonly CONAN_VERSION=2.16.1 # Or specific version you are testing

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
echo "Initial pip version in venv:"
python -m pip --version

# --- Install specific tool versions ---
echo "Installing target pip version: ${PIP_VERSION}..."
# Use the venv's python to install the target pip version
# Add --use-feature=fast-deps potentially for newer pip if needed, but usually not required here
python -m pip install --force-reinstall "pip==${PIP_VERSION}"

echo "Verifying installed pip version:"
python -m pip --version # Verify pip installation

echo "Installing target setuptools version: ${SETUPTOOLS_VERSION}..."
# Use the (potentially just changed) pip to install the target setuptools
python -m pip install --force-reinstall "setuptools==${SETUPTOOLS_VERSION}"

echo "Installing wheel (needed for builds)..."
# Ensure wheel is present
python -m pip install wheel

echo "Listing installed pip, setuptools, wheel versions:"
# Use the installed pip to list versions
python -m pip list | grep -E '(pip|setuptools|wheel)'
# --- End tool installation ---

echo "Downloading Conan ${CONAN_VERSION} sources..."
curl -LO "${UPSTREAM_URL}"
echo "Extracting sources..."
tar -zxf "${UPSTREAM_TARBALL_NAME}"
rm "${UPSTREAM_TARBALL_NAME}"

echo "Changing to conan-${CONAN_VERSION} source directory..."
cd "conan-${CONAN_VERSION}"

echo "Installing Conan in editable mode..."
# Use the installed pip; add -v for verbose output if debugging
python -m pip install -v -e .

echo "Installing PyInstaller..."
python -m pip install pyinstaller

echo "Running PyInstaller script..."
# Assuming pyinstaller command is now on PATH from the venv
python pyinstaller.py # Or use 'pyinstaller ...' if the script calls it directly

echo "--- Build with Pip ${PIP_VERSION}, Setuptools ${SETUPTOOLS_VERSION} completed successfully ---"