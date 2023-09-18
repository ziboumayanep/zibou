---
title: "Designing a comparator library for end to end tests"
date: 2018-10-22 
tags:
    - scala
    - test
---
# Regression test

Let's quote the definition of regression testing from Wikipedia:

> Regression testing is a type of software testing which verifies that software which was previously developed and tested still performs the same way after it was changed or interfaced with other software. Changes may include software enhancements, patches, configuration changes.

This kind of test is prevalent in the numerical library. In such projects, the developers want to make sure that the output of the program (which are numerical values) does not change. The benefits are:

 * Safe refactoring: Developers don't be scared of moving code around, renaming things as long as the tests passed
 * Controle: Developers can control changes they made to the library. They expect to see only the differences in some part of the library

# Regression test workflow
We can see our software as a function that takes an input and produce an output. The regression test does not guarantee the correctness of the output, and it only tells if the output was modified since the last run.

This common implementation of regression test consists of:

1. A collection of input of the program. It's usually under the form of text file.
2. A collection of output where `output = f(input)`. The output is persisted somewhere
3. When the test run, it goes through all the input in the collection, apply the function and compare the result with the output stored in the file system.

If the test pass, then congratulation, there is nothing to do. However, what if it fails? In this case, you should analyze the differences between the reference value and the new value. The quality of the comparator is essential to speed up this process. Let's have a look at an example:

## Example 1:
You have 2 objects that are a list of thousands of elements. If you use the standard scala `==`, you only have the `True` or `False` as a result. However, there are 1000 elements, and you want to see which elements are modified. You want to have a message like this instead: `512 / 1.2 != 1.3` where 512 is the position of the element

## Example 2:
You have 2 objects of type Toto defined by:

```scala
case class Toto(x: X, y: Y, z: Z)
```
The comparator should tell which field contains the differences between 2 objects

`x / left != right`

The ability to compare 2 case class is particularly helpful. If the calculation represents significant steps, we want to output all the intermediate steps so we can control when the bug is introduced into the system.

When comparing two doubles, the comparator should take into account an acceptable error because we always have the numerical error in the numerical calculation: Only a little rearrangement of the function can result in some 1e-12 difference.

Now there are 2 possibilities when the regression test fails: You either see what you have done is wrong and corrected it or you think the new value is the better value. For the latter situation, you have to update the references values to the latest version.

Updating the reference values are risky, and you should be sure about the new values. A CVS should track the reference values.

# Designing the comparator

The comparator is the center part of the integration tests and the purpose of the library called `comparator`.

## The API

In this section, I describe step by step the way I've followed in implementing this library.

The very first question to ask is of course: What if the API? We want to compare 2 values, and the output is the list of differences between these 2 values

```scala
Comparator.compare[A](left: A, right: A): List[Diff]
```

The function signature tells us that it takes two values of the same type and return a list of differences between these values.

The `Diff` must provide 2 facts: The position of the difference and the difference. For example, when comparing two lists, it should specify the position of these different elements

```scala
case class Diff(paths: List[String], diff: ComparatorDiff)
```
This class can output something like: `data / 0 / x: 5 is not equal to 6`

The `ComparatorDiff` can be a `String` but it will be difficult to test... That's why I've chosen to use some type system.

```scala
sealed trait Side
case object Left extends Side
case object Right extends Side


sealed trait ComparatorDiff

case class SizeDiff(left: Int, right: Int) extends ComparatorDiff
case class DoubleDiff(left: Double, right: Double) extends ComparatorDiff
case class KeyNotExist(key: String, side: Side) extends ComparatorDiff
case object TypeDiff extends ComparatorDiff
```

Since we have to specify the `path`, we should have a method that adds new path into the child path

```scala
def compareWithPath(path: String, left: A, right: A)(implicit err: AcceptanceError): List[Diff] = {
    val temp = compare(left, right)
    temp.map { diff => diff.copy(paths = path :: diff.paths)
    }
  }
```

Since we choose `List` to store paths, the `prepend` operator is `O(1)`

## Comparator of some useful types

The library provides some essential type classes
```scala
implicit def doubleComparator(implicit err: AcceptanceError): Comparator[Double] = (left: Double, right: Double) => {
    val abs = Math.abs(left - right)
    val diff = Diff(Nil, DoubleDiff(left, right)) :: Nil
    if (left == 0.0 || right == 0.0)
      if (abs > err.absolute) diff else Nil
    else {
      val rel = abs / left
      if (rel > err.relative) diff else Nil
    }
  }
```
Notice that the `doubleComparator` is not a value but an implicit function because It requires an `AcceptenceError` 

Other example is the comparator of `List`
```scala
implicit def listComparator[A](implicit c: Comparator[A]): Comparator[List[A]] = (left: List[A], right: List[A]) => {
    if (left.lengthCompare(right.size) != 0)
      Diff(Nil, SizeDiff(left.size, right.size)) :: Nil
    else {
      left.zip(right).zipWithIndex.flatMap {
        case ((l, r), index) =>
          c.compareWithPath(index.toString, l, r)
      }
    }
  }
```
The signature of the implicit function `listComparator` tells that if we can provide a comparator of type `A`, then the compiler can create an instance of type `Comparator[List[A]]` automatically. The implicit system is beneficial here to reduce much boilerplate code

The comparator instances I suggest you take a look in the code source are `Option` and `Map`.

# Using shapeless power
In the last part, we've defined some useful type classes that can be composed automatically by the compiler in many ways. However, we still have lots of boilerplate code to write. For example what if we want to compare tuple? There are no ways to tell the compiler to construct the comparator of tuple2, tuple3 automatically, without using the macro. Fortunately, this is the purpose of the powerful library called shapeless.

Explaining the library `shapeless` is out of the article's scope. However, I show how to use `shapeless` to create derive automatically type class instances

I strongly recommend the [free guide](https://github.com/underscoreio/shapeless-guide/blob/develop/dist/shapeless-guide.pdf) to fully understand shapeless.

The ideal behind shapeless is that It can convert any object (case class) into a generic representation. The generic representation is used to compose the child type classes to create the parent type class. The users only need to write the composition function and let the implicit mechanism works with the compiler to create automatically the required type class.

Shapeless provides 2 intermediate representation.

The first is `HList` that stands for a heterogenous list which represents a `case class` as a tuple. In this representation, we don't have the information about the field. The name of the field is needed because the comparator should show the position of the difference

The second is `LablledGeneric` is similar to `HList` but with the information of the name of the field. For example, the generic representation of `case class Person(name: String, age: Int)` is
```
String with KeyTag[Symbol with Tagged["name"], String] ::
Int with KeyTag[Symbol with Tagged["numCherries"], Int] ::
Boolean with KeyTag[Symbol with Tagged["inCone"], Boolean] ::
HNil
```
## The entry point

The entry point of the implicit search:

```scala
implicit def genericComparator[A, H](implicit
    generic: LabelledGeneric.Aux[A, H],
    hEncoder: Lazy[Comparator[H]]): Comparator[A] =
    (left: A, right: A) => {
      hEncoder.value.compare(generic.to(left), generic.to(right))
    }
```

The signature of the function tells that if we can provide a way to convert an object of type `A` to the intermediate representation of type `H` and the comparator of type `H`, then it can create a comparator of type `A`

To create the comparator of type `A`. We have to write a function that takes 2 elements of type `A` and return their difference. Since we have the comparator of the representation of `A`, we can convert both elements to `H` and use this comparator instead

## Comparator of `HList`

To construct the instance of `Comparator` of any `case class` including `Tuple`. We have to define 2 functions

The first one is the comparator of `HNil`:

```scala
implicit val hNilComparator: Comparator[HNil] = (left: HNil, right: HNil) => Nil
```

The second one is:
```scala
 implicit def hlistFieldComparator[K <: Symbol, H, T <: HList](implicit
    witness: Witness.Aux[K],
    hEncoder: Lazy[Comparator[H]],
    tEncoder: Comparator[T]): Comparator[FieldType[K, H] :: T]) = {
    val fieldName: String = witness.value.name
    
    }
```
As always, the signature of the function tells us that if we have the Comparator of the head, the tail and way to access the name of the head, then we can create a comparator of the combination `head :: tail`.
We can use the name of the field provided by the implicit value `witness`.
The complete function is:

```scala
 implicit def hlistFieldComparator[K <: Symbol, H, T <: HList](implicit
    witness: Witness.Aux[K],
    hEncoder: Lazy[Comparator[H]],
    tEncoder: Comparator[T]): Comparator[FieldType[K, H] :: T] = {
    val fieldName: String = witness.value.name
    (left: FieldType[K, H] :: T, right: FieldType[K, H] :: T) => {
      val headDiffs = hEncoder.value.compare(left.head, right.head)
      val tailDiffs = tEncoder.compare(left.tail, right.tail)
      val headWithPath = headDiffs.map(d => d.copy(paths = fieldName :: d.paths))
      headWithPath ++ tailDiffs
    }
  }
```
The logic is the same: We have the comparator of the head, so we use it to compute the differences of the head. Since we have the name of the head's field, we need to prepend the field name to the result. We have the comparator of the tail, we use it the compute the difference of the tail. Finally we append the two lists together to form the final result

## Comparator of `Product`

In the same fashion, `shapeless` let us construct any type class of a trait if we can provide all the type class of the concrete case class.

The pattern is the same as `HList`,  `shapeless` can construct an intermediate representation of the `trait` called `CoProduct`. For example 

```scala
sealed trait People

case class Man(name: String) extends People
case class Woman(name: String) extends People

```

The intermediate representation of `People` is `Man :+: Woman :+: CNil` which is very similar to the standard `Either`:
`Either[Man, Either[Woman, CNil]]`

If we admit the power of `shapeless` that can create automatically this intermediate type for us, then we can define 2 functions (or values)

The first one is `CNil`. We never have to evaluate a type class of `CNil` so we can throw exceptions or return a `Nil`


```scala
 implicit val cNilComparator: Comparator[CNil] = (left: CNil, right: CNil) => Nil
```

The second function is the one that combines the `Comparator[Head]` and the `Comparator[Tail]`

```scala
implicit def coProductComparator[H, T <: Coproduct](implicit hComparator: Lazy[Comparator[H]], tComparator: Comparator[T]): Comparator[H :+: T] =
    (left: :+:[H, T], right: :+:[H, T]) => {
      (left, right) match {
        case (Inl(h1), Inl(h2)) => hComparator.value.compare(h1, h2)
        case (Inr(h1), Inr(h2)) => tComparator.compare(h1, h2)
        case (x, y)             => Diff(Nil, TypeDiff(x.toString, y.toString)) :: Nil
      }
    }
```

The function is relatively simple. It says that if 2 elements are the left type, use the comparator of the head. If the 2 elements are of the right type, use the comparator of the tail. Otherwise, this is an error because the 2 elements are not the same type

# Examples

This example uses every feature offered by `shapeless`

```scala
sealed trait Tree 
case class Branch(left: Tree, right: Tree) extends Tree 
case class Leaf(value: Option[Double]) extends Tree 
```
In order to use the comparator

```scala
Comparator.compare[Tree](left, right)
```

This example uses all the power offered by `shapeless`

 * The `LabelledGeneric`, the `HList` to create type class of any case class with a field name
 * The `CoProduct` to create type class of any trait
 * Use `Lazy` type class helps to work with recursive implicit search

 # Conclusion

 `shapeless` is a perfect tool for the job, and the final product helps to boost the performance of developers. They can see  precisely what changed in the input and be able to correct bugs quickly
