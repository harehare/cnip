open Ink

module Spinner = InkCommunity_Spinner

@react.component
let make = (~snippet: option<string>, ~gistId: option<string>) => {
  let (action, gistId, error) = CommandHook.useSyncCommands(snippet, ~gistId)

  switch (action, gistId, error) {
  | (Some(action), Some(gistId), _) =>
    <Box flexDirection=#column>
      <TextView selected={true}> {`Gist ID: ${gistId}`->React.string} </TextView>
      <TextView>
        {`${switch action {
          | Config.Sync.Download => "Download success."
          | Config.Sync.Upload => "Upload success."
          | Config.Sync.NoOp => "Already up-to-date."
          }} `->React.string}
      </TextView>
    </Box>
  | (_, None, Some(error)) => <TextView error={true}> {error->React.string} </TextView>
  | _ =>
    <Box>
      <Spinner type_=#dots />
      <TextView> {" Syncing..."->React.string} </TextView>
    </Box>
  }
}
