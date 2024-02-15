open Ink
open Modules

module ClearEventEmitter = {
  include EventEmitter.Make()
}

let clearEventEmitter = ClearEventEmitter.make()
let clearEvent = Event.fromString("clear")

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

try {
  Cli.parse(Process.process->Process.argv->Array.sliceToEnd(~start=2))
  ->Result.map(command => {
    let {waitUntilExit, clear} = InkEx.render(
      <Main
        cliCommand={command}
        clear={_ => {
          clearEventEmitter->ClearEventEmitter.emit(clearEvent, ())->ignore
        }}
      />,
      ~exitOnCtrlC=true,
      ~patchConsole=false,
      ~stdout=stdout(),
      ~stdin=stdin(),
      (),
    )
    clearEventEmitter
    ->ClearEventEmitter.on(clearEvent, () => {
      clear()
    })
    ->ignore

    waitUntilExit()
    ->Promise.then(_ => {
      Process.process->Process.exit()->ignore
      Promise.resolve()
    })
    ->ignore
  })
  ->ResultEx.mapError(error => {
    Modules.Console.error(error->Cli.errorToString)->Js.Console.error
  })
  ->ignore
} catch {
| Exception.NotFound(m) => Modules.Console.error(m)->Js.Console.error
}

%%raw(`
const updateNotifier = require('update-notifier');
const packageJson = require('../package.json');

console.log(packageJson);

updateNotifier({pkg: packageJson}).notify();
`)
