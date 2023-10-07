open Ink

@react.component
let make = (~prompt: string, ~error: bool) => {
  let colors = CommandHook.useColor()
  <>
    {prompt === ""
      ? React.null
      : <Text bold={true} color={error ? colors.error : colors.prompt}>
          {`${prompt} `->React.string}
        </Text>}
    <Pointer error={error} />
  </>
}
