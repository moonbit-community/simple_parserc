///|
pub(all) struct SourcePos {
  row : Int
  col : Int
} derive(Eq, Compare)

///|
pub impl Show for SourcePos with output(self, logger) {
  let { row, col } = self
  logger.write_string("{row: ")
  logger.write_object(row)
  logger.write_string(", col: ")
  logger.write_object(col)
  logger.write_char('}')
}

///|
pub impl Debug for SourcePos with to_repr(self) {
  Repr::literal(self.to_string())
}

///|
pub(all) struct Input {
  chars : StringView
  row : Int
  col : Int
}

///|
pub impl Show for Input with output(self, logger) {
  let { chars, row, col } = self
  logger.write_string("{chars: ")
  logger.write_object(chars)
  logger.write_string(", row: ")
  logger.write_object(row)
  logger.write_string(", col: ")
  logger.write_object(col)
  logger.write_char('}')
}

///|
pub impl Debug for Input with to_repr(self) {
  Repr::literal(self.to_string())
}

///|
pub(all) suberror ParseError {
  ParseError(SourcePos, @list.List[String])
}

///|
pub(all) struct Parser[A]((Input) -> (A, Input) raise ParseError)

///|
pub impl Show for ParseError with output(self, logger) {
  let ParseError({ row, col }, xs) = self
  logger.write_string("\nParse Error:\{row}:\{col}:\n")
  for msg in xs {
    logger.write_string("    \{msg} is expected\n")
  }
}

///|
pub impl Debug for ParseError with to_repr(self) {
  Repr::literal(self.to_string())
}
