@react.component
let make = (~snippet: option<string>, ~onSubmit: Command.t => unit) => {
  let (selected, setSelected) = React.useState(_ => None)
  let editCommand = CommandHook.useEditCommand(snippet)
  let saveCommand = CommandHook.useSaveCommands(snippet)
  let (_, snippet) = CommandHook.useSnippet(snippet)

  switch selected {
  | Some(command) =>
    <Container>
      <CommandEditor
        editCommand={command}
        onSubmit={command => {
          saveCommand(editCommand(command))
          onSubmit(command)
        }}
      />
    </Container>
  | None =>
    <CommandList
      commands={snippet.commands}
      tags={snippet.tags}
      query={None}
      defaultTag={None}
      onSelect={c => setSelected(_ => Some(c))}
    />
  }
}
