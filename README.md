# Sokolang

Sokolang is a mixed stack- and register-based programming language designed as a "toy language" for use in my game; it is used to solve puzzles within context of the game, and is not intended to be used as a general purpose language. You can certainly use it as such, but it is not designed with that in mind.

In this repository you'll find the work-in-progress prototype implementation of the language, written in Lua. It has no dependencies and never will have.

Additionally, this very document serves as the language specification. The language will likely be in a state of perpetual refinement, so features and details are not stable. I will try to tag releases whenever the language finds itself in a somewhat complete state, where "complete" may or may not actually mean anything.

This Lua implementation is being written with maximum readability in mind, avoiding usage of highly specific Lua-isms, at least within the lexer and interpreter. This should allow the implementation to be easy to read and port to another language. If you **do** port this to another language, please let me know!

No special test suite is used, see the examples in the `tests` directory for reference on how tests are written, and check out the `tests.lua` file to see how they are used. It's all very simple!

# Goals

Sokolang is intended to be relatively easy to use for non-programmers, in that it should do what they *want* as often as possible. This means Sokolang may sometimes not do what an *experienced* programmer expects. There are some *magical* features at work, arithmetic operators understand some complex data types for example, and so on.


# Features


## Magic Stack

The stack upon which Sokolang operates, is *magical* in the sense that it can hold really weird data types, directly on the stack. For example, it can hold; records (arbitrary data chunks), memory addresses, strings, device pointers, arrays... And more. Some of these things obviously won't work outside of the game. In these cases, this prototype implementation will approximate the game-specific types with simplified models.

Here is a list of types the stack can hold, which also conveniently doubles as a list of all the types recognized by the language in general:

* **Numbers**: Ints only
    * `push 5`
* **Strings**: String literals. They must be quoted by double quotes. Single characters are also strings.
    * `push "hello world"`
    * `push "a"`
* **Arrays**: An array can hold any one data type; that is to say, no mixed arrays. An array can be empty.
    * `push []`
    * `push [1 2 3]` - note how commas are optional inside array definitions.
* **Records**: Records are chunks of data, that can be operated on by [magic operators](#magic-operators) and some [folding operators](#folding-operators). Images, for example, are considered records. Records cannot be explicitly referenced or created, but they can be operated on, and moved around within the stack/registers/memory/filesystem.
* **Addresses**: Memory addresses, treated as numbers for most operations, but visually represented as `0x` hex values.
    * `push 0xFF`
    * `0xF0 1 +` -> `0xF1`
* **Devices**: Think of these as pointers to devices that can be interacted with. Used by the `call` instruction. Can be text labels, or hex addresses.
    * `push $DEVICE_LABEL`
    * `push $F00`
* **NaN**: Not a Number. This one means something has gone terribly wrong. See [NaN: Not a Number](#nan-not-a-number).


## Arithmetic Operators

Sokolang supports the basic arithmetic operators:

* `+` addition
* `-` subtraction
* `*` multiplication
* `/` integer division. The remainder is discarded


## Magic Operators

To complement the [Magic Stack](#magic-stack), there are Magic Operators. Really they are just the same as the arithmetic operators, but they apply to most datatypes in ways that may be unexpected to programmers, but perhaps intuitive to non-programmers.

For example, adding two images together is completely valid, and produces a new image that is the pixel-wise sum of its operands. The intention is more or less that *if you can imagine this operation doing something useful with these operands, it should do that thing*. Adding a number to an image? Fine, your image is now brighter. Add two arrays together? Sure, they will add element-wise (pseudocode): `[1, 2] + [3, 4] = [4, 6]`. Add two strings together? They are concatenated. Subtract a number from a string? That string is now shorter! And so on.

TODO: A Magic Matrix of type & operator combinations should appear in this document at some point.


## Devices & the `call` instruction

Sokolang is designed to interact with hardware devices in the game. To that end, devices have special treatment. Sokolang understands two ways of "pointing" to a device; by label or by direct addressing. Labels are essentially just an address in fancy clothes; they behave identically.

```
# Label style
push $DEVICE
call

# Address style
push 0xFF0
call
```

Both examples above would have the same result, if `$DEVICE` was a label for address `0xFF0` (or, as an integer, `4080`)

The `call` instruction essentially pokes the device and says hey, do something. What exactly happens next depends on the specific device. Devices may want parameters to their call, and they can be provided by pushing them onto the stack before `call`ing. As you can probably tell by now, this is effectively a function call.

Some devices may push something onto the stack as a result, such as a record, others may simply perform a task and update the ERR register, or provide no feedback what so ever.

```
push 3
push $CAMERA
call
```

In this example, we could imagine that a Camera device is called, with the value 3 as a parameter, takes 3 pictures, and pushes an array containing three [Records](#records) `[img_1, img_2, img_3]` onto the stack when it's done.




## Array Operators

Some special operators exist for dealing with arrays.

* `join` - joins two arrays on the stack together. `["A", "B"] ["C", "D"] join` -> `["A", "B", "C", "D"]`
* `insert` - inserts item *x* at index *i* in an array. The stack order of the arguments is `array, item, (index)`. Index defaults to end of array.
* `remove` - removes an item at an index in an array. The order of the arguments is `array, item, (index)`. Index defaults to end of array.
* `cut` - cuts an array at index *n*, where *n* can be any positive or negative value between 1 and array length-1, or negative value in the same range, which will go backwards from the end of the array. Index defaults to the end of the array minus one (e.g. separates the last element from the array). If any of the parts after cutting contains only one item, it will be pushed back as just that item, instead of an array of length 1. `[1, 2, 3, 4] 2 cut` -> `[1, 2] [3, 4]`. `[1, 2, 3] 2 cut` -> `[1, 2] 3`.

```
push [1, 3, 2]
cut
push 1
insert

# [1, 2, 3]
```


## Folding Operators

Since arrays can live on the stack, it makes sense that operators can manipulate them. In addition to the regular arithmetic operators, Sokolang offers a few unique "folding" operators that apply to the **contents of the array**. These operators are also somewhat magical, in that they can work with arrays of records (images being the prime use case).

* `sum` - computes the sum of the elements. Like inserting `+` between every element.
* `prod` - computes the product of the elements. Like inserting `*` between every element.
* `avg` - computes the arithmetic mean elements. Like summing and dividing by the original length, truncated.
* `diff` - computes the cumulative difference among the elements.
* `concat` - concatenates the elements. Integers and strings used as-is, records are type-dependent


## Stack manipulation & inspection

Common to stack machines are ways to, well, manipulate the stack. Also a few ways to inspect the state of the stack.

Manipulation:
* `push`   pushes something onto the stack. This keyword is actually optional! It is purely there to provide clarity.
* `drop`   drops (discards) the top item
* `swap`   swaps places of the top two items
* `pick`   pops a number *n* off the stack, and then copies the *n*th item on the stack to the top.
* `rotate` rotates the top 3 items on the stack, by moving the top element to the bottom, so the top-of-stack item becomes #3. `3 2 1` -> `1 3 2`
* `dup`    duplicates the top item
* `!`      repeat the last instruction that wasn't also a `!`. This means these can be chained (e.g. `+ !!!` will repeat the `+` command 3 times). For large number of repetitions, better use a loop.

Inspection:
* `.` prints the current top item without popping it
* `peek` pops a number *n* from the stack and prints the *n*th item on the stack without any side effects. This is basically the same as `.` but with more control.
* `dump` prints the basic representation of the whole stack. For files (images, recordings) this just prints the file name. For strings, prints a trunkated version.


## Registers

Sokolang does offer a few general purpose registers, three special purpose registers, and facilities to manipulate them. The general purpose registers are named `A`, `B`, `C`, `X`, `Y`, `Z`. These registers can hold any value that the stack can hold. They retain their value when read. Storing a value does ***NOT*** pop it off of the stack; values are simply copied to the register, and the stack is left as-is.

The special registers are the Program `PP`, Error `ERR`, and I/O `IO` registers. The Program Pointer register automatically tracks the current program line being executed. It can also be written to, effectively moving the program pointer; this allows for some different control flow vs labels. The Error register `ERR` contains information about the most recent instruction; `ERR` equals 0 if the last instruction succeeded, any value other than 0 is an error code specific to the type of error that occured. The I/O register sets the target for `read` and `write` instructions, and can hold either hex memory addresses or file names, and will redirect reads/writes accordingly. This is a very powerful feature, allowing the user to shuttle chunks of data between the stack, memory, and the file system.

* `store A` - copies the top stack item to register A
* `store AX` - copies the top stack item to registers `A` and `X` simultaneously. Each available general purpose register can appear once in the list, in any order.
* `store AIOX` - copies the top stack item to registers `A`, `IO`, and `X`.
* `load A` - pushes a copy of the value in register `A` onto the stack.
* `load AX` - pushes copies of the values of all registers in the list onto the stack, in left-to-right order (e.g. `A` first, `X` second).

There are shorthands for these operations, as follows:

* `ST<regs>` - same as `store <regs>`. `STXBC` -> copies stack value to registers X, B, and C.
* `LD<regs>` - same as `load <regs>`. `LDXBC` -> pushes copies of values in X, B, and C onto the stack in that order.

As mentioned, the `E` error register register values give a hint to what went wrong. Here's a list of error codes;

+ TBD


## Records

Some devices and operations return a complex chunk of data, and these are considered Records. Records are things like images, sound recordings, instrument data, etc. Records cannot usually be manipulated on a byte level, however they have lots of interesting interactions with the "magic operators". For instance, adding two image records will add the two images together pixel-wise. Records cannot be directly referenced, and cannot be directly created. You can operate on them, move them around on the stack, in registers, memory, and files. Records are displayed by their name, e.g. `img_1`.


## Read & Write

`write` - pops the top value off the stack, and writes it to its `IO` destination.
`read`  - reads data from the current `IO` destination, and pushes it into the stack.

Reads and writes can be directed to one of two systems; Memory or File. With respect to reading and writing, these are equivalent, however Memory is addressed via numerical addresses (hex or integer), and is a finite structure; that is, there are only so many memory blocks available to use. Files are less restrictive, and is addressed by file name.

There is a safety system in place, which will block writes completely unless disabled. This system is enabled by default, and can be disabled by using the `unsafe` instruction. The system remains unlocked until a `safe` instruction is entered. This safety mechanism is local to whatever script is currently executing, or to the current REPL session.

The `read` and `write` commands will read or write from/to whatever destination is currently set in the `IO` register. If the `IO` register contains a number value (in either `0xFF` hex style format, or an integer `255`, both are equivalent), then this memory location will be used. If the `IO` register contains a string value, a file with this name will be used.

Reading an "empty" memory block will just return `0`. Writing to a valid memory block or existing File will immediately overwrite it, if the system is `unsafe`. If the system is `safe`, it will do nothing, and write a non-zero value to the `ERR` register. Reading/writing from/to a non-existent/invalid location will do nothing, and write a non-zero value to the `ERR` register.




## Boolean Operators

Boolean piecewise operators `AND` `OR` `XOR` `NOT` are availabe (that is not a typo - it does say *piece*wise). They have some *very magical* powers.

The exact behavior of the piecewise ops depend on the types of its operand(s), left and right operands *usually* have to be of the same type. `NOT` obviously only takes a single operand. These operations pop items off the stack and push a result back on.

Here are some examples of what piecewise ops does to different data types, when operand types are symmetrical:
* Numbers   - your regular bitwise operations.
* Strings   - performs some pretty unique piece-wise operations, see [String Magic](#string-magic).
* Images    - bitwise op on pixel values across images. Basically; masking, blending, diffing, inverting.
* Records   - incompatible?
* Addresses - treated as integers
* Arrays - applies the piecewise operator to pairs of values from each array; `[1, 2] [1, 0] AND` -> `[1, 0]`


## Control Flow

Sokolang only really implements one feature for control flow, and that is labels, as well as obviously ways to jump to labels conditionally (or unconditionally).

```
push 5
:LOOP
.
push 1
-
JGZ LOOP
```

In this example, we define a label `LOOP`, and later perform a conditional jump `JGZ LOOP`, which checks the top item on the stack, and **J**umps if **G**reater than **Z**ero. Thus, this code is a loop that successively prints the values `5 4 3 2 1`.

Labels can be any string containing the letters [A-Z].

There are several conditional jumps:

* `JMP` Unconditional Jump. Always jumps to the specified label.
* `JEZ` Jump if Equal to Zero. Jumps if the top stack item is 0.
* `JNZ` Jump if Not Zero. Jumps if the top stack item is not 0.
* `JGZ` Jump if Greater than Zero. Jumps if the top stack item is greater than 0.
* `JLZ` Jump if Less than Zero. Jumps if the top stack item is less than 0.

Note: As far as jumps are concerned, ANY non-numerical value on the stack is treated as "greater than 0".


## NaN: Not a Number

NaN represents the void screaming back at you. Well, okay, it's the result of an undefined operation, like dividing by zero. The reason it's dangerous is because it is infectious - any operation that encounters **NaN** as an operand, will immediately produce **NaN**. This makes sense, because trying to perform any sort of arithmetic or logic when one of the operands is literally the representation of an intangible void, can never compute something useful, and will thus itself always produce **NaN**.

What this all really means is that once NaN appears in some part of your program, unless you are extremely careful, it will spread like a disease until everything you touch becomes **NaN**.