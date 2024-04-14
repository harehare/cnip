open Modules

type t = {gistId: string}

let path = `${Constants.configDir}/config.json`

let encode = (config: t): Json.value => {
  open Json.Encode
  object([("gistId", string(config.gistId))])
}

let decoder: Json.Decode.t<t> = {
  open Json.Decode
  map(field("gistId", string), ~f=gistId => {
    {gistId: gistId}
  })
}

let read = () => {
  if Fs.existsSync(path) {
    Fs.readFileSync(path)
    ->Buffer.toString
    ->Decode.decodeString(decoder)
    ->ResultEx.mapError(Decode.errorToString)
  } else {
    Error(`${path} not found`)
  }
}

let write = (config: t) => {
  Fs.writeFileSync(path, config->encode->Encode.encode(~indentLevel=2)->Buffer.fromString)
}

module Sync = {
  type action = Download | Upload | NoOp

  let download = params =>
    Octokit.createClient({auth: Env.githubAccessToken})
    ->Octokit.rest
    ->Octokit.Rest.gists
    ->Octokit.Rest.Gist.get(params)

  let create = (snippet: Snippet.t) => {
    if snippet.commands->Array.length === 0 {
      raise(Exception.NotFound("sinppets is empty."))
    }

    let file: (string, Octokit.Rest.Gist.gistFile) = (
      ".cnip.snippet.json",
      {content: snippet->Snippet.encode->Encode.encode(~indentLevel=2)},
    )

    Octokit.createClient({auth: Env.githubAccessToken})
    ->Octokit.rest
    ->Octokit.Rest.gists
    ->Octokit.Rest.Gist.create({
      public: false,
      description: "",
      files: Js.Dict.fromList(list{file}),
    })
  }

  let update = (snippet: Snippet.t, gistId: string) => {
    let file: (string, Octokit.Rest.Gist.gistFile) = (
      ".cnip.snippet.json",
      {content: snippet->Snippet.encode->Encode.encode(~indentLevel=2)},
    )

    Octokit.createClient({auth: Env.githubAccessToken})
    ->Octokit.rest
    ->Octokit.Rest.gists
    ->Octokit.Rest.Gist.update({
      gist_id: gistId,
      public: false,
      description: "",
      files: Js.Dict.fromList(list{file}),
    })
  }

  let sync = (config: option<t>, snippet: Snippet.t, snippetPath: string) => {
    switch config {
    | Some(c) =>
      download({gist_id: c.gistId})->Promise.then(gist => {
        let gistSnippet = switch gist.data.files->Js.Dict.values->Array.get(0) {
        | Some(gist) =>
          Decode.decodeString(gist.content, Snippet.decoder)->Result.getOr({
            tags: [],
            commands: [],
          })
        | None => {tags: [], commands: []}
        }

        let localDate = Fs.existsSync(snippetPath)
          ? Some(Snippet.updatedAt(snippetPath)->Date.fromString->DateEx.toString)
          : None
        let remoteDate = gist.data.updated_at->Date.fromString->DateEx.toString

        if localDate->Option.map(localDate => localDate > remoteDate)->Option.getOr(false) {
          update(snippet, c.gistId)->Promise.then(gist => Promise.resolve((Upload, gist)))
        } else if localDate->Option.map(localDate => localDate < remoteDate)->Option.getOr(true) {
          Snippet.write(snippetPath, gistSnippet)->ignore
          Promise.resolve((Download, gist))
        } else {
          Promise.resolve((NoOp, gist))
        }
      })
    | None =>
      create(snippet)->Js.Promise2.then(gist => {
        write({gistId: gist.data.id})
        Promise.resolve((Upload, gist))
      })
    }
  }

  let syncDownloadOnly = (config: option<t>, snippet: Snippet.t, snippetPath: string) => {
    switch config {
    | Some(c) =>
      download({gist_id: c.gistId})->Promise.then(gist => {
        let gistSnippet = switch gist.data.files->Js.Dict.values->Array.get(0) {
        | Some(gist) =>
          Decode.decodeString(gist.content, Snippet.decoder)->Result.getOr({
            tags: [],
            commands: [],
          })
        | None => {tags: [], commands: []}
        }

        Snippet.write(snippetPath, snippet->Snippet.merge(gistSnippet))->ignore
        Promise.resolve((Download, gist))
      })
    | None => Promise.reject(Exception.NotFound("git not found"))
    }
  }
}
