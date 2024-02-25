THREADS      ?= 64
TIMINGS      ?= timings.txt

TIME         := /usr/bin/time -p -a -o $(TIMINGS)

BASE_PATH    := $(PWD)
LLVM_VERSION := 17.0.6
GIT_REPO     := https://github.com/llvm/llvm-project.git
GIT_PATH     := llvm-project
BUILD_PATH   := $(GIT_PATH)/build

CCBS         != which $(CC)
CXXBS        != which $(CXX)
CCllvm       := $(BASE_PATH)/llvm-bootstrap/bin/clang
CXXllvm      := $(BASE_PATH)/llvm-bootstrap/bin/clang++
CCbench      := $(BASE_PATH)/llvm/bin/clang
CXXbench     := $(BASE_PATH)/llvm/bin/clang++

all: fetch llvm-bootstrap llvm benchmark

fetch: llvm-project
llvm-project:
	@git clone $(GIT_REPO) --branch llvmorg-$(LLVM_VERSION) --depth 1 -q --progress

# Build with the system's compiler
llvm-bootstrap:
	@echo Building llvm-bootstrap with $(CCBS) and $(CXXBS)
	@rm -rf $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)
	@cmake -S $(GIT_PATH)/llvm -G Ninja -B $(BUILD_PATH) 			\
		-DCMAKE_C_COMPILER=$(CCBS)					\
		-DCMAKE_CXX_COMPILER=$(CXXBS)					\
		-DCMAKE_BUILD_TYPE=Release 					\
		-DCMAKE_INSTALL_PREFIX=$(BASE_PATH)/llvm-bootstrap 		\
		-DLLVM_ENABLE_WARNINGS=OFF					\
		-DLLVM_INCLUDE_TESTS=OFF					\
		-DLLVM_INCLUDE_EXAMPLES=OFF					\
		-DLLVM_INCLUDE_BENCHMARKS=OFF					\
		-DLLVM_ENABLE_PROJECTS='lld;clang'	 			\
		-DLLVM_ENABLE_RUNTIMES='all' 					\
		--log-level=ERROR -Wno-deprecated -Wno-dev
	@cmake --build $(BUILD_PATH) -j $(THREADS) --target clang cxx runtimes 
	@cmake --build $(BUILD_PATH) -j $(THREADS) --target install install-clang install-cxx install-runtimes


# Build with the previously compiled version of clang
llvm:
	@echo Building llvm with $(CCllvm) and $(CXXllvm)
	@rm -rf $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)
	@cmake -S $(GIT_PATH)/llvm -G Ninja -B $(BUILD_PATH)	 		\
		-DCMAKE_C_COMPILER=$(CCllvm)					\
		-DCMAKE_CXX_COMPILER=$(CXXllvm)					\
		-DCMAKE_INSTALL_PREFIX=$(BASE_PATH)/llvm 			\
		-DCMAKE_BUILD_TYPE=Release 					\
		-DLLVM_ENABLE_WARNINGS=OFF					\
		-DLLVM_INCLUDE_TESTS=OFF					\
		-DLLVM_INCLUDE_EXAMPLES=OFF					\
		-DLLVM_INCLUDE_BENCHMARKS=OFF					\
		-DLLVM_ENABLE_LIBCXX=ON						\
		-DLLVM_ENABLE_LLVM_LIBC=ON					\
		-DLLVM_ENABLE_LLD=ON						\
		-DLLVM_ENABLE_PROJECTS='lld;clang'				\
		-DLLVM_ENABLE_RUNTIMES='all'					\
		-DLLVM_BUILD_TESTS='False'					\
		--log-level=ERROR -Wno-deprecated -Wno-dev
	@cmake --build $(BUILD_PATH) -j $(THREADS) --target clang cxx runtimes
	@cmake --build $(BUILD_PATH) -j $(THREADS) --target install install-clang install-cxx install-runtimes

# Timed benchmark
.PHONY: benchmark
benchmark:
	@echo Timing benchmark with $(CCbench) and $(CXXbench)
	@$(CXXbench) --verbose
	@rm -rf $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)
	@cmake -S $(GIT_PATH)/llvm -G Ninja -B $(BUILD_PATH) 			\
		-DCMAKE_C_COMPILER=$(CCbench)					\
		-DCMAKE_CXX_COMPILER=$(CXXbench)				\
		-DCMAKE_BUILD_TYPE=Release 					\
		-DLLVM_ENABLE_WARNINGS=OFF					\
		-DLLVM_INCLUDE_TESTS=OFF					\
		-DLLVM_INCLUDE_EXAMPLES=OFF					\
		-DLLVM_INCLUDE_BENCHMARKS=OFF					\
		-DLLVM_ENABLE_LIBCXX=ON						\
		-DLLVM_ENABLE_LLVM_LIBC=ON					\
		-DLLVM_ENABLE_LLD=ON						\
		-DLLVM_ENABLE_PROJECTS='llvm;clang;flang'			\
		--log-level=ERROR -Wno-deprecated -Wno-dev
	@echo ================ >> $(TIMINGS)
	@echo = llvm-libraries >> $(TIMINGS)
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target llvm-libraries
	@echo = clang >> $(TIMINGS)
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target clang
	@echo = flang-new >> $(TIMINGS)
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target flang-new

.PHONY: clean
clean:
	@rm -rf llvm-project/build
	@rm -rf llvm-bootstrap
	@rm -rf llvm

.PHONY: distclean
distclean: clean
	@rm -rf llvm-project
