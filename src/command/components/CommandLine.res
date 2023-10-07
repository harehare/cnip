open Ink

module Description = {
  @react.component
  let make = (~description: option<string>, ~color: Ink.Text.Color.t) => {
    <>
      <Spacer />
      <Text color wrap=#truncate>
        {description->Option.map(d => ` ${d}`)->Option.getWithDefault("")->React.string}
      </Text>
    </>
  }
}

@react.component
let make = (
  ~column: int,
  ~command: Command.t,
  ~current: bool,
  ~selected: bool,
  ~showCheckBox: bool=false,
) => {
  let colors = CommandHook.useColor()
  let displayCommand = React.useMemo0(() => {
    if command.command->String.length > column {
      `${command.command->String.slice(~start=0, ~end=column - 5)}…`
    } else {
      command.command
    }
  })
  let displayDescription = React.useMemo0(() => {
    command.description->Option.flatMap(d => {
      let len = column - command.command->String.length

      if len <= 0 {
        None
      } else if d->String.length > len - 6 {
        Some(`${d->String.slice(~start=0, ~end=len - 6)}…`)
      } else {
        Some(d)
      }
    })
  })

  <Box>
    {current
      ? <>
          <TextView highlight={true}> {`${Figures.symbol.pointer} `->React.string} </TextView>
          {showCheckBox
            ? selected
                ? <TextView highlight={true}>
                    {`${Figures.symbol.success} `->React.string}
                  </TextView>
                : <TextView highlight={true}>
                    {`${Figures.symbol.square} `->React.string}
                  </TextView>
            : React.null}
          <TextView highlight={true} truncate={true}> {displayCommand->React.string} </TextView>
          <Description description={displayDescription} color=colors.description />
        </>
      : selected
      ? <>
        <TextView selected={true}> {"  "->React.string} </TextView>
        {showCheckBox
          ? <TextView selected={true}> {`${Figures.symbol.success} `->React.string} </TextView>
          : React.null}
        <TextView selected={true} truncate={true}> {displayCommand->React.string} </TextView>
        <Description description={displayDescription} color=#green />
      </>
      : <>
          <TextView> {"  "->React.string} </TextView>
          {showCheckBox
            ? <TextView> {`${Figures.symbol.square} `->React.string} </TextView>
            : React.null}
          <TextView truncate={true}> {displayCommand->React.string} </TextView>
          <Description description={displayDescription} color=#gray />
        </>}
  </Box>
}
