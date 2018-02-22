#!/bin/bash

testspec="Tests/FixtureGenTests/Fixtures/Single/test_swagger.json"

modelsdir="Temp/models/"
fixturesdir="Temp/Fixtures/"

manual=$1

$manual \
  -i "$testspec" \
  -g "$modelsdir" \
  -f "$fixturesdir" \

function checkIfFileExists() {
  if ! [ -e $1 ] ; then
      echo "File not found: $1"
      exit 1
  fi
}

checkIfFileExists "$modelsdir/Pet.go"
checkIfFileExists "$fixturesdir/petstore.swagger.io/info.json"
