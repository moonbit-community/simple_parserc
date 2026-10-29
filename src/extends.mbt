
///|
pub extend Input with @debug.Debug::{to_repr}

///|
pub extend Input with Show::{to_string, output}

///|
pub extend ParseError with @debug.Debug::{to_repr}

///|
pub extend ParseError with Show::{to_string, output}

///|
pub extend Parser with BitOr::{lor}

///|
pub extend SourcePos with @debug.Debug::{to_repr}

///|
pub extend SourcePos with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend SourcePos with Eq::{not_equal, equal}

///|
pub extend SourcePos with Show::{to_string, output}
