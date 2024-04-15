open Ink

module Link = InkCommunity_Link

module SnippetOption = {
  @react.component
  let make = () =>
    <Box>
      <TextView> {"--snippet [STRING]"->React.string} </TextView>
      <Spacer />
      <TextView> {" snippet file (default is $HOME/.cnip.snippet.json)"->React.string} </TextView>
    </Box>
}

module ListOption = {
  @react.component
  let make = () => <>
    <Box>
      <TextView> {"-c "->React.string} </TextView>
      <Spacer />
      <TextView> {"Copy selected command to clipboard"->React.string} </TextView>
    </Box>
    <SnippetOption />
    <Box>
      <TextView> {"--input [STRING]"->React.string} </TextView>
      <Spacer />
      <TextView>
        {" Reads the specified text file into the command list (e.g. $HISTFILE, etc.)"->React.string}
      </TextView>
    </Box>
    <Box>
      <TextView> {"--tag [STRING]"->React.string} </TextView>
      <Spacer />
      <TextView> {" Specify the tag to be selected for initial display"->React.string} </TextView>
    </Box>
    <Box>
      <TextView> {"--select [STRING]"->React.string} </TextView>
      <Spacer />
      <TextView>
        {" Display aliases and commands that match the specified text"->React.string}
      </TextView>
    </Box>
    <Box>
      <TextView> {"--pet-snippet [STRING]"->React.string} </TextView>
      <Spacer />
      <Link url={"https://github.com/knqyf263/pet"}>
        <TextView> {" Read Pet snippet file"->React.string} </TextView>
      </Link>
    </Box>
  </>
}

module HelpOption = {
  @react.component
  let make = () =>
    <Box>
      <TextView> {"-h"->React.string} </TextView>
      <Spacer />
      <TextView> {Cli.Help(None)->Cli.commandToHelpString->React.string} </TextView>
    </Box>
}

@react.component
let make = (~command: option<Cli.command>=?) => {
  let availableCommands = [
    Cli.List({
      action: Cli.Select,
      snippet: None,
      sort: None,
      input: None,
      query: None,
      tag: None,
      select: None,
    }),
    Cli.Add({command: None, snippet: None}),
    Cli.Edit({snippet: None}),
    Cli.Delete({snippet: None}),
    Cli.Import({action: Cli.History(""), snippet: None}),
    Cli.Sync({snippet: None, gistId: None, createBackup: false, downloadOnly: false}),
    Cli.Version,
  ]

  switch command {
  | Some(Cli.Add(_)) =>
    <Box flexDirection=#column>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"USAGE:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <TextView> {"cnip add [OPTIONS]"->React.string} </TextView>
        </Box>
      </Box>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"OPTIONS:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <Box>
            <TextView> {"-c"->React.string} </TextView>
            <Spacer />
            <TextView> {"Add the specified command"->React.string} </TextView>
          </Box>
          <SnippetOption />
          <HelpOption />
        </Box>
      </Box>
    </Box>
  | Some(Cli.List(_)) =>
    <Box flexDirection=#column>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"USAGE:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <TextView> {"cnip list [OPTIONS]"->React.string} </TextView>
        </Box>
      </Box>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"OPTIONS:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <ListOption />
          <HelpOption />
        </Box>
      </Box>
    </Box>
  | Some(Cli.Edit(_)) | Some(Cli.Delete(_)) =>
    <Box flexDirection=#column>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"USAGE:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <TextView>
            {`snip ${command->Option.getExn->Cli.commandToString} [OPTIONS]`->React.string}
          </TextView>
        </Box>
      </Box>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"OPTIONS:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <SnippetOption />
          <HelpOption />
        </Box>
      </Box>
    </Box>
  | Some(Cli.Sync(_)) =>
    <Box flexDirection=#column>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"USAGE:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <TextView>
            {`snip ${command->Option.getExn->Cli.commandToString} [OPTIONS]`->React.string}
          </TextView>
        </Box>
      </Box>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"OPTIONS:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <SnippetOption />
          <Box>
            <TextView> {"--gist-id"->React.string} </TextView>
            <Spacer />
            <TextView> {"Specify gist id to sync"->React.string} </TextView>
          </Box>
          <Box>
            <TextView> {"-b"->React.string} </TextView>
            <Spacer />
            <TextView> {"Create backup before sync"->React.string} </TextView>
          </Box>
          <Box>
            <TextView> {"-d"->React.string} </TextView>
            <Spacer />
            <TextView> {"Execute download only"->React.string} </TextView>
          </Box>
          <HelpOption />
        </Box>
      </Box>
    </Box>
  | Some(Cli.Import(_)) =>
    <Box flexDirection=#column>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"USAGE:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <TextView> {"cnip import [OPTIONS]"->React.string} </TextView>
        </Box>
      </Box>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"OPTIONS:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <SnippetOption />
          <Box>
            <TextView> {"--pet [STRING]"->React.string} </TextView>
            <Spacer />
            <Link url={"https://github.com/knqyf263/pet"}>
              <TextView> {"Imports snippets from pet snippet"->React.string} </TextView>
            </Link>
          </Box>
          <Box>
            <TextView> {"--history [STRING]"->React.string} </TextView>
            <Spacer />
            <TextView> {"Imports snippets from history file"->React.string} </TextView>
          </Box>
          <Box>
            <TextView> {"--navi [STRING]"->React.string} </TextView>
            <Spacer />
            <TextView> {"Imports snippets from navi cheatsheet"->React.string} </TextView>
          </Box>
          <HelpOption />
        </Box>
      </Box>
    </Box>
  | _ =>
    <Box flexDirection=#column>
      <Box marginBottom={1}>
        <TextView>
          {"cnip is a simple command-line snippet management tool."->React.string}
        </TextView>
      </Box>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"USAGE:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          <TextView> {"cnip [COMMAND]"->React.string} </TextView>
        </Box>
      </Box>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"AVAILABLE COMMANDS:"->React.string} </TextView>
        <Box flexDirection=#column paddingLeft={4}>
          {availableCommands
          ->Array.map(command =>
            <Box key={command->Cli.commandToString}>
              <TextView> {command->Cli.commandToString->React.string} </TextView>
              <Spacer />
              <TextView> {command->Cli.commandToHelpString->React.string} </TextView>
            </Box>
          )
          ->React.array}
        </Box>
      </Box>
      <Box flexDirection=#column marginBottom={1}>
        <TextView primary={true}> {"OPTIONS:"->React.string} </TextView>
        <Box paddingLeft={4} flexDirection=#column>
          <ListOption />
          <HelpOption />
        </Box>
      </Box>
    </Box>
  }
}
