let getEnv = key => Process.process->Process.env->Dict.get(key)

let isUnicodeSupported = () => {
  if Process.process->Process.platform !== "win32" {
    getEnv("TERM")->Option.getWithDefault("") !== "linux"
  } else {
    getEnv("CI")->Option.isSome ||
    getEnv("WT_SESSION")->Option.isSome ||
    getEnv("TERMINUS_SUBLIME")->Option.isSome ||
    getEnv("ConEmuTask")->Option.getWithDefault("") === "{cmd::Cmder}" ||
    getEnv("TERM_PROGRAM")->Option.getWithDefault("") === "Terminus-Sublime" ||
    getEnv("TERM_PROGRAM")->Option.getWithDefault("") === "vscode" ||
    getEnv("TERM")->Option.getWithDefault("") === "xterm-256color" ||
    getEnv("TERM")->Option.getWithDefault("") === "alacritty" ||
    getEnv("TERMINAL_EMULATOR")->Option.getWithDefault("") === "JetBrains-JediTerm"
  }
}

module Symbol = {
  let pointer = "❯"
  let success = "✔"
  let square = "□"
}

module StringSymbol = {
  let pointer = ">"
  let success = "√"
  let square = "[]"
}

type t = {
  pointer: string,
  success: string,
  square: string,
}

let symbol = isUnicodeSupported()
  ? {
      pointer: Symbol.pointer,
      success: Symbol.success,
      square: Symbol.square,
    }
  : {
      pointer: StringSymbol.pointer,
      success: StringSymbol.success,
      square: StringSymbol.square,
    }
