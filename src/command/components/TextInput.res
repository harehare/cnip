open Ink

module TextInput = InkCommunity_TextInput

@react.component
let make = (
  ~prompt: option<string>=?,
  ~error: bool=false,
  ~text: string,
  ~onChange: string => unit,
  ~onSubmit: option<string => unit>=?,
) => {
  <Box>
    <Prompt prompt={prompt->Option.getOr("")} error={error} />
    <TextInput
      highlightPastedText={true}
      value={text}
      onChange={s => {
        onChange(s)
      }}
      onSubmit={onSubmit->Option.getOr(_ => ())}
    />
  </Box>
}
