open Ink

@react.component
let make = (~children: React.element) =>
  <Box>
    <Text bold={true} color=#magenta> children </Text>
  </Box>
