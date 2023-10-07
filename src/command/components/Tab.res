open Ink

@react.component
let make = (~selected: bool, ~tag: string) => {
  let colors = CommandHook.useColor()
  let tab = React.useMemo0(() => ` ${tag} `)

  {
    <>
      {selected
        ? <Text bold={true} backgroundColor=colors.selectedTab wrap=#"truncate-start">
            {tab->React.string}
          </Text>
        : <Text bold={true} wrap=#"truncate-start"> {tab->React.string} </Text>}
      <Text bold={true}> {"|"->React.string} </Text>
    </>
  }
}
