# makefile for fire model

TARGET = nc2asc
LIBPATH = -L/usr/local/netcdf-cxx-legacy/lib -L/home/jaideep/codes/Flare/lib -L/usr/local/cuda/lib64
INCPATH = -I/usr/local/netcdf-c-4.3.2/include -I/usr/local/netcdf-cxx-legacy/include -I/usr/local/cuda/include
INCPATH += -I/home/jaideep/codes/Flare/include
LDFLAGS =  
CPPFLAGS = -g

LIBS = -l:libflare.so.3 -lnetcdf_c++

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



