type fuzzysortResult = {score: float}

@module("fuzzysort") external fuzzysort: (string, string) => Js.nullable<fuzzysortResult> = "single"

type name = string
type command = string

type commandType = Snippet | History | Navi | Pet | Stdin

type commandParam = {
  name: string,
  defaultValue: option<string>,
}

type t = {
  id: string,
  command: string,
  description: option<string>,
  tag: array<string>,
  alias: option<string>,
  commandType: commandType,
}
type param = {name: string, value: string}

let create = (~command, ~description, ~tag, ~alias, ~commandType) => {
  id: Uuid.V4.make(),
  command: command->Js.String2.trim->Js.String2.replace("\n", ""),
  description,
  tag,
  alias,
  commandType,
}

let createWithId = (~id, ~command, ~description, ~tag, ~alias, ~commandType) => {
  id: Uuid.V3.make(~name=id, ~namespace=#Uuid("77cdf7f7-7df4-4400-a993-539a6d3dad68")),
  command: command->Js.String2.trim->Js.String2.replace("\n", ""),
  description,
  tag,
  alias,
  commandType,
}

let toTagString = (c: t) => {
  let {tag} = c

  tag->Array.joinWith(",")
}

let toDisplayString = (c: t, ~showAlias: bool) => {
  let icon = switch c.commandType {
  | Snippet => Icons.icons.command
  | History => Icons.icons.history
  | Pet => Icons.icons.externalCommand
  | Navi => Icons.icons.externalCommand
  | Stdin => Icons.icons.shell
  }

  icon === ""
    ? c.command
    : `${icon} ${c.command}${showAlias
          ? c.alias
            ->Option.map(alias => ` ${Figures.symbol.right} ${alias}`)
            ->Option.getOr("")
          : ""}`
}

let params: string => array<commandParam> = %raw(`
  function getParams(command) {
    const regexp = /<([\S][^\<]+?[\S])>/g;

    return Object.values(Object.fromEntries([...command.matchAll(regexp)].map(p => {
      const param = p[0];
      const params = param.split('=')

      if (params.length === 2) {
        const command = params[0].replace("<", "").replace(">", "");
        return [command, {name: command, defaultValue: params[1].replace("<", "").replace(">", "")}];
      } else {
        const command = param.replace("<", "").replace(">", "");
        return [command, {name: command, defaultValue: undefined}];
      }
    })));
  }`)

let filledParam: (string, param) => string = %raw(`
  function filledParam(command, param) {
    const regexp = new RegExp("<(" + param.name + "([^\<]+)?)>", 'g');
    return command.replace(regexp, param.value);
  }`)

let filledParams = (t, params) => {
  ...t,
  command: params->Array.reduce(t.command, (acc, p) => filledParam(acc, p)),
}

let match = (command: t, text: string) =>
  fuzzysort(text, command.command)
  ->Js.Nullable.toOption
  ->Option.map(a => a.score)
  ->Option.getOr(0.0)

let encode = (c: t): Json.value => {
  open Json.Encode
  object([
    ("id", string(c.id)),
    ("command", string(c.command)),
    ("description", c.description->Option.map(string)->Option.getOr(Json.Encode.null)),
    ("tag", array(c.tag, string)),
    ("alias", c.alias->Option.map(string)->Option.getOr(Json.Encode.null)),
  ])
}

let decoder: Json.Decode.t<t> = {
  open Json.Decode
  map5(
    field("id", string),
    field("command", string),
    option(field("description", string)),
    field("tag", array(string)),
    option(field("alias", string)),
    ~f=(id, command, description, tag, alias) => {
      id,
      command,
      description,
      tag,
      alias,
      commandType: Snippet,
    },
  )
}
