jp
==
A JSON processor: it takes a stream of JSON text, parses it onto a stack, optionally transforms it, and then prints it out. jp automatically detects multiline JSON, and JSON per line input.

    jp [options] [arg ...]

    echo '[{"id":1},{"id":2}]' | jp .map .v
    2
    1

Options
-------

    -i  set indent value (default is two spaces)
    -m  load macros from a file (option can be given multiple times)
    -p  force pretty print output (default to tty)
    -P  force plain output (default to non-tty)
    -s  silent, disable print step
    -t  trace mode


Parse
-----
If jp received any input, it parses the incoming JSON stream into an array of tokens that are pushed onto its stack. If it detects any malformed JSON it will emit an error and exit non-zero.

jp passes 314/318 of the [JSONTestSuite](https://github.com/nst/JSONTestSuite) parsing tests, making it one of the strongest validators. The failed tests are all related to null byte detection:

    n_multidigit_number_then_00.json
    n_string_unescaped_crtl_char.json
    n_string_unescaped_newline.json
    n_structure_null-byte-outside-string.json

Unlike some parsers, jp preserves object key order, and permits duplicate keys in objects.


Transform
---------
If jp received any input and it was successfully parsed into tokens, they will be in a single item on Top Of Stack ("TOS"). The transform stage is an opportunity to manipulate the stack with programming via args. jp processes its args at least once; when it receives JSON-per-line input it will process its args for each line. E.g: this program receives a stream of incrementing numbers and builds a JSON array containing the number and whether or not it is greater than 2:

    echo -e '1\n2\n3' | jp -P .dup 2 .gt [] .swap .cons .swap .cons
    [1,false]
    [2,false]
    [3,true]


### Stack Control

#### JSON values
Any JSON literal will be parsed and pushed onto the stack, here's a string:

    jp '"howdy"'
    "howdy"

#### .pop
Pops the top item off the stack, deleting it.

    jp 1 .pop
    # no output as stack is empty

#### .swap
Swaps the top two items of the stack with each other.

    jp '"Hello"' '"World!"' .swap
    "Hello"
    "World!"

#### .dup
Copies the value on the top of the stack making it the top two items.

    jp '"Hello"' .dup
    "Hello"
    "Hello"

#### .over
Copies the second stack item onto the top of the stack, "over" the first.

    jp 1 2 .over
    1
    2
    1

#### .rot
Rotates the third stack item into first place.

    jp 1 2 3 .rot
    1
    3
    2

### Reflection

#### .count
Pushes a count of items on the stack.

    jp 1 1 1 .count
    3
    1
    1
    1

#### .empty
This macro pushes true if the stack is empty, or false otherwise.

    jp -m macros.jp .empty
    true

#### .is_obj, .is_arr, .is_bool, .is_str, ._is_num, .is_null
Inspects TOS and pushes true or false.

    jp -P [1,2,3] .is_arr
    true
    [1,2,3]

### Control Flow

#### .do .. .done
Declares a block of code as a single statement, must be terminated with `.done`. Do blocks can be nested.

    jp .do 1 2 3 .done
    3
    2
    1

Empty do blocks can be used as a "no op" with `.map` to unroll an object or array:

    jp [1,2,3] .map .do .done
    3
    2
    1

    jp -P '{"name":"Lex Luthor","email":"lex@example.com","job":"villain"}' .map .do .done
    {"job":"villain"}
    {"email":"lex@example.com"}
    {"name":"Lex Luthor"}

#### .if [.else]
Pops the top stack item and if it is true, evaluates the next statement, otherwise ignoring it. Optionally accepts an else clause.

    jp true .if 1
    1

    jp false .if .do 1 2 3 .done .else 4
    4

#### .map
Pops an object/array off the stack and pushes each element onto the stack one by one, evaluating the next statement every iteration.

    jp [1,2,3] .map .do 3 .le .done
    true
    false
    false

Map is powerful. For example here's how to delete a pair from an object:

    jp '{"a":1,"b":2,"c":3}' {} .swap .map .do .dup .k '"a"' .eq .if .pop .else .concat .done
    {
      "c": 3,
      "b": 2
    }

### Logic
All of the logic functions are implemented as macros in the file `macros.jp`.

#### .and
Returns the conjunction of the top two stack items.

    jp -m macros.jp true false .and
    false

#### .or
Returns the disjunction of the top two stack items.

    jp -m macros.jp true false .or
    true

#### .not
Returns the logical complement (negation) of the top stack item.

    jp -m macros.jp true .not
    false

#### .exists
Pops a string off the stack, then pops an object. Pushes true/false depending on whether the string is found as a key in the object.

    jp -m macros.jp '{"a":1}' '"b"' .exists
    false

### Comparisons

#### .lt .le .eq .ne .ge .gt
Pops the top two stack items and pushes true/false depending on the result of the comparison. Bash can only compare integers and strings.

    jp 1 2 .eq
    false

N.B. Bash's test function does not support "greater-than-or-equal" or "less-than-or-equal" string comparisons.

#### .match
Pops the top stack item which should be a string containing an extended posix pattern. Pops the next item (which should be a string or number) compares them, pushing true/false onto the stack.

    jp 5 '"^[0-9]+$"' .match
    true

### Changing Data

#### .concat
Concatenate the top two strings, arrays or objects on the stack into one value.

    jp '" World!"' '"Hello,"' .concat
    "Hello, World!"

    jp '["JavaScript","PHP","Perl"]' '["Python"]' .concat
    [
      "Python",
      "JavaScript",
      "PHP",
      "Perl"
    ]

    jp '{"name":"Lex Luthor", "email":"lex@example.com"}' '{"job":"villain"}' .concat
    {
      "job": "villain",
      "name": "Lex Luthor",
      "email": "lex@example.com"
    }

`.concat` can be combined with `.map` to create filter, delete and update routines.

#### .cons
Pops a value off the stack, then pops an array and prepends the value to the array, pushing the new array back onto the stack.

    jp -P [2,3] 1 .cons
    [1,2,3]

Can be used with `.map` to reverse an array:

    jp -P [1,2,3] [] .swap .map .cons
    [3,2,1]

Indeed this is the definition of the `.reva` macro.

#### .collect
Creates a new array, pops every stack item appending it to the array and pushes the array.

    jp '"octocat"' '"atom"' '"electron"' '"api"' .collect
    [
      "api",
      "electron",
      "atom",
      "octocat"
    ]

#### .fromstr
Pops a string off the stack, strips its outer quotes and re-parses it as JSON. This can be used to cast a valid JSON string into any other JSON type. As `.ex` command output is always treated as strings, the two commands often go together:

    jp '"date"' '"+%s"' 2 .ex .fromstr
    1639074686

#### .k
Pops an object off the stack, pushing the first key back on the stack. See also `.v`.

    jp '{"a":1,"b":2}' .k
    "a"

#### .pair
Pops the top item off the stack, which must be a string. Pops the next item as its value and pushes an object with a single key/value pair back onto the stack.

    jp 123 '"a"' .pair
    {
      "a": 123
    }

#### .uniq
Pops an object off the stack, pushing the object back with any duplicate keys removed. The first key wins:

    jp '{"a":1,"a":2}' .uniq
    {
      "a": 1
    }

Want the last key to win? Reverse the object first:

    jp '{"a":1,"a":2}' {} .swap .map .do .concat .done .uniq
    {
      "a": 2
    }

#### .v
Pops an object off the stack, pushing the first value back on the stack. See also `.k`.

    jp '{"a":1,"b":2}' .v
    1

### Programming

#### .def
Define a macro. Reads the next arg as the macro name (must begin with .). The following statement is used as the macro body. Whenever the name is encountered, it will be replaced with the macro body. Recursive macros are not supported, but macro bodies can include other macros (just not themselves). Macros cannot be changed and redefinitions are ignored.

    jp .def .abc .do '"a"' '"b"' '"c"' .done .abc
    "c"
    "b"
    "a"

You can load a file of macro definitions by providing the `-m` option. Macro files are loaded line-by-line, so macro definitions cannot contain newlines. This repo has an example macros file, `macros.jp`:

    # load the .exists macro
    jp -m macros.jp '{"a":1}' '"a"' .exists
    true

Two advantages of defining macros in a file: first, they are only parsed once per jp process and second, arguments do not need to be quoted like they do on the command line:

    .def .abc .do "a" "b" "c" .done

#### .ex
Calls another program, stringifies its output and pushes it onto the stack. Pops the number of args to collect off the stack, and then pops that many args, building a command string by stripping surrounding quotes and prepending the result to the command string. Evals the command string and stringifies the output, pushing it back onto the stack.

    jp '"date"' 1 .ex
    "Thu 09 Dec 2021 01:54:08 PM EST"

Note the command args are prepended into the command string so they are backwards on the stack, but this makes them easier to read. Even if the quoting does get gnarly (see `.q`):

    jp '"perl"' '"-E"' $'"\'say for 1..5\'"' 3 .ex
    "5"
    "4"
    "3"
    "2"
    "1"

If the output is valid JSON, `.fromstr` can be used to cast the string into another value:

    jp '"date"' '"+%s"' 2 .ex .fromstr
    1639076249

#### .q and .nq
Quoting command line args can get pretty tiresome, so `.q` enables quote mode, which causes jp to wrap any JSON arg in quotes. The `.nq` command disables quote mode. Args must still be quoted to avoid word splitting. The `.ex` example condenses nicely:

    jp .q perl -E "'say for 1..5'" .nq 3 .ex
    "5"
    "4"
    "3"
    "2"
    "1"

Print
-----
jp prints whatever data is left on the stack after the transform stage. By default jp pretty prints JSON when printing to the terminal. You can override this behavior with the  -p and -P options:

    # pretty but piped
    jp -p [1,2,3] | head
    [
      1,
      2,
      3
    ]

    # terse but in the terminal
    jp -P [1,2,3]
    [1,2,3]

The default indent for pretty printing is two spaces but you can override it with the -i option:

    # tab indent
    jp -i '	' '{"foo":[1,2,3]}'
    {
    	"foo": [
    		1,
    		2,
    		3
    	]
    }

If you just want to use jp as a JSON validator and don't need the output, use silent mode `-s` and check the return code is zero:

    jp -s [1,2,3] && echo "valid!"
    valid!

N.B. errors are emitted on stderr, to silence them, redirect:

    jp -s [1,2,] 2>/dev/null
    # no error output

Use jp as a library
-------------------
jp is a [modulino](https://blog.dnmfarrell.com/post/modulinos-in-bash/). All of its functions and global variables are namespaced under `jp_` or `JP_`. If jp is sourced, it will not execute the main function, and it can be used as a library by other scripts.

Install
-------
Clone this repo:

    git clone git@github.com:dnmfarrell/jp

Add the root project dir to your PATH, or copy the file to a directory in your PATH.


Run test suite
--------------
Tests are shell scripts which emit [TAP](https://testanything.org/) output. You can run them with [prove](https://perldoc.perl.org/prove) (comes with Perl). I wrote a blog [post](https://blog.dnmfarrell.com/post/unit-testing-shell-scripts/) about this setup.

From the root project directory:

    prove tests/**/*.bash
    ...
    All tests successful.
    Files=28, Tests=473,  6 wallclock secs ( 0.16 usr  0.04 sys +  5.34 cusr  1.11 csys =  6.65 CPU)
    Result: PASS

Shell Native
------------
jp is a shell native program, that is, it is written in the same programming language used to program the shell. This has some benefits:

1. Users of the program do not need to learn another DSL for transforming JSON. Args are just function names and JSON data.
2. Being written in shell code in a single file, all users need to modify jp is a text editor. All they need to run it is Bash 4.3 or higher.
3. Learning to program jp means learning shell, which is a useful skill that users can employ to build their own programs, understand the command line better, and so on.
4. jp can be used as a program, and as a library to provide behavior to other shell scripts.

Being shell native has some downsides too:
1. Shell code's limited support for programming concepts like data structures, return values and so on make it difficult to create apps in.
2. jp is not as fast as [jq](https://stedolan.github.io/jq/)!
3. Users have to be familiar with shell programming to get the most out of the program

All that's needed to solve these issues is a better shell programming language which is really fast, portable and used everywhere.


Improvements
------------
* jp is a recursive descent parser; this means it doesn't need to store a lot of state, it just traverses the data structure. The downside is it will gladly recurse down any data structure until the stack becomes full and it crashes. On my computer this happens after recursing through ~2000 nested arrays. A different parsing strategy would be more robust.


Other Shell JSON Parsers
------------------------
These parse a JSON stream of text, and output a linear tree of paths which can be grepped:
* [JSON.sh](https://github.com/dominictarr/JSON.sh/) is compatible with ash, bash, dash and zsh
* [JSON.bash](https://github.com/ingydotnet/git-hub/tree/master/ext/json-bash) is a source-able bash library

[TickTick](https://github.com/kristopolous/TickTick) is a Bash library which provides inline JSON parsing and searching.


License
-------
Copyright 2021 David Farrell

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
