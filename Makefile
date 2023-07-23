TIME         :=  /usr/bin/time -p

BASE_PATH    := $(PWD)
LLVM_VERSION := 15.0.1
GIT_REPO     := https://github.com/llvm/llvm-project.git
GIT_PATH     := llvm-project
BUILD_PATH   := $(GIT_PATH)/build
THREADS      ?= 4

CCBS         !=  which $(CC)
CXXBS        !=  which $(CXX)
CCllvm       := $(BASE_PATH)/llvm-bootstrap/bin/clang
CXXllvm      := $(BASE_PATH)/llvm-bootstrap/bin/clang++
CCbench      := $(BASE_PATH)/llvm/bin/clang
CXXbench     := $(BASE_PATH)/llvm/bin/clang++

all: fetch llvm-bootstrap llvm benchmark

fetch: llvm-project
llvm-project:
	@git clone $(GIT_REPO) --branch llvmorg-$(LLVM_VERSION) --depth 1

# Build with the system's compiler
llvm-bootstrap:
	@echo Building llvm-bootstrap with $(CCBS) and $(CXXBS)
	@rm -rf $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)
	@cd $(BUILD_PATH)
	@CC=$(CC) CXX=$(CXX) cmake $(GIT_PATH)/llvm -DCMAKE_BUILD_TYPE=Release -G Ninja -B $(BUILD_PATH) -DLLVM_ENABLE_PROJECTS='clang' -DCMAKE_INSTALL_PREFIX=$(BASE_PATH)/llvm-bootstrap --log-level=NOTICE 
	@cmake --build $(BUILD_PATH) --target install

# Build with the previously compiled version of clang
llvm:
	@echo Building llvm with $(CCllvm) and $(CXXllvm)
	@rm -rf $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)
	@cd $(BUILD_PATH)
	@CC=$(CCllvm) CXX=$(CXXllvm) cmake $(GIT_PATH)/llvm -DCMAKE_BUILD_TYPE=Release -G Ninja -B $(BUILD_PATH) -DLLVM_ENABLE_PROJECTS='clang' -DCMAKE_INSTALL_PREFIX=$(BASE_PATH)/llvm --log-level=NOTICE
	@cmake --build $(BUILD_PATH) --target install

# Timed benchmark
.PHONY: benchmark
benchmark:
	@echo Timing benchmark with $(CCbench) and $(CXXbench)
	@$(CXXbench) --verbose
	@rm -rf $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)
	@cd $(BUILD_PATH)
	@CC=$(CCbench) CXX=$(CXXbench) cmake $(GIT_PATH)/llvm -DCMAKE_BUILD_TYPE=Release -G Ninja -B $(BUILD_PATH) -DLLVM_ENABLE_PROJECTS='llvm;clang;flang' --log-level=NOTICE
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target llvm-libraries
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target clang
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target flang-new

.PHONY: clean
clean:
	@rm -rf llvm-project
	@rm -rf llvm-bootstrap
	@rm -rf llvm
	@rm -rf benchmark
