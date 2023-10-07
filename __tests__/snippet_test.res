open Jest

let () = {
  describe("parse cli", () => {
    open ExpectJs

    test("parse add", () =>
      expect(Cli.parse(["add", "-c", "command", "--snippet", "snippet.json"]))->toEqual(
        Ok(Cli.Add({command: Some("command"), snippet: Some("snippet.json")})),
      )
    )

    test("parse edit", () =>
      expect(Cli.parse(["edit", "--snippet", "snippet.json"]))->toEqual(
        Ok(Cli.Edit({snippet: Some("snippet.json")})),
      )
    )

    test("parse list", () =>
      expect(Cli.parse(["list", "-c", "--snippet", "snippet.json"]))->toEqual(
        Ok(
          Cli.List({
            action: Cli.Copy,
            snippet: Some("snippet.json"),
            sort: None,
            input: None,
            query: None,
            tag: None,
            select: None,
          }),
        ),
      )
    )

    test("parse del", () =>
      expect(Cli.parse(["del", "--snippet", "snippet.json"]))->toEqual(
        Ok(Cli.Delete({snippet: Some("snippet.json")})),
      )
    )

    test("parse import pet", () =>
      expect(
        Cli.parse(["import", "--pet", "petConfig.json", "--snippet", "snippet.json"]),
      )->toEqual(Ok(Cli.Import({action: Cli.Pet("petConfig.json"), snippet: Some("snippet.json")})))
    )

    test("parse import history", () =>
      expect(Cli.parse(["import", "--history", "histfile", "--snippet", "snippet.json"]))->toEqual(
        Ok(Cli.Import({action: Cli.History("histfile"), snippet: Some("snippet.json")})),
      )
    )

    test("parse help", () => expect(Cli.parse(["-h"]))->toEqual(Ok(Cli.Help(None))))
    test("parse add help", () =>
      expect(Cli.parse(["add", "-h"]))->toEqual(
        Ok(Cli.Help(Some(Cli.Add({command: None, snippet: None})))),
      )
    )
    test("parse edit help", () =>
      expect(Cli.parse(["edit", "-h"]))->toEqual(Ok(Cli.Help(Some(Cli.Edit({snippet: None})))))
    )
    test("parse list help", () =>
      expect(Cli.parse(["list", "-h"]))->toEqual(
        Ok(
          Cli.Help(
            Some(
              Cli.List({
                action: Cli.Select,
                snippet: None,
                sort: None,
                input: None,
                query: None,
                tag: None,
                select: None,
              }),
            ),
          ),
        ),
      )
    )
    test("parse del help", () =>
      expect(Cli.parse(["del", "-h"]))->toEqual(Ok(Cli.Help(Some(Cli.Delete({snippet: None})))))
    )
    test("parse version", () => expect(Cli.parse(["version"]))->toEqual(Ok(Cli.Version)))

    test("command not found", () =>
      expect(Cli.parse(["test"]))->toEqual(Error(Cli.NotFound(Some("test"))))
    )
    test("invalid option", () =>
      expect(Cli.parse(["list", "-b"]))->toEqual(Error(Cli.InvalidOption({name: "b"})))
    )
  })
}
