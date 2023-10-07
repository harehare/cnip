open Ink

module TextInput = InkCommunity_TextInput

@react.component
let make = (~prompt: string, ~color: Ink_Components_Text.Color.t, ~icon: string, ~text: string) => {
  <Box>
    <Text color={color}> {`${prompt} ${icon} ${text}`->React.string} </Text>
  </Box>
}
