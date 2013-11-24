import Website.Skeleton (skeleton)
import Window

intro = [markdown|

<h1><div style="text-align:center">The Syntax of Elm
<div style="font-size:0.5em;font-weight:normal">*A Quick Tour*</div></div>
</h1>

<style type="text/css">
h3 { padding-top: 1em; }
pre {
 background-color: rgb(245,245,245);
 margin: 0 30px;
 padding: 4px 10px;
 border-left: solid 2px rgb(96,181,204);
}
table.sourceCode, tr.sourceCode, td.lineNumbers, td.sourceCode {
  margin: 0; padding: 0; vertical-align: baseline; border: none; }
table.sourceCode { width: 100%; background-color: #f8f8f8; }
td.lineNumbers { text-align: right; padding-right: 4px; padding-left: 4px; color: #aaaaaa; border-right: 1px solid #aaaaaa; }
td.sourceCode { padding-left: 5px; }
pre, code { background-color: #f8f8f8; }
code > span.kw { color: #204a87; font-weight: bold; }
code > span.dt { color: #204a87; }
code > span.dv { color: #0000cf; }
code > span.bn { color: #0000cf; }
code > span.fl { color: #0000cf; }
code > span.ch { color: #4e9a06; }
code > span.st { color: #4e9a06; }
code > span.co { color: #8f5902; font-style: italic; }
code > span.ot { color: #8f5902; }
code > span.al { color: #ef2929; }
code > span.fu { color: #000000; }
code > span.er { font-weight: bold; }
</style>

This syntax reference is a minimal introduction to:

- [Comments](#comments)
- [Literals](#literals)
- [Lists](#lists)
- [Conditionals](#conditionals)
- [Algebraic Data Types](#algebraic-data-types)
- [Records](#records)
- [Functions](#functions)
- [Infix Operators](#infix-operators)
- [Let Expressions](#let-expressions)
- [Applying Functions](#applying-functions)
- [Lifting with `(<~)` and `(~)`](#lifting)
- [Modules](#modules)
- [Type Annotations](#type-annotations)
- [Type Aliases](#type-aliases)
- [JavaScript FFI](#javascript-ffi)
- [Things *not* in Elm](#things-not-in-elm)

Check out the [learning resources](/Learn.elm) for
tutorials and examples on actually *using* this syntax.

### Comments

```haskell
-- a single line comment

{- a multiline comment
   {- can be nested -}
-}
```

Here's a handy trick that every Elm programmer should know:

```haskell
{--}
add x y = x + y
--}
```

Just add or remove the `}` on the first line and you'll toggle between commented and uncommented!

### Literals

```haskell
-- Boolean
True  : Bool
False : Bool

42    : number  -- Int or Float depending on usage
3.14  : Float

'a'   : Char
"abc" : String
```

```

-- multi-line String
"""
This is useful for holding JSON or other
content that has "quotation marks".
"""
```

Typical manipulation of literals:

```haskell
True && not (True || False)
(2 + 4) * (4^2 - 9)
"abc" ++ "def"
```

### Lists

Here are four things that are equivalent:

```haskell
[1..4]
[1,2,3,4]
1 :: [2,3,4]
1 :: 2 :: 3 :: 4 :: []
```

### Conditionals

```haskell
if powerLevel > 9000 then "OVER 9000!!!" else "meh"
```

Multi-way if-expressions make it easier
to have a bunch of different branches.
You can read the `|` as *where*.

```haskell
if | key == 40 -> n+1
   | key == 38 -> n-1
   | otherwise -> n
```

You can alse have conditional behavior based on the structure of algebraic
data types and literals

```haskell
case maybe of
  Just xs -> xs
  Nothing -> []

case xs of
  hd::tl -> Just (hd,tl)
  []     -> Nothing

case n of
  0 -> 1
  1 -> 1
  _ -> fib (n-1) + fib (n-2)
```

Each pattern is indentation sensitive, meaning that you have to align
all of your patterns.

### Algebraic Data Types

```haskell
data List = Nil | Cons Int List
```

Not sure what this means? [Read this](/learn/Pattern-Matching.elm).

### Records

For more explanation of Elm&rsquo;s record system, see [this overview][exp],
the [initial announcement][v7], or [this academic paper][records].

  [exp]: /learn/Records.elm "Records in Elm"
  [v7]:  /blog/announce/0.7.elm "Elm version 0.7"
  [records]: http://research.microsoft.com/pubs/65409/scopedlabels.pdf "Extensible records with scoped labels"

```haskell
point = { x = 3, y = 4 }       -- create a record

point.x                        -- access field
map .x [point,{x=0,y=0}]       -- field access function

{ point - x }                  -- remove field
{ point | z = 12 }             -- add field
{ point - x | z = point.x }    -- rename field
{ point - x | x = 6 }          -- update field

{ point | x <- 6 }             -- nicer way to update a field
{ point | x <- point.x + 1
        , y <- point.x + 1 }   -- batch update fields

dist {x,y} = sqrt (x^2 + y^2)  -- pattern matching on fields
\{x,y} -> (x,y)

lib = { id x = x }             -- polymorphic fields
(lib.id 42 == 42)
(lib.id [] == [])

type Location = { line:Int, column:Int }
```

### Functions

```haskell
square n = n^2

hypotenuse a b = sqrt (square a + square b)

distance (a,b) (x,y) = hypotenuse (a-x) (b-y)
```

Anonymous functions:

```haskell
square = \n -> n^2
squares = map (\n -> n^2) [1..100]
```

### Infix Operators

You can create custom infix operators. The default
[precedence](http://en.wikipedia.org/wiki/Order_of_operations)
is 9 and the default
[associativity](http://en.wikipedia.org/wiki/Operator_associativity)
is left, but you can set your own.
You cannot override [the built-in operators](http://docs.elm-lang.org/InfixOps.elm) though.

```haskell
f <| x = f x
(<~) = lift

infixr 0 <|
infixl 4 <~
```

Use [`(<|)`](http://docs.elm-lang.org/library/Basics.elm#<|)
and [`(|>)`](http://docs.elm-lang.org/library/Basics.elm#|>)
to reduce parentheses usage. They are aliases for function
application.

```haskell
f <| x = f x
x |> f = f x

dot  = scale 2 (move (20,20) (filled blue (circle 10)))
dot' = circle 10 |> filled blue
                 |> move (20,20)
                 |> scale 2
```

Historical note: this is borrowed from F#, inspired by Unix pipes,
improving upon Haskell&rsquo;s `($)`.

### Let Expressions

```haskell
let n = 42
    (a,b) = (3,4)
    {x,y} = { x=3, y=4 }
    square n = n * n
in
    square a + square b
```

Let-expressions are indentation sensitive.
Each definition should align with the one above it.

### Applying Functions

```haskell
-- alias for appending lists and two lists
append xs ys = xs ++ ys
xs = [1,2,3]
ys = [4,5,6]

-- All of the following expressions are equivalent:
a1 = append xs ys
a2 = (++) xs ys

b1 = xs `append` ys
b2 = xs ++ ys

c1 = (append xs) ys
c2 = ((++) xs) ys
```

The basic arithmetic infix operators all figure out what type they should have automatically.

```haskell
23 + 19    : number
2.0 + 1    : Float

6 * 7      : number
10 * 4.2   : Float

1 `div` 2  : Int
1 / 2      : Float
```

There is a special function for creating tuples:

```haskell
(,) 1 2              == (1,2)
(,,,) 1 True 'a' []  == (1,True,'a',[])
```

You can use as many commas as you want.

### Lifting

The `lift` functions are used to apply a normal function like `sqrt` to a signal
of values such as `Mouse.x`. So the expression `(lift sqrt Mouse.x)` evaluates
to a signal in which the current value is equal to the square root of the current
x-coordinate of the mouse.

You can also use the functions `(<~)` and `(~)` to lift signals. The squigly
arrow is exactly the same as the lift function, so the following expressions
are the same:

```haskell
lift sqrt Mouse.x
sqrt <~ Mouse.x
```

You can think of it as saying &ldquo;send this signal through this
function.&rdquo;

The `(~)` operator allows you to apply a signal of functions to a signal of
values `(Signal (a -> b) -> Signal a -> Signal b)`. It can be used to put
together many signals, just like `lift2`, `lift3`, etc. So the following
expressions are equivalent:

```haskell
lift2 (,) Mouse.x Mouse.y
(,) <~ Mouse.x ~ Mouse.y

lift2 scene (fps 50) (sampleOn Mouse.clicks Mouse.position)
scene <~ fps 50 ~ sampleOn Mouse.clicks Mouse.position
```

More info can be found [here](/blog/announce/0.7.elm#do-you-even-lift)
and [here](http://docs.elm-lang.org/library/Signal.elm).

### Modules

```haskell
module MyModule where

import List
import open List
import List as L
import List (map,foldl,foldr)
```

### Type Annotations

```haskell
answer : Int
answer = 42

factorial : Int -> Int
factorial n = product [1..n]

addName : String -> a -> { a | name:String }
addName name record = { record | name = name }
```

### Type Aliases

```haskell
type Name = String
type Age = Int

info : (Name,Age)
info = ("Steve", 28)

type Point = { x:Float, y:Float }

origin : Point
origin = { x=0, y=0 }
```

### JavaScript FFI

The foreign function interface provides [HTML and JS
integration](https://github.com/evancz/elm-html-and-js).

```haskell
foreign import jsevent "eventName"
    (expr)
    signalName : Signal jsType
```

The `expr` can be any Elm expression. It is the initial value of the
signal `signalName`. As events with name `eventName` occur, signal
`signalName` will get updated. The type `jsType` must be a JavaScript
type such as `JSNumber` or `JSString`.

```haskell
foreign export jsevent "eventName"
   signalName : Signal jsType
```

The rules are the same for `export` except you do not need an initial value.

Elm has three built-in event handlers that take a `JSString` and automatically
take some imperative action:

* `"title"` which sets the page title, ignoring empty strings.
* `"log"` which logs messages in the developer console.
* `"redirect"` which redirects to a different page, ignoring empty strings.

```haskell
logged = constant <| JavaScript.fromString "This gets logged"
foreign export jsevent "log"
    logged : Signal JavaScript.JSString
```

### Things *not* in Elm

Elm currently does not support:

- operator sections such as `(+1)`
- guarded definitions or guarded cases. Use the multi-way if and case statements
  for this.
- `where` clauses
- any sort of `do` or `proc` notation

|]

content w = width (min 600 w) intro

main = lift (skeleton content) Window.dimensions
