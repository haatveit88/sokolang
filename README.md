# Sokolang

Sokolang is a simple (but *magical*) stack-based programming language. It was designed and built for the specific purpose of being the language used by the player in my programming-puzzle-game (currently in development).

This is the first time I ever try to seriously design and implement a programming language, so do not expect anything fancy; my only goal is for this to work, at all!

The name is (obviously, I hope) insired by Sokoban. Being a stack-based language, we'll be doing a lot of `push`ing. 🥁

In this repository you'll find the work-in-progress prototype implementation of the language, written in Lua. It has no dependencies and never will have. I may or may not ever write the language spec separately from the Lua implementation; I am inventing this as I go. But if it ever reaches some kind of completeness, I will consider sitting down to do it. Else, just view the code! It is being written with maximum readability in mind, avoiding usage of highly specific Lua-isms as much as possible. This should allow the implementation code to be easy to read for anyone, regardless of language preference. This, in turn, should make it easy to port to any language. If you **DO** port this to another language, please let me know, that'd be really cool!

# Goals

Sokolang is intended to be very simple to understand for non-programmers, and to do what they *want* as often as possible. This means Sokolang may sometimes *not* do what an experienced programmer would expect. There are some *magical* features to work on unusual data types. And there are some not-strictly-stack-based features, borrowing ideas from register machines, etc.


# Features


## Magic Stack

The stack upon which Sokolang operates, is *magical* in the sense that it can hold really weird data types, directly on the stack. For example, it can hold; images, audio recordings, memory addresses, strings... And more. Some of these things obviously won't work outside of the game. In these cases, this prototype implementation will approximate the game-specific types with simplified models.

Here is a list of types the stack can hold, which also conveniently doubles as a list of all the types recognized by the language in general:

* **Numbers**: Floats and ints can intermingle in most contexts, but for some operations only one or the other is supported
    * `push 5` `push 3.14`
* **Strings**: String literals. They must be quoted, either by single or double quotes. No mixing of quotes. Single characters are also strings.
    * `push "hello world"` `push 'a'` `push "b"` `push 'sokoban'`
* **Images**:  The exact representation is TBD. Referenced by filename. Prime target for [magic operators](#magic-operators) and [fold operators](#folding-operators).
    * `push [img_a, img_b, img_c]` assuming files img_a, img_b, img_c to exist in the filesystem.
* **Audio**:   Treated as array of samples in time, where a sample is the average input some sample interval TBD.
* **Memory**:  Memory addresses, treated as numbers for most operations, but visually represented as `$LABELS` (if exists) or `0x` hex values.
    * `push $DEVICE_ADDRESS` `push 0xFF`
* **Files**:   Files have a special set of operators, see [File Operations](#file-operations). But they do support some magic operators and folds.
    * `> A_FILE` append current top of stack item to file, if supported (anything but audio and images, basically)
    * `< A_FILE` read one byte from file and pushes onto stack
* **NaN**:     Not a Number. This one means things are about to go from bad to worse, see [NaN: Not a Number]()


## Magic Operators

To complement the [Magic Stack](#magic-stack), there are Magic Operators. Really they are just regular operations, but they apply to most datatypes in ways that may be unexpected to programmers, but perhaps intuitive to non-programmers.

For example, adding two images together is completely valid, and produces a new image that is the pixel-wise sum of its operands. The intention is more or less that *if you can imagine this operation doing something useful, it should do that thing*. Adding a number to an image? Fine, your image is now brighter. Add two arrays together? Sure, they will add element-wise (pseudocode): `[1, 2] + [3, 4] = [4, 6]`.

Of special note is the negate operator `!` - this

A matrix of type & operator combinations should appear in this document at some point.


## Folding Operators

Since arrays - which are really more like lists - can live on the stack, it makes sense that operators can manipulate them. Sokolang offers a few "folding" operators that apply to the **contents of the list**. These operators are also somewhat magical, in that they can accept numbers or images (the list elements must all be the same type).

`sum` - computes the sum of the elements. Like inserting `+` between every element.
`prod` - computes the product of the elements. Like inserting `*` between every element.
`avg` - computes the arithmetic mean elements. Like summing and dividing by the original length.
`diff` - computes the cumulative difference among the elements.
`concat` - concatenates the elements. Integers and strings only.


## Stack manipulation & inspection

Common to stack machines are ways to, well, manipulate the stack. Also a few ways to inspect the state of the stack.

Manipulation:
* `push x` pushes *x* onto the stack
* `drop`   drops (discards) the top item
* `swap`   swaps places of the top two items
* `pick`   pops a number *n* off the stack, and then copies the *n*th item on the stack to the top.
* `rotate` rotates the top 3 items on the stack. #1 becomes #3, #2 becomes #1, and #3 becomes #2. `3 2 1` -> `1 3 2`
* `dup`    duplicates the top item

Inspection:
* `.` prints the current top item without popping it
* `peek` pops a number *n* from the stack and prints the *n*th item on the stack without any side effects. This is basically the same as `.` but with more control.
* `dump` prints the basic representation of the whole stack. For files (images, recordings) this just prints the file name. For strings, prints a trunkated version.


## Registers

Despite being a stack machine, Sokolang does offer a few general purpose registers, as well as a program counter register, and some facilities to manipulate them. The program counter register, called `P`, automatically increments for each program instruction that is executed. It can also be written to, effectively moving the instruction pointer somewhere else. This allows for some different types of control flow vs labels, but can be used in combination with it. Each line in a program counts as an instruction.

The general purpose registers are named `A`, `B`, `C`, `X`, `Y`, `Z`. These registers can hold any value that the stack can hold. They retain their value when read.

* `store A` - stores the top stack item in one of the registers; `A`, `B`, `C`, `X`, `Y`, `Z`, `P`.
* `store [A, X]` - stores the top two stack items in `A` and `X`, respectively. The list can contain any combination of the available registers.
* `recall A` - copies the item in register `A` onto the stack.
* `recall [A, X]` - copies items from all registers in the list onto the stack, in left-to-right order.
* `clear A` - clears register `A` to 0.
* `clear [A, X]` - you get the idea. Clears all registers in the list to 0.


## Boolean Operators

Boolean piecewise operators `AND` `OR` `XOR` `NOT` are availabe. They also have some *magic* powers, but less so than other features. That is not a typo - it does say *piece*wise, not bitwise. Some data types are treated bitwise, some are treated more like pieces or fragments.

Pure logic operators are absent simply because pure boolean values don't exist, and their useage for control flow is already covered by other features (cond. jumps, program counter). Besides, piecewise logic can function equivalently in many use cases.

The exact behavior of the piecewise ops depend on the types of its operand(s), left and right operands *usually* have to be of the same type. `NOT` obviously only takes a single operand.

Here are some examples of what piecewise ops does to different data types, when operand types are symmetrical:
* Numbers   - your regular bitwise operations. **Floats are truncated first**.
* Strings   - performs some pretty unique operations, see [String Magic](#string-magic).
* Images    - bitwise op on pixel values across images. Effectively, masking, screening, diffing, inverting
* Audio     - incompatible
* Files     - incompatible
* Addresses - treated as integers


## Control Flow

Sokolang only really implements one feature for control flow, and that is labels, as well as obviously ways to jump to labels conditionally (or unconditionally).

```
push 5
:LABEL
.
push 1
-
JGZ LABEL
```

In this example, we define a label `LABEL`, and later perform a conditional jump `JGZ LABEL`, which checks the top item on the stack, and **J**umps if **G**reater than **Z**ero. Thus, this code is a loop that successively prints the values `5 4 3 2 1`.

Labels can be any string containing the letters [A-Z].

There are several conditional jumps:

* `JMP` Unconditional Jump. Always jumps to the specified label.
* `JEZ` Jump if Equal to Zero. Jumps to the label if the top of the stack is 0.
* `JNZ` Jump if Not Zero. Jumps to the label if the top of the stack is not 0.
* `JGZ` Jump if Greater than Zero. Jumps to the label if the top of the stack is greater than 0.
* `JLZ` Jump if Less than Zero. Jumps to the label if the top of the stack is less than 0.

As far as jumps are concerned, ANY non-numerical value on the stack is treated as "not 0".


## NaN: Not a Number

NaN represents the void screaming back at you. Well, okay, it's the result of an undefined operation, like dividing by zero. The reason it's dangerous is because it is infectious - any operation that encounters **NaN** as an operand, will immediately return **NaN**. This makes sense, because trying to perform any sort of arithmetic or logic when one of the operands is literally the representation of an intangible void, can never compute something useful, and will thus itself always return **NaN**.

What this all really means is that once NaN appears in some part of your program, unless you are extremely careful, it will spread like a disease until everything you touch becomes **NaN**.

As you can tell, computer science is essentially existential horror.
