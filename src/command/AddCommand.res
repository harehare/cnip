@react.component
let make = (~snippet: option<string>, ~command: option<string>, ~onSubmit: Command.t => unit) => {
  let addCommand = CommandHook.useAddCommand(snippet)
  let saveCommand = CommandHook.useSaveCommands(snippet)
  let (_, snippet) = CommandHook.useSnippet(snippet)
  let aliasList = React.useMemo1(() =>
    snippet.commands
    ->Array.map(command => command.alias->Option.getOr(""))
    ->Array.filter(v => v !== "")
  , [snippet])

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
        aliasList={aliasList}
        onSubmit={command => {
          saveCommand(addCommand(command))
          onSubmit(command)
        }}
      />
    | None =>
      <CommandEditor
        aliasList={aliasList}
        onSubmit={command => {
          saveCommand(addCommand(command))->ignore
          onSubmit(command)
        }}
      />
    }}
  </Container>
}
