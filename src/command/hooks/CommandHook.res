let extractTags = (commands: array<Command.t>) =>
  commands
  ->Array.flatMap(c => c.tag)
  ->Js.Array2.map(c => (c, c))
  ->Js.Dict.fromArray
  ->Js.Dict.values
  ->Js.Array2.filter(tag => tag !== "")
  ->Js.Array2.sortInPlace

let useStdout = () => {
  let write = React.useCallback(text => {
    Process.process->Process.stdout->Stream.writeWith(`${text}\n`->Buffer.fromString, ())->ignore
  }, [])

  write
}

type colors = {
  highlight: Color.t,
  currentLine: Color.t,
  text: Color.t,
  description: Color.t,
  prompt: Color.t,
  selectedTab: Color.t,
  tab: Color.t,
  selected: Color.t,
  pointer: Color.t,
  border: Color.t,
  error: Color.t,
}

let useColor = () => {
  let colors = React.useMemo(() => {
    {
      highlight: Color.highlight(),
      currentLine: Color.currentLine(),
      text: Color.text(),
      description: Color.description(),
      prompt: Color.prompt(),
      selectedTab: Color.selectedTab(),
      tab: Color.tab(),
      selected: Color.selected(),
      pointer: Color.pointer(),
      border: Color.border(),
      error: Color.error(),
    }
  }, ())

  colors
}

let useSnippet = (snippet: option<string>) => {
  let (isLoading, setIsLoading) = React.useState(_ => true)
  let (readedSnippet, setReadedSnippet) = React.useState(_ => None)

  React.useEffect(() => {
    if Snippet.isExists(snippet) {
      Snippet.readAsync(snippet->Option.getOr(Snippet.path), c => {
        setReadedSnippet(_ => Some(c))
        setIsLoading(_ => false)
      })->ignore
    } else {
      setReadedSnippet(_ => None)
      setIsLoading(_ => false)
    }

    None
  }, [snippet])

  (
    isLoading,
    readedSnippet->Option.getOr({
      tags: [],
      commands: [],
    }),
  )
}

let usePetCommands = (snippet: option<string>) => {
  let commands = React.useMemo(() => {
    switch snippet {
    | Some(petConfig) => {
        let snippet = Snippet.Pet.petSnipptesToConfig(Snippet.Pet.readFromPetSnippets(petConfig))
        snippet.commands
      }
    | None => []
    }
  }, [snippet])

  commands
}

let useNaviCommands = (config: option<string>) => {
  let (isLoading, setIsLoading) = React.useState(_ => false)
  let (commands, setCommands) = React.useState(_ => None)

  React.useEffect(() => {
    config
    ->Option.map(f => {
      setIsLoading(_ => true)
      Snippet.Navi.readAsync(
        f,
        commands => {
          setCommands(_ => Some(commands))
          setIsLoading(_ => false)
        },
      )->ignore
    })
    ->ignore
    None
  }, [config])

  (isLoading, commands)
}

let useHistoryCommands = (histfile: option<string>) => {
  let (isLoading, setIsLoading) = React.useState(_ => false)
  let (histories, setHistories) = React.useState(_ => None)

  React.useEffect(() => {
    histfile
    ->Option.map(f => {
      setIsLoading(_ => true)
      Snippet.History.readAsync(
        f,
        commands => {
          let re = Js.Re.fromString(": [0-9]{10}:[0-9]+;(.*)")
          setHistories(
            _ => Some(
              commands->Array.map(
                command => {
                  switch re->Js.Re.exec_(command.command) {
                  | Some(r) =>
                    Js.Re.captures(r)[1]
                    ->Option.map(
                      v => {
                        ...command,
                        command: v->Js.Nullable.toOption->Option.getOr(command.command),
                      },
                    )
                    ->Option.getOr(command)
                  | None => command
                  }
                },
              ),
            ),
          )
          setIsLoading(_ => false)
        },
      )->ignore
    })
    ->ignore
    None
  }, [histfile])

  (isLoading, histories)
}

let useStats = () => {
  let (stats, setStats) = React.useState(_ => None)
  React.useEffect(() => {
    Stat.create()
    Stat.readAsync(s => setStats(_ => Some(s->Stat.statByHash)))->ignore
    None
  }, [])

  (
    React.useCallback(
      (command: string) => stats->Option.flatMap(s => s->Js.Dict.get(command->Stat.commandHash)),
      [stats],
    ),
    React.useCallback(
      (command: string) => stats->Option.map(s => Stat.use(s->Js.Dict.values, command)),
      [stats],
    ),
  )
}

let useSelectCommand = () => {
  let (_, updateStats) = useStats()

  React.useCallback((command: Command.t) => updateStats(command.id), [updateStats])
}

let useSaveCommands = (snippet: option<string>) => {
  let saveCommands = React.useCallback((commands: array<Command.t>) => {
    Snippet.create(snippet)
    Snippet.write(
      snippet->Option.getOr(Snippet.path),
      {
        tags: commands->extractTags,
        commands,
      },
    )
  }, [snippet])

  saveCommands
}

let useImportCommand = (snippet: option<string>) => {
  let saveCommands = useSaveCommands(snippet)
  let (_, snippet) = useSnippet(snippet)

  React.useCallback((addCommands: array<Command.t>) => {
    let newCommands = Array.concat(addCommands, snippet.commands)
    saveCommands(newCommands)
  }, (saveCommands, snippet))
}

let useAddCommand = (config: option<string>) => {
  let (_, snippet) = useSnippet(config)
  let addCommand = React.useCallback(
    (command: Command.t) => [command]->Array.concat(snippet.commands),
    [snippet],
  )

  addCommand
}

let useEditCommand = (config: option<string>) => {
  let (_, snippet) = useSnippet(config)
  let editCommand = React.useCallback(
    (command: Command.t) => snippet.commands->Array.map(c => c.id === command.id ? command : c),
    [snippet],
  )

  editCommand
}

let useDeleteCommands = (snippet: option<string>) => {
  let (_, snippet) = useSnippet(snippet)
  let deleteCommand = React.useCallback((deleteCommands: array<Command.t>) => {
    let deleteCommandIds = deleteCommands->Array.map(c => c.id)->Set.fromArray
    snippet.commands->Array.filter(c => !(deleteCommandIds->Set.has(c.id)))
  }, [snippet])

  deleteCommand
}

let useSyncCommands = (
  snippetPath: option<string>,
  ~gistId: option<string>,
  ~createBackup: bool,
  ~downloadOnly: bool,
) => {
  let (isSnippetLoading, snippets) = useSnippet(snippetPath)
  let (syncedGistId, setSyncedGistId) = React.useState(_ => None)
  let (action, setAction) = React.useState(_ => None)
  let (error, setError) = React.useState(_ => None)
  let saveCommands = useSaveCommands(
    Some(`${Constants.configDir}/snippet_${Js.Date.now()->Int.fromFloat->Int.toString}.json`),
  )
  let targetGistId =
    gistId
    ->Option.map(g => {
      let config: Config.t = {gistId: g}
      Some(config)
    })
    ->Option.getOr(
      switch Config.read() {
      | Ok(config) => Some(config)
      | Error(_) => None
      },
    )

  React.useEffect(() => {
    if !isSnippetLoading {
      if createBackup {
        saveCommands(snippets.commands)
      }

      if downloadOnly {
        Config.Sync.syncDownloadOnly(
          targetGistId,
          snippets,
          snippetPath->Option.getOr(Snippet.path),
        )
      } else {
        Config.Sync.sync(targetGistId, snippets, snippetPath->Option.getOr(Snippet.path))
      }
      ->Promise.then(((action, gist)) => {
        setSyncedGistId(_ => Some(gist.data.id))
        setAction(_ => Some(action))
        Promise.resolve(gist.data.id)
      })
      ->Promise.catch(e => {
        setError(
          _ => Some(
            switch e {
            | Exception.NotFound(msg) => msg
            | e =>
              `Error occurred: ${e
                ->Exn.asJsExn
                ->Option.flatMap(e => e->Exn.message)
                ->Option.getOr("")}`
            },
          ),
        )
        Promise.resolve(error->Option.getOr(""))
      })
      ->ignore
    }
    None
  }, [isSnippetLoading])

  (action, syncedGistId, error)
}

let useStdinCommands = () => {
  let (commands, setCommands) = React.useState(_ => None)
  let (isLoaded, setLoaded) = React.useState(_ => false)

  React.useEffect(() => {
    Snippet.Stdin.readAsync(commands => {
      if !isLoaded {
        setCommands(_ => Some(commands))
        setLoaded(_ => true)
      }
    })->ignore
    None
  }, [])

  commands
}
