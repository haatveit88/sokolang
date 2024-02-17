# Sokolang

Sokolang is a simple (but *magical*) stack-based programming language. It was designed and built for the specific purpose of being the language used by the player in my programming-puzzle-game (currently in development).

This is the first time I ever try to seriously design and implement a programming language, so do not expect anything fancy; my only goal is for this to work, at all!

The name is (obviously, I hope) insired by Sokoban. Being a stack-based language, we'll be doing a lot of `push`ing. 🥁

In this repository you'll find the work-in-progress prototype implementation of the language, written in Lua. It has no dependencies and never will have. I may or may not ever write the language spec separately from the Lua implementation; I am inventing this as I go. But if it ever reaches some kind of completeness, I will consider sitting down to do it. Else, just view the code! It is being written with maximum readability in mind, avoiding usage of highly specific Lua-isms as much as possible. This should allow the implementation code to be easy to read for anyone, regardless of language preference. This, in turn, should make it easy to port to any language. If you **DO** port this to another language, please let me know, that'd be really cool!

# Goals

Sokolang is intended to be very simple to understand for non-programmers, and to do what they *want* as often as possible. This means Sokolang may sometimes *not* do what an experienced programmer would expect. There are some *magical* features to work on unusual data types. And there are some not-strictly-stack-based features, borrowing ideas from register machines, etc.


# Features


## Magic Stack

The stack upon which Sokolang operates, is *magical* in the sense that it can hold really weird data types, directly on the stack. For example, it can hold; images, files, device pointers, strings, floats, booleans, jump labels... Among others.

Some of these things obviously won't work outside of the game. In these cases, this prototype implementation will approximate the game in a simple way; `images` will just be 2D matrices, `device pointers` will call lua functions that behave like the devices in the game do, etc.

Here is a list of types the stack can hold:

* Numbers: They can intermingle in most contexts, but for some operations (like `concat`) only one or the other is supported
* Strings: String literals. Single characters `a` are also technically strings, with a length of 1
* Images:  Essentially 1D arrays, accessed as `y * index + x`
* Audio:   Treated as array of samples. Impractical to work on as array, but can accept many [magic operators](#magic-operators) and [fold operators](#folding-operators).
* Memory:  Memory addresses, treated as numbers for most operations, but visually represented as `$LABELS` (if exists) or `0x` hex values.


## Magic Operators

To complement the [Magic Stack](#magic-stack), there are Magic Operators. Really they are just regular operations, but they apply to most datatypes in ways that may be unexpected to programmers, but perhaps intuitive to non-programmers.

For example, adding two images together is completely valid, and produces a new image that is the pixel-wise sum of its operands. The intention is more or less that *if you can imagine this operation doing something useful, it should do that thing*. Adding a number to an image? Fine, your image is now brighter. Add two arrays together? Sure, they will add element-wise (pseudocode): `[1, 2] + [3, 4] = [4, 6]`.

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




# TODO:

* named registers
* `read` & `write` operators; %files and $memory, needs to be defined and explained
* array creation, `append` and `trim` (`split` ?) syntax needs to be defined and explained.
* Type & Operator matrix
* Error handling
* Examples
    * More complex loops
    * Working with arrays
    * Concrete problem examples