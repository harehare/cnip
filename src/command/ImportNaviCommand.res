@react.component
let make = (~snippet: option<string>, ~config: string, ~onImport: array<Command.t> => unit) => {
  let importCommand = CommandHook.useImportCommand(snippet)
  let (_, naviCommands) = CommandHook.useNaviCommands(Some(config))

  let handleMultiSelect = React.useCallback((commands: array<Command.t>) => {
    importCommand(commands)
    onImport(commands)
  }, [importCommand, onImport])

  <CommandList
    commands={naviCommands->Option.getOr([])}
    multiSelect={true}
    showTabs={false}
    query={None}
    defaultTag={None}
    onMultiSelect={handleMultiSelect}
  />
}
