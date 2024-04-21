@react.component
let make = (~snippet: option<string>, ~histfile: string, ~onImport: array<Command.t> => unit) => {
  let importCommand = CommandHook.useImportCommand(snippet)
  let (_, historyCommands) = CommandHook.useHistoryCommands(Some(histfile))

  let handleMultiSelect = React.useCallback((commands: array<Command.t>) => {
    importCommand(commands)
    onImport(commands)
  }, [importCommand, onImport])

  <CommandList
    commands={historyCommands}
    multiSelect={true}
    showTabs={false}
    query={None}
    defaultTag={None}
    onMultiSelect={handleMultiSelect}
  />
}
