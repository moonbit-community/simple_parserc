///|
pub(all) struct SourcePos {
  row : Int
  col : Int
} derive(Show)

///|
pub(all) struct Input {
  chars : @string.View
  row : Int
  col : Int
} derive(Show)

///|
pub(all) suberror ParseError {
  Many(Array[ParseError])
  Expect(row~ : Int, col~ : Int, String)
}

///|
pub(all) type Parser[A] (Input) -> (A, Input) raise ParseError

///|
pub impl Show for ParseError with output(self, logger) {
  match self {
    Many(xs) =>
      for x in xs {
        logger.write_object(x)
        logger.write_string("\n")
      }
    Expect(row~, col~, msg) =>
      logger.write_string(
        $| Parse Error:\{row}:\{col}: \{msg} is expected
        ,
      )
  }
}
