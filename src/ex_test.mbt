///|
fn input(chars : StringView) -> @simple_parserc.Input {
  @simple_parserc.Input::new(chars)
}

///|
fn[A] parse_error_to_string(
  f : () -> A raise @simple_parserc.ParseError,
) -> String {
  try {
    let _ = f()
    "Ok"
  } catch {
    e => e.to_string()
  }
}

///|
test "foldr/none" {
  let input = @simple_parserc.Input::new("123456")
  let integer = @simple_parserc.foldr(
    @simple_parserc.digit,
    @simple_parserc.pure(0),
    @simple_parserc.pure((acc, x) => acc * 10 + (Char::to_int(x) - '0'.to_int())),
  )
  inspect(integer.run(input), content="654321")
}

///|
test "foldr/separator" {
  let input = @simple_parserc.Input::new("1_2_3_4_5_6")
  let integer = @simple_parserc.foldr(
    @simple_parserc.digit,
    @simple_parserc.map(@simple_parserc.digit, x => Char::to_int(x) - '0'),
    @simple_parserc.char('_').discard_left(
      @simple_parserc.pure((acc, x) => {
        acc * 10 + (Char::to_int(x) - '0'.to_int())
      }),
    ),
  )
  inspect(integer.run(input), content="654321")
}

///|
test "foldl/none" {
  let input = @simple_parserc.Input::new("123456")
  let integer = @simple_parserc.foldl(
    @simple_parserc.digit,
    @simple_parserc.pure(0),
    @simple_parserc.pure((acc, x) => acc * 10 + (Char::to_int(x) - '0'.to_int())),
  )
  inspect(integer.run(input), content="123456")
}

///|
test "foldl/separator" {
  let input = @simple_parserc.Input::new("1_2_3_4_5_6")
  let integer = @simple_parserc.foldl(
    @simple_parserc.digit,
    @simple_parserc.map(@simple_parserc.digit, x => Char::to_int(x) - '0'),
    @simple_parserc.char('_').discard_left(
      @simple_parserc.pure((acc, x) => acc * 10 + (Char::to_int(x) - '0')),
    ),
  )
  inspect(integer.run(input), content="123456")
}

///|
test "calculator" {
  let input = @simple_parserc.Input::new("123456")
  let integer = @simple_parserc.foldl(
    @simple_parserc.digit,
    @simple_parserc.pure(0),
    @simple_parserc.pure((acc, x) => acc * 10 + (Char::to_int(x) - '0'.to_int())),
  )
  inspect(integer.run(input), content="123456")
  let add = @simple_parserc.char('+').discard_left(
    @simple_parserc.pure(Int32::add),
  )
  let sub = @simple_parserc.char('-').discard_left(
    @simple_parserc.pure(Int32::sub),
  )
  let mul = @simple_parserc.char('*').discard_left(
    @simple_parserc.pure(Int32::mul),
  )
  let div = @simple_parserc.char('/').discard_left(
    @simple_parserc.pure(Int32::div),
  )
  letrec expr = fn(
    input,
  ) -> (Int32, @simple_parserc.Input) raise @simple_parserc.ParseError {
    @simple_parserc.foldl1(term, add | sub)(input)
  }
  and term = fn(
    input,
  ) -> (Int32, @simple_parserc.Input) raise @simple_parserc.ParseError {
    @simple_parserc.foldl1(factor, mul | div)(input)
  }
  and factor = fn(
    input,
  ) -> (Int32, @simple_parserc.Input) raise @simple_parserc.ParseError {
    (@simple_parserc.Parser::round_bracket(expr) | integer)(input)
  }

  let input = @simple_parserc.Input::new("(1+2)*3")
  let expr : @simple_parserc.Parser[Int32] = expr
  inspect(expr.run(input), content="9")
  inspect(expr.run(@simple_parserc.Input::new("3*3+4*4")), content="25")
  let buf = StringBuilder(size_hint=100_000 * 5)
  buf.write_char('1')
  for _ in 0..<100_000 {
    buf.write_char('+')
    buf.write_char('1')
  }
  let input = @simple_parserc.Input::new(buf.to_string())
  inspect(expr.run(input), content="100001")
}

///|
test "or" {
  let x = @simple_parserc.char('x')
  let y = @simple_parserc.char('y')
  let parse = (x | y) |> @simple_parserc.label("x or y")
  let input = @simple_parserc.Input::new("x")
  let (ch, rest) = parse(input)
  inspect(ch, content="x")
  inspect(rest.to_string(), content="{chars: \"\", row: 0, col: 1}")
  inspect(
    parse_error_to_string(() => parse(@simple_parserc.Input::new("_"))),
    content="\nParse Error:0:0:\n    x or y is expected\n    y is expected\n",
  )
}

///|
test "error" {
  let parse = @simple_parserc.char('x')
  let input = @simple_parserc.Input::new("_")
  inspect(
    parse_error_to_string(() => parse(input)),
    content="\nParse Error:0:0:\n    x is expected\n",
  )
  inspect(
    parse_error_to_string(() => @simple_parserc.label(parse, "?")(input)),
    content="\nParse Error:0:0:\n    ? is expected\n    x is expected\n",
  )
}

///|
test "between" {
  let parser = @simple_parserc.char('_').round_bracket()
  inspect(parser.run(input("(_)")), content="_")
}

///|
test "digit" {
  inspect(@simple_parserc.digit.run(input("1")), content="1")
  inspect(
    parse_error_to_string(() => @simple_parserc.digit.run(input("_"))),
    content="\nParse Error:0:0:\n    digit is expected\n",
  )
}

///|
test "space" {
  inspect(@simple_parserc.space.run(input(" ")), content=" ")
  inspect(
    parse_error_to_string(() => @simple_parserc.space.run(input("_"))),
    content="\nParse Error:0:0:\n    space is expected\n",
  )
}

///|
test "alphabetic" {
  inspect(@simple_parserc.alphabetic.run(input("a")), content="a")
  inspect(
    parse_error_to_string(() => @simple_parserc.alphabetic.run(input("_"))),
    content="\nParse Error:0:0:\n    alphabetic is expected\n",
  )
}

///|
test "any" {
  inspect(@simple_parserc.any.run(input("a")), content="a")
  inspect(@simple_parserc.any.run(input("_")), content="_")
}

///|
test "space1" {
  inspect(@simple_parserc.space1.run(input("  ")), content=" ")
  inspect(
    parse_error_to_string(() => @simple_parserc.space1.run(input(""))),
    content="\nParse Error:0:0:\n    space1 is expected\n    space is expected\n",
  )
}

///|
test "spaces" {
  inspect(@simple_parserc.spaces.run(input("  ")), content=" ")
  inspect(@simple_parserc.spaces.run(input("")), content=" ")
}

///|
test "pure" {
  inspect(@simple_parserc.pure(1).run(input("")), content="1")
}

///|
test "between/spaces" {
  let x = @simple_parserc.pure(0).round_bracket()
  inspect(x.run(input("()")), content="0")
  inspect(x.run(input(" ()")), content="0")
  inspect(x.run(input("() ")), content="0")
  inspect(x.run(input("( )")), content="0")
  inspect(x.run(input(" ( ) ")), content="0")
}

///|
test "label" {
  let rb = @simple_parserc.char(')').label("lambda").label("expr")
  inspect(
    parse_error_to_string(() => rb.run(input(""))),
    content="\nParse Error:0:0:\n    expr is expected\n    lambda is expected\n    ) is expected\n",
  )
}

///|
test "SourcePos::compare" {
  fn srcpos(row, col) {
    @simple_parserc.SourcePos::{ row, col, }
  }

  inspect(srcpos(0, 1) < srcpos(0, 2), content="true")
  inspect(srcpos(1, 0) > srcpos(0, 2), content="true")
}

///|
test "branch" {
  let x = @simple_parserc.char('x')
  let y = @simple_parserc.char('y')
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
