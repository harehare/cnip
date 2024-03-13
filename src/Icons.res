type t = {
  clojure: string,
  command: string,
  css: string,
  elm: string,
  error: string,
  elixir: string,
  erlang: string,
  externalCommand: string,
  dart: string,
  docker: string,
  dotnet: string,
  firebase: string,
  git: string,
  golang: string,
  gradle: string,
  haskell: string,
  history: string,
  java: string,
  json: string,
  javaScript: string,
  node: string,
  npm: string,
  nim: string,
  makefile: string,
  markdown: string,
  mysql: string,
  perl: string,
  python: string,
  php: string,
  rails: string,
  react: string,
  ruby: string,
  rust: string,
  sbt: string,
  scala: string,
  shell: string,
  svg: string,
  swift: string,
  typeScript: string,
  vue: string,
  webpack: string,
  yaml: string,
  zig: string,
}

let icons = Env.showIcons
  ? {
      clojure: "\u{e768}",
      command: "\u{f121}",
      css: "\u{e749}",
      elm: "\u{e62c}",
      error: "\u{f071}",
      elixir: "\u{e62d}",
      erlang: "\u{e7b1}",
      externalCommand: "\u{EB14}",
      dart: "\u{e798}",
      docker: "\u{f308}",
      dotnet: "\u{e77f}",
      firebase: "\u{e657}",
      git: "\u{e702}",
      golang: "\u{e626}",
      gradle: "\u{E660}",
      haskell: "\u{e61f}",
      history: "\u{f464}",
      java: "\u{e738}",
      json: "\u{e60b}",
      javaScript: "\u{e74e}",
      node: "\u{e719}",
      npm: "\u{e71e}",
      nim: "\u{e677}",
      makefile: "\u{eb99}",
      markdown: "\u{e73e}",
      mysql: "\u{e704}",
      perl: "\u{fbe4}",
      python: "\u{e73c}",
      php: "\u{e608}",
      rails: "\u{e604}",
      react: "\u{e7ba}",
      ruby: "\u{f219}",
      rust: "\u{e7a8}",
      sbt: "\u{E68D}",
      scala: "\u{e737}",
      shell: "\u{e795}",
      svg: "\u{e698}",
      swift: "\u{e755}",
      typeScript: "\u{fbe4}",
      vue: "\u{e6a0}",
      webpack: "\u{e6a3}",
      yaml: "\u{e6a8}",
      zig: "\u{e6a9}",
    }
  : {
      clojure: "",
      command: "",
      css: "",
      elm: "",
      error: "",
      elixir: "",
      erlang: "",
      externalCommand: "",
      dart: "",
      docker: "",
      dotnet: "",
      firebase: "",
      git: "",
      golang: "",
      gradle: "",
      haskell: "",
      history: "",
      java: "",
      json: "",
      javaScript: "",
      node: "",
      npm: "",
      nim: "",
      makefile: "",
      markdown: "",
      mysql: "",
      perl: "",
      python: "",
      php: "",
      rails: "",
      react: "",
      ruby: "",
      rust: "",
      sbt: "",
      scala: "",
      shell: "",
      svg: "",
      swift: "",
      typeScript: "",
      vue: "",
      webpack: "",
      yaml: "",
      zig: "",
    }

let getIcon = (name: string) =>
  switch name->String.toLowerCase {
  | "bash" => icons.shell
  | "clojure" => icons.clojure
  | "css" => icons.css
  | "c#" => icons.dotnet
  | "elm" => icons.elm
  | "elixir" => icons.elixir
  | "erlang" => icons.erlang
  | "dart" => icons.dart
  | "docker" => icons.docker
  | "dotnet" => icons.dotnet
  | "firebase" => icons.firebase
  | "fish" => icons.shell
  | "flutter" => icons.dart
  | "git" => icons.git
  | "go" => icons.golang
  | "golang" => icons.golang
  | "gradle" => icons.gradle
  | "haskell" => icons.haskell
  | "java" => icons.java
  | "json" => icons.json
  | "javascript" => icons.javaScript
  | "js" => icons.javaScript
  | "node" => icons.node
  | "node.js" => icons.node
  | "npm" => icons.npm
  | "nim" => icons.nim
  | "makefile" => icons.makefile
  | "markdown" => icons.markdown
  | "mysql" => icons.mysql
  | "perl" => icons.perl
  | "python" => icons.python
  | "php" => icons.php
  | "rails" => icons.rails
  | "react" => icons.react
  | "ruby" => icons.ruby
  | "rust" => icons.rust
  | "sbt" => icons.sbt
  | "scala" => icons.scala
  | "shell" => icons.shell
  | "svg" => icons.svg
  | "swift" => icons.swift
  | "ts" => icons.typeScript
  | "typescript" => icons.typeScript
  | "vue" => icons.vue
  | "webpack" => icons.webpack
  | "yaml" => icons.yaml
  | "zig" => icons.zig
  | "zsh" => icons.shell
  | _ => ""
  }
