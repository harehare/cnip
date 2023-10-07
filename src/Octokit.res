type t
type octokit = {auth: string}
@module("@octokit/rest") @new external createClient: octokit => t = "Octokit"

module Rest = {
  type t

  module Gist = {
    type gistFile = {content: string}

    module CreateGist = {
      type t = {
        public: bool,
        description: string,
        files: Js.Dict.t<gistFile>,
      }
    }

    module GistContent = {
      type get = {gist_id: string}
      type create = {
        public: bool,
        description: string,
        files: Js.Dict.t<gistFile>,
      }

      type update = {
        gist_id: string,
        public: bool,
        description: string,
        files: Js.Dict.t<gistFile>,
      }

      type gistData = {
        id: string,
        public: bool,
        description: string,
        files: Js.Dict.t<gistFile>,
        created_at: string,
        updated_at: string,
      }

      type t = {data: gistData}
    }

    type t

    @get external id: t => string = "id"

    @send external create: (t, GistContent.create) => Promise.t<GistContent.t> = "create"
    @send external update: (t, GistContent.update) => Promise.t<GistContent.t> = "update"
    @send external get: (t, GistContent.get) => Promise.t<GistContent.t> = "get"
  }

  @get external gists: t => Gist.t = "gists"
}

@get external rest: t => Rest.t = "rest"
