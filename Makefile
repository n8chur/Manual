TOOL_NAME = manual

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(TOOL_NAME)
BUILD_DIRECTORY = .build/release
BIN = ${BUILD_DIRECTORY}/${TOOL_NAME}

.PHONY: build bootstrap test test_script_output clean generate-project lint diff ci

install: bootstrap build
	@mkdir -p $(PREFIX)/bin
	@cp -f ${BIN} $(INSTALL_PATH)

build:
	@swift build -c release

bootstrap:
	@swift package resolve

test:
	@swift test
	@make test_script_output

test_script_output:
	@make build
	@Scripts/integration_test.sh ${BIN}

clean:
	@rm -rf .build Packages/
	@swift package clean

generate-project:
	@swift package generate-xcodeproj

lint:
	@swiftlint # See https://github.com/realm/SwiftLint for info on how to integrate into Xcode

diff:
	@make ci

ci:
	@make clean
	@make bootstrap
	@make build
	@make lint
	@make test
