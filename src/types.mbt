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
pub(all) type! ParseError {
  Many(Array[ParseError])
  Expect(row~ : Int, col~ : Int, String)
} derive(Show)

///|
pub(all) type Parser[A] (Input) -> (A, Input)!ParseError
