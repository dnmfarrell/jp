jp
==
jp is a JSON processor: it takes a stream of JSON text, parses it, optionally changes it, and then prints it on STDOUT. jp automatically detects multiline JSON, and JSON per line input.


Parsing
-------
jp passes 317/318 of the [JSONTestSuite](https://github.com/nst/JSONTestSuite) parsing tests, making it one of the strongest validators. The failure stems from jp not detecting a trailing null byte in a text stream which is not newline terminated. It detects any null byte encountered mid-stream though.


Transforming
------------
N.B. transformations are a work in progresss; more functions to come!

jp parses the incoming JSON stream into a data structure and places it on a stack. It then reads args for any transformation instructions.

    - push: any json literal will be parsed and pushed onto the stack, e.g. `"foo"`
    - pop: pops the top entry off the stack, deleting it
    - swap: swaps the top two entries of the stack with each other
    - dup: copies the vlaue on the top of the stack making it the top two entries
    - merge: combines all values on the stack into a single structure
    - keys, values, pairs: pop an object off the stack and push one key/values/object pair for each member of the object

    # merge two objects
    echo '{"foo": 123}' | jp '{"bar": 456}' jp.merge
    {
      "foo": 123,
      "bar": 456
    }

    # print an object's keys
    echo '{"foo": 123, "bar": 456}' | jp jp.keys
    "foo"
    "bar"

    # convert an object's keys into an array
    echo '{"foo": 123, "bar": 456}' | jp jp.keys '[]' jp.merge
    [
      "foo",
      "bar"
    ]


Printing
--------
jp prints whatever data is left on the stack after it has processed args. By default jp pretty prints JSON when printing to the terminal. You can override this behavior with the  -p and -P options:

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

    # tab indent - quoting to protect whitespace a recurring theme in shell code
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

1. Users of the program do not need to learn another DSL for transforming JSON. Args are just function names and json data,
2. Being written in shell code in a single file, all users need to modify jp is a text editor.
3. Learning to program jp means learning shell, which is a useful skill that users can employ to build their own programs, understand the command line better, and so on.
4. jp can be used as a program, and as a library to provide behavior to other shell scripts

Being shell native has some downsides too:
1. Shell code's limited support for programming concepts like data structures, return values and so on make it difficult to create apps in
2. Bash 4.3 or higher is needed to run jp because it uses namerefs
3. jp is not as fast as [jq](https://stedolan.github.io/jq/)!
4. Users have to be familiar with shell programming to get the most out of the program

All that's needed to solve these issues is a better shell programming language which is really fast and used everywhere.


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
