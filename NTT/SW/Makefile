# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++17 -O2 -Wall

# Executables
GEN = gen.exe
RUN = NTTConv.exe
BRUTE = BasicConv.exe

# Source files
GEN_SRC = gen.cpp
RUN_SRC = NTTConv.cpp
BRUTE_SRC = BasicConv.cpp

# Test directory
TEST_DIR = ./test_cases

# Number of test cases
NUM_CASES = 10

# Default target
all: $(GEN) $(RUN) $(BRUTE) test

# Compile rules
$(GEN): $(GEN_SRC)
	$(CXX) $(CXXFLAGS) -o $@ $<

$(RUN): $(RUN_SRC)
	$(CXX) $(CXXFLAGS) -o $@ $<

$(BRUTE): $(BRUTE_SRC)
	$(CXX) $(CXXFLAGS) -o $@ $<

# Create test directory if not exist
# $(TEST_DIR):
# 	mkdir -p $(TEST_DIR)


# Test rule: generate multiple inputs, run both programs, compare outputs
test: $(GEN) $(RUN) $(BRUTE) $(TEST_DIR)
	@echo Running $(NUM_CASES) test cases...
	@for /L %%i in (1,1,$(NUM_CASES)) do ( \
		echo == Test case %%i == & \
		$(GEN) $(TEST_DIR)\input_%%i.txt & \
		$(RUN) < $(TEST_DIR)\input_%%i.txt > $(TEST_DIR)\output_run_%%i.txt & \
		$(BRUTE) < $(TEST_DIR)\input_%%i.txt > $(TEST_DIR)\output_brute_%%i.txt & \
		fc $(TEST_DIR)\output_run_%%i.txt $(TEST_DIR)\output_brute_%%i.txt >nul && \
		echo Test %%i: Outputs match! || echo Test %%i: Outputs differ! Check input_%%i.txt \
	)

# Clean rule
clean:
	rm -f $(GEN) $(RUN) $(BRUTE)
	rm -rf $(TEST_DIR)
