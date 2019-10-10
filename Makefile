DUMMY := $(shell mkdir -p out/obj out/generated)
VERBOSE ?= @

vpath %.yy contrib/aidl
vpath %.ll contrib/aidl
vpath %.cpp contrib/aidl
vpath %.cpp contrib/core/base
vpath %.cpp out/generated

AIDL_OBJECTS += ast_cpp.o
AIDL_OBJECTS += ast_java.o
AIDL_OBJECTS += aidl.o
AIDL_OBJECTS += aidl_language.o
AIDL_OBJECTS += code_writer.o
AIDL_OBJECTS += generate_cpp.o
AIDL_OBJECTS += generate_java.o
AIDL_OBJECTS += generate_java_binder.o
AIDL_OBJECTS += import_resolver.o
AIDL_OBJECTS += io_delegate.o
AIDL_OBJECTS += line_reader.o
AIDL_OBJECTS += main_cpp.o
AIDL_OBJECTS += options.o
AIDL_OBJECTS += type_namespace.o
AIDL_OBJECTS += type_cpp.o
AIDL_OBJECTS += type_java.o

AIDL_OBJECTS += aidl_language_y.o
AIDL_OBJECTS += aidl_language_l.o

BASE_OBJECTS += logging.o
BASE_OBJECTS += threads.o
BASE_OBJECTS += strings.o
BASE_OBJECTS += stringprintf.o

CC = clang++

CFLAGS += -Icontrib/aidl
CFLAGS += -Icontrib/core/base/include
CFLAGS += -Icontrib/googletest/googletest/include
CFLAGS += -Iout/generated

CFLAGS += -std=c++17

aidl-cpp: $(addprefix out/obj/,$(AIDL_OBJECTS) $(BASE_OBJECTS))
	@echo LINK $@
	$(VERBOSE)$(CC) $(LDFLAGS) -o $@ $^

out/obj/%.o: %.cpp
	@echo COMPILE $@
	$(VERBOSE)$(CC) $(CFLAGS) -c -o $@ $<

out/obj/%.o: out/generated/%.cpp
	@echo COMPILE $@
	$(VERBOSE)$(CC) $(CFLAGS) -c -o $@ $<

out/generated/%.h out/generated/%.cpp: %.yy
	@echo BISON $@
	$(VERBOSE)bison -Dapi.pure -Lc++ --defines=out/generated/$*.h -o out/generated/$*.cpp $<

out/generated/%.cpp: %.ll
	@echo FLEX $@
	$(VERBOSE)flex -o $@ $<

contrib/aidl/aidl_language.cpp: out/generated/aidl_language_y.h

clean:
	rm -rf out aidl-cpp
