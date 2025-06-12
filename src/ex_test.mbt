///|
fnalias Input::new as input

///|
test "foldr/none" {
  let input = Input::new("123456")
  let integer = foldr(
    digit,
    pure(0),
    pure(fn { acc, x => acc * 10 + (Char::to_int(x) - '0'.to_int()) }),
  )
  inspect(integer.run(input), content="654321")
}

///|
test "foldr/separator" {
  let input = Input::new("1_2_3_4_5_6")
  let integer = foldr(
    digit,
    map(digit, fn { x => Char::to_int(x) - '0' }),
    char('_').discard_left(
      pure(fn { acc, x => acc * 10 + (Char::to_int(x) - '0'.to_int()) }),
    ),
  )
  inspect(integer.run(input), content="654321")
}

///|
test "foldl/none" {
  let input = Input::new("123456")
  let integer = foldl(
    digit,
    pure(0),
    pure(fn { acc, x => acc * 10 + (Char::to_int(x) - '0'.to_int()) }),
  )
  inspect(integer.run(input), content="123456")
}

///|
test "foldl/separator" {
  let input = Input::new("1_2_3_4_5_6")
  let integer = foldl(
    digit,
    map(digit, fn { x => Char::to_int(x) - '0' }),
    char('_').discard_left(
      pure(fn { acc, x => acc * 10 + (Char::to_int(x) - '0') }),
    ),
  )
  inspect(integer.run(input), content="123456")
}

///|
test "calculator" {
  let input = Input::new("123456")
  let integer = foldl(
    digit,
    pure(0),
    pure(fn { acc, x => acc * 10 + (Char::to_int(x) - '0'.to_int()) }),
  )
  inspect(integer.run(input), content="123456")
  let add = char('+').discard_left(pure(Int::op_add))
  let sub = char('-').discard_left(pure(Int::op_sub))
  let mul = char('*').discard_left(pure(Int::op_mul))
  let div = char('/').discard_left(pure(Int::op_div))
  fn expr(input) -> (Int, Input) raise ParseError {
    foldl1(term, add | sub)(input)
  }

  fn term(input) -> (Int, Input) raise ParseError {
    foldl1(factor, mul | div)(input)
  }

  fn factor(input) -> (Int, Input) raise ParseError {
    (Parser::round_bracket(expr) | integer)(input)
  }

  let input = Input::new("(1+2)*3")
  let expr : Parser[Int] = expr
  inspect(expr.run(input), content="9")
  inspect(expr.run(Input::new("3*3+4*4")), content="25")
  let buf = StringBuilder::new(size_hint=100_000 * 5)
  buf.write_char('1')
  for i in 0..<100_000 {
    buf.write_char('+')
    buf.write_char('1')
  }
  let input = Input::new(buf.to_string())
  inspect(expr.run(input), content="100001")
}

///|
test "or" {
  let x = char('x')
  let y = char('y')
  let parse = x | y |> label("x or y")
  let input = Input::new("x")
  inspect(
    try? parse(input),
    content=
      #|Ok(('x', {chars: "", row: 0, col: 1}))
    ,
  )
  inspect(
    try? parse(Input::new("_")),
    content=
      #|Err(Expect(row=0, col=0, "x or y"))
    ,
  )
}

///|
test "error" {
  let parse = char('x')
  let input = Input::new("_")
  inspect(
    try? parse(input),
    content=
      #|Err(Expect(row=0, col=0, "x"))
    ,
  )
  inspect(
    try? label(parse, "?")(input),
    content=
      #|Err(Expect(row=0, col=0, "?"))
    ,
  )
}

///|
test "between" {
  let parser = char('_').round_bracket()
  inspect(parser.run(input("(_)")), content="_")
}

///|
test "digit" {
  inspect(try? digit.run(input("1")), content="Ok('1')")
  inspect(
    try? digit.run(input("_")),
    content=
      #|Err(Expect(row=0, col=0, "digit"))
    ,
  )
}

///|
test "space" {
  inspect(try? space.run(input(" ")), content="Ok(' ')")
  inspect(
    try? space.run(input("_")),
    content=
      #|Err(Expect(row=0, col=0, "space"))
    ,
  )
}

///|
test "alphabetic" {
  inspect(try? alphabetic.run(input("a")), content="Ok('a')")
  inspect(
    try? alphabetic.run(input("_")),
    content=
      #|Err(Expect(row=0, col=0, "alphabetic"))
    ,
  )
}

///|
test "any" {
  inspect(try? any.run(input("a")), content="Ok('a')")
  inspect(try? any.run(input("_")), content="Ok('_')")
}

///|
test "space1" {
  inspect(try? space1.run(input("  ")), content="Ok(' ')")
  inspect(
    try? space1.run(input("")),
    content=
      #|Err(Expect(row=0, col=0, "space1"))
    ,
  )
}

///|
test "spaces" {
  inspect(try? spaces.run(input("  ")), content="Ok(' ')")
  inspect(try? spaces.run(input("")), content="Ok(' ')")
}

///|
test "pure" {
  inspect(try? pure(1).run(input("")), content="Ok(1)")
}

///|
test "between" {
  let x = pure(0).round_bracket()
  inspect(x.run(input("()")), content="0")
  inspect(x.run(input(" ()")), content="0")
  inspect(x.run(input("() ")), content="0")
  inspect(x.run(input("( )")), content="0")
  inspect(x.run(input(" ( ) ")), content="0")
}
