# Seafoam

*Seafoam* is a tool for working with compiler graphs. It's designed primarily
for working with the graph files dumped by the GraalVM compiler, such as in
TruffleRuby, but it could be used with other compilers and graph dump file
formats.

The *Ideal Graph Visualizer*, or *IGV*, is the tool usually used to work with
GraalVM compiler graphs. Seafoam aims to solve several problems with IGV. Unlike
IGV, Seafoam:

* is open source and can be used without restriction
* is able to some extent seek BGV files to load specific graphs without loading the rest of the file
* has a command-line interface
* can be used as a library
* has easy PDF, SVG and PNG output
* looks prettier, in our opinion

Admittedly, Seafoam does not yet have:

* subgraphs
* an interactive user interface
* diffing of graphs
* visualization of basic blocks
* breaking of edges for very congested graphs
* the same speed in rendering big graphs - Seafoam is best suited for looking at graphs before lowering, which is what language developers are usually doing, or use spotlight

## Seafoam compared to IGV

<p>
<img src="docs/images/seafoam.png" width="350">
<img src="docs/images/igv.png" width="350">
</p>

## Installation

```
$ brew install graphviz
$ gem install seafoam
$ seafoam --version
seafoam 0.1
````

Quick-start demo:

```
$ seafoam render examples/fib-java.bgv:0
```

## Getting compiler graphs

If you are just experimenting, there are example graphs such as
`examples/fib-java.bgv`.

This is just a quick summary - see more information on
[getting graphs out of compilers](docs/getting-graphs.md).

### GraalVM for Java

```
$ javac Fib.java
$ java -XX:CompileOnly=::fib -Dgraal.Dump=* Fib 14
```

### TruffleRuby and other Truffle languages

```
$ ruby --vm.Dgraal.TruffleCompileOnly=fib --vm.Dgraal.TruffleFunctionInlining=false  --vm.Dgraal.Dump=Truffle:1 fib.rb 14
```

You will usually want to look at the *After TruffleTier* graph.

## Name syntax

When using a command-line interface, Seafoam refers to
`file.bgv[:graph][:node[-edge]]`, where `file.bgv` is a file, `graph` is a graph
index, `node` is a node index, and `to` is another node index to form an edge
from `node` to another node `edge`.

Note that a *graph ID* is an ID found in BGV files, but is not unique. A
*graph index* is what we use in names, and is unique.

## Use cases

Print information about a file.

```
$ seafoam info examples/fib-java.bgv
BGV 6.1
```

List graphs in a file.

```
$ seafoam list examples/fib-java.bgv
examples/fib-java.bgv:0  2:Fib.fib(int)/After parsing
examples/fib-java.bgv:1  2:Fib.fib(int)/Before phase %s
examples/fib-java.bgv:2  2:Fib.fib(int)/After high tier
examples/fib-java.bgv:3  2:Fib.fib(int)/After mid tier
examples/fib-java.bgv:4  2:Fib.fib(int)/After low tier
```

Search for strings in a graph, or node or edge within a graph.

```
$ seafoam search examples/fib-java.bgv:0 -- Start
examples/fib-java.bgv:0:0  ...node_class":"org.graalvm.compiler.nodes.StartNode","name_template":"Start","inputs":[...
examples/fib-java.bgv:0:0  ...piler.nodes.StartNode","name_template":"Start","inputs":[{"direct":true,"name":"state...
```

Print edges of a graph, or node or edge within a graph.

```
$ seafoam edges examples/fib-java.bgv:0
22 nodes, 30 edges
$ seafoam edges examples/fib-java.bgv:0:13
Input:
  13 (Call Fib.fib) <-() 7 (Begin)
  13 (Call Fib.fib) <-() 14 (@{:declaring_class=>"Fib", :method_name=>"fib", :signature=>{:args=>["I"], :ret=>"I"}, :modifiers=>9}:13)
  13 (Call Fib.fib) <-() 12 (MethodCallTarget)
Output:
  13 (Call Fib.fib) ->() 18 (Call Fib.fib)
  13 (Call Fib.fib) ->(values) 14 (@{:declaring_class=>"Fib", :method_name=>"fib", :signature=>{:args=>["I"], :ret=>"I"}, :modifiers=>9}:13)
  13 (Call Fib.fib) ->(values) 19 (@{:declaring_class=>"Fib", :method_name=>"fib", :signature=>{:args=>["I"], :ret=>"I"}, :modifiers=>9}:19)
  13 (Call Fib.fib) ->(x) 20 (+)
$ seafoam edges examples/fib-java.bgv:0:13-20
13 (Call Fib.fib) ->(x) 20 (+)
```

Print properties of a graph, or node or edge within a graph.

```
$ seafoam props examples/fib-java.bgv:0
{
  "group": [
    {
      "name": "2:Fib.fib(int)",
      "short_name": "2:Fib.fib(int)",
      "method": null,
...
$ seafoam props examples/fib-java.bgv:0:13
{
  "nodeSourcePosition": {
    "method": {
      "declaring_class": "Fib",
      "method_name": "fib",
      "signature": {
...
$ seafoam props examples/fib-java.bgv:0:13-20
{
  "direct": true,
  "name": "x",
  "type": "Value"
}
```

Render a graph as a PDF image and have it opened automatically.

```
$ seafoam render examples/fib-java.bgv:0
```

Render a graph showing just a few nodes and those surrounding them, similar to
the IGV feature of gradually revealing nodes.

```
$ seafoam render examples/fib-java.bgv:0 --spotlight 13,20
```

<p>
<img src="docs/images/spotlight-seafoam.png" width="200">
<img src="docs/images/spotlight-igv.png" width="350">
</p>

## Options for GraalVM graphs

`render` supports these options:

* `--out filename.pdf` or `.pdf`, `.svg`, `.png`, `.dot`
* `--show-frame-state` shows frame state nodes, which are hidden by default
* `--hide-floating` hides nodes that aren't fixed by control flow
* `--no-reduce-edges` turns off the option to reduce the number of edges by inlining simple nodes above their users
* `--no-break-edges` turns off the option to break long edges to simplify the graph
* `--option key value` for custom annotators

## Configuration

Seafoam loads and runs a Ruby script called `~/.seafoam/config` in the first
directory it finds starting with the current working directory and moving up.
You can require or configure extra [annotators](docs/annotators.md) in this
file.

## Debugging

Exception backtraces are printed if `$DEBUG` (`-d`) is set.

Use `seafoam debug file.bgv` to debug file parsing.

## More documentation

* [Graph annotators](docs/annotators.md)
* [Details of the BGV file format](docs/bgv.md)
* [How to get graphs from various compilers](docs/getting-graphs.md)

## Frequently asked questions

#### Why is it called *Seafoam*?

GraalVM graphs are *seas of nodes*. Seafoam is a shade of green, and Seafoam was
written at Shopify, which has green as a brand colour. Graphs can sometimes be
very complicated, appearing like a foam without any structure - Seafoam tries to
help you make sense of it all.

#### What do you mean by *graphs*, and *seas* or *soups* of nodes?

Graphs, as in edges and nodes, are the data structure some compilers use to
represent your program while they're compiling it. It's a form of *intermediate
representation*. Graphs are how the compiler understands the programs and if the
compiler isn't doing what you want you need to look at the graph and make sense
of it. Some graphs are loosely structured and large, making them like a sea or
soup of nodes.

#### Doesn't *reduce edges* actually introduce more edges?

Yes, but they're shorter edges, and it achieves the intended effect of less
edges crossing over the graph.

## Related work

The graph layout algorithm we use, via Graphviz, is

* E. R. Gansner, et al, [*A Technique for Drawing Directed Graphs*](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.3.8982), IEEE Transactions on Software Engineering, 1993

IGV is the existing tool for working with Graal graphs. It uses a *hierarchical*
layout algorithm, rather than the *force directed* algorithm we use when we use
Graphviz. It's based on the NetBeans IDE platform. It's related to the *C1
Visualiser*, for control-flow graphs. The C1 Visualiser can also be used with
Graal as the backend of Graal is similar enough to C1. IGV is closed-source and
available under a proprietary licence.

* T. Würthinger, [*Visualization of Program Dependence Graphs*](http://www.ssw.uni-linz.ac.at/Research/Papers/Wuerthinger07Master/), Master Thesis, Linz 2007
* T. Würthinger, [*Visualization of Java Control Flow Graphs*](http://www.ssw.uni-linz.ac.at/General/Staff/TW/Wuerthinger06Bachelor.pdf), Bachelor Thesis, Linz 2006

[*Turbolizer*][turbolizer] is a similar tool for the intermediate representation
in the V8 JavaScript compiler.

[turbolizer]: https://github.com/v8/v8/blob/4b9b23521e6fd42373ebbcb20ebe03bf445494f9/tools/turbolizer

## Author

Seafoam was written by Chris Seaton at Shopify, chris.seaton@shopify.com.
