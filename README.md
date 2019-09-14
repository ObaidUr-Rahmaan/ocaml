# OCaml

OCaml is a general purpose programming language with an emphasis on expressiveness and safety.

## Why OCaml?

Some compelling reasons to learn and use OCaml:

* **Hybrid vigor** - OCaml is a functional programming language, but also an imperative language, and also an object-oriented language. This means you can mix and match paradigms at will. If you need extreme speed or frugal memory usage and the functional aspects are getting in your way, you can write an imperative function or two (not an option with a purely functional language like Haskell). And you needn't structure your entire application in an object-oriented fashion (the way you must with Java, for example) -- only the parts where that's appropriate.

* **Extremely efficient implementation** - Different "scripting languages" (e.g., Perl, Python, Tcl, PHP) naturally differ in how fast they execute. But compared to C or C++, they are all so slow -- an order of magnitude slower -- that they can be considered together in one speed category. Why wait for your successful program, implemented in your favorite scripting language, to disappoint you by not scaling as your users push its boundaries? OCaml is basically as fast as C. Time for a powerful, high-level, type-safe language (i.e. not C or C++) that's truly fast.

* **Strong static typing with type inference** - OCaml is a strongly-typed language (which means no core dumps and eliminates a large class of data corruption problems) which is statically typed (which means that OCaml detects type conflicts -- a large class of bugs -- at compile-time rather than at run-time, perhaps months after your application is in production) and polymorphically typed (meaning that you can write one function that manipulates a list (array, ...) regardless of what type (integers, strings, ...) that list contains). And it achieves this without requiring you to write type declarations for your variables or functions.

* **Single-file Deployment** - With its traditional compiler-and-linker technology, OCaml allows you to deploy your application as a single-file executable, with no prerequisites on the target system (such as an installed interpreter or installed third-party libraries)

* **Extensive Libraries** - OCaml comes with an extensive standard library with good data structures, POSIX system calls, and networking primitives. Third-party libraries contributed by the community support high-level network APIs, databases, XML, Unicode, and much more

* **True Static Scope with Closures** - OCaml has true nested scope: in other words, you can define functions inside of other functions (recursively). This may not sound impressive -- after all, nested functions have been around since Algol 60 -- until you remember that C's "innovation" of not allowing nested functions was widely copied and many languages that were designed after C likewise disallow it.

* **Pattern Matching** - OCaml allows you to use pattern matching in your function definitions. As a result, the structure of the function models the structure of the data it's processing, making it easy to see base cases and harder to miss a case, as you might using conditionals. In fact, OCaml's type checker can often warn you that you've left out a case. For example, this definition:

```OCaml
let rec listlength = function
      | car::cdr -> 1 + listlength cdr
```

   results in this warning:

```OCaml
let rec listlength = function
    | car::cdr -> 1 + listlength cdr
      ;;
    Warning: this pattern-matching is not exhaustive.
    Here is an example of a value that is not matched:
    []
    
    val listlength : 'a list -> int = <fun>
```

* **Good Development Tools** The OCaml distribution comes with a very good suite of development tools. Of course you get the byte-code and native-code compilers, the byte-code interpreter and the interactive top-level. (Note that this means you can evaluate OCaml code interactively the way you would with Lisp or Tcl, as well as compile standalone executables linked with all your libraries, the way you would with C or C++.) But it also comes with a debugger and a profiler for the byte-code (native-code applications are profiled with gprof). The debugger deserves special mention: it's what is sometimes called a time travel debugger, in that you can not only step execution forward, but backwards -- going back in time to see previous values of variables. This is a real treat after years of stepping debuggers one step forward too many and then having to start over! I should also mention that the OCaml interactive top-level has a trace facility that's very easy to use and often obviates the need to use the debugger (at least when you have a reasonable idea of which function your bug is in).

<br/>
