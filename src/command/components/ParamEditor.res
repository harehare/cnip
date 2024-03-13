open Ink

@react.component
let make = (
  ~command: Command.t,
  ~params: array<Command.commandParam>,
  ~onSubmit: array<Command.param> => unit,
) => {
  let (index, setIndex) = React.useState(_ => 0)
  let (error, setError) = React.useState(_ => false)
  let (params, setParams) = React.useState(_ =>
    params->Array.map(p => {
      let p: Command.param = {name: p.name, value: p.defaultValue->Option.getOr("")}
      p
    })
  )
  let colors = CommandHook.useColor()

  useInput((_, key) => {
    if key.upArrow {
      setIndex(_ => Js.Math.max_int(0, index - 1))
      setError(_ => false)
    } else if key.downArrow {
      setIndex(_ => Js.Math.min_int(params->Array.length - 1, index + 1))
      setError(_ => false)
    }
  }, ())

  <Box flexDirection=#column paddingLeft=1>
    <TextView highlight={true}> {command.command->React.string} </TextView>
    <Box flexDirection=#column paddingTop=1>
      {params
      ->Array.mapWithIndex((param, i) =>
        <Box key={param.name}>
          {i === index
            ? <TextInput
                prompt={param.name}
                error={error}
                default={param.value}
                onChange={value => {
                  if value->String.trim === "" {
                    setError(_ => true)
                  } else {
                    setParams(_ =>
                      params->Array.mapWithIndex((p, i) => i === index ? {...p, value} : p)
                    )
                    setError(_ => false)
                  }
                }}
                onSubmit={value => {
                  if value->String.trim === "" {
                    setError(_ => true)
                  } else if !error {
                    if i === params->Array.length - 1 {
                      onSubmit(params)
                      setError(_ => false)
                    } else {
                      setIndex(_ => Js.Math.min_int(params->Array.length - 1, index + 1))
                      setError(_ => false)
                    }
                  }
                }}
              />
            : param.value !== ""
            ? <ReadOnlyTextInput
              prompt={param.name}
              color=colors.selected
              icon={Figures.symbol.success}
              text={param.value}
            />
            : <ReadOnlyTextInput
                prompt={param.name} color=#gray icon={Figures.symbol.pointer} text={param.value}
              />}
        </Box>
      )
      ->React.array}
    </Box>
  </Box>
}
