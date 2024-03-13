open Jest

let () = describe("parse params", () => {
  open ExpectJs

  test("has default value", () =>
    expect("command <test=value>"->Command.params)->toEqual([
      {
        name: "test",
        defaultValue: Some("value"),
      },
    ])
  )
})
