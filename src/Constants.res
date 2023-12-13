let configDir = `${Process.process
  ->Process.env
  ->Dict.get(Process.process->Process.platform == "win32" ? "USERPROFILE" : "HOME")
  ->Option.getWithDefault("")}/.config/cnip`
