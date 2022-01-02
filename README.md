jp
==
A JSON processor: it takes a stream of JSON text, parses it onto a stack, optionally transforms it, and then prints it out. jp automatically detects multiline JSON, and JSON per line input.

    jp [options] [arg ...]

    echo '[{"id":1},{"id":2}]' | jp .map .v
    2
    1

To get productive with jp quickly, try out the [tutorial](#tutorial). If you are trying to use jp and struggling, try [tech-support](#tech-support).

Options
-------

    -d  launch transform debugger
    -h  set repl history file (default is `.history`)
    -H  do not load/save repl history
    -i  set indent value (default is two spaces)
    -m  load macros from a file (option can be given multiple times)
    -p  force pretty print output (default to tty)
    -P  force plain output (default to non-tty)
    -r  launch REPL
    -s  silent, disable print step


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
Pops the the stack, deleting TOS.

    jp 1 .pop
    # no output as stack is empty

#### .swap
Swaps the top two stack items with each other.

    jp '"Hello"' '"World!"' .swap
    "Hello"
    "World!"

#### .dup
Copies TOS making it the top two items.

    jp '"Hello"' .dup
    "Hello"
    "Hello"

#### .over
Copies and pushes the second stack item ("over" the first).

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

#### .is_obj, .is_arr, .is_bool, .is_str, .is_num, .is_null
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
Pops TOS and if it is true, evaluates the next statement, otherwise ignoring it. Optionally accepts an else clause.

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
Returns the logical complement (negation) of TOS.

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

#### .ltarr .eqarr .gtarr
Filters an array by a comparison to a number or string (macro).

    jp -m macros.jp -P [1,2,3,4,5] 3 .ltarr
    [1,2]

#### .match
Pops TOS which should be a string containing an extended posix pattern. Pops the next item (which should be a string or number) compares them, pushing true/false onto the stack.

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

Indeed this is the definition of the `.revarr` macro.

#### .fromstr
Pops a string off the stack, strips its outer quotes and re-parses it as JSON. This can be used to cast a valid JSON string into any other JSON type. As `.ex` command output is always treated as strings, the two commands often go together:

    jp '"date"' '"+%s"' 2 .ex .fromstr
    1639074686

#### .h
Pops an array off the stack, pushing the first element (head). To get the remainder of the array, see `.t`

    jp [1,2,3] .h
    1

#### .ht
This macro splits a TOS array into its head and tail:

    jp -P -m macros.jp [1,2,3] .ht
    1
    [2,3]

#### .idx
Pops an integer and an array off the stack, pushing the element from the array which matches the index number. Index number must be 0 or higher. Pushes nothing if the index number is greater than the array length.

  jp '["foo","bar","baz"]' 1 .idx
  "bar"

#### .k
Pops an object off the stack, pushing the first key back on the stack. See also `.v`.

    jp '{"a":1,"b":2}' .k
    "a"

#### .keyval
Pops a string and an object off the stack, pushing the value of the first pair with a matching key in the object.

    jp '{"a":1,"b":2}' '"b"' .keyval
    2

#### .len
Pops an array and pushes its length:

    jp [1,2,3] .len
    3

#### .pair
Pops TOS, which must be a string. Pops the next item as its value and pushes an object with a single pair back onto the stack.

    jp 123 '"a"' .pair
    {
      "a": 123
    }

#### .sort
This macro sorts an array in ascending order using quicksort. The array elements must all be strings or integers.

    jp -m macros.jp -P '["h","a","e","p","r"]' .sort
    ["a","e","h","p","r"]

#### .t
Pops an array off the stack, removes the first element (head) and pushes the remainder (tail). To get the head of the array, see `.h`

    jp [1,2,3] .t
    [
      2,
      3
    ]

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
Define a macro. Reads the next arg as the macro name (must begin with .). The following statement is used as the macro body. Whenever the name is encountered, it will be replaced with the macro body. Once defined, macros cannot be changed and redefinitions are ignored.

    jp .def .abc .do '"a"' '"b"' '"c"' .done .abc
    "c"
    "b"
    "a"

Because macros are lazily evaluated, they can recurse. This macro cons every stack item into an array on TOS:

    jp .def .consall .do .count 1 .gt .if .do .swap .cons .consall .done .done 1 2 3 [] .consall
    [
      1,
      2,
      3
    ]

You can load a file of macro definitions by providing the `-m` option. Macro files are loaded line-by-line, so macro definitions cannot contain newlines. This repo has an example macros file, `macros.jp`:

    # load the .exists macro
    jp -m macros.jp '{"a":1}' '"a"' .exists
    true

You can load multiple macro files by repeating the `-m` option.

Two advantages of defining macros in a file: first, they are only parsed once per jp process and second, arguments do not need to be quoted like they do on the command line:

    .def .abc .do "a" "b" "c" .done

#### .dump
Prints the contents of the stack to stderr, starting with `TOS` and ending with `---`:

    jp [1,2,3] false null '"foo"' .dump 1>/dev/null
    TOS     "foo"
      2     null
      3     false
      4     [1,2,3]
    ---

Dump will indicate when the stack is empty:

    jp .dump
    TOS     (empty)
    ---

Dump can serve as a simple debugging aid for programs, like print statements for other languages. Debug mode (option `-d`) will call `.dump` every step of a program.

#### .ex
Executes another program, stringifies its output and pushes it onto the stack. Pops the number of args to collect off the stack, and then pops that many args, building a command string by stripping surrounding quotes and prepending the result to the command string. Evals the command string and stringifies the output, pushing it back onto the stack.

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

REPL
----
Run jp with the `-r` option to launch the REPL:

```
Welcome to the jp REPL. Type commands and ENTER to evaluate, q quits.
> 
TOS     (empty)
---
```

This interactive mode reads commands, evaluates them, updates the stack and prints the stack contents. Multiple commands can be entered on one line. This a good way to try out commands and see their effect on the stack.

REPL history is stored in `.history`. As with the bash command line, Ctrl-R searches the history and the up key displays the next most recent command. Commands that generated an error are not saved in the history. The history file can be changed with the `-h` option, or disabled entirely with `-H`.


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

Tech Support
------------
If you are trying to use jp and running into difficulty, I want to hear from you! Please open a new [issue](https://github.com/dnmfarrell/jp/issues/new?labels=tech-support&title=%3CI%27m%20having%20difficulty%20with%20...%3E&body=%3CI%27ve%20tried%20...%3E%0A%0A%3Cattach%20sample%20JSON%20if%20any%3E). Include any JSON input data you are using, a brief description of what you are trying to accomplish, and what you've tried so far. I can't provide any service guarantees, but when I have time I'll look at your issue and try to provide a solution.

Tutorial
--------
### Intro
This tutorial will show you how to accomplish simple transformations on JSON objects like update, filter and delete. You'll need to [install](#install) jp and start a bash shell session. I recommend typing out all of the code examples yourself to better understand (and remember) what's going on. If you have suggestions for how this tutorial could be better please let me know by opening a new [issue](https://github.com/dnmfarrell/jp/issues/new?labels=tutorial).

To demonstrate I need some input data, so I'm going to use a shortened version of my GitHub profile. If you have a GitHub account, you can download your own JSON profile with curl (replace `gh_username` with your github username):

    curl https://api.github.com/users/gh_username > gh-profile.json

The first thing to get comfortable with is passing data into jp, which we can do using `cat` and pipe:

    cat gh-profile.json | jp
    {
      "login": "dnmfarrell",
      "id": 1469333,
      "url": "https://api.github.com/users/dnmfarrell",
      "type": "User",
      "site_admin": false,
      "name": "David Farrell",
      "blog": "blog.dnmfarrell.com",
      "location": "Buccaneer's Den, Britannia",
      "twitter_username": "perltricks",
      "public_repos": 147,
      "created_at": "2012-02-24T11:56:06Z"
    }

N.B. Because jp's parent directory is in my PATH environment variable, I don't need to provide the shell with the full path to `jp`. If jp is not in your PATH, you'll need to provide the path to jp. For example, if you cloned this repo and are currently in the root project dir, `./jp` is the relative path to the program.

All jp does is print the content back onto the terminal. What is the use in that? For one thing the fact that jp did not report an error means I know this JSON is syntactically correct. If that's all I care about though, I can give jp the silent option `-s`:

    cat gh-profile.json | jp -s

Now imagine I want to collapse the JSON into a single line of text, to make it easy to use as input for an API request. The  plain print `-P` does that:

    cat gh-profile.json | jp -P
    {"login":"dnmfarrell", ...}

(I've truncated the output for brevity, from now on whenever you see the ellipsis `...` just imagine it represents the rest of the data).

That just about covers parsing input and printing output. The real action happens between parsing and printing. That's called the transform stage.

### Filter
Let's filter my profile to extract my twitter username:

    cat gh-profile.json | jp -m macros.jp '"twitter_username"' .filterobj
    {
      "twitter_username": "perltricks"
    }

I've used a new option `-m` to load the macros helper file as that's where `.filterobj` is defined.

Next I pass the JSON string `"twitter_username"` as an argument, which jp stores on its internal stack. Finally the `.filterobj` macro uses the two stack values (the string, and the object of my GitHub profile) to inspect each pair in the object, and if the pair's key matches `"twitter_username"` it will keep it, else `.filterobj` deletes the pair.

However all I wanted was my twitter username, I don't care about the curly braces or key string. To pluck the value out of the pair, I can use `.v`:

    cat gh-profile.json | jp -m macros.jp '"twitter_username"' .filterobj .v
    "perltricks"

Note that the string `"perltricks"` is valid JSON. jp always prints JSON (or error messages).

### Delete
I can delete pairs from objects using the `.deleteobj` macro; e.g. to delete the twitter username pair:

    cat gh-profile.json | jp -m macros.jp '"twitter_username"' .deleteobj
    {
      "login": "dnmfarrell",
      "id": 1469333,
      "url": "https://api.github.com/users/dnmfarrell",
      "type": "User",
      "site_admin": false,
      "name": "David Farrell",
      "blog": "blog.dnmfarrell.com",
      "location": "Buccaneer's Den, Britannia",
      "public_repos": 147,
      "created_at": "2012-02-24T11:56:06Z"
    }

### Add
Here's how to add data to an object:

    cat gh-profile.json | jp  '{"favorite_food":"pizza"}' .concat
    {
      "favorite_food": "pizza",
      "login": "dnmfarrell",
      ...
    }

I pass the JSON object I want to add and use `.concat` to combine them. My "favorite\_food" pair has been prepended to the object. What if I want to _append_ it instead? In that case I need to swap the stack order so `.concat` gets the "favorite\_food" object as its second arg:

    cat gh-profile.json | jp  '{"favorite_food":"pizza"}' .swap .concat
    {
      "login": "dnmfarrell",
      ...
      "favorite_food": "pizza"
    }

### Update / Upsert
Perhaps I want to hide my location before sending the data elsewhere:

    cat gh-profile.json | jp  -m macros.jp '{"location":null}' .updateobj
    {
      "login": "dnmfarrell",
      ...
      "location": null,
      ...
    }

I've used the `.updateobj` macro to nullify the location value. The difference between update and add is that update will only take effect if the key "location" exists, whereas add will always add data to the object.

An upsert operation is yet another way to modify data: if the key exists, update it, otherwise insert the data. The `.upsertobj` macro does this.

### Programming
So far all of these conditional operations (filter, delete, update, upsert) are key based. That means the input string needs to exactly match the pair key to take effect. What if I want to take some action based on a pair _value_ instead? Now I can't use a predefined macro, I have to program the transformation myself.

For this scenario, imagine I am streaming GitHub user profiles to jp, and want to filter my profile out of the stream.

First I need to extract the login pair:

    cat gh-profile.json | jp -m macros.jp .dup '"login"' .filterobj
    {
      "login": "dnmfarrell"
    }
    {
      "login": "dnmfarrell",
      ...
    }

To avoid losing the input object, I duplicate it first, with `.dup`. Then I use the `.filterobj` macro to extract the login pair. jp now prints the stack containing the two objects. I find it easier to inspect the stack using plain output:

    cat gh-profile.json | jp -P -m macros.jp .dup '"login"' .filterobj
    {"login":"dnmfarrell"}
    {"login":"dnmfarrell", ...}

Now each line is one stack entry, I can easily count that there are 2 objects on the stack. Next I need to test whether the username is my own:

    cat gh-profile.json | jp -P -m macros.jp .dup '"login"' .filterobj .v '"dnmfarrell"' .eq
    true
    {"login":"dnmfarrell", ...}

Now the top stack value is a boolean, I can use `.if` to take some optional action:

    cat gh-profile.json | jp -P -m macros.jp .dup '"login"' .filterobj .v '"dnmfarrell"' .eq .if .pop

Because `.if` consumes the boolean, only the object is left on the stack. If it matches my username, I pop it off the stack. As the stack is empty, jp does not print anything.

To simulate the stream, I downloaded the GitHub profile of Beren Minor, who (among other things) mirrors GNU repos like bash to GitHub:

    curl https://api.github.com/users/bminor > gh-profile-bminor.json

Bash expands the argument `gh-profile*` into `gh-profile-bminor.json gh-profile.json`:

    cat gh-profile* | jp -P -m macros.jp .dup '"login"' .filterobj .v '"dnmfarrell"' .eq .if .pop
    {"login":"bminor", ...}

jp correctly filters my profile but still emits Beren's.

License
-------
Copyright 2021 David Farrell

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
