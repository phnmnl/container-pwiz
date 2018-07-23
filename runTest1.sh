#!/bin/bash

function DOWNLOAD() {
	# Download RAW
	curl -L -o /tmp/test.zip "https://github.com/phnmnl/container-pwiz/raw/master/neg-MM8_1-A%2C1_01_376.zip"

	# Download expected output and run it through mscat
	curl -L -o /tmp/test.mzml_expected_output "https://github.com/phnmnl/container-pwiz/raw/master/neg-MM8_1-A%2C1_01_376.mzML"
	wine mscat /tmp/test.mzml_expected_output > /tmp/test.expected_output
}

function MSCONVERT() {
	# Process RAW, create mzml and run it through mscat
	unzip -d /tmp/test /tmp/test.zip
	#export WINEPREFIX=~/.wine-new
	wine msconvert.exe /tmp/test --mzML
	wine mscat /tmp/test.mzML > /tmp/test.output
}

function EXIT1() {
	echo "msconvert output does not match expected output!"
	exit 1
}

function TEST1() {
	# Compare msconvert-output with expected output
	cmp /tmp/test.output /tmp/test.expected_output || EXIT1
}

# Set WORKDIR!!!
cd /tmp

# Launch functions
DOWNLOAD
MSCONVERT
TEST1
