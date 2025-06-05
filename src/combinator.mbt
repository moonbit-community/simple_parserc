///|
pub impl[A] BitOr for Parser[A] with lor(x, y) {
  fn(input) {
    try x(input) catch {
      e =>
        try y(input) catch {
          e_ => raise Many([e, e_]).flatten()
        }
    }
  }
}

///|
pub fn[A] Parser::label(x : Parser[A], s : String) -> Parser[A] {
  fn(input) {
    try x(input) catch {
      Expect(row~, col~, _) => raise Expect(row~, col~, s)
      Many([Expect(row~, col~, _), ..]) => raise Expect(row~, col~, s)
      Many(_) => panic()
    }
  }
}
