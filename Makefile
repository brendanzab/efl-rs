# Copyright 2014 The Servo Project Developers. See the COPYRIGHT
# file at the top-level directory of this distribution.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

RUSTC                 ?= rustc
RUSTDOC               ?= rustdoc

MAKE = make
ifeq ($(OS), Windows_NT)
	MAKE = mingw32-make
endif

LINK_ARGS             = $(shell sh etc/glfw-link-args.sh)

SRC_DIR               = src
DEPS_DIR              = deps
DEPS_LIB_DIR          = $(DEPS_DIR)/lib
LIB_DIR               = lib
BIN_DIR               = bin
DOC_DIR               = doc

BINDGEN_FILE          = $(DEPS_DIR)/rust-bindgen/lib.rs
BINDGEN_INPUT         = $(DEPS_DIR)/rust-bindgen/*.rs
BINDGEN_OUT           = $(DEPS_LIB_DIR)/$(shell $(RUSTC) --print-file-name $(BINDGEN_FILE))
# this works for brew - not sure about other platforms
BINDGEN_SEARCH_PATHS  = /usr/local/opt/llvm/lib
BINDGEN_SEARCH_FLAGS  = $(patsubst %,-L %, $(BINDGEN_SEARCH_PATHS))

EXTERN_DIR            = $(SRC_DIR)/ffi/extern
EXTERN_GENERATOR      = $(EXTERN_DIR)/generate
EXTERN_INPUT          = $(EXTERN_GENERATOR) $(EXTERN_DIR)/includes.h
EXTERN_OUT            = $(EXTERN_DIR)/efl.h

FFI_FILE              = $(SRC_DIR)/ffi/lib.rs
FFI_INPUT             = $(SRC_DIR)/ffi/*.rs
FFI_OUT               = $(LIB_DIR)/$(shell $(RUSTC) --print-file-name $(FFI_FILE))
FFI_SEARCH_PATHS      = $(DEPS_LIB_DIR)
FFI_SEARCH_FLAGS      = $(patsubst %,-L %, $(FFI_SEARCH_PATHS))
FFI_DOC_OUT           = $(DOC_DIR)/$(shell $(RUSTC) --print-crate-name $(FFI_FILE))

EFL_FILE              = $(SRC_DIR)/efl/lib.rs
EFL_INPUT             = $(SRC_DIR)/efl/*.rs $(FFI_OUT)
EFL_OUT               = $(LIB_DIR)/$(shell $(RUSTC) --print-file-name $(EFL_FILE))
EFL_SEARCH_PATHS      = $(LIB_DIR)
EFL_SEARCH_FLAGS      = $(patsubst %,-L %, $(EFL_SEARCH_PATHS))
EFL_DOC_OUT           = $(DOC_DIR)/$(shell $(RUSTC) --print-crate-name $(EFL_FILE))

EXAMPLE_FILES         = $(SRC_DIR)/examples/*.rs
EXAMPLE_SEARCH_PATHS  = $(LIB_DIR)
EXAMPLE_SEARCH_FLAGS  = $(patsubst %,-L %, $(EXAMPLE_SEARCH_PATHS))

# Default target

.PHONY: all
all: lib examples doc

# Friendly initialization

.PHONY: init
init: submodule-update deps all

# Dependency handling

.PHONY: submodule-update
submodule-update:
	@git submodule init
	@git submodule update --recursive

$(BINDGEN_OUT): $(BINDGEN_INPUT)
	mkdir -p $(DEPS_LIB_DIR)
	$(RUSTC) --out-dir=$(DEPS_LIB_DIR) $(BINDGEN_SEARCH_FLAGS) -O $(BINDGEN_FILE)

.PHONY: deps
deps: $(BINDGEN_OUT)

.PHONY: clean-deps
clean-deps:
	rm -rf $(DEPS_LIB_DIR)

# Library compilation

$(EXTERN_OUT): $(EXTERN_INPUT)
	$(EXTERN_GENERATOR)

$(FFI_OUT): $(EXTERN_OUT) $(FFI_INPUT)
	mkdir -p $(LIB_DIR)
	$(RUSTC) --out-dir=$(LIB_DIR) $(FFI_SEARCH_FLAGS) -O $(FFI_FILE)

$(EFL_OUT): $(EFL_INPUT)
	mkdir -p $(LIB_DIR)
	$(RUSTC) --out-dir=$(LIB_DIR) $(EFL_SEARCH_FLAGS) -O $(EFL_FILE)

.PHONY: lib
lib: $(EFL_OUT)

.PHONY: clean-lib
clean-lib:
	rm $(EXTERN_OUT)
	rm -rf $(LIB_DIR)

# Documentation generation

$(FFI_DOC_OUT): $(FFI_INPUT)
	mkdir -p $(DOC_DIR)
	$(RUSTDOC) -o $(DOC_DIR) $(FFI_SEARCH_FLAGS) $(FFI_FILE)

$(EFL_DOC_OUT): $(EFL_INPUT)
	mkdir -p $(DOC_DIR)
	$(RUSTDOC) -o $(DOC_DIR) $(EFL_SEARCH_FLAGS) $(EFL_FILE)

.PHONY: doc
doc: $(EFL_DOC_OUT) $(FFI_DOC_OUT)

.PHONY: clean-doc
clean-doc:
	rm -rf $(DOC_DIR)

# Example compilation

$(EXAMPLE_FILES): lib
	mkdir -p $(BIN_DIR)
	$(RUSTC) $(EXAMPLE_SEARCH_FLAGS) --out-dir=$(BIN_DIR) $@

.PHONY: examples
examples: $(EXAMPLE_FILES)

.PHONY: clean-examples
clean-examples:
	rm -rf $(BIN_DIR)

# Cleanup

.PHONY: clean
clean: clean-lib clean-doc clean-examples
