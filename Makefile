TIME         :=  /usr/bin/time -p -a -o timings.txt

BASE_PATH    := $(PWD)
LLVM_VERSION := 17.0.6
GIT_REPO     := https://github.com/llvm/llvm-project.git
GIT_PATH     := llvm-project
BUILD_PATH   := $(GIT_PATH)/build
THREADS      ?= 64

TRIPLE       != $(CC) -dumpmachine
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
	@CC=$(CCBS) CXX=$(CXXBS) CCFLAGS="-w" \
		cmake -S $(GIT_PATH)/llvm -G Ninja -B $(BUILD_PATH) 		\
		-DCMAKE_ASM_FLAGS="-w"						\
		-DCMAKE_C_FLAGS="-w"						\
		-DCMAKE_CXX_FLAGS="-w"						\
		-DCMAKE_BUILD_TYPE=Release 					\
		-DCMAKE_INSTALL_PREFIX=$(BASE_PATH)/llvm-bootstrap 		\
		-DLLVM_ENABLE_PROJECTS='lld;clang;compiler-rt' 			\
		-DLLVM_ENABLE_RUNTIMES='all' 					\
		--log-level=ERROR -Wno-deprecated -Wno-dev
	@cmake --build $(BUILD_PATH) -j $(THREADS) --target clang cxx runtimes compiler-rt
	@cmake --build $(BUILD_PATH) -j $(THREADS) --target install install-clang install-cxx install-runtimes install-compiler-rt


# Build with the previously compiled version of clang
llvm:
	@echo Building llvm with $(CCllvm) and $(CXXllvm)
	@rm -rf $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)
	@CC=$(CCllvm) CXX=$(CXXllvm)						\
		cmake -S $(GIT_PATH)/llvm -G Ninja -B $(BUILD_PATH) 		\
		-DCMAKE_ASM_FLAGS="-w"						\
		-DCMAKE_C_FLAGS="-w"						\
		-DCMAKE_CXX_FLAGS="-w -stdlib=libc++"				\
		-DCMAKE_EXE_LINKER_FLAGS="-rtlib=compiler-rt -stdlib=libc++"	\
		-DCMAKE_SHARED_LINKER_FLAGS="-rtlib=compiler-rt -stdlib=libc++" \
		-DCMAKE_INSTALL_PREFIX=$(BASE_PATH)/llvm 			\
		-DCMAKE_BUILD_TYPE=Release 					\
		-DLLVM_ENABLE_PROJECTS='lld;clang;compiler-rt'			\
		-DLLVM_ENABLE_RUNTIMES='all'					\
		-DLLVM_USE_LINKER='lld'						\
		-DLLVM_BUILD_TESTS='False'					\
		--log-level=ERROR -Wno-deprecated -Wno-dev
	@cmake --build $(BUILD_PATH) -j $(THREADS) --target clang cxx runtimes compiler-rt
	@cmake --build $(BUILD_PATH) -j $(THREADS) --target install install-clang install-cxx install-runtimes install-compiler-rt

# Timed benchmark
.PHONY: benchmark
benchmark:
	@echo Timing benchmark with $(CCbench) and $(CXXbench)
	@$(CXXbench) --verbose
	@rm -rf $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)
	@CC=$(CCbench) CXX=$(CXXbench) 						\
		cmake -S $(GIT_PATH)/llvm -G Ninja -B $(BUILD_PATH) 		\
		-DCMAKE_ASM_FLAGS="-w"						\
		-DCMAKE_C_FLAGS="-w"						\
		-DCMAKE_CXX_FLAGS="-w -stdlib=libc++"				\
		-DCMAKE_EXE_LINKER_FLAGS="-rtlib=compiler-rt -stdlib=libc++"	\
		-DCMAKE_SHARED_LINKER_FLAGS="-rtlib=compiler-rt -stdlib=libc++"	\
		-DCMAKE_BUILD_TYPE=Release 					\
		-DLLVM_ENABLE_PROJECTS='llvm;clang;flang'			\
		-DLLVM_USE_LINKER='lld'						\
		--log-level=ERROR -Wno-deprecated -Wno-dev
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target llvm-libraries
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target clang
	@$(TIME) cmake --build $(BUILD_PATH) -j $(THREADS) --target flang-new

.PHONY: clean
clean:
	@rm -rf llvm-project/build
	@rm -rf llvm-bootstrap
	@rm -rf llvm

.PHONY: distclean
distclean: clean
	@rm -rf llvm-project
