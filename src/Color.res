type t = Ink.Text.Color.t

let highlight = _ => Env.highlightColor()->Option.getWithDefault("#6E4BEC")->#hex
let currentLine = _ => Env.currentLineColor()->Option.getWithDefault("#6E4BEC")->#hex
let prompt = _ => Env.promptColor()->Option.getWithDefault("#6E4BEC")->#hex
let text = _ => Env.textColor()->Option.getWithDefault("#D4D7DC")->#hex
let description = _ => Env.textColor()->Option.getWithDefault("#3BBFBF")->#hex
let selected = _ => Env.selectedColor()->Option.getWithDefault("#008000")->#hex
let selectedTab = _ => Env.selectedTabColor()->Option.getWithDefault("#6E4BEC")->#hex
let tab = _ => Env.tabColor()->Option.getWithDefault("#A9A9A9")->#hex
let pointer = _ => Env.pointerColor()->Option.getWithDefault("#6E4BEC")->#hex
let border = _ => Env.borderColor()->Option.getWithDefault("#ADADAD")->#hex
let error = _ => Env.errorColor()->Option.getWithDefault("#FF4500")->#hex
