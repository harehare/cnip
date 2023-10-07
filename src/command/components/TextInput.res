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
  let (text, setText) = React.useState(_ => default->Option.getWithDefault(""))

  <Box>
    <Prompt prompt={prompt->Option.getWithDefault("")} error={error} />
    <TextInput
      value={text}
      highlightPastedText={true}
      onChange={s => {
        setText(_ => s)
        onChange(s)
      }}
      onSubmit={onSubmit->Option.getWithDefault(_ => ())}
    />
  </Box>
}
