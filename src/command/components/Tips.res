open Ink
open Modules

module TipKey = {
  @react.component
  let make = (~text) => {
    <>
      <TextView truncate={true}> {"["->React.string} </TextView>
      <TextView primary={true} truncate={true}> {text->React.string} </TextView>
      <TextView truncate={true}> {"]"->React.string} </TextView>
    </>
  }
}

module TipDescription = {
  @react.component
  let make = (~text) => {
    <>
      <TextView> {" => "->React.string} </TextView>
      <TextView truncate={true}> {`${text} `->React.string} </TextView>
    </>
  }
}

@react.component
let make = _ => {
  let (numColumns, _) = React.useMemo(() => Dimension.windowSize(), [])
  <Box width=#length(numColumns)>
    <TextView> {" Tips: "->React.string} </TextView>
    <TipKey text={"tab, shift+tab"} />
    <TipDescription text={"Move tab."} />
    <TipKey text={"esc"} />
    <TipDescription text={"Select all/Unselect all."} />
    <TipKey text={"space"} />
    <TipDescription text={"Select command/Unselect command."} />
  </Box>
}
