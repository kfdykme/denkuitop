import {basicSetup} from "codemirror"
import {javascript} from "@codemirror/lang-javascript"
import {EditorView, keymap} from "@codemirror/view"
import {indentWithTab} from "@codemirror/commands"

let editor = new EditorView({
  extensions: [basicSetup, javascript(), keymap.of([indentWithTab])],
  parent: document.body
})

editor.dispatch({
  changes: {from: 0, insert: "#!/usr/bin/env node\n"}
})