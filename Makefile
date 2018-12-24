# makefile for fire model

TARGET = nc2asc
LIBPATH = -L/home/jaideep/codes/Flare/lib -L/usr/local/cuda/lib64 -L/usr/local/netcdf-cxx4/lib
INCPATH = -I/usr/local/netcdf-cxx4/include -I/usr/local/cuda/include -I/usr/local/netcdf-c/include 
INCPATH += -I/home/jaideep/codes/Flare/include
LDFLAGS =  
CPPFLAGS = -g

LIBS = -l:libflare.so.3 -lnetcdf_c++4

SOURCEDIR = src
BUILDDIR = build

SOURCES = $(wildcard $(SOURCEDIR)/*.cpp)
OBJECTS = $(patsubst $(SOURCEDIR)/%.cpp, $(BUILDDIR)/%.o, $(SOURCES))


all: dir $(TARGET)

dir:
	mkdir -p $(BUILDDIR)

$(TARGET): $(OBJECTS)
	g++ -o $(LDFLAGS) $(TARGET) $(OBJECTS) $(LIBPATH) $(LIBS)

$(OBJECTS): $(BUILDDIR)/%.o : $(SOURCEDIR)/%.cpp
	g++ -c $(CPPFLAGS) $(INCPATH) $< -o $@ 

clean:
	rm -f $(BUILDDIR)/*.o $(TARGET)



