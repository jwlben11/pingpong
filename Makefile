#CC = clang
CFLAGS = -Ipingpong_lib
#CFLAGS = -DDEBUG -g3 -O0 -Ipingpong_lib

SRC = src
BIN_DIR = bin
DATA_DIR = data

# Detect OS
UNAME_S := $(shell uname -s)

# Set OS-specific linker flags
ifeq ($(UNAME_S),Linux)
    LDFLAGS += -lrt
endif

PINGPONG_LIB=$(BIN_DIR)/libpingpong.a
PONG = $(BIN_DIR)/pong_server
UDP_PING = $(BIN_DIR)/udp_ping
TCP_PING = $(BIN_DIR)/tcp_ping
PONG_OBJS = $(BIN_DIR)/pong_server.o
UDP_PING_OBJS = $(BIN_DIR)/udp_ping.o
TCP_PING_OBJS = $(BIN_DIR)/tcp_ping.o

EXECS = $(PONG) $(UDP_PING) $(TCP_PING)

all: $(EXECS)

.PHONY: clean tgz tgz-full

$(EXECS): | $(DATA_DIR)

# Common library
LIB_OBJS = $(BIN_DIR)/fail.o $(BIN_DIR)/readwrite.o $(BIN_DIR)/statistics.o

$(PINGPONG_LIB): $(LIB_OBJS) | $(BIN_DIR)
	ar rcs $@ $(LIB_OBJS)

$(BIN_DIR)/fail.o: $(SRC)/pingpong.h $(SRC)/fail.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c -o $@ $(SRC)/fail.c

$(BIN_DIR)/readwrite.o: $(SRC)/pingpong.h $(SRC)/readwrite.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c -o $@ $(SRC)/readwrite.c

$(BIN_DIR)/statistics.o: $(SRC)/pingpong.h $(SRC)/statistics.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c -o $@ $(SRC)/statistics.c

# Pong server
$(PONG): $(PONG_OBJS) $(PINGPONG_LIB) | $(BIN_DIR)
	$(CC) -o $@ $(PONG_OBJS) $(PINGPONG_LIB) $(LDFLAGS)

$(BIN_DIR)/pong_server.o: $(SRC)/pingpong.h $(SRC)/pong_server.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c -o $@ $(SRC)/pong_server.c

# UDP Ping client
$(UDP_PING): $(UDP_PING_OBJS) $(PINGPONG_LIB) | $(BIN_DIR)
	$(CC) -o $@ $(UDP_PING_OBJS) $(PINGPONG_LIB) $(LDFLAGS)

$(BIN_DIR)/udp_ping.o: $(SRC)/pingpong.h $(SRC)/udp_ping.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c -o $@ $(SRC)/udp_ping.c

# TCP Ping client
$(TCP_PING): $(TCP_PING_OBJS) $(PINGPONG_LIB) | $(BIN_DIR)
	$(CC) -o $@ $(TCP_PING_OBJS) $(PINGPONG_LIB) $(LDFLAGS)

$(BIN_DIR)/tcp_ping.o: $(SRC)/pingpong.h $(SRC)/tcp_ping.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c -o $@ $(SRC)/tcp_ping.c

# Directories
$(BIN_DIR):
	mkdir $(BIN_DIR)

$(DATA_DIR):
	mkdir $(DATA_DIR)

# Utilities
clean:
	rm -f $(BIN_DIR)/*.o $(EXECS) $(PINGPONG_LIB)
	rmdir $(BIN_DIR) 2>/dev/null || true
	rmdir $(DATA_DIR) 2>/dev/null || true

tgz: clean
	cd ..; tar cvzf pingpong.tgz --exclude='pingpong/.idea' pingpong

tgz-full: clean
	cd ..; tar cvzf pingpong-full.tgz --exclude='pingpong-full/.idea' pingpong-full

