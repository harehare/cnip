type t = {
  tags: array<string>,
  commands: array<Command.t>,
}

let encode = (c: t): Json.value => {
  open Json.Encode
  object([("tags", array(c.tags, string)), ("commands", array(c.commands, Command.encode))])
}

let decoder: Json.Decode.t<t> = {
  open Json.Decode
  map2(field("tags", array(string)), field("commands", array(Command.decoder)), ~f=(
    tags,
    commands,
  ) => {
    tags,
    commands,
  })
}

let readAsync = (configPath: string, onRead: t => unit) => {
  Modules.File.readAsync(configPath, text => {
    switch Decode.decodeString(text, decoder) {
    | Ok(s) => onRead(s)
    | Error(error) => Exn.raiseError(error->Json.Decode.errorToString)
    }->ignore
  })
}

let updatedAt: string => string = %raw(`
function(snippetPath) {
  const fs = require("fs");
  const stats = fs.statSync(snippetPath);
  return stats.mtime;
}`)

let write = (configPath, config: t) =>
  Fs.writeFileSync(configPath, config->encode->Encode.encode(~indentLevel=2)->Buffer.fromString)

let path = `${Constants.configDir}/snippet.json`

let create = (config: option<string>) => {
  let file = config->Option.getOr(path)

  if !Fs.existsSync(file) {
    Fs.mkdirSyncWith(Constants.configDir, {recursive: true})
    write(file, {tags: [], commands: []})
  }
}

let isExists = (config: option<string>) => {
  let file = config->Option.getOr(path)
  Fs.existsSync(file)
}

let merge = (src: t, dest: t) => {
  let tags =
    src.tags
    ->Array.concat(dest.tags)
    ->Js.Array2.map(t => (t, t))
    ->Js.Dict.fromArray
    ->Js.Dict.values
    ->Js.Array2.filter(tag => tag !== "")
    ->Js.Array2.sortInPlace

  let commands = dest.commands->Array.reduce([], (acc, destCommand) =>
    switch src.commands->Array.find(c => c.id === destCommand.id) {
    | Some(existCommand) => acc->Array.concat([existCommand])
    | None => acc->Array.concat([destCommand])
    }
  )
  let commands = commands->Array.concat(
    src.commands->Array.reduce([], (acc, srcCommand) =>
      switch commands->Array.find(c => c.id === srcCommand.id) {
      | Some(_) => acc
      | None => acc->Array.concat([srcCommand])
      }
    ),
  )

  {tags, commands}
}

module Pet = {
  type petSnippet = {command: string, description: string, tag: option<array<string>>}
  type petSnippets = {snippets: array<petSnippet>}

  @module("toml") external parseToml: string => petSnippets = "parse"

  let readFromPetSnippets = (config: string) => parseToml(Fs.readFileSync(config)->Buffer.toString)
  let petSnipptesToConfig = (petSnippets: petSnippets) => {
    let tags =
      petSnippets.snippets
      ->Array.map(snippet => (
        snippet.tag->Option.getOr([])->Array.get(0)->Option.getOr(""),
        snippet.tag->Option.getOr([])->Array.get(0)->Option.getOr(""),
      ))
      ->Js.Dict.fromArray
      ->Js.Dict.values
      ->Js.Array2.filter(tag => tag !== "")
      ->Js.Array2.sortInPlace
    let commands =
      petSnippets.snippets->Array.map(snippet =>
        Command.create(
          ~command=snippet.command,
          ~description=snippet.description->String.trim === "" ? None : Some(snippet.description),
          ~tag=snippet.tag->Option.getOr([]),
          ~alias=None,
          ~commandType=Pet,
        )
      )

    {tags, commands}
  }
}

module History = {
  let parse = (text: string) =>
    text
    ->String.split("\n")
    ->Array.map(line => line->String.trim)
    ->Set.fromArray
    ->Set.values
    ->Array.fromIterator
    ->Array.filterMap(line =>
      line === ""
        ? None
        : Some(
            Command.createWithId(
              ~id=line,
              ~command=line,
              ~description=None,
              ~tag=[],
              ~alias=None,
              ~commandType=History,
            ),
          )
    )

  let readAsync = (filepath: string, onRead: array<Command.t> => unit) =>
    if !Fs.existsSync(filepath) {
      raise(Exception.NotFound(`"${filepath}"" could not be found.`))
    } else {
      Modules.File.readAsync(filepath, text => text->parse->onRead)
    }
}

module Navi = {
  let parse = (text: string) =>
    text
    ->String.split("%")
    ->Array.filter(v => v->String.trim !== "")
    ->Array.flatMap(commandsByTag => {
      let lines = commandsByTag->String.split("\n")

      if lines->Array.length === 0 {
        []
      } else {
        let tags =
          lines
          ->Array.get(0)
          ->Option.map(tag => tag->String.split(",")->Array.map(String.trim))
          ->Option.getOr([])

        lines->Array.reduce([], (acc, line) => {
          let line = line->String.trim->String.replace("\\", "")

          if line->String.startsWith(";") {
            acc
          } else if line->String.startsWith("$") {
            let command = switch line->String.split(":") {
            | [_, command] => command
            | _ => line->String.slice(~start=1, ~end=line->String.length)
            }

            acc->Array.concat([
              Command.create(
                ~command=command->String.slice(~start=1, ~end=line->String.length),
                ~description=None,
                ~tag=tags,
                ~alias=None,
                ~commandType=Navi,
              ),
            ])
          } else if line->String.startsWith("#") {
            let description = line->String.slice(~start=1, ~end=line->String.length)->String.trim

            acc->Array.concat([
              Command.create(
                ~command="",
                ~description=description === "" ? None : Some(description),
                ~tag=tags,
                ~alias=None,
                ~commandType=Navi,
              ),
            ])
          } else if line->String.startsWith("|") {
            acc
            ->Array.get(acc->Array.length - 1)
            ->Option.map(
              lastCommand =>
                acc->Array.map(
                  command =>
                    command.id === lastCommand.id
                      ? {
                          ...command,
                          command: `${command.command}${line->String.replace("\\", "")}`,
                        }
                      : command,
                ),
            )
            ->Option.getOr(acc)
          } else if line !== "" {
            acc
            ->Array.get(acc->Array.length - 1)
            ->Option.map(
              lastCommand =>
                acc->Array.map(
                  command =>
                    command.id === lastCommand.id &&
                    command.command === "" &&
                    command.description->Option.isSome
                      ? {...command, command: line}
                      : command,
                ),
            )
            ->Option.getOr(acc)
          } else {
            acc
          }
        })
      }
    })

  let readAsync = (filepath: string, onRead: array<Command.t> => unit) =>
    Modules.File.readAsync(filepath, text => text->parse->onRead)
}
