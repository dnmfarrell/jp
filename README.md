jp
==
A JSON processor: it takes a stream of JSON text, parses it onto a stack, optionally transforms it, and then prints it on STDOUT. jp automatically detects multiline JSON, and JSON per line input.

    echo '[{"id":1},{"id":2}]' | jp jp.vals '"id"' jp.k jp.vals
    1
    2


Options
-------

    -i  set indent value (default is two spaces)
    -n  no input, just process args
    -p  pretty print output (default to tty)
    -P  force plain output (default to non-tty)
    -s  silent disable output
    -t  trace mode


Dependencies
------------
* Bash 4.3 or higher (namerefs)


Parse
-----
jp parses the incoming JSON stream into an array of tokens that are pushed onto its stack. If it detects any malformed JSON it will emit an error and exit non-zero.

jp passes 314/318 of the [JSONTestSuite](https://github.com/nst/JSONTestSuite) parsing tests, making it one of the strongest validators. The failed tests are all related to Byte Order Marks:

     i_string_utf16LE_no_BOM.json
     i_string_UTF-16LE_with_BOM.json
     i_string_utf16BE_no_BOM.json
     i_structure_UTF-8_BOM_empty_object.json

Unlike some parsers, jp preserves object key order, and permits duplicate keys in objects.


Transform
---------
The stack of parsed JSON tokens can be transformed with the following args:

### JSON values
Any json literal will be parsed and pushed onto the stack, here's a string:

    echo '"Hello"' | jp '"World!"'
    "World!"
    "Hello"

### .pop
Pops the top entry off the stack, deleting it.

    echo '"Hello"' | jp .pop
    # no output as stack is empty

### .swap
Swaps the top two items of the stack with each other.

    echo '"Hello"' | jp '"World!"' .swap
    "Hello"
    "World!"

### .dup
Copies the value on the top of the stack making it the top two items.

    echo '"Hello"' | jp .dup
    "Hello"
    "Hello"

### .++
Concat strings, arrays or objects on the stack into one value.

    echo '"Hello"' | jp '" World!"' .swap .++
    "Hello, World!"

    echo '["JavaScript","PHP","Perl"]' | jp '["Python"]' .++
    [
      "Python",
      "JavaScript",
      "PHP",
      "Perl"
    ]

    echo '{"name":"Lex Luthor", "email":"lex@example.com"}' | jp '{"job":"villain"}' .++
    {
      "job": "villain",
      "name": "Lex Luthor",
      "email": "lex@example.com"
    }

### .keys
Pop an object off the stack and push one value for each key.

    echo '{"name":"Lex Luthor", "email":"lex@example.com"}' | jp .keys
    "email"
    "name"

### .vals
Pop an object/array off the stack and push one value for each item.

    echo '{"name":"Lex Luthor", "email":"lex@example.com"}' | jp .vals
    "lex@example.com"
    "Lex Luthor"

    echo '["octocat","atom","electron","api"]' | jp .vals
    "api"
    "electron"
    "atom"
    "octocat"

### .collect
Creates a new array, pops every stack entry appending it to the array and pushes the array. Here `.vals` and `.collect` combine to reverse the input array:

    echo '["octocat","atom","electron","api"]' | jp .vals .collect
    [
      "api",
      "electron",
      "atom",
      "octocat"
    ]

### .drop
Pops the top entry off the stack to get a count. Then pops that many items, deleting them.

    echo '[1,2,3]' | jp .vals 1 .drop
    2
    1

### .pairs
Pop an object off the stack and pushes an object for each key/value pair.

    echo '{"name":"Lex Luthor", "email":"lex@example.com"}' | jp -P .pairs
    {"email":"lex@example.com"}
    {"name":"Lex Luthor"}

### .k
Pops a key and then pops every object off the stack, accumulating all the key values (if found) in an array, pushes the array.

    echo '{"user":"dnmfarrell","email":"david@example.com"}' | jp '"email"' .k
    ["david@example.com"]

### .i
Pops an index and then pops every array off the stack, accumulating all the values (if found) in an array, pushes the array.

    echo '["JavaScript","PHP","Perl"]' | jp 1 .i
    ["PHP"]

### .lt .le .eq .ne .ge .gt
Filter strings/numbers. Pops the first value off the stack to use as an operand, then pops all remaining values off the stack, accumulating any which pass the comparison in an array, pushes the array.

    echo '[1,2,3]' | jp -P .vals 2 .le
    [3,2]

### .count
Replaces the stack with a count of stack items.

    echo '["JavaScript","PHP","Perl"]' | jp .vals .count
    3


Print
-----
jp prints whatever data is left on the stack after the transform stage. By default jp pretty prints JSON when printing to the terminal. You can override this behavior with the  -p and -P options:

    # pretty but piped
    echo '[1,2,3]' | jp -p | head
    [
      1,
      2,
      3
    ]

    # terse but in the terminal
    echo [1,2,3] | jp -P
    [1,2,3]

The default indent for pretty printing is two spaces but you can override it with the -i option:

    # tab indent - quoting to protect whitespace is a recurring theme in shell code
    echo '{"foo":[1,2,3]}' | jp -i '     '
    {
            "foo": [
                    1,
                    2,
                    3
            ]
    }


Use jp as a library
-------------------
All of jp's functions and global variables are namespaced under jp./JP. If jp is sourced, it will not execute the main function, and it can be used as a library by other scripts.


Shell Native
------------
jp is a shell native program, that is, it is written in the same programming language used to program the shell. This has some benefits:

1. Users of the program do not need to learn another DSL for transforming JSON. Args are just function names and json data.
2. Being written in shell code in a single file, all users need to modify jp is a text editor. All they need to run it is Bash 4.3 or higher.
3. Learning to program jp means learning shell, which is a useful skill that users can employ to build their own programs, understand the command line better, and so on.
4. jp can be used as a program, and as a library to provide behavior to other shell scripts.

Being shell native has some downsides too:
1. Shell code's limited support for programming concepts like data structures, return values and so on make it difficult to create apps in.
2. Bash 4.3 or higher is needed to run jp because it uses namerefs.
3. jp is not as fast as [jq](https://stedolan.github.io/jq/)!
4. Users have to be familiar with shell programming to get the most out of the program

All that's needed to solve these issues is a better shell programming language which is really fast, portable and used everywhere.


Improvements
------------
* jp is a recursive descent parser; this means it doesn't need to store a lot of state, it just traverses the data structure. The downside is it will gladly recurse down any data structure until the stack becomes full and it crashes. On my computer this happens after recursing through ~2000 nested arrays. A different parsing strategy would be more robust.
* jp needs more tests!


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
