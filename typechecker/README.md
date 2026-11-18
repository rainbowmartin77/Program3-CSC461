# Programming Assignment 3: Typechecker Implementation in Prolog

This programming assignment integrates what we have learned about logical programming with what we have learned about type checkers.
To do so, you will implement a type checker for a set of (relatively) simple rules in Prolog.
Your code will be tested using the SWI-Prolog environment, and you will upload two files: `typechecker.pro` and `REFLECTION.md`.
These files may *not* be included in a Zip file, and must be separately.
Each file must contain your name, following the template provided.

# Description of the Type System

## Types

The type checker we are dealing with has the following types.

 - Integers (`int`)
 - Floating Point Numbers (`float`)
 - Real Numbers (`real`)
 - Characters (`char`, strings of length 1)
 - Booleans (`bool`)
 - Arrays of a type (`(array, T)`, where T is a type specifier)
 - The Void type (`void`)
 - Function Types (Discussed Below)

## Type Rules

For the sake of this assignment, the type rules are described informally.
You should spend some time writing out these type rules as axioms and formal inference rules.

### Compatibility Rules

 - Integers are compatible with real numbers
 - Floats are compatible with real numbers
 - Characters are compatible with arrays of characters
 - An array with items of type X is compatible with an array of items of type Y if X is compatible with Y
 - This relation is *transitive* and *reflexive* (except for the case of the `void` type, which is not compatible with anything).

### Expression Rules

 - `true` and `false` are `bool`
 - An integer has type `int`
 - A float has type `float`
 - A single-character string has type `char`
 - A string otherwise has type `(array, char)`
 - Dividing two integer literals `(div, X, Y)` has type `real`
 - An atom (a name representing a variable) gets its type from the environment.
 - An instance of `(mkarray, Type, Length)` resolves to the type `(array, Type)`, provided:
   - `Type` is not `void`, and
   - `Length` resolves to a type `int`.
 
The remaining expressions have a compound form.
Each expression is a tuple, with its first element as the operation, represented by a fixed symbol.
All remaining elements of the tuple are arguments for the operation.

The binary operations (`(Op, A, B)`) have types as follows.

| **Category** | **Operation** | **Type**          | **Argument Types**                      |
|--------------|---------------|-------------------|-----------------------------------------|
| Equivalence  | `equiv`       | `bool`            | Must have mutually compatible supertype |
| Comparison   | `lt`          | `bool`            | Compatible with `real`                  |
|              | `lte`         | `bool`            | Compatible with `real`                  |
|              | `gte`         | `bool`            | Compatible with `real`                  |
|              | `gt`          | `bool`            | Compatible with `real`                  |
| Logic        | `and`         | `bool`            | `bool`s                                 |
|              | `or`          | `bool`            | `bool`s                                 |
|              | `xor`         | `bool`            | `bool`s                                 |
| Arithmetic   | `add`         | Lowest Compatible | Both compatible with `real`             |
|              | `sub`         | Lowest Compatible | Both compatible with `real`             |
|              | `mul`         | Lowest Compatible | Both compatible with `real`             |
|              | `div`         | Lowest Compatible | Both compatible with `real`             |

#### Variable Declarations

Variables come into the environment when they are declared (or created by a control structure or function, below).
To declare a variable, the variable *must not already exist* in the environment, and **must not** have a `void` type.
There are two forms of declaration.

 - Type-Inferring Declaration, `(vardecl, Var, Expr)`, which will use the type of the expression to provide a type to `Var` in the modified environment.
 - Type-Checking Declaration, `(vardecltype, Var, Expr, Type)`, which will verify the type of `Expr` is compatible with `Type`, and use `Type` for `Var` in the modified environment.

#### Variable Assignment and Array Access

In addition to the simple variable access rule described above (a bare symbol resolves to the type it has in the environment), it is necessary to define rules for array element access, and variable assignment (separate from declaration).

Setting variables takes two forms, `(set, Var, Expr)` and `(arraySet, Var, Index, Expr)`, and require that `Expr` be compatible with the variable's declared type (in the case of `arraySet`, the type the array contains).
Additionally, `arraySet` requires that `Index` resolve to an integer type.

The array element access operation, `(arrayInd, Var, Index)` behaves similarly.
The resulting type is the type contained in the array, `Var`, `(array, Type)`, provided `Index` has type `int`.

#### Control Structures

This typechecker supports two control structures, `if` and `for`; both have a type of `void` (i.e., they produce no value).
`if` has two forms, `(if, Cond, Then)` and `(if, Cond, Then, Else)`, which typecheck when, `Cond` has type `bool` and the lists of expressions `Then` and `Else` both typecheck.

The for loop structure, however, is slightly more complicated.
It takes the form `(for, Var, Iter, Body)`, and typechecks when:
 - `Var` is not in the environment;
 - `Iter` has type `(array, IterType)`; and,
 - The list of functions, `Body` is type-consistent when `Var` is given type `IterType`.

#### Functions

This typechecker supports the introduction of functions and validation of function calls for type consistency.

The result of function creation has the type `(function, Params, ReturnType)`, introduces a binding for the name `(FName, FType)` where `FType` is as described earlier.
A function creation expression has the following form: `(function, FName, Params, Body, ReturnType)`, and is valid when:
 - There is not a type associated with `FName` in the environment;
 - The `Body` (a list of expressions) is consistent when the parameters and the function are bound with their respective types (i.e., `Params`, is a list of names and type bindings); and,
 - The type of the final expression in the `Body` is compatible with the declared `ReturnType`.

A function call, `(call, Name, Args)`, then, will have the type `ReturnType` of the function `Name`, when:
 - The function `Name` exists; and,
 - Each element of the list `Args` has the same type as its mate in the function's `Params`.

# Expected Interface

Your Prolog code must implement the following predicates.

 - `name/1` should have its first argument unify to a string containing your name.
 - `semester/1` should list the current semester (this is provided!).
 - `course/1` should unify to the course you are enrolled in, including section.
   For example, `CSC-461-D01` or `CSC-561-DT1`.
 - `typecheck/3` should have as its first argument the expressions remaining to be typechecked. 
   Its second argument should be the current environment, and the final argument should be the environment at the end of typechecking the whole program.
   **Note:** The final environment should show variable/type pairs in most-recently-determined-first order.

Additional predicates are permitted as needed.

For examples of the calls, see the Tests section.

# Tests

While I will use more tests than these, the following are provided as illustrations.

```prolog
typecheck([(vardecl, x, 7), (vardecltype, y, (div, 1, x), real)], [], [(y, real), (x, int)]).
\+ typecheck([(vardecl, x, 7), (vardecltype, y, (div, 1, x), float)], [], _).
typecheck([(vardecl, arr, (mkarray, int, 7)),
           (for, x, arr, [(vardecltype, y, x, int)])], [], [(arr, (array, int))]).
typecheck([(function, foo, [(x, int), (y, char)],
            [(vardecltype, r, y, (array, char)),
             (if, (gt, x, 0),
              [(set, r, (call, foo, [(sub, x, 1), y]))]),
             r], (array, char))], [],
         [(foo, function, [(x, int), (y, char)], array, char)]).
```

# Reflection Component

The reflection for this assignment must contain your name.
Additionally, you should answer the following questions:

 - How do you plan to begin this assignment?
 - What do you think will be the hardest part about this assignment?
 - How can you find solutions for the hardest part of the assignment?
 - What resources did you find helpful when completing this assignment?
 - How did your plan align with your actual experience writing the typechecker?
 - Did you find this assignment interesting?
   Did it help you to understand Prolog better?

# Further Notes

As a reminder, students are **not** permitted to collaborate on this assignment.
You may discuss with other students at a very high level, but you may not discuss at a level at or below pseudocode.
Additionally, recall the following restrictions from the syllabus:

 - You *may* use code from the textbook(s) or resources listed in assignments, lecture notes, or the syllabus.
 - You *may* use code from the /official documentation/ of the programming languages or libraries used in this class.
   (Hint: RTFM, read the fine manual, to find such potentially helpful code.)
   However, you may only use code examples from built-in packages.
 - You *may* use code that was presented or discussed in lecture.
 - You *may* use code from team members in group projects.
 - You *may not* use code from any other people, including students in or out of this course.
   If you provide code to other people for this purpose, you will be found to have violated the academic integrity policy as well.
 - You *may not* use code found from websites or resources found online other than those specifically authorized above.
 - You *may not* use code generated by large language model tools (or other AI tools), including ChatGPT, CoPilot, or any other AI program or AI assistant which may be embedded in your IDE or editor of choice.
   It is your responsibility to know if your IDE has an AI assistant, and to shut it off for this course; due to the multitude of AI tools and IDEs, I am unable to provide guidance on how to do so (Hint: RTFM).
 - You *may* use generative AI tools to try to explain error messages.
   If you do so, you *must* ask questions in such a way that none of the terms above are violated.
   If you are unsure if something is not permitted, just ask me first; if you get feedback from AI that contains code, send me a copy of your conversation, and we can talk.
 - Finally, you *must* cite any code you get from elsewhere (allowed or not).
   Citations need not be overly formal: from the textbook, just state the chapter & page, from lecture state which one, from docs, state the section (or link to the page).

## Resources

The following resources are approved for use.

 - [The SWI-Prolog Reference Manual](https://www.swi-prolog.org/pldoc/doc_for?object=manual)
 - [The Programmer Passport: Prolog](https://learning.oreilly.com/library/view/programmer-passport-prolog/9781680509373/) (Requires DSU Login through library)
 - [The Prolog WikiBook](https://en.wikibooks.org/wiki/Prolog)
 - [The Prolog Syntax and Semantics Wikipedia Page](https://en.wikipedia.org/wiki/Prolog_syntax_and_semantics)

# Required Files & Submission

You will submit exactly two files, and they must have exactly the following names:

 - `typechecker.pro`
 - `REFLECTION.md`
 
These files **must** conform to the specifications above for full credit.
A template is available as a Zip file on D2L which contains this specification (in Markdown), a template typechecker (with minimal definitions of all predicates), and a reflection file.

Points are allocated as follows:

 - 40 points will be assigned based on successfully passing testcases.
   There will be 20 tests, each test will be worth 10 points.
 - 10 points will be assigned for reasonable completion of the reflection.
