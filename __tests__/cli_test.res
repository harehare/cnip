open Jest

let () = {
  describe("imprt navi", () => {
    open ExpectJs

    test("parse", () =>
      expect(
        Snippet.Navi.parse(`
% tag1, tag2

# test
test command

# launch Rails server
bin/rails server --port=3001

$ test2

; test3
`)->Array.map(c => {...c, id: ""}),
      )->toEqual(
        [
          Command.create(
            ~command="test command",
            ~description=Some("test"),
            ~tag=["tag1", "tag2"],
            ~alias=None,
          ),
          Command.create(
            ~command="bin/rails server --port=3001",
            ~description=Some("launch Rails server"),
            ~tag=["tag1", "tag2"],
            ~alias=None,
          ),
          Command.create(~command="test2", ~description=None, ~tag=["tag1", "tag2"], ~alias=None),
        ]->Array.map(c => {...c, id: ""}),
      )
    )
  })
}
