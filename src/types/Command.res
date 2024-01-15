type fuzzyOptions

@obj
external fuzzyOptions: (
  ~normalizeWhitespace: bool=?,
  ~useSeparatedUnicode: bool=?,
  ~useDamerau: bool=?,
  unit,
) => fuzzyOptions = ""

@module("fast-fuzzy") external fuzzy: (string, string, fuzzyOptions) => float = "fuzzy"

type name = string
type command = string

type t = {
  id: string,
  command: string,
  description: option<string>,
  tag: array<string>,
  alias: option<string>,
}
type param = {name: string, value: string}

let create = (~command, ~description, ~tag, ~alias) => {
  id: Uuid.V4.make(),
  command: command->Js.String2.trim,
  description,
  tag,
  alias,
}

let toTagString = (c: t) => {
  let {tag} = c

  tag->Array.joinWith(",")
}

let params: string => array<string> = %raw(`
  function getParams(command) {
    const regexp = /<([\S][^\<]+?[\S])>/g;
    return [...new Set([...command.matchAll(regexp)].flatMap(p => p[0]))];
  }`)

let filledParam = (command, p) => command->Js.String2.split(p.name)->Array.joinWith(p.value)
let filledParams = (t, params) => {
  ...t,
  command: params->Array.reduce(t.command, (acc, p) => filledParam(acc, p)),
}

let match = (command: t, text: string) =>
  fuzzy(
    text,
    command.command,
    fuzzyOptions(~normalizeWhitespace=false, ~useSeparatedUnicode=true, ~useDamerau=true, ()),
  )

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
    },
  )
}
