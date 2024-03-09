open Ink

@react.component
let make = (~selected: bool, ~tag: string) => {
  let colors = CommandHook.useColor()
  let icon = Icons.getIcon(tag)
  let tab = React.useMemo(() => icon === "" ? ` ${tag} ` : ` ${icon} ${tag} `, ())

  {
    <>
      {selected
        ? <Text bold={true} backgroundColor=colors.selectedTab wrap=#"truncate-start">
            {tab->React.string}
          </Text>
        : <Text bold={true} color=#white wrap=#"truncate-start"> {tab->React.string} </Text>}
      <Text wrap=#"truncate-start"> {Figures.symbol.separator->React.string} </Text>
    </>
  }
}
