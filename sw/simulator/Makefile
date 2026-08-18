CXX =  g++
CXXFLAGS = -std=c++17 -Wall

SRCS= simulator.cpp InstDecoder.cpp Control.cpp AluControl.cpp Alu.cpp
OBJS = $(SRCS:.cpp=.o)

simulator: $(OBJS)
	$(CXX) $(OBJS) -o simulator

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f (OBJS) simulator