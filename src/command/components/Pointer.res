open Ink

@react.component
let make = (~error: bool) => {
  let colors = CommandHook.useColor()
  <Text bold={true} color={error ? colors.error : colors.pointer}>
    {`${Figures.symbol.pointer} `->React.string}
  </Text>
}
