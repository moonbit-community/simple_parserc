///|
pub impl[A] BitOr for Parser[A] with lor(x, y) {
  fn(input) {
    x(input) catch {
      e =>
        y(input) catch {
          e_ => raise if e.source_pos() > e_.source_pos() { e } else { e_ }
        }
    }
  }
}

///|
pub fn[A] Parser::label(x : Parser[A], msg : String) -> Parser[A] {
  fn(input) { x(input) catch { ParseError(_) as e => raise e.cons(msg) } }
}
