open Ink

type edit = Command | Description | Tag | Alias | Complete

type editState = {
  command: bool,
  description: bool,
  tag: bool,
  alias: bool,
}

@react.component
let make = (~editCommand: option<Command.t>=?, ~onSubmit: Command.t => unit) => {
  let (current, setCurrent) = React.useState(_ => Command)
  let (command, setCommand) = React.useState(_ =>
    editCommand->Option.getWithDefault(
      Command.create(~command="", ~description=None, ~tag=[], ~alias=None),
    )
  )
  let (editState, setEditState) = React.useState(_ => {
    command: false,
    description: false,
    tag: false,
    alias: false,
  })
  let colors = CommandHook.useColor()

  useInput((_, key) => {
    if key.upArrow {
      if current == Description {
        setCurrent(_ => Command)
      } else if current == Tag {
        setCurrent(_ => Description)
      } else if current == Alias {
        setCurrent(_ => Tag)
      } else {
        setCurrent(_ => Alias)
      }
    } else if key.downArrow {
      if current == Command {
        setCurrent(_ => Description)
      } else if current == Description {
        setCurrent(_ => Tag)
      } else if current == Tag {
        setCurrent(_ => Alias)
      } else {
        setCurrent(_ => Command)
      }
    }
  }, ())

  React.useEffect2(() => {
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
          onChange={c => {
            setEditState(_ => {...editState, command: true})
            setCommand(_ => {...command, command: c})
          }}
          onSubmit={c => {
            setCurrent(_ => Description)
          }}
        />
      : editState.command
      ? <ReadOnlyTextInput
        prompt="Command" color=colors.selected icon={Figures.symbol.success} text={command.command}
      />
      : <ReadOnlyTextInput
          prompt="Command" color=#gray icon={Figures.symbol.pointer} text={command.command}
        />}
    {current === Description
      ? <TextInput
          prompt="Description"
          default={command.description->Option.getWithDefault("")}
          onChange={description => {
            setEditState(_ => {...editState, description: true})
            setCommand(_ => {...command, description: Some(description)})
          }}
          onSubmit={description => {
            setCurrent(_ => Tag)
          }}
        />
      : editState.description
      ? <ReadOnlyTextInput
        prompt="Description"
        color=colors.selected
        icon={Figures.symbol.success}
        text={command.description->Option.getWithDefault("")}
      />
      : <ReadOnlyTextInput
          prompt="Description"
          color=#gray
          icon={Figures.symbol.pointer}
          text={command.description->Option.getWithDefault("")}
        />}
    {current === Tag
      ? <TextInput
          prompt="Tag"
          default={command.tag->Array.joinWith(",")}
          onChange={tag => {
            setEditState(_ => {...editState, tag: true})
            setCommand(_ => {...command, tag: tag->String.split(",")->Array.map(String.trim)})
          }}
          onSubmit={tag => {
            setCurrent(_ => Alias)
          }}
        />
      : editState.tag
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
          default={command.alias->Option.getWithDefault("")}
          onChange={alias => {
            setCommand(_ => {
              ...command,
              alias: alias->String.trim === "" ? None : alias->String.trim->Some,
            })
            setEditState(_ => {...editState, alias: true})
          }}
          onSubmit={tag => {
            setCurrent(_ => Complete)
          }}
        />
      : editState.alias
      ? <ReadOnlyTextInput
        prompt="Alias"
        color=colors.selected
        icon={Figures.symbol.success}
        text={command.alias->Option.getWithDefault("")}
      />
      : <ReadOnlyTextInput
          prompt="Alias"
          color=#gray
          icon={Figures.symbol.pointer}
          text={command.alias->Option.getWithDefault("")}
        />}
  </Box>
}
