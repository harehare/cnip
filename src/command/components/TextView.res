open Ink

@react.component
let make = (
  ~children,
  ~highlight: option<bool>=?,
  ~selected: option<bool>=?,
  ~primary: option<bool>=?,
  ~error: option<bool>=?,
  ~truncate: option<bool>=?,
) => {
  let colors = CommandHook.useColor()
  let wrap = React.useMemo1(
    () => truncate->Option.map(v => v ? #truncate : #wrap)->Option.getWithDefault(#wrap),
    [truncate],
  )

  {
    primary->Option.getWithDefault(false)
      ? <Text bold={true} color=colors.currentLine wrap> {children} </Text>
      : selected->Option.getWithDefault(false)
      ? <Text bold={true} color=colors.selected wrap> {children} </Text>
      : highlight->Option.getWithDefault(false)
      ? <Text bold={true} backgroundColor=colors.highlight wrap> {children} </Text>
      : error->Option.getWithDefault(false)
      ? <Text color=#red wrap> {children} </Text>
      : <Text bold={true} color=colors.text wrap> {children} </Text>
  }
}
