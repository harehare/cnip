open Ink

module TextInput = InkCommunity_TextInput

@react.component
let make = (
  ~prompt: option<string>=?,
  ~error: bool=false,
  ~default: option<string>=?,
  ~onChange: string => unit,
  ~onSubmit: option<string => unit>=?,
) => {
  let (text, setText) = React.useState(_ => default->Option.getOr(""))

  <Box>
    <Prompt prompt={prompt->Option.getOr("")} error={error} />
    <TextInput
      value={text}
      onChange={s => {
        setText(_ => s)
        onChange(s)
      }}
      onSubmit={onSubmit->Option.getOr(_ => ())}
    />
  </Box>
}
