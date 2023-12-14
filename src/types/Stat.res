type t = {commandHash: string, lastUsed: float, usageCount: int}

let commandHash = %raw(`
function commandHash(command) {
  const crypto = require('crypto')
  const md5 = crypto.createHash('md5')
  return md5.update(command, 'binary').digest('hex')
}
`)

let encode = (c: t): Json.value => {
  open Json.Encode
  object([
    ("commandHash", string(c.commandHash)),
    ("lastUsed", Json.Encode.float(c.lastUsed)),
    ("usageCount", int(c.usageCount)),
  ])
}

let decoder: Json.Decode.t<t> = {
  open Json.Decode
  map3(
    field("commandHash", string),
    field("lastUsed", Json.Decode.float),
    field("usageCount", int),
    ~f=(commandHash, lastUsed, usageCount) => {
      commandHash,
      lastUsed,
      usageCount,
    },
  )
}

let path = `${Constants.configDir}/stat.json`

let readAsync = (onRead: array<t> => unit) => {
  Modules.File.readAsync(path, text => {
    switch Decode.decodeString(text, Json.Decode.array(decoder)) {
    | Ok(s) => onRead(s)
    | Error(error) => Exn.raiseError(error->Json.Decode.errorToString)
    }->ignore
  })
}

let write = (stat: array<t>) => {
  Fs.writeFileSync(
    path,
    stat->Json.Encode.array(encode)->Encode.encode(~indentLevel=2)->Buffer.fromString,
  )
}

let use = (stats: array<t>, command: string) => {
  let hash = command->commandHash

  if stats->Array.find(s => s.commandHash === hash)->Option.isSome {
    write(
      stats->Array.map(s =>
        s.commandHash === hash ? {...s, usageCount: s.usageCount + 1, lastUsed: Js.Date.now()} : s
      ),
    )
  } else {
    write(stats->Array.concat([{commandHash: hash, usageCount: 1, lastUsed: Js.Date.now()}]))
  }
}

let statByHash = (stats: array<t>) => {
  let map = Js.Dict.empty()
  stats->Js.Array2.forEach(s => map->Js.Dict.set(s.commandHash, s))
  map
}

let create = () => {
  if !Fs.existsSync(path) {
    write([])
  }
}
