jp
==
A JSON processor: it takes a stream of JSON text, parses it onto a stack, optionally transforms it, and then prints it out. jp automatically detects multiline JSON, and JSON per line input.

    jp [options] [arg ...]

    echo '[{"id":1},{"id":2}]' | jp .vals '"id"' .k .vals
    1
    2

Options
-------

    -i  set indent value (default is two spaces)
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
If jp received any input and it was successfully parsed into tokens, they will be in a single item on top of the stack. The transform stage is an opportunity to manipulate the stack with programming via args. jp processes its args at least once; when it receives JSON-per-line input it will process its args for each line. E.g: the JSON string `"customer"` is pushed onto the stack which is collected into an array, for each line of input:

    echo -e $'1\n2' | jp -P '"customer"' .collect
    ["customer",1]
    ["customer",2]

### JSON values
Any JSON literal will be parsed and pushed onto the stack, here's a string:

    jp '"howdy"'
    "howdy"

### .pop
Pops the top item off the stack, deleting it.

    jp 1 .pop
    # no output as stack is empty

### .swap
Swaps the top two items of the stack with each other.

    jp '"Hello"' '"World!"' .swap
    "Hello"
    "World!"

### .dup
Copies the value on the top of the stack making it the top two items.

    jp '"Hello"' .dup
    "Hello"
    "Hello"

### .++
Concatenate strings, arrays or objects on the stack into one value.

    jp '" World!"' '"Hello,"' .++
    "Hello, World!"

    jp '["JavaScript","PHP","Perl"]' '["Python"]' .++
    [
      "Python",
      "JavaScript",
      "PHP",
      "Perl"
    ]

    jp '{"name":"Lex Luthor", "email":"lex@example.com"}' '{"job":"villain"}' .++
    {
      "job": "villain",
      "name": "Lex Luthor",
      "email": "lex@example.com"
    }

### .keys
Pop an object off the stack and push one value for each key.

    jp '{"name":"Lex Luthor", "email":"lex@example.com"}' .keys
    "email"
    "name"

### .vals
Pop an object/array off the stack and push one value for each item.

    jp '{"name":"Lex Luthor", "email":"lex@example.com"}' .vals
    "lex@example.com"
    "Lex Luthor"

    jp '["octocat","atom","electron","api"]' .vals
    "api"
    "electron"
    "atom"
    "octocat"

### .collect
Creates a new array, pops every stack item appending it to the array and pushes the array.

    jp '"octocat"' '"atom"' '"electron"' '"api"' .collect
    [
      "api",
      "electron",
      "atom",
      "octocat"
    ]

Combine with `.vals` to reverse an array:

    jp '["octocat","atom","electron","api"]' .vals .collect
    [
      "octocat",
      "atom",
      "electron",
      "api"
    ]

### .drop
Pops the top item off the stack to get a count. Then pops that many items, deleting them.

    jp '"foo"' '"bar"' 1 .drop
    "foo"

### .pairs
Pop an object off the stack and pushes an object for each key/value pair.

    jp -P '{"name":"Lex Luthor", "email":"lex@example.com"}' .pairs
    {"email":"lex@example.com"}
    {"name":"Lex Luthor"}

### .k
Pops a string and then pops every item off the stack, accumulating all the key values (if found) in an array, pushes the array.

    jp -P '{"user":"dnmfarrell","email":"david@example.com"}' '"email"' .k
    ["david@example.com"]

### .i
Pops an integer off the stack to use as an index and then pops every array off the stack, accumulating all the values (if found) in an array, pushes the array.

    jp -P '["JavaScript","PHP","Perl"]' 1 .i
    ["PHP"]

### .lt .le .eq .ne .ge .gt
Filter strings/numbers. Pops the first value off the stack to use as an operand, then pops all remaining values off the stack, accumulating any which pass the comparison in an array, pushes the array.

    jp -P 1 2 3 2 .le
    [2,1] # less than or equal to 2

N.B. Bash's test function does not support "greater-than-or-equal" or "less-than-or-equal" string comparisons. For `.le` string comparisons, jp uses `<`, and `>` for `.ge'.

### .=~
Match a string extended posix pattern against other strings or numbers.

    jp '"5"' 123 5.0 -1 '"foo"' '"^[0-9]+$"' .=~
    [
      123,
      "5"
    ]

### .count
Replaces the stack with a count of stack items.

    jp '"JavaScript"' '"PHP"' '"Perl"' .count
    3


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

    prove $(find tests -name '*bash')
    tests/parse/string-unicode.bash ....... ok
    tests/parse/array.bash ................ ok
    tests/parse/json-test-suite.bash ...... ok
    tests/parse/null.bash ................. ok
    tests/parse/halts.bash ................ ok
    tests/transform/count.bash ............ ok
    tests/transform/json-test-suite.bash .. ok
    tests/transform/match.bash ............ ok
    tests/transform/push.bash ............. ok
    tests/transform/drop.bash ............. ok
    tests/transform/keys.bash ............. ok
    tests/transform/pop.bash .............. ok
    tests/transform/collect.bash .......... ok
    tests/transform/concat.bash ........... ok
    tests/transform/dup.bash .............. ok
    tests/transform/k.bash ................ ok
    tests/transform/i.bash ................ ok
    tests/transform/pairs.bash ............ ok
    tests/transform/swap.bash ............. ok
    tests/transform/vals.bash ............. ok
    tests/transform/test.bash ............. ok
    tests/print/plain.bash ................ ok
    tests/print/indent.bash ............... ok
    tests/print/pretty.bash ............... ok
    tests/print/silent.bash ............... ok
    All tests successful.
    Files=25, Tests=457,  6 wallclock secs ( 0.19 usr  0.06 sys +  5.26 cusr  1.53 csys =  7.04 CPU)
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
