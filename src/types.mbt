///|
pub(all) struct SourcePos {
  row : Int
  col : Int
} derive(Show, Eq, Compare)

///|
pub(all) struct Input {
  chars : @string.View
  row : Int
  col : Int
} derive(Show)

///|
pub typealias @list.T as List

///|
pub(all) suberror ParseError {
  ParseError(SourcePos, List[String])
}

///|
pub(all) type Parser[A] (Input) -> (A, Input) raise ParseError

///|
pub impl Show for ParseError with output(self, logger) {
  let ParseError({ row, col }, xs) = self
  logger.write_string(
    $|
    $|Parse Error:\{row}:\{col}:
    $|
    ,
  )
  for msg in xs {
    logger.write_string(
      $|    \{msg} is expected
      $|
      ,
    )
  }
}
