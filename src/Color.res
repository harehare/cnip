type t = Ink.Text.Color.t

let highlight = _ => Env.highlightColor()->Option.getOr("#6E4BEC")->#hex
let currentLine = _ => Env.currentLineColor()->Option.getOr("#6E4BEC")->#hex
let prompt = _ => Env.promptColor()->Option.getOr("#6E4BEC")->#hex
let text = _ => Env.textColor()->Option.getOr("#D4D7DC")->#hex
let description = _ => Env.textColor()->Option.getOr("#3BBFBF")->#hex
let selected = _ => Env.selectedColor()->Option.getOr("#008000")->#hex
let selectedTab = _ => Env.selectedTabColor()->Option.getOr("#6E4BEC")->#hex
let tab = _ => Env.tabColor()->Option.getOr("#A9A9A9")->#hex
let pointer = _ => Env.pointerColor()->Option.getOr("#6E4BEC")->#hex
let border = _ => Env.borderColor()->Option.getOr("#ADADAD")->#hex
let error = _ => Env.errorColor()->Option.getOr("#FF4500")->#hex
