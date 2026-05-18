///|
fn input(chars : StringView) -> Input {
  Input::new(chars)
}

///|
fn[A] parse_error_to_string(f : () -> A raise ParseError) -> String {
  try {
    let _ = f()
    "Ok"
  } catch {
    e => e.to_string()
  }
}

///|
test "foldr/none" {
  let input = Input::new("123456")
  let integer = foldr(
    digit,
    pure(0),
    pure((acc, x) => acc * 10 + (Char::to_int(x) - '0'.to_int())),
  )
  inspect(integer.run(input), content="654321")
}

///|
test "foldr/separator" {
  let input = Input::new("1_2_3_4_5_6")
  let integer = foldr(
    digit,
    map(digit, x => Char::to_int(x) - '0'),
    char('_').discard_left(
      pure((acc, x) => acc * 10 + (Char::to_int(x) - '0'.to_int())),
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
    pure((acc, x) => acc * 10 + (Char::to_int(x) - '0'.to_int())),
  )
  inspect(integer.run(input), content="123456")
}

///|
test "foldl/separator" {
  let input = Input::new("1_2_3_4_5_6")
  let integer = foldl(
    digit,
    map(digit, x => Char::to_int(x) - '0'),
    char('_').discard_left(pure((acc, x) => acc * 10 + (Char::to_int(x) - '0'))),
  )
  inspect(integer.run(input), content="123456")
}

///|
test "calculator" {
  let input = Input::new("123456")
  let integer = foldl(
    digit,
    pure(0),
    pure((acc, x) => acc * 10 + (Char::to_int(x) - '0'.to_int())),
  )
  inspect(integer.run(input), content="123456")
  let add = char('+').discard_left(pure(Int::add))
  let sub = char('-').discard_left(pure(Int::sub))
  let mul = char('*').discard_left(pure(Int::mul))
  let div = char('/').discard_left(pure(Int::div))
  letrec expr = fn(input) -> (Int, Input) raise ParseError {
    foldl1(term, add | sub)(input)
  }
  and term = fn(input) -> (Int, Input) raise ParseError {
    foldl1(factor, mul | div)(input)
  }
  and factor = fn(input) -> (Int, Input) raise ParseError {
    (Parser::round_bracket(expr) | integer)(input)
  }

  let input = Input::new("(1+2)*3")
  let expr : Parser[Int] = expr
  inspect(expr.run(input), content="9")
  inspect(expr.run(Input::new("3*3+4*4")), content="25")
  let buf = StringBuilder::new(size_hint=100_000 * 5)
  buf.write_char('1')
  for _ in 0..<100_000 {
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
  let parse = (x | y) |> label("x or y")
  let input = Input::new("x")
  let (ch, rest) = parse(input)
  inspect(ch, content="x")
  inspect(rest.to_string() == "{chars: \"\", row: 0, col: 1}", content="true")
  inspect(
    parse_error_to_string(() => parse(Input::new("_"))),
    content="\nParse Error:0:0:\n    x or y is expected\n    y is expected\n",
  )
}

///|
test "error" {
  let parse = char('x')
  let input = Input::new("_")
  inspect(
    parse_error_to_string(() => parse(input)),
    content="\nParse Error:0:0:\n    x is expected\n",
  )
  inspect(
    parse_error_to_string(() => label(parse, "?")(input)),
    content="\nParse Error:0:0:\n    ? is expected\n    x is expected\n",
  )
}

///|
test "between" {
  let parser = char('_').round_bracket()
  inspect(parser.run(input("(_)")), content="_")
}

///|
test "digit" {
  inspect(digit.run(input("1")), content="1")
  inspect(
    parse_error_to_string(() => digit.run(input("_"))),
    content="\nParse Error:0:0:\n    digit is expected\n",
  )
}

///|
test "space" {
  inspect(space.run(input(" ")), content=" ")
  inspect(
    parse_error_to_string(() => space.run(input("_"))),
    content="\nParse Error:0:0:\n    space is expected\n",
  )
}

///|
test "alphabetic" {
  inspect(alphabetic.run(input("a")), content="a")
  inspect(
    parse_error_to_string(() => alphabetic.run(input("_"))),
    content="\nParse Error:0:0:\n    alphabetic is expected\n",
  )
}

///|
test "any" {
  inspect(any.run(input("a")), content="a")
  inspect(any.run(input("_")), content="_")
}

///|
test "space1" {
  inspect(space1.run(input("  ")), content=" ")
  inspect(
    parse_error_to_string(() => space1.run(input(""))),
    content="\nParse Error:0:0:\n    space1 is expected\n    space is expected\n",
  )
}

///|
test "spaces" {
  inspect(spaces.run(input("  ")), content=" ")
  inspect(spaces.run(input("")), content=" ")
}

///|
test "pure" {
  inspect(pure(1).run(input("")), content="1")
}

///|
test "between/spaces" {
  let x = pure(0).round_bracket()
  inspect(x.run(input("()")), content="0")
  inspect(x.run(input(" ()")), content="0")
  inspect(x.run(input("() ")), content="0")
  inspect(x.run(input("( )")), content="0")
  inspect(x.run(input(" ( ) ")), content="0")
}

///|
test "label" {
  let rb = char(')').label("lambda").label("expr")
  inspect(
    parse_error_to_string(() => rb.run(input(""))),
    content="\nParse Error:0:0:\n    expr is expected\n    lambda is expected\n    ) is expected\n",
  )
}

///|
test "SourcePos::compare" {
  fn srcpos(row, col) {
    SourcePos::{ row, col }
  }

  inspect(srcpos(0, 1) < srcpos(0, 2), content="true")
  inspect(srcpos(1, 0) > srcpos(0, 2), content="true")
}

///|
test "branch" {
  let x = char('x')
  let y = char('y')
  let fst = x
    .label("x1")
    .discard_left(x.label("x2"))
    .discard_left(x.label("x3"))
  let snd = x.label("x1").discard_left(y.label("y2"))
  let s = input("xx")
  inspect(
    parse_error_to_string(() => (fst | snd).run(s)),
    content="\nParse Error:0:2:\n    x3 is expected\n    x is expected\n",
  )
}
