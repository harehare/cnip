open Ink

@module("clipboardy") external writeToClipboard: string => unit = "writeSync"

let version = "0.1.25"

@react.component
let make = (~cliCommand: Cli.command, ~clear: unit => unit) => {
  let app = useApp()
  let stdoutWrite = CommandHook.useStdout()
  let exit = React.useCallback(() => {
    clear()
    app.exit(None)
  }, (app, clear))
  let showTips = React.useMemo(_ =>
    Env.showTips->Option.map(v => v === "true" || v === "1")->Option.getOr(true) &&
      switch cliCommand {
      | Sync(_) => false
      | List({select: Some(_)}) => false
      | Help(_) => false
      | Version => false
      | _ => true
      }
  , [])

  <>
    {switch cliCommand {
    | Cli.List({action: Cli.Select, snippet, sort, input, query, tag, select}) =>
      switch select {
      | Some(select) =>
        <SelectCommand
          snippet
          select
          onSelect={command => {
            switch command {
            | Some(command) => {
                exit()
                stdoutWrite(command.command)
              }
            | None => {
                exit()
                stdoutWrite(select)
              }
            }
          }}
        />
      | None =>
        <ListCommand
          snippet
          sort
          input
          query
          defaultTag={tag}
          onSelect={command => {
            exit()
            stdoutWrite(command.command)
          }}
        />
      }

    | Cli.List({action: Cli.Copy, snippet, sort, input, query, tag, select}) =>
      switch select {
      | Some(select) =>
        <SelectCommand
          snippet
          select
          onSelect={command => {
            switch command {
            | Some(command) => {
                exit()
                stdoutWrite(command.command)
              }
            | None => {
                exit()
                stdoutWrite(select)
              }
            }
          }}
        />
      | None =>
        <ListCommand
          snippet
          sort
          input
          query
          defaultTag={tag}
          onSelect={command => {
            exit()
            writeToClipboard(command.command)
          }}
        />
      }
    | Cli.Add({command, snippet}) =>
      <AddCommand
        command={command}
        snippet={snippet}
        onSubmit={command => {
          exit()
          stdoutWrite(Modules.Console.success(`"${command.command}" command added.`))
        }}
      />
    | Cli.Edit({snippet}) =>
      <EditCommand
        snippet={snippet}
        onSubmit={command => {
          exit()
          stdoutWrite(Modules.Console.success(`"${command.command}" command updated.`))
        }}
      />
    | Cli.Delete({snippet}) =>
      <DeleteCommand
        snippet={snippet}
        onDelete={commands => {
          exit()
          stdoutWrite(
            Modules.Console.success(`${commands->Array.length->Int.toString} commands deleted.`),
          )
        }}
      />
    | Cli.Import({action: Cli.Pet(petConfig), snippet}) =>
      <ImportPetCommand
        snippet={snippet}
        petConfig={petConfig}
        onImport={commands => {
          exit()
          stdoutWrite(
            Modules.Console.success(`${commands->Array.length->Int.toString} commands imported.`),
          )
        }}
      />
    | Cli.Import({action: Cli.History(histfile), snippet}) =>
      <ImportHistoryCommand
        snippet={snippet}
        histfile={histfile}
        onImport={commands => {
          exit()
          stdoutWrite(
            Modules.Console.success(`${commands->Array.length->Int.toString} commands imported.`),
          )
        }}
      />
    | Cli.Import({action: Cli.Navi(config), snippet}) =>
      <ImportNaviCommand
        snippet={snippet}
        config={config}
        onImport={commands => {
          exit()
          stdoutWrite(
            Modules.Console.success(`${commands->Array.length->Int.toString} commands imported.`),
          )
        }}
      />
    | Cli.Sync({snippet, gistId, createBackup, downloadOnly}) =>
      <SyncCommand
        snippet={snippet} gistId={gistId} createBackup={createBackup} downloadOnly={downloadOnly}
      />
    | Cli.Help(None) => <HelpCommand />
    | Cli.Help(Some(command)) => <HelpCommand command={command} />
    | Cli.Version => <Text bold={true}> {version->React.string} </Text>
    }}
    {showTips ? <Tips /> : React.null}
  </>
}
