let highlightColor = Process.process->Process.env->Dict.get("CNIP_HIGHLIGHT_COLOR")
let errorColor = Process.process->Process.env->Dict.get("CNIP_ERROR_COLOR")
let promptColor = Process.process->Process.env->Dict.get("CNIP_PROMPT_COLOR")
let textColor = Process.process->Process.env->Dict.get("CNIP_TEXT_COLOR")
let descriptionColor = Process.process->Process.env->Dict.get("CNIP_DESCRIPTION_COLOR")
let selectedColor = Process.process->Process.env->Dict.get("CNIP_SELECTED_COLOR")
let selectedTabColor = Process.process->Process.env->Dict.get("CNIP_SELECTED_TAB_COLOR")
let tabColor = Process.process->Process.env->Dict.get("CNIP_TAB_COLOR")
let pointerColor = Process.process->Process.env->Dict.get("CNIP_POINTER_COLOR")
let borderColor = Process.process->Process.env->Dict.get("CNIP_BORDER_COLOR")
let currentLineColor = Process.process->Process.env->Dict.get("CNIP_CURRENT_LINE_COLOR")
let showIcons = Process.process->Process.env->Dict.get("CNIP_SHOW_ICONS")->Option.getOr("0") == "1"

let showTips = Process.process->Process.env->Dict.get("CNIP_SHOW_TIPS")
let gistId = Process.process->Process.env->Dict.get("CNIP_GIST_ID")

let githubAccessToken =
  Process.process->Process.env->Dict.get("CNIP_GITHUB_GIST_ACCESS_TOKEN")->Option.getExn
