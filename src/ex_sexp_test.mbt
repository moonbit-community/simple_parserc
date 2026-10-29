///|
enum Sexp {
  Atom(String)
  List(Array[Sexp])
}

///|
impl Show for Sexp with output(self, logger) {
  match self {
    Atom(s) => logger.write_string(s)
    List(xs) => {
      logger.write_char('[')
      for i, x in xs {
        if i > 0 {
          logger.write_string(", ")
        }
        logger.write_object(x)
      }
      logger.write_char(']')
    }
  }
}

///|
test "sexp" {
  let buffer = StringBuilder(size_hint=40)
  let atom = (@simple_parserc.digit | @simple_parserc.alphabetic | @simple_parserc.one_of("+-*/"))
    .many_each(fn(x) { buffer.write_char(x) })
    .map(fn(_) {
      let res = Atom(buffer.to_string())
      buffer.reset()
      res
    })
  letrec list = fn(input : @simple_parserc.Input) -> (Sexp, @simple_parserc.Input) raise @simple_parserc.ParseError {
    let expr : @simple_parserc.Parser[Sexp] = expr
    expr.discard_spaces().many().round_bracket().map(x => List(x))(input)
  }
  and expr = fn(input : @simple_parserc.Input) -> (Sexp, @simple_parserc.Input) raise @simple_parserc.ParseError {
    @simple_parserc.Parser::lor(list, atom)(input)
  }

  let expr : @simple_parserc.Parser[Sexp] = expr
  inspect(atom.run(input("1232")), content="1232")
  inspect(expr.run(input("(1 2 3 4 5 6)")), content="[1, 2, 3, 4, 5, 6]")
  inspect(
    expr.run(input("((1 2) (3 4) (1 (2 (3)))))")),
    content="[[1, 2], [3, 4], [1, [2, [3]]]]",
  )
  inspect(
    expr.run(input("(+ (* 3 3) (* 4 4))")),
    content="[+, [*, 3, 3], [*, 4, 4]]",
  )
}
