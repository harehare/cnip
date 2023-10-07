module ResultEx = {
  let mapError = (result, fn) =>
    switch result {
    | Ok(_) as ok => ok
    | Error(err) => Error(fn(err))
    }
}

module InkEx = {
  type renderOptions

  @module("ink")
  external render_: (React.element, renderOptions) => Ink.renderInstance = "render"

  @obj
  external renderOptions_: (
    ~debug: bool=?,
    ~exitOnCtrlC: bool=?,
    ~patchConsole: bool=?,
    ~stdout: Fs.WriteStream.t=?,
    ~stdin: Fs.WriteStream.t=?,
    unit,
  ) => renderOptions = ""

  let render = (element, ~debug=?, ~exitOnCtrlC=?, ~patchConsole=?, ~stdout=?, ~stdin=?, ()) =>
    render_(element, renderOptions_(~debug?, ~exitOnCtrlC?, ~patchConsole?, ~stdout?, ~stdin?, ()))
}

module IO = {
  let stdout = %raw(`
function getStdout() {
  const fs = require('fs');
  const tty = require('tty');
  return new tty.WriteStream(fs.openSync('/dev/tty', 'w'));
}
`)
  let stdin = %raw(`
function getStdin() {
  const fs = require('fs');
  const tty = require('tty');
  const ttyIn = new tty.ReadStream(fs.openSync('/dev/tty'));
  ttyIn.setRawMode(true);
  return ttyIn;
}
`)
}

module Dimension = {
  let windowSize = %raw(`
function windowSize() {
  const fs = require('fs');
  const tty = require('tty');
  return new tty.WriteStream(fs.openSync('/dev/tty', 'w')).getWindowSize();
}
`)
}

module Tuple = {
  let first = ((f, _)) => f
  let second = ((_, s)) => s
}

module Console = {
  let error = s => `\x1b[31m${s}\x1b[0m`
  let success = s => `\x1b[32m${s}\x1b[0m`
}

module File = {
  let readAsync = (filePath: string, onReadFile: string => unit) => {
    Fs.PromiseAPI.open_(~path=#Str(filePath), ~flags=Fs.Flag.read)->Promise.then(fd => {
      fd
      ->Fs.FileHandle.readFile
      ->Promise.then(buf => {
        onReadFile(buf->Buffer.toStringWithEncoding(StringEncoding.utf8))
        Promise.resolve()
      })
      ->Promise.catch(e => {
        fd->Fs.FileHandle.close->ignore
        Promise.reject(e)
      })
      ->ignore
      fd->Fs.FileHandle.close->ignore
      Promise.resolve()
    })
  }

  let writeAsync = (filePath: string, text: string) => {
    Fs.PromiseAPI.open_(~path=#Str(filePath), ~flags=Fs.Flag.write)->Promise.then(fd => {
      fd->Fs.FileHandle.writeFile(text->Buffer.fromString)
    })
  }
}

module DateEx = {
  let toString = (date: Date.t) => {
    `${date->Date.getFullYear->Int.toString}${(date->Date.getMonth + 1)
      ->Int.toString
      ->String.padStart(2, "0")}${date->Date.getDate->Int.toString->String.padStart(2, "0")}${date
      ->Date.getHours
      ->Int.toString
      ->String.padStart(2, "0")}${date->Date.getMinutes->Int.toString->String.padStart(2, "0")}`
  }
}
