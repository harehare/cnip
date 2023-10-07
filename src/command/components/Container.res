open Ink
open Modules

@react.component
let make = (~children=?) => {
  let (numColumns, numRows) = React.useMemo0(() => Dimension.windowSize())
  let rows = React.useMemo0(_ => numRows - 2)
  let colors = CommandHook.useColor()

  <Box
    flexDirection=#column
    width=#length(numColumns)
    height=#length(rows)
    borderStyle=#single
    borderColor=colors.border>
    {children->Option.getWithDefault(React.null)}
  </Box>
}
