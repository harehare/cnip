open Ink
open Modules

@react.component
let make = (~children=?) => {
  let (numColumns, numRows) = React.useMemo(() => Dimension.windowSize(), [])
  let rows = React.useMemo(_ => numRows - 2, ())
  let colors = CommandHook.useColor()

  <Box
    flexDirection=#column
    width=#length(numColumns)
    height=#length(rows)
    borderStyle=#single
    borderColor=colors.border>
    {children->Option.getOr(React.null)}
  </Box>
}
