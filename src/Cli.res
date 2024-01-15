open Modules

@module external minimist: (array<string>, unit) => Js.Json.t = "minimist"

type cliError =
  | NotFound(option<string>)
  | InvalidOption({name: string})

type listAction = Copy | Select
type importAction = Pet(string) | History(string) | Navi(string)

type rec command =
  | Add({command: option<string>, snippet: option<string>})
  | Edit({snippet: option<string>})
  | Delete({snippet: option<string>})
  | List({
      action: listAction,
      snippet: option<string>,
      sort: option<Sort.t>,
      input: option<string>,
      query: option<string>,
      tag: option<string>,
      select: option<string>,
    })
  | Sync({snippet: option<string>, gistId: option<string>})
  | Help(option<command>)
  | Import({action: importAction, snippet: option<string>})
  | Version

let commandToHelpString = command => {
  switch command {
  | Add(_) => "Add a new snippet"
  | Edit(_) => "Edit snippet"
  | Delete(_) => "Delete snippet"
  | List(_) => "Show all snippets"
  | Import(_) => "Import snippets"
  | Help(_) => "Print help"
  | Sync(_) => "Sync snippets"
  | Version => "Print version"
  }
}

let commandToString = command => {
  switch command {
  | Add(_) => "add"
  | Edit(_) => "edit"
  | Delete(_) => "del"
  | List(_) => "list"
  | Import(_) => "import"
  | Help(_) => "help"
  | Sync(_) => "sync"
  | Version => "version"
  }
}

let errorToString = error =>
  switch error {
  | NotFound(s) => `${s->Option.getOr("")} is not found`
  | InvalidOption({name}) => `${name} is invalid option`
  }

let parse = (args: array<string>) => {
  if args->Array.length === 0 {
    Ok(
      List({
        action: Select,
        snippet: None,
        sort: None,
        input: None,
        query: None,
        tag: None,
        select: None,
      }),
    )
  } else {
    args
    ->minimist()
    ->S.parseWith(
      S.union([
        // Default
        S.object(o => {
          ignore(
            o->S.field(
              "_",
              S.union([S.tuple0(.), S.tuple1(. S.literalVariant(String("list"), ()))]),
            ),
          )
          ignore(o->S.field("c", S.literal(Bool(true))))
          List({
            action: Copy,
            snippet: o->S.field("snippet", S.string()->S.option),
            input: o->S.field("input", S.string()->S.option),
            query: o->S.field("query", S.string()->S.option),
            tag: o->S.field("tag", S.string()->S.option),
            select: o->S.field("select", S.string()->S.option),
            sort: o->S.field(
              "s",
              S.union([
                S.literalVariant(String("last-used"), Sort.LastUsed),
                S.literalVariant(String("usage-count"), Sort.UsageCount),
                S.literalVariant(String("name"), Sort.Name),
              ])->S.option,
            ),
          })
        })->S.Object.strict,
        S.object(o => {
          ignore(
            o->S.field(
              "_",
              S.union([S.tuple0(.), S.tuple1(. S.literalVariant(String("list"), ()))]),
            ),
          )
          List({
            action: Select,
            snippet: o->S.field("snippet", S.string()->S.option),
            input: o->S.field("input", S.string()->S.option),
            query: o->S.field("query", S.string()->S.option),
            tag: o->S.field("tag", S.string()->S.option),
            select: o->S.field("select", S.string()->S.option),
            sort: o->S.field(
              "s",
              S.union([
                S.literalVariant(String("last-used"), Sort.LastUsed),
                S.literalVariant(String("usage-count"), Sort.UsageCount),
                S.literalVariant(String("name"), Sort.Name),
              ])->S.option,
            ),
          })
        })->S.Object.strict,
        // Add
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("add"), ()))))
          Add({
            command: o->S.field("c", S.string()->S.option),
            snippet: o->S.field("snippet", S.string()->S.option),
          })
        })->S.Object.strict,
        // Edit
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("edit"), ()))))
          Edit({
            snippet: o->S.field("snippet", S.string()->S.option),
          })
        })->S.Object.strict,
        // Delete
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("del"), ()))))
          Delete({
            snippet: o->S.field("snippet", S.string()->S.option),
          })
        })->S.Object.strict,
        // Import
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("import"), ()))))
          Import({
            action: History(o->S.field("history", S.string())),
            snippet: o->S.field("snippet", S.string()->S.option),
          })
        }),
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("import"), ()))))
          Import({
            action: Pet(o->S.field("pet", S.string())),
            snippet: o->S.field("snippet", S.string()->S.option),
          })
        }),
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("import"), ()))))
          Import({
            action: Navi(o->S.field("navi", S.string())),
            snippet: o->S.field("snippet", S.string()->S.option),
          })
        }),
        // Sync
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("sync"), ()))))
          Sync({
            snippet: o->S.field("snippet", S.string()->S.option),
            gistId: o->S.field("gist-id", S.string()->S.option),
          })
        })->S.Object.strict,
        // add help
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("add"), ()))))
          ignore(o->S.field("h", S.bool()))
          Help(Some(Add({command: None, snippet: None})))
        })->S.Object.strict,
        // edit help
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("edit"), ()))))
          ignore(o->S.field("h", S.bool()))
          Help(Some(Edit({snippet: None})))
        })->S.Object.strict,
        // delete help
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("del"), ()))))
          ignore(o->S.field("h", S.bool()))
          Help(Some(Delete({snippet: None})))
        })->S.Object.strict,
        // list help
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("list"), ()))))
          ignore(o->S.field("h", S.bool()))
          Help(
            Some(
              List({
                action: Select,
                snippet: None,
                sort: None,
                input: None,
                query: None,
                tag: None,
                select: None,
              }),
            ),
          )
        })->S.Object.strict,
        // import help
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("import"), ()))))
          ignore(o->S.field("h", S.bool()))
          Help(Some(Import({action: History(""), snippet: None})))
        })->S.Object.strict,
        // sync help
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("sync"), ()))))
          ignore(o->S.field("h", S.bool()))
          Help(Some(Sync({snippet: None, gistId: None})))
        })->S.Object.strict,
        // help
        S.object(o => {
          ignore(o->S.field("_", S.array(S.string())))
          ignore(o->S.field("h", S.bool()))
          Help(None)
        })->S.Object.strict,
        // version
        S.object(o => {
          ignore(o->S.field("_", S.tuple1(. S.literalVariant(String("version"), ()))))
          Version
        })->S.Object.strict,
      ]),
    )
    ->ResultEx.mapError(e => {
      switch e.code {
      | InvalidUnion(e) =>
        switch e
        ->Array.find(e =>
          switch e.code {
          | ExcessField(_) => true
          | _ => false
          }
        )
        ->Option.map(e => {
          switch e.code {
          | ExcessField(n) => n
          | _ => Exn.raiseError("Unknown error.")
          }
        }) {
        | Some(n) => InvalidOption({name: n})
        | None => NotFound(Some(args->Array.joinWith(" ")))
        }
      | _ => Exn.raiseError("Unknown error.")
      }
    })
  }
}
