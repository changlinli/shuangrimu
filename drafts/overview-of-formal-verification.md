# A rough sketch of "interesting things" in formal verification

Formal verification is an extremely wide umbrella that covers basically any form
of computer programs analyzing other computer programs. That means e.g. basic type
systems are a form of formal verification. Unit tests can also be thought of as
a form of formal verification.

However, for people getting into the field of formal verification, most of those
examples are not very "interesting."

This doc lays out some things that I'm aware of that I find interesting, and
roughly categorizes them.

## Thinking of different things to prove

One way of categorizing the field of formal verification is to look at what we
are trying to verify.

In this framework, we have two large top-level categories

+ Verifying code that actually runs:
    * New programming languages:
        - Dependently typed languages functional programming languages
            + Coq
            + Agda
            + Idris
            + Lean
        - Non-FP languages
            + Dafny
    * Annotations to existing programming languages:
        - Adding to Haskell: Liquid Haskell
        - Adding to Java: Java Modeling Language (with some verifier backend)
+ Verifying informal thoughts
    * Formal specification languages
        - TLA+
        - Alloy
    * Non-type theory (i.e. FP) theorem provers
        - Metamath

In theory due to the Curry-Howard Isomorphism type-based theorem provers bridge
the gap between verifying code that runs and verifying informal thoughts. After
all every formal statement can be translated into a type and every proof is then
a program.

In particular, Agda, Coq, Idris, and Lean can all be used to both prove theorems
as well as write executable programs.

In practice theorem provers still tend to target one niche or the other. E.g.
Agda and Coq are used generally as theorem provers. Most Agda and Coq code is
never run after being typechecked. Its only purpose in life is to be
typechecked. The second most common usecase of Agda and Coq is to *generate*
code that can then be executed (see e.g. the Bedrock project that attempts to
use Coq to generate assembly). Only in third place is actual direct execution
of Agda or Coq code.

E.g. Idris on the other hand tries to position itself as a language to
write executable programs first (hence calling itself a Pacman-complete
language, i.e. a language that you could reasonably implement Pacman in) and a
theorem prover only second.

This means that IDE support, library support, language idioms etc. usually try
to cater to one or the other.

## Thinking of different ways of verifying things

Another way to slice the field of formal verification is to focus on the
verification side of things: what strategies are there for verifying statements?

+ Exhaustive, 100% sound verification
    * Deductive proofs
        - Type-theoretic theorem provers
            + Coq
            + Agda
            + Lean
            + Isabelle
        - Set-theoretic theorem provers
            + Mizar
        - Meta-language (basically pure logic) theorem provers
            + Metamath
    * Model checking
        - TLC (TLA+ checker)
    * SAT/SMT solver translation
        - TLAPS (TLA+ checker)
+ Non-exhaustive/<100% sound verification
    * Automatic test generation
        - Property testing
        - Fuzz testing
        - Mutation testing
        - Concolic testing
    * Non-sound type systems
        - Typescript
        - Dependent Haskell
