open Ink
open Modules

@react.component
let make = (~children=?) => {
  let (numColumns, numRows) = React.useMemo(() => Dimension.windowSize(), [])
  let rows = React.useMemo(_ => numRows - 2, ())

  <Box flexDirection=#column width=#length(numColumns) height=#length(rows)>
    {children->Option.getOr(React.null)}
  </Box>
}
