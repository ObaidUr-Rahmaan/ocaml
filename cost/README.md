# Execution and cost models

By "execution and cost model" we understand the way a functional program is executed, not only from the point of view of its *extensional* (that is, input-output) behaviour but also as *time and space* execution costs are concerned. For any language, functional or imperative or otherwise, identifying the execution cost model *inherent* to a program written in that language is difficult as we must try to abstract away from various contingencies such as:

* the execution costs of the underlying *hardware*
* the execution costs of the underlying *operating system*
* the execution costs of the underlying language *runtime*
* the quality and sophistication of the *compiler optimisations*
* the quality and sophistication of the *libraries*
* in general, the quality of the *language ecosystem*

Note that in common "shoot-out" approaches in comparing programming benchmarks all of the above comes into play. This is why such shoot-outs favour languages with a mature ecosystem and broad developer community. But we are here aiming to study *languages*. 

Imperative programming languages have simple cost models -- this is part of their appeal. A procedure is a sequence of instructions of fixed, usually unitary in some abstract sense, cost. The accounting of the overheads introduced by function calls tends to be similarly simple, e.g. proportional to the number and size of arguments of the function (since all arguments are pushed on the stack). 

Functional languages have much more sophisticated cost models, since higher-order and partial function applications are not straightforward operations. Moreover, functional languages usually require a form of *garbage collection* to reclaim memory which is no longer needed. 

In order to keep this presentation as simple as possible we will only focus on the most basic infrastructure of any functional language, the lambda-calculus, and its execution and cost model.

## Evaluation strategies

The syntax of the lambda calculus has only variables (`x`), function application (`F X`), and function definition or "abstraction" (`fun x -> U`). This calculus is called the lambda calculus because abstraction is traditionally written in mathematical notation as $`\lambda x.U`$. Since we will consider the lambda calculus in general we will favour the mathematical notation. For the sake of simplicity we will write $`\lambda f.\lambda x.U`$ as $`\lambda fx.U`$. 


The original lambda calculus is *untyped*, so we can write terms such as $`\lambda x.x\ x`$ which are disallowed by the usual type system:

```ocaml
# fun x -> x x;;
Error: This expression has type 'a -> 'b
       but an expression was expected of type 'a
       The type variable 'a occurs inside 'a -> 'b
```

The basic execution model of the lambda calculus is deceptively simple: whenever we see a function application of the form $`(\lambda x.U)V`$ we *substitute* $`V`$ for $`x`$ in $`U`$ -- while being careful about variable capture. This is called a (beta) *reduction* and $`(\lambda x.U)V`$ is called the *redex*.

The examples that follow here are purely *synthetic*. They do not make any algorithmic sense, they are used simply to illustrate the behaviour of the lambda calculus. Imagine that the lambda calculus is a new and expensive racing car. Before taking it into rallies we are taking it on a training course and slowly driving it forward and backward, turning left and right, braking and accelerating, etc. It is natural to do such drills before diving into 'realistic' usage. 

Take, for example, $`(\lambda fx.f\ x\ x)(\lambda yz.y)(\lambda u.u)`$. Since application associates to the left we have one redex to deal with, $`(\lambda fx.f\ x\ x)(\lambda yz.y)`$. Upon substitution of $`f`$ the result is $`(\lambda yz.y)\ x\ x`$, so the original term becomes $`((\lambda yz.y)\ x\ x)(\lambda u.u)`$. Here now we have two options of a redex to choose, the whole term or $`((\lambda yz.y)\ x`$. Which one to reduce first? 

In a *pure* functional language (no effects, no divergence) the choice does not matter because such languages are *confluent*, i.e. the input-output behaviour is choice-independent. Otherwise, the choice matters! Actually, even in the case of pure functional languages we will see that the choice matters from the point of view of the *cost* of execution. 

In all realistic programming languages reduction is not performed "under the lambda" but that is not enough to determinise reduction. If the term is a variable $`x`$ or a lambda term $`\lambda x.U`$ no reduction is attempted -- such terms are called "values". But if a term $`U\ V`$ is encountered and $`U\neq\lambda x.U'`$ then there are unavoidable choices to "search" for redexes. These choices are called *evaluation strategies* and we shall consider the three most common evaluations (from a theoretical perspective). 

### Call-by-value (CBV)

First note that $`U\ V`$ can only be reduced if $`U=\lambda x.U'`$, i.e. it is a value. CBV additionally requires $`V`$ to also be a value, so when $`U\ V`$ is handled both sub-terms must be reduced to values first. This can be done either left-to-right or right-to-left, which means that CBV has two versions. 

CBV is perhaps the most common evaluation strategy. Left-to-right CBV is the evaluation startegy of the original ML, now called "Standard ML". But CBV/L2R is inefficient, because a term $`U\ V\ V'\ V''\ldots`$ requires a costly form of partial evaluation. This caused OCaml to use right-to-left CBV for a while but now it uses an unspecified mix of L2R and R2L CBV. 

### Call-by-name (CBN)

In CBN, $`U\ V`$ is handled by reducing $`U`$ to a lambda form then performing the reduction without processing $`V`$ any further. CBN is the evaluation strategy of Algol 60, one of the first (and most influential) programming languages. CBN has excellent mathematical properties and makes reasoning about extensional behaviour relatively easy. However, the model proved confusing both for programmers and for compiler implementers since arguments may end up re-evaluated multiple times, and fell out of favour. No commonly used languages use this model. 

### Call-by-need (lazy)

Lazy evaluation is the most sophisticated, and it is not easy to formalise. The term $`U\ V`$ is handled by first reducing $`U`$, just like in CBN or CBV. When the argument is required $`V`$ is also reduced to a value, like in CBV -- but if the argument is *not* needed then $`V`$ is not evaluated, like in CBN. This strategy combines the efficiencies of both CBN (since unused arguments are not evaluated) and CBV (since arguments are not repeatedly evaluated). 

## The DGOI machine

To evaluate terms we need an *abstract machine* -- think of it as an abstract compiler. Abstract machines are a widely researched and complex topic, so we shall only scratch the surface. To illustrate all the strategies above I will use an abstract machine called [DGOI](https://doi.org/10.4230/LIPIcs.CSL.2017.32), for the following reasons:

* it is a common machine for all evaluation strategies, unlike other machines;
* it is diagram-based, which should make it easier to understand;
* it is efficient, in a technical sense, which means that it gives a correct account of execution costs (time and space);
* it is implemented interactively [online](https://koko-m.github.io/GoI-Visualiser/)

(For full disclosure: This machine is part of Koko Muroya's doctoral research, under my supervision.)

In the DGOI machine a term is represented as a graph with the following main elements:

* `(@)` is a trivalent node denoting application with the left edge representing a link to the function, the right edge the argument, and the bottom edge the term itself
* `(λ)` is a trivalent node denoting abstraction with the left edge representing the bound variable, the right edge the function body, and the bottom edge the term itself
* boxed subgraphs represent values, and are always copied and shared as a whole.

What makes the DGOI special is the fact that sharing of sub-terms is explicitly represented, using the node `(C)` called "contraction". Finally, the nodes `(D)`, `(!)`, and `(?)` serve a technical role in the management of copying and sharing. 

For example the term $`\lambda f . λ x. f\ x\ x`$ shows all these nodes:

![Alt Image Text](fxx.png "$\lambda f . λ x. f\ x\ x$")

Execution in the DGOI machine proceeds by guiding a "token" (i.e. a special edge) around the graph and by maintaining some global information ("token data"). At every stage the token either propagats, looking for a redex, or it causes rewrites. Two rewrites are very important:

* reducing a pair of `(@)`-`(λ)` nodes to model function application
* copying a shared subgraph via a `(C)` node

Some other reductions are also performed. They serve to prepare the token and the token data for the main reductions. 

*Note:* The CBN reduction might seem a bit surprising in the DGOI because it involves *no rewriting*. Since terms are always re-evaluated rewriting can be avoided, resulting in a very small execution memory footprint. CBN can be the most space-efficient strategy, but at the cost of extra time! 

## Examples

Let us run the following examples in the interactive [online visualiser](https://koko-m.github.io/GoI-Visualiser/) and discuss them:

* Simple example: `(λ x.x)(λ x.x)`
* Sharing: `(λ x.x x)(λ x.x)`
* CBV vs lazy cs CBN: `(λ x.x x)((λ x.x)(λ x.x))`

The differences between strategies become more obvious in the presence of recursion and divergence. The lambda calculus does not have recursive definitions but recursion can be encoded using "fixpoint operators" such as the Y combinator: `λf. (λx. f(x x))(λx. f(x x))`. Note that `Y g = g(Y g)`. 

Applying the Y combinator to the identity function produces divergent behaviour: `(λf. (λx. f(x x))(λx. f(x x)))(λ x.x)`. Examine the various behaviours in the visualiser. 

*Question:* Which one of the strategies is going to "blow the stack" and which one will execute indefinitely? 

A simpler divergence is Ω = `(λ x.x x)(λ x.x x)`. Examine the various behaviour in the visualiser. 

The differences between strategies is the most striking when passing Ω as an argument to a *non-strict* function i.e. a function that does not use its argument, e.g. `(λy.λx.x)((λ x.x x)(λ x.x x))`.

It is also interesting to look at some side-by-side executions of non-trivial terms, encoding of arithmetic into the lambda calculus:

* [Graphical evaluation](https://www.youtube.com/watch?v=IFmG_B9dWJc) 

# Cost-profiling OCaml

A version of this visualiser taylored to OCaml is also available [online](https://fyp.jackhughesweb.com/) developed as a final year project by Jack Hughes. 

It is interesting to look at some sped-up side-by-side evaluations:

* [Tail recursion](https://www.youtube.com/watch?v=R4yCV5Ts1gk)
* Two algorithms with the *same asymptotic complexity* (insert-sort vs bubble-sort) but which differ greatly in cost ([video](https://www.youtube.com/watch?v=bZMSwo0zLio))
* Two algorithms with different asymptotic complexity (insert-sort vs merge-sort) but in a small example the "worse" algo is faster ([video](https://www.youtube.com/watch?v=U1NI-mWeNe0))