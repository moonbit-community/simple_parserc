///|
pub impl[A] BitOr for Parser[A] with lor(x, y) {
  fn(input) {
    x(input) catch {
      e => y(input) catch { e_ => raise Many([e, e_]).flatten() }
    }
  }
}

///|
pub fn[A] Parser::label(x : Parser[A], s : String) -> Parser[A] {
  fn(input) {
    x(input) catch {
      Expect(row~, col~, _) as prev =>
        raise Many([Expect(row~, col~, s), prev]).flatten()
      Many([Expect(row~, col~, _), ..]) as prev =>
        raise Many([Expect(row~, col~, s), prev]).flatten()
      Many(_) => panic()
    }
  }
}
