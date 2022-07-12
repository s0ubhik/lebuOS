LEBU = lebu
CC = x86_64-elf-gcc
LD = x86_64-elf-ld

LEBU_FLAGS = -c -w -nobase -noio
CC_FLAGS = -m32 -ffreestanding -fno-pie -nostdinc -w -c
LD_FLAGS = -m elf_i386

SRC = $(wildcard src/*.bn)
CSRC = $(wildcard src/*.c)
OBJ = $(SRC:.bn=.o)
OBJ += $(CSRC:.c=.o)

os.bin: kernel.bin boot.bin
	cat boot.bin kernel.bin > os.bin

%.c: %.bn
	$(LEBU) $^ $(LEBU_FLAGS) -o $@

%.o: %.c
	$(CC) $(CC_FLAGS) -o $@ -c $^

kernel.bin: start.o $(OBJ)
	$(LD) $(LD_FLAGS) -Ttext 0x1000 --oformat binary $^ -o $@

start.o:
	nasm -f elf src/start.asm -o $@

boot.bin:
	nasm -f bin src/boot.asm -o $@

run: os.bin
	qemu-system-x86_64 -fda os.bin

clean:
	rm src/*.o *.bin *.o
