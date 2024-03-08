let getEnv = key => Process.process->Process.env->Dict.get(key)

let isUnicodeSupported = () => {
  if Process.process->Process.platform !== "win32" {
    getEnv("TERM")->Option.getOr("") !== "linux"
  } else {
    getEnv("CI")->Option.isSome ||
    getEnv("WT_SESSION")->Option.isSome ||
    getEnv("TERMINUS_SUBLIME")->Option.isSome ||
    getEnv("ConEmuTask")->Option.getOr("") === "{cmd::Cmder}" ||
    getEnv("TERM_PROGRAM")->Option.getOr("") === "Terminus-Sublime" ||
    getEnv("TERM_PROGRAM")->Option.getOr("") === "vscode" ||
    getEnv("TERM")->Option.getOr("") === "xterm-256color" ||
    getEnv("TERM")->Option.getOr("") === "alacritty" ||
    getEnv("TERMINAL_EMULATOR")->Option.getOr("") === "JetBrains-JediTerm"
  }
}

module Symbol = {
  let pointer = "❯"
  let success = "✔"
  let square = "□"
  let left = "←"
  let right = "→"
  let separator = "│"
}

module StringSymbol = {
  let pointer = ">"
  let success = "√"
  let square = "[]"
  let left = "<-"
  let right = "->"
  let separator = "|"
}

type t = {
  pointer: string,
  success: string,
  square: string,
  left: string,
  right: string,
  separator: string,
}

let symbol = isUnicodeSupported()
  ? {
      pointer: Symbol.pointer,
      success: Symbol.success,
      square: Symbol.square,
      left: Symbol.left,
      right: Symbol.right,
      separator: Symbol.separator,
    }
  : {
      pointer: StringSymbol.pointer,
      success: StringSymbol.success,
      square: StringSymbol.square,
      left: StringSymbol.left,
      right: StringSymbol.right,
      separator: StringSymbol.separator,
    }
