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
        let cleanedValue = %re("/\[200~|201~/g")->Js.String.replaceByRe("", s)
        onChange(cleanedValue)
      }}
      onSubmit={onSubmit->Option.getOr(_ => ())}
    />
  </Box>
}
