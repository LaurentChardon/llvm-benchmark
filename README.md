# llvm-benchmark
This project is a compilation benchmark that compiles llvm with clang to assess the speed of a compilation platform. It is multiplatform and has so far been tested in Linux (x86-64), FreeBSD (arm64) and MacOS (x86-64,M1).

The test is not perfect because the llvm compilation is not exactly the same on all platforms. There is usually a small difference in the number of files being compiled, and of course code that's behind `ifdef`s will be potentially different for each platform. This could be reduced by doing cross-compilation for a common platform. That's a TODO for a next version.
## How it works
There are four stages in the process:
1. `llvm-project`: get the llvm source code with git
2. `llvm-bootstrap`: do a first compilation of clang with the system's C and C++ compilers
3. `llvm`: use the compiler from the previous stage to compile clang with itself
4. `benchmark`: use the compiler from the previous stage to time the compilation of llvm, clang and flang-new
   
Each stage is a target in the `Makefile`, and can be targeted individually. If the make process is interrupted, when it is resumed it will restart from the beginning of the last stage that was not completed, rather than resume where it was interrupted.
## Usage
Simply type `make` to go through all stages. This will use the platform default compilers, all the system's threads in stages 2 and 3, and 4 threads for the `benchmark` stage. On Linux the GNU compilers will be used by default, and on BSD and MacOS, clang will be used.

More control can be obtained by specifying some parameters:
- `CC` can be used to change the C compiler used in stage 2
- `CXX` can be used to change the C++ compiler used in stage 2
- `THREADS` can be used to change the number of compiler threads used in the `benchmark` stage

For example, to compile stage 2 with clang on Linux, and use 8 threads for the `benchmark` stage:
```
make CC=clang CXX=clang++ THREADS=8
```
## Sample results
See [Results.md](Results.md) for some sample timings. 
## Notes
Currently, `flang-new` is not very mature, and its compilation requires a large amount of RAM. For this reason, you might have to lower the `THREADS` parameter to not exceed your available memory. `flang-new`is only compiled in the `benchmark` phase.

The `make` utility that comes with MacOS is currently 17 years old and is not compatible with this project. You will have to install a newer make, possibly from [Homebrew](https://brew.sh/) or [MacPort](https://www.macports.org/).



