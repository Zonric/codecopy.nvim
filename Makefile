NVIM ?= nvim
TEST_CONFIG_DIR := .test-config/nvim/pack/tests/start
PLENARY_DIR := $(TEST_CONFIG_DIR)/plenary.nvim
PLENARY_URL := https://github.com/nvim-lua/plenary.nvim

.PHONY: all test test-setup lint clean help

all: test

## Show help for each target
help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

## Setup plenary.nvim dependency for testing
test-setup: $(PLENARY_DIR)

$(PLENARY_DIR):
	@echo "Installing plenary.nvim into $(PLENARY_DIR)..."
	@mkdir -p $(TEST_CONFIG_DIR)
	@git clone --depth 1 $(PLENARY_URL) $(PLENARY_DIR)

## Run plenary tests
test: test-setup
	@echo "Running tests..."
	@$(NVIM) --headless -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/codecopy { minimal_init = 'tests/minimal_init.lua' }"

## Run stylua code formatting check
lint:
	@command -v stylua >/dev/null 2>&1 || (echo "stylua is not installed. Please install stylua." && exit 1)
	@stylua --check lua/ plugin/ tests/

## Clean test dependencies and cache
clean:
	@echo "Removing $(TEST_CONFIG_DIR)..."
	@rm -rf .test-config
