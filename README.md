jp
==
jp is a JSON processor: it takes a stream of JSON text, validates it, optionally changes it, and then prints it on STDOUT. jp automatically detects multiline JSON, and JSON per line input.

As a validator, jp passes 317/318 of the [JSONTestSuite](https://github.com/nst/JSONTestSuite) parsing tests, making it one of the strongest validators. The failure stems from jp not detecting a trailing null byte (which shell treats the same as an empty string).


Transforming
------------
...

Printing
--------
By default jp pretty prints JSON when printing to the terminal. You can override this behavior with the PRETTY variable:

    # pretty but piped
    echo [1,2,3] | jp -b PRETTY=1 | head
    [
      1,
      2,
      3
    ]

    # terse but in the terminal
    echo [1,2,3] | jp -b PRETTY=
    [1,2,3]

The INDENT variable is used to indent nested data when pretty printing. It is set to 2 spaces, but you can override it:

    echo '{"foo":[1,2,3]}' | jp
    {
      "foo": [
        1,
        2,
        3
      ]
    }

    # tab indent - quoting to protect whitespace a recurring theme in shell code
    echo '{"foo":[1,2,3]}' | jp -b 'INDENT="     "'
    {
            "foo": [
                    1,
                    2,
                    3
            ]
    }

That `-b` argument stands for "before parsing" and is a hook for users to pass in arbitrary code to be eval'd by jp before it parses its input.

Shell Native
------------
jp is a shell native program, that is, it is written in the same programming language used to program the shell. This has some benefits:

1. Users of the program do not need to learn another DSL for programming jp. For example to make jp run under trace mode: `jp -b TRACE=1`
2. Because jp runs in the shell, I did not have to anticipate all the ways in which users may which to change the program behavior, and build APIs for them, unlike if it was written in C, for example. Using the before or after hooks, users can pass in code which is eval'd.
3. Being written in shell code in a single file, all users need to modify it is bash and a text editor.
4. Learning to program jp means learning shell, which is a useful skill that users can employ to build their own programs, understand the command line better, and so on.

Being shell native has some downsides too:
1. Shell code's limited support for programming concepts like data structures, return values and so on make it difficult to create apps in
2. Bash 4.3 or higher is needed to run jp because it uses namerefs
3. jp is not as fast as [jq](https://stedolan.github.io/jq/)!
4. Users have to be familiar with shell programming to get the most out of the program

All that's needed to solve these issues is a better shell programming language which is really fast and used everywhere.


License
-------
Copyright 2021 David Farrell

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
