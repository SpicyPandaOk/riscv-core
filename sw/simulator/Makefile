CXX =  g++
CXXFLAGS = -std=c++17 -Wall
DEBUGFLAGS = -g -O0

SRCS= Cpu.cpp InstDecoder.cpp Control.cpp AluControl.cpp Alu.cpp Memory.cpp Main.cpp
OBJS = $(SRCS:.cpp=.o)

simulator: $(OBJS)
	$(CXX) $(OBJS) -o simulator


debug: CXXFLAGS += $(DEBUGFLAGS)
debug: clean simulator
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) simulator

.PHONY: simulator debug clean