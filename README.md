# 1A2B
This is a game that user guesses the number of computer.  
It is written by x86 Assembly(AT&T syntax).

### How to build it
```
1. Prepare Linux environment.
2. as guessnum.s --32 -o guessnum.o
3. ld guessnum.o -m elf_i386 -o guessnum.out
```

### Library
```
Pure Assembly code. Any special operations are offered by OS system calls.
```

### Game rules
```
The answer is "9527"
* "1234" -> 0A1B
* "5678" -> 0A2B
* "9726" -> 2A1B
* "9627" -> 3A0B
* "9527" -> 4A0B
```
