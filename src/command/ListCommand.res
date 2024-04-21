@react.component
let make = (
  ~snippet: option<string>,
  ~sort: option<Sort.t>,
  ~input: option<string>,
  ~query: option<string>,
  ~defaultTag: option<string>,
  ~onSelect: Command.t => unit,
) => {
  let (isSnippetLoading, snippet) = CommandHook.useSnippet(snippet)
  let (isHistoryLoading, historyCommands) = CommandHook.useHistoryCommands(input)
  let stdinCommands = CommandHook.useStdinCommands()
  let (commandAndParams, setCommandAndParams) = React.useState(_ => None)
  let commands = React.useMemo(
    () => snippet.commands->Array.concatMany([historyCommands, stdinCommands]),
    (snippet.commands, historyCommands, stdinCommands),
  )

  let (getStats, _) = CommandHook.useStats()
  let commands = React.useMemo(() => {
    switch sort {
    | Some(LastUsed) =>
      commands->Js.Array2.sortInPlaceWith((a, b) => {
        let v1 = a.id->getStats->Option.map(s => s.lastUsed)->Option.getOr(0.0)
        let v2 = b.id->getStats->Option.map(s => s.lastUsed)->Option.getOr(0.0)
        v1 === v2 ? 0 : v2 > v1 ? 1 : -1
      })
    | Some(UsageCount) =>
      commands->Js.Array2.sortInPlaceWith((a, b) => {
        let v1 = a.id->getStats->Option.map(s => s.usageCount)->Option.getOr(0)
        let v2 = b.id->getStats->Option.map(s => s.usageCount)->Option.getOr(0)
        v1 === v2 ? 0 : v2 > v1 ? 1 : -1
      })
    | Some(Name) =>
      commands->Js.Array2.sortInPlaceWith((a, b) => {
        a.command === b.command ? 0 : b.command > a.command ? 1 : -1
      })
    | None => commands
    }
  }, (sort, commands, historyCommands, getStats))

  let onSelectCommand = React.useCallback((command: Command.t) => {
    let params = command.command->Command.params

    if params->Array.length === 0 {
      onSelect(command)
    } else {
      setCommandAndParams(_ => Some((command, params)))
    }
  }, [])

  {
    isSnippetLoading || isHistoryLoading
      ? <Container />
      : switch commandAndParams {
        | Some((command, params)) =>
          <Container>
            <ParamEditor
              command={command}
              params={params}
              onSubmit={params => {
                onSelect(command->Command.filledParams(params))
              }}
            />
          </Container>
        | None =>
          <CommandList commands tags={snippet.tags} defaultTag query onSelect={onSelectCommand} />
        }
  }
}
