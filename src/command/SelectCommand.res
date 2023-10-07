@react.component
let make = (~snippet: option<string>, ~select: string, ~onSelect: option<Command.t> => unit) => {
  let (isSnippetLoading, snippet) = CommandHook.useSnippet(snippet)
  let (commandAndParams, setCommandAndParams) = React.useState(_ => None)

  React.useEffect2(() => {
    if !isSnippetLoading {
      switch snippet.commands->Array.find(command => {
        command.alias->Option.getWithDefault("") === select || command.command === select
      }) {
      | Some(command) => {
          let params = command.command->Command.params
          if params->Array.length === 0 {
            onSelect(Some(command))
          } else {
            setCommandAndParams(_ => Some((command, params)))
          }
        }
      | None => onSelect(None)
      }
    }
    None
  }, (isSnippetLoading, snippet))

  {
    isSnippetLoading
      ? React.null
      : switch commandAndParams {
        | Some((command, params)) =>
          <Container>
            <ParamEditor
              command={command}
              params={params}
              onSubmit={params => {
                onSelect(Some(command->Command.filledParams(params)))
              }}
            />
          </Container>
        | None => React.null
        }
  }
}
