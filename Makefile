CC    ?=  clang
CXX   ?=  clang++
CCWP  !=  which $(CC)
CXXWP !=  which $(CXX)
TIME  :=  /usr/bin/time -p

BASE_PATH    := $(PWD)
LLVM_VERSION := 15.0.1
GIT_REPO     := https://github.com/llvm/llvm-project.git
GIT_PATH     := llvm-project
BUILD_PATH   := $(GIT_PATH)/build
THREADS      ?= 4

all: fetch llvm-bootstrap llvm benchmark

fetch: llvm-project
llvm-project:
	@git clone $(GIT_REPO) --branch llvmorg-$(LLVM_VERSION) --depth 1

# bootstrap: build with the system's compiler
llvm-bootstrap:
	@echo Building llvm-bootstrap with $(CCWP) and $(CXXWP)
	@mkdir -p $(BUILD_PATH)
	@rm -rf $(BUILD_PATH)/*
	@cd $(BUILD_PATH)
	@CC=$(CC) CXX=$(CXX) cmake $(GIT_PATH)/llvm -DCMAKE_BUILD_TYPE=Release -G Ninja -B $(BUILD_PATH) -DLLVM_ENABLE_PROJECTS='clang' -DCMAKE_INSTALL_PREFIX=$(BASE_PATH)/llvm-bootstrap --log-level=NOTICE 
	@cmake --build $(BUILD_PATH) --target install

# llvm: build with the compiled version of clang
llvm:
	$(eval CC  := $(BASE_PATH)/llvm-bootstrap/bin/clang)
	$(eval CXX := $(BASE_PATH)/llvm-bootstrap/bin/clang++)
	@echo Building llvm with $(CC) and $(CXX)
	@mkdir -p $(BUILD_PATH)
	@rm -rf $(BUILD_PATH)/*
	@cd $(BUILD_PATH)
	@CC=$(CC) CXX=$(CXX) cmake $(GIT_PATH)/llvm -DCMAKE_BUILD_TYPE=Release -G Ninja -B $(BUILD_PATH) -DLLVM_ENABLE_PROJECTS='clang' -DCMAKE_INSTALL_PREFIX=$(BASE_PATH)/llvm --log-level=NOTICE
	@cmake --build $(BUILD_PATH) --target install

# Timed benchmark
.PHONY: benchmark
benchmark:
	$(eval CC  := $(BASE_PATH)/llvm/bin/clang)
	$(eval CXX := $(BASE_PATH)/llvm/bin/clang++)
	@echo Timing benchmark with $(CC) and $(CXX)
	@$(CXX) --verbose
	@mkdir -p $(BUILD_PATH)
	@rm -rf $(BUILD_PATH)/*
	@cd $(BUILD_PATH)
	@CC=$(CC) CXX=$(CXX) cmake $(GIT_PATH)/llvm -DCMAKE_BUILD_TYPE=Release -G Ninja -B $(BUILD_PATH) -DLLVM_ENABLE_PROJECTS='llvm;clang;flang' >/dev/null
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target llvm-libraries
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target clang
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target flang-new

.PHONY: clean
clean:
	@rm -rf llvm-project
	@rm -rf llvm-bootstrap
	@rm -rf llvm
	@rm -rf benchmark
