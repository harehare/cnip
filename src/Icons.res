type t = {
  history: string,
  command: string,
  externalCommand: string,
  clojure: string,
  css: string,
  elm: string,
  elixir: string,
  erlang: string,
  docker: string,
  dotnet: string,
  firebase: string,
  git: string,
  golang: string,
  gradle: string,
  haskell: string,
  java: string,
  json: string,
  javaScript: string,
  node: string,
  npm: string,
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
  swift: string,
  typeScript: string,
  vue: string,
  webpack: string,
  yaml: string,
  zig: string,
}

let icons = Env.showIcons
  ? {
      history: "\u{f464}",
      command: "\u{f44f}",
      externalCommand: "\u{EB14}",
      clojure: "\u{e768}",
      css: "\u{e749}",
      elm: "\u{e62c}",
      elixir: "\u{e62d}",
      erlang: "\u{e7b1}",
      docker: "\u{f308}",
      dotnet: "\u{e77f}",
      firebase: "\u{e657}",
      git: "\u{e702}",
      golang: "\u{e626}",
      gradle: "\u{E660}",
      haskell: "\u{e61f}",
      java: "\u{e738}",
      json: "\u{e60b}",
      javaScript: "\u{e74e}",
      node: "\u{e719}",
      npm: "\u{e71e}",
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
      swift: "\u{e755}",
      typeScript: "\u{fbe4}",
      vue: "\u{e6a0}",
      webpack: "\u{e6a3}",
      yaml: "\u{e6a8}",
      zig: "\u{e6a9}",
    }
  : {
      history: "",
      command: "",
      externalCommand: "",
      clojure: "",
      css: "",
      elm: "",
      elixir: "",
      erlang: "",
      docker: "",
      dotnet: "",
      firebase: "",
      git: "",
      golang: "",
      gradle: "",
      haskell: "",
      java: "",
      json: "",
      javaScript: "",
      node: "",
      npm: "",
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
  | "docker" => icons.docker
  | "dotnet" => icons.dotnet
  | "firebase" => icons.firebase
  | "fish" => icons.shell
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
