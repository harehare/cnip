open Ink
open Modules

let tabCount = 10

@react.component
let make = (
  ~commands: array<Command.t>,
  ~tags: option<array<string>>=?,
  ~displayRows: option<int>=?,
  ~canSearch: bool=true,
  ~showTabs: bool=true,
  ~multiSelect: bool=false,
  ~query: option<string>,
  ~defaultTag: option<string>,
  ~onSelect: option<Command.t => unit>=?,
  ~onMultiSelect: option<array<Command.t> => unit>=?,
) => {
  let select = CommandHook.useSelectCommand()

  let (searchText, setSearchText) = React.useState(_ => query->Option.getOr(""))
  let (line, setLine) = React.useState(_ => 0)
  let (selectedCommands, setSelectedCommands) = React.useState(_ => Js.Dict.empty())
  let (selectedTab, setSelectedTab) = React.useState(_ => 0)
  let (displayStart, setDisplayStart) = React.useState(_ => 0)

  let (numColumns, numRows) = React.useMemo(() => Dimension.windowSize(), [])
  let selectableTags = React.useMemo(
    () =>
      tags->Option.getOr([])->Array.length === 0
        ? []
        : Array.concat(["All"], tags->Option.getOr([])),
    [tags],
  )

  React.useEffect(_ => {
    defaultTag
    ->Option.map(t => {
      let index = selectableTags->Array.indexOf(t)

      if index >= 0 {
        setSelectedTab(_ => index)
      }
    })
    ->ignore
    None
  }, [defaultTag])

  let selectedTabCommands = React.useMemo(
    () =>
      commands->Array.filter(command =>
        selectableTags->Array.length === 0 ||
        selectableTags->Array.get(selectedTab)->Option.getOr("All") === "All" ||
        command.tag->Array.includes(selectableTags->Array.get(selectedTab)->Option.getOr("All"))
      ),
    (commands, selectableTags, selectedTab),
  )
  let tabGroupCount = React.useMemo(
    () => selectableTags->Array.length / tabCount + 1,
    [selectableTags],
  )
  let filteredCommands = React.useMemo(() =>
    selectedTabCommands
    ->Array.filterMap(command => {
      let score = command->Command.match(searchText)
      searchText === "" || score > 0.0 ? Some((score, command)) : None
    })
    ->Js.Array2.sortInPlaceWith((a, b) => {
      b->Tuple.first > a->Tuple.first ? 1 : a->Tuple.first == b->Tuple.first ? 0 : -1
    })
    ->Array.map(Tuple.second)
  , (selectedTabCommands, searchText))

  let maxRows = React.useMemo(
    _ =>
      displayRows->Option.getOr(numRows->Option.getOr(0)) -
        (6 +
        tabGroupCount -
        (canSearch ? 1 : 0)) < 0
        ? 10
        : displayRows->Option.getOr(numRows->Option.getOr(0)) -
            (6 +
            tabGroupCount -
            (canSearch ? 1 : 0)),
    (),
  )
  let displayCommands = React.useMemo(
    _ => filteredCommands->Array.slice(~start=displayStart, ~end=displayStart + maxRows),
    (filteredCommands, displayStart),
  )
  let commandCount = React.useMemo(() => filteredCommands->Array.length - 1, [filteredCommands])

  useInput((input, key) => {
    if key.upArrow {
      if line - 1 < 0 {
        let nextLine = commandCount

        setLine(_ => nextLine)
        setDisplayStart(_ => nextLine - maxRows + 1)
      } else {
        let nextLine = Js.Math.max_int(0, line - 1)

        setLine(_ => nextLine)
        setDisplayStart(_ => Js.Math.max_int(0, Js.Math.min_int(nextLine, displayStart - 1)))
      }
    } else if key.downArrow {
      if line + 1 > commandCount {
        setLine(_ => 0)
        setDisplayStart(_ => 0)
      } else {
        let nextLine = Js.Math.min_int(line + 1, commandCount)

        setLine(_ => nextLine)
        setDisplayStart(_ => Js.Math.max_int(0, nextLine - maxRows + 1))
      }
    } else if showTabs && key.leftArrow {
      let nextTab = Js.Math.max_int(0, selectedTab - 1)
      setLine(_ => 0)
      setSelectedTab(_ =>
        selectedTab === nextTab
          ? selectableTags->Array.length - 1
          : Js.Math.max_int(0, selectedTab - 1)
      )
    } else if showTabs && key.rightArrow {
      let nextTab = Js.Math.min_int(selectedTab + 1, selectableTags->Array.length - 1)
      setSelectedTab(_ => selectedTab === nextTab ? 0 : nextTab)
      setLine(_ => 0)
    } else if multiSelect {
      if input === ' ' {
        filteredCommands[line]
        ->Option.map(selectCommand => {
          if selectedCommands->Dict.get(selectCommand.id)->Option.isSome {
            setSelectedCommands(
              _ =>
                selectedCommands
                ->Dict.valuesToArray
                ->Array.filter((command: Command.t) => selectCommand.id !== command.id)
                ->Array.map(command => (command.id, command))
                ->Dict.fromArray,
            )
          } else {
            setSelectedCommands(
              _ =>
                Array.concat([selectCommand], selectedCommands->Dict.valuesToArray)
                ->Array.map(command => (command.id, command))
                ->Dict.fromArray,
            )
          }
        })
        ->ignore
      } else if key.escape {
        if selectedCommands->Dict.keysToArray->Array.length === 0 {
          setSelectedCommands(_ =>
            commands->Array.map(command => (command.id, command))->Dict.fromArray
          )
        } else {
          setSelectedCommands(_ => Js.Dict.empty())
        }
      } else if key.return {
        onMultiSelect
        ->Option.map(onMultiSelect => onMultiSelect(selectedCommands->Dict.valuesToArray))
        ->ignore
      }
    } else if key.return {
      let selectCommand = filteredCommands[line]->Option.getExn
      select(selectCommand)->ignore
      onSelect->Option.map(onSelect => onSelect(selectCommand))->ignore
    }
  }, ())

  let tabs = React.useMemo(() =>
    showTabs
      ? Belt.Array.range(0, tabGroupCount - 1)
        ->Array.map(group =>
          <Box key={group->Int.toString} width=#percent(100.0)>
            {selectableTags
            ->Array.slice(~start=group * tabCount, ~end=group * tabCount + tabCount)
            ->Array.mapWithIndex(
              (tag, i) =>
                <Tab key={tag} tag={tag} selected={group * tabCount + i === selectedTab} />,
            )
            ->React.array}
          </Box>
        )
        ->React.array
      : React.null
  , (showTabs, selectableTags, selectedTab))

  let lines = React.useMemo(() =>
    displayCommands
    ->Array.mapWithIndex((command, i) =>
      <CommandLine
        key={command.id}
        column={numColumns}
        command={command}
        current={displayStart + i === line}
        selected={selectedCommands->Dict.get(command.id)->Option.isSome}
        showCheckBox={multiSelect}
      />
    )
    ->React.array
  , (selectedCommands, displayCommands, line, multiSelect, displayStart))

  React.useEffect(() => {
    setLine(_ => 0)
    None
  }, [searchText])

  <Container>
    {tabs}
    {!multiSelect && canSearch
      ? <Box>
          <TextInput
            default={searchText}
            onChange={s => {
              setSearchText(_ => s)
            }}
          />
        </Box>
      : React.null}
    {multiSelect
      ? <Box>
          <Text color=#gray>
            {`  ${selectedCommands
              ->Dict.keysToArray
              ->Array.length
              ->Int.toString}/${selectedTabCommands->Array.length->Int.toString}`->React.string}
          </Text>
        </Box>
      : <Box>
          <Text color=#gray>
            {`  ${filteredCommands->Array.length->Int.toString}/${selectedTabCommands
              ->Array.length
              ->Int.toString}`->React.string}
          </Text>
        </Box>}
    {lines}
  </Container>
}
