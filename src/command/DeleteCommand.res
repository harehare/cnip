open Modules

@react.component
let make = (~snippet: option<string>, ~onDelete: array<Command.t> => unit) => {
  let deleteCommands = CommandHook.useDeleteCommands(snippet)
  let saveCommand = CommandHook.useSaveCommands(snippet)
  let (_, snippet) = CommandHook.useSnippet(snippet)
  let (_, numRows) = React.useMemo(() => Dimension.windowSize(), [])

  <CommandList
    commands={snippet.commands}
    tags={snippet.tags}
    multiSelect={true}
    displayRows={numRows->Option.map(rows => rows - 1)->Option.getOr(0)}
    query={None}
    defaultTag={None}
    onMultiSelect={commands => {
      saveCommand(deleteCommands(commands))
      onDelete(commands)
    }}
  />
}
