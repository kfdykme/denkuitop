__webpack_require__.r(__webpack_exports__);/* harmony import */ var monaco_editor__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! monaco-editor */ \"../node_modules/monaco-editor/esm/vs/editor/editor.main.js\");


self.MonacoEnvironment = {
    getWorkerUrl: function (moduleId, label) {
        if (label === 'json') {
            return './json.worker.bundle.js';
        }
        if (label === 'css' || label === 'scss' || label === 'less') {
            return './css.worker.bundle.js';
        }
        if (label === 'html' || label === 'handlebars' || label === 'razor') {
            return './html.worker.bundle.js';
        }
        if (label === 'typescript' || label === 'javascript') {
            return './ts.worker.bundle.js';
        }
        return './editor.worker.bundle.js';
    }
};
const editorContainerHolder = document.getElementById('editor_container_holder')




const defaultEditorOption = {
    value: ['defaultEditorOption'].join('\
'),
    language: 'javascript'
}

const initDenkui = () => {
    if (window.denkui === undefined) {
        window.denkui = {}
    }
}

const denkSetKeyValue = (key, value) => {
    initDenkui()
    window.denkui[key] = value
}

const denkGetKey = (key) => {
    initDenkui()
    return window.denkui[key]
}

window.denkGetKey = (name) => {
    const res = denkGetKey(name)
    console.info('window.denkGetKey ', name, res)
    return res
}
window.denkSetKeyValue = (name, value) => {
    console.info('window.denkSetKeyValue', name, value)
    denkSetKeyValue(name, value)
}

// window.denkSetKeyValue('editor', codeEditor)
window.denkSetKeyValue('monaco', monaco_editor__WEBPACK_IMPORTED_MODULE_0__)
window.denkAllKeys = () => {
    initDenkui()
    const res = []
    for(let x in window.denkui) {
        res.push(x)
    }
    return res
}

const sendIpcMessage = (data) => {
    try {
        window.webkit.messageHandlers.ipcRender.postMessage(data)
    } catch(err) {
        console.error(err)
    }
}

const prepareInjectJs = async () => {
    if (denkGetKey('prepareInjectJsResolve')) {
        return Promise.reject('already loading')
    }
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            reject(new Error('timeout prepareInjectJs'))
        }, 1000);
        denkSetKeyValue('prepareInjectJsResolve', resolve);
        sendIpcMessage({
            name: 'prepareInjectJs'
        })
    })
}

window.denkSetKeyValue('sendIpcMessage', sendIpcMessage)


window.onload = () => {
    console.info('editor window onload()')
    // window.

    new Promise((resolve, reject) => {
        console.info('wait inject js')
        // window.denkSetKeyValue('windowOnloadResolve', resolve)
        resolve()
    }).then(res => {

    }).finally(() => {
        prepareInjectJs()
    })
}

console.info('version 111111')


console.info(\"DENKUI_EDITOR_INJECT start\");

for (let x in window) {
  if (x.startsWith(\"denk\")) {
    console.info(x);
  }
}
// console.info(window)
// [\"monaco\", \"clearEditor\", \"createEditorFunc\", \"sendIpcMessage\", \"windowOnloadResolve\", \"prepareInjectJsResolve\"]
console.info(window.denkAllKeys());

const getOption = (filePath = \"\") => {
  let myOption = {};
  if (filePath.endsWith(\".js\")) {
    myOption.language = \"javascript\";
  }


  if (filePath.endsWith(\".md\")) {
  myOption.theme = \"myCoolTheme\";
    myOption.language = \"markdown\";
  }

  return {
    language: \"javascript\",
    ...myOption,
  };
};

const getEditor = (filePath = \"\") => {
  const id = \"editor\" + filePath;
  let editor = window.denkGetKey(id);
  let editorView = document.getElementById(id);
  if (!editor) {
    const holder = document.getElementById(\"editor_container_holder\");
    if (!holder) {
      throw new Error(\"error\");
    }
    if (!editorView) {
      editorView = document.createElement(\"div\");
      editorView.style.width = \"100%\";
      editorView.style.height = \"100%\";
      editorView.id = id;
      editorView.className = \"editor_view\";
      holder.appendChild(editorView);
    }
    const monaco = window.denkGetKey(\"monaco\");
    editor = monaco.editor.create(editorView, getOption(filePath));
    window.denkSetKeyValue(id, editor);

    const onEditorCreate = window.denkGetKey('onEditorCreate')
    if (onEditorCreate && typeof onEditorCreate === 'function') {
      onEditorCreate(editor)
    }

  }
   for (
      let x = 0;
      x < document.getElementsByClassName(\"editor_view\").length;
      x++
    ) {
      document.getElementsByClassName(\"editor_view\")[x].style.display =
        \"none\";
    }
  editorView.style.display = \"\";

  return editor;
};

window.denkSetKeyValue(\"insertIntoEditor\", (content, filePath) => {
    console.info('insertIntoEditor', content, filePath)
  getEditor(filePath).setValue(content);
});



//# sourceURL=webpack://browser-esm-webpack/./index.js?