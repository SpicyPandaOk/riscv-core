CXX =  g++
CXXFLAGS = -std=c++17 -Wall

SRCS= Cpu.cpp InstDecoder.cpp Control.cpp AluControl.cpp Alu.cpp Memory.cpp Main.cpp
OBJS = $(SRCS:.cpp=.o)

simulator: $(OBJS)
	$(CXX) $(OBJS) -o simulator

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f (OBJS) simulator