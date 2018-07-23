#!/bin/bash

function DOWNLOAD() {
	# Download RAW
	curl -L -o /tmp/small.RAW "https://github.com/phnmnl/container-pwiz/raw/master/small.RAW"

	# Download expected output and run it through mscat
	curl -L -o /tmp/small.pwiz.1.1.mzML "https://github.com/phnmnl/container-pwiz/raw/master/small.pwiz.1.1.mzML"
	wine mscat /tmp/small.pwiz.1.1.mzML > /tmp/test.expected_output
}

function MSCONVERT() {
	wine msconvert.exe /tmp/small.RAW --mzML
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
