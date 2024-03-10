@react.component
let make = (~snippet: option<string>, ~command: option<string>, ~onSubmit: Command.t => unit) => {
  let addCommand = CommandHook.useAddCommand(snippet)
  let saveCommand = CommandHook.useSaveCommands(snippet)

  <Container>
    {switch command {
    | Some(command) =>
      <CommandEditor
        editCommand={Command.create(
          ~command,
          ~description=None,
          ~tag=[],
          ~alias=None,
          ~commandType=Snippet,
        )}
        onSubmit={command => {
          saveCommand(addCommand(command))
          onSubmit(command)
        }}
      />
    | None =>
      <CommandEditor
        onSubmit={command => {
          saveCommand(addCommand(command))->ignore
          onSubmit(command)
        }}
      />
    }}
  </Container>
}
