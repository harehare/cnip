open Ink

type edit = Command | Description | Tag | Alias | Complete
type editStateValue = {enter: bool, error: bool}
type editState = {
  command: editStateValue,
  description: editStateValue,
  tag: editStateValue,
  alias: editStateValue,
}

@react.component
let make = (
  ~editCommand: option<Command.t>=?,
  ~aliasList: array<string>,
  ~onSubmit: Command.t => unit,
) => {
  let (current, setCurrent) = React.useState(_ => Command)
  let (command, setCommand) = React.useState(_ =>
    editCommand->Option.getOr(
      Command.create(~command="", ~description=None, ~tag=[], ~alias=None, ~commandType=Snippet),
    )
  )
  let (editState, setEditState) = React.useState(_ => {
    command: {enter: false, error: false},
    description: {enter: false, error: false},
    tag: {enter: false, error: false},
    alias: {enter: false, error: false},
  })
  let colors = CommandHook.useColor()
  let validate = React.useCallback1((~edit, ~command) => {
    switch edit {
    | Alias => aliasList->Array.includes(command)
    | Description => false
    | Tag => false
    | _ => command->String.trim === ""
    }
  }, [aliasList])

  useInput((_, key) => {
    if key.upArrow {
      if current == Description {
        setEditState(_ => {
          ...editState,
          description: {
            ...editState.description,
            error: validate(~edit=Description, ~command=command.description->Option.getOr("")),
          },
        })
        setCurrent(_ => Command)
      } else if current == Tag {
        setEditState(_ => {
          ...editState,
          tag: {
            ...editState.tag,
            error: validate(~edit=Tag, ~command=command.tag->Array.joinWith("")),
          },
        })
        setCurrent(_ => Description)
      } else if current == Alias {
        setEditState(_ => {
          ...editState,
          alias: {
            ...editState.alias,
            error: validate(~edit=Alias, ~command=command.alias->Option.getOr("")),
          },
        })
        setCurrent(_ => Tag)
      } else {
        setEditState(_ => {
          ...editState,
          command: {
            ...editState.command,
            error: validate(~edit=Command, ~command=command.command),
          },
        })
        setCurrent(_ => Alias)
      }
    } else if key.downArrow {
      if current == Command {
        setEditState(_ => {
          ...editState,
          command: {...editState.command, error: validate(~edit=Command, ~command=command.command)},
        })
        setCurrent(_ => Description)
      } else if current == Description {
        setEditState(_ => {
          ...editState,
          description: {
            ...editState.description,
            error: validate(~edit=Description, ~command=command.description->Option.getOr("")),
          },
        })
        setCurrent(_ => Tag)
      } else if current == Tag {
        setEditState(_ => {
          ...editState,
          tag: {
            ...editState.tag,
            error: validate(~edit=Tag, ~command=command.tag->Array.joinWith("")),
          },
        })
        setCurrent(_ => Alias)
      } else {
        setEditState(_ => {
          ...editState,
          alias: {
            ...editState.alias,
            error: validate(~edit=Alias, ~command=command.alias->Option.getOr("")),
          },
        })
        setCurrent(_ => Command)
      }
    }
  }, ())

  React.useEffect(() => {
    if current === Complete {
      onSubmit(command)
    }
    None
  }, (current, command))

  <Box flexDirection=#column paddingLeft=1>
    {current === Command
      ? <TextInput
          prompt="Command"
          default={command.command}
          error={editState.command.error}
          onChange={c => {
            setEditState(_ => {
              ...editState,
              command: {enter: true, error: validate(~edit=Command, ~command=c)},
            })
            setCommand(_ => {...command, command: c})
          }}
          onSubmit={_ => {
            setCurrent(_ => Description)
          }}
        />
      : editState.command.error
      ? <ReadOnlyTextInput
        prompt="Command" color=colors.error icon={Figures.symbol.pointer} text={command.command}
      />
      : editState.command.enter
      ? <ReadOnlyTextInput
        prompt="Command" color=colors.selected icon={Figures.symbol.success} text={command.command}
      />
      : <ReadOnlyTextInput
          prompt="Command" color=#gray icon={Figures.symbol.pointer} text={command.command}
        />}
    {current === Description
      ? <TextInput
          prompt="Description"
          default={command.description->Option.getOr("")}
          error={editState.description.error}
          onChange={description => {
            setEditState(_ => {
              ...editState,
              description: {enter: true, error: validate(~edit=Description, ~command=description)},
            })
            setCommand(_ => {...command, description: Some(description)})
          }}
          onSubmit={_ => {
            setCurrent(_ => Tag)
          }}
        />
      : editState.description.error
      ? <ReadOnlyTextInput
        prompt="Description"
        color=colors.error
        icon={Figures.symbol.pointer}
        text={command.description->Option.getOr("")}
      />
      : editState.description.enter
      ? <ReadOnlyTextInput
        prompt="Description"
        color=colors.selected
        icon={Figures.symbol.success}
        text={command.description->Option.getOr("")}
      />
      : <ReadOnlyTextInput
          prompt="Description"
          color=#gray
          icon={Figures.symbol.pointer}
          text={command.description->Option.getOr("")}
        />}
    {current === Tag
      ? <TextInput
          prompt="Tag"
          default={command.tag->Array.joinWith(",")}
          error={editState.tag.error}
          onChange={tag => {
            setEditState(_ => {
              ...editState,
              tag: {enter: true, error: validate(~edit=Tag, ~command=tag)},
            })
            setCommand(_ => {...command, tag: tag->String.split(",")->Array.map(String.trim)})
          }}
          onSubmit={_ => {
            setCurrent(_ => Alias)
          }}
        />
      : editState.tag.error
      ? <ReadOnlyTextInput
        prompt="Tag"
        color=colors.error
        icon={Figures.symbol.pointer}
        text={command->Command.toTagString}
      />
      : editState.tag.enter
      ? <ReadOnlyTextInput
        prompt="Tag"
        color=colors.selected
        icon={Figures.symbol.success}
        text={command->Command.toTagString}
      />
      : <ReadOnlyTextInput
          prompt="Tag" color=#gray icon={Figures.symbol.pointer} text={command->Command.toTagString}
        />}
    {current === Alias
      ? <TextInput
          prompt="Alias"
          default={command.alias->Option.getOr("")}
          error={editState.alias.error}
          onChange={alias => {
            setCommand(_ => {
              ...command,
              alias: alias->String.trim === "" ? None : alias->String.trim->Some,
            })
            setEditState(_ => {
              ...editState,
              alias: {enter: true, error: validate(~edit=Alias, ~command=alias)},
            })
          }}
          onSubmit={_ => {
            if (
              !editState.command.error &&
              !editState.description.error &&
              !editState.tag.error &&
              !editState.alias.error
            ) {
              setCurrent(_ => Complete)
            }
          }}
        />
      : editState.alias.error
      ? <ReadOnlyTextInput
        prompt="Alias"
        color=colors.error
        icon={Figures.symbol.pointer}
        text={command.alias->Option.getOr("")}
      />
      : editState.alias.enter
      ? <ReadOnlyTextInput
        prompt="Alias"
        color=colors.selected
        icon={Figures.symbol.success}
        text={command.alias->Option.getOr("")}
      />
      : <ReadOnlyTextInput
          prompt="Alias"
          color=#gray
          icon={Figures.symbol.pointer}
          text={command.alias->Option.getOr("")}
        />}
  </Box>
}
