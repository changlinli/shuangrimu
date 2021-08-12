> I want to see how you use stateless functional programming to control a garage door actuator. How do you receive UDP packets, including a buffer implementation that is able to sort out-of-order packets and send retransmission requests for missing ones?

Reasonable enough. I'll start with a high-level summary and then build out some pseudo-code.

A theme that permeates a lot of functional programming is "reify your actions." This sounds perhaps a bit too fancy, so let's recast this phrase in various more specific instantiations. Each of these instantiations is closely related to the other; they are all multiple lenses of the same thing so if only one of them resonates with you that's fine.

Instantiation 1: We can often think of a lot of stateful problems as compiler problems. Let's look at database access underlying a simple CRUD app. One way of looking at database access that is popular in OO languages (and ultimately motivates the creation of things like ORMs) is an "onion object model." That is there is an "HTTP server object" whose getters and setters are GET and POST requests. That then wraps a "logical server object" whose getters and setters are the usual ones on an object. Finally we wrap database access in a similar interface. Each of these stateful interfaces can be mocked out or replaced for testing purposes and code reuse (which inevitably leads to things like DI).

The FP approach would look at this differently. What is an HTTP request? At its core it's a bunch of data representing some sort of abstract request written in a DSL. What is database access? Well really at the end of the day database access is just us crafting a bunch of SQL statements. So really what we're creating is a simple, domain-specific HTTP to SQL compiler. All our code creating in-memory representations of various things between the HTTP and SQL is really just different intermediate languages. E.g. you might have two compiler phases:

  HTTP -> In-memory Representation
  In-memory Representation -> SQL

So for example, in the FP approach we don't test by creating mocks of interfaces, instead we just make a new compiler pass, e.g .

  In-memory Representation -> JSON

Now of course at a sufficiently high level of abstraction that is equivalent to the OO approach (which shouldn't be all that surprising since in the end these are all Turing complete approaches so one way of doing things should be translatable to the other), but the actual code that is written is very very different. In one world you have a very stateful-interface-heavy codebase whereas in the other world (almost) everything is a stateless compiler pass. The only things that remain stateless in the latter are a "read" (get the HTTP data) and "write" (ship the SQL to the DB) command.

Instantiation 2: The mantra you'll often hear in the Clojure community is "data-oriented programming" or "data-driven development." Things are always set up as 

Instantiation 3: FP in some sense tries to make things as "first-class" as possible. So for example

So far you may be nodding your head along and saying "okay fine that makes sense for uni-directional actions, where there is a clear and unique direction, but a lot of real-world stuff is bidirectional! The UDP example requires bi-directional communication: my consumer needs to contact the producer as well as pull data! My garage door may have a multi-step process that gives feedback to the user!"

The trick in all these circumstances is that we can make bidirectional dataflow unidirectional by keeping a central store of state and splitting the outside world into a source and sink.

  Outside world <---> Me

becomes

  Outside world incoming data -> Me -> Outgoing data to the outside world

This doesn't seem like we've bought much from this change of reference.

Let's return to the DB example
