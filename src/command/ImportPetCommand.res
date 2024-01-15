@react.component
let make = (~snippet: option<string>, ~petConfig: string, ~onImport: array<Command.t> => unit) => {
  let importCommand = CommandHook.useImportCommand(snippet)
  let petCommands = CommandHook.usePetCommands(Some(petConfig))

  let handleMultiSelect = React.useCallback((commands: array<Command.t>) => {
    importCommand(commands)
    onImport(commands)
  }, [importCommand, onImport])

  <CommandList
    commands={petCommands}
    multiSelect={true}
    showTabs={false}
    query={None}
    defaultTag={None}
    onMultiSelect={handleMultiSelect}
  />
}
