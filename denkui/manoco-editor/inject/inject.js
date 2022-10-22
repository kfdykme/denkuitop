console.info("DENKUI_EDITOR_INJECT start");


// 规范定义:
// filePath 传入的文件路径 mac /Users/xxxxxx, win C://xxxx
// id editor_${filePath}


window.denkSetKeyValue('getOS', () => {
    return window.navigator.userAgent.indexOf('Mac') !== -1 ? 'MAC' : 'WIN'
})
const checkFilePathVaild = (filePath) => {
    let res = false;
    if (window.denkGetKey('getOS')() === 'MAC') {
        res = filePath.startsWith('/Users')
    } else {
        res = /^([a-z]|[A-Z]):/.exec(filePath) !== null
    }
    if (!res) {
        throw new Error('funcGetIdByFilePath error filePath not vaild ' + filePath)
    }
}
window.denkSetKeyValue('funcCheckFilePathVaild', checkFilePathVaild)


const checkIdVaild = (filePath) => {
    let res = false;
    if (window.denkGetKey('getOS')() === 'MAC') {
        res = filePath.startsWith('editor_/Users')
    } else {
        res = /^editor_([a-z]|[A-Z]):/.exec(filePath) !== null
    }
    if (!res) {
        throw new Error('checkIdVaild error checkIdVaild not vaild ' + filePath)
    }
}
window.denkSetKeyValue('funcCheckIdVaild', checkIdVaild)

window.denkSetKeyValue('funcGetIdByFilePath', (filePath) => {
    while (filePath.startsWith('_')) {
        filePath = filePath.substring(1)
    }
    window.denkGetKey('funcCheckFilePathVaild')(filePath)

    return 'editor_' + filePath
})

window.denkSetKeyValue('funcGetFilePathById', (id) => {
    window.denkGetKey('funcCheckIdVaild')(id)
    return id.replace(/^editor_/, '')
})


window.denkSetKeyValue('getEditorByFilePath', (filePath) => {

    const id = window.denkGetKey('funcGetIdByFilePath')(filePath)
    let editor = window.denkGetKey(id)
    console.info('getEditorByFilePath editor', editor)
    if (!editor) {
        editor = window.denkGetKey('editor' + 'new')
        console.info('getEditorByFilePath editor from new', editor)
    }

    if (editor) {
        console.error('editor is null', window.denkAllKeys())
    } else {
        window.denkSetKeyValue(id, editor)
    }

    return editor
})



const getOption = (filePath = "") => {
    let myOption = {
        unicodeHighlight: {
            ambiguousCharacters: false,
        },
        scrollbar: { 
            vertical: 'hidden', 
            horizontal: 'hidden', 
        }
    };
    if (filePath.endsWith(".js")) {
        myOption.language = "javascript";
        myOption.theme = 'vs'
    }


    if (filePath.endsWith(".md")) {
        myOption.theme = "denk";
        myOption.language = "kfmarkdown";
    }

    return {
        language: "javascript",
        automaticLayout: true,
        lineNumbers: "off",
        wordWrap: "on",
        ...myOption,
    };
};

const getEditor = (filePath = "") => {
    const id = window.denkGetKey('funcGetIdByFilePath')(filePath)
    let editor = window.denkGetKey(id);
    let editorView = document.getElementById(id);
    if (!editor) {
        const holder = document.getElementById("editor_container_holder");
        if (!holder) {
            throw new Error("error");
        }
        if (!editorView) {
            editorView = document.createElement("div");
            editorView.style.width = "50%";
            editorView.style.height = "100%";
            editorView.id = id;
            editorView.className = "editor_view";
            editorView.ondblclick = () => {
                let func = window.denkGetKey('funcMarkdownPreview')
                if (func) {
                    func()
                }
            }
            holder.appendChild(editorView);
        }
        const monaco = window.denkGetKey("monaco");
        editor = monaco.editor.create(editorView, getOption(filePath));
        editor.getModel().onDidChangeContent((e) => {
            let func = window.denkGetKey('funcMarkdownPreview')
            if (func) {
                func()
            }
            const value = e.changes[0].text
            console.info('kfdebug onDidChangeContent ' + value)
            if (value === e.eol) {
                const content = editor.getModel().getLineContent(e.changes[0].range.startLineNumber)
                // console.info(content)
                if (/^> .+/.exec(content)) {
                    var selection = editor.getSelection();
                    var range = new monaco.Range(selection.startLineNumber+1, selection.startColumn, selection.endLineNumber+1, selection.endColumn);
                    var id = { major: 1, minor: 1 };             
                    var text = "> ";
                    var op = {identifier: id, range: range, text: text, forceMoveMarkers: true};
                    
                    editor.executeEdits("my-source->", [op], [selection]);

                    var pos = new monaco.Position(range.startLineNumber , text.length +1)
                    setTimeout(() => {
                        editor.setPosition(pos)
                    },0)
                }
                if (/^> $/.exec(content)) {
                    var selection = editor.getSelection();
                    var range = new monaco.Range(selection.startLineNumber, 0, selection.endLineNumber, selection.endColumn);
                    var id = { major: 1, minor: 1 };             
                    var text = "";
                    var op = {identifier: id, range: range, text: text, forceMoveMarkers: true};
                    
                    editor.executeEdits("my-source->-emp", [op], [selection]);
        
                    var pos = new monaco.Position(range.startLineNumber ,0)
                    setTimeout(() => {
                        editor.setPosition(pos)
                    },0)
                }
                if (/^- $/.exec(content)) {
                    var selection = editor.getSelection();
                    var range = new monaco.Range(selection.startLineNumber, 0, selection.endLineNumber, selection.endColumn);
                    var id = { major: 1, minor: 1 };             
                    var text = "";
                    var op = {identifier: id, range: range, text: text, forceMoveMarkers: true};
                    
                    editor.executeEdits("my-source---emp", [op], [selection]);
        
                    var pos = new monaco.Position(range.startLineNumber ,0)
                    setTimeout(() => {
                        editor.setPosition(pos)
                    },0)
                }
                if (/^- .+/.exec(content)) {
                    var selection = editor.getSelection();
                    var range = new monaco.Range(selection.startLineNumber + 1, selection.startColumn, selection.endLineNumber + 1, selection.endColumn);
                    var id = { major: 1, minor: 1 };             
                    var text = "- ";
                    var op = {identifier: id, range: range, text: text, forceMoveMarkers: true};
                    
                    editor.executeEdits("my-source--", [op], [selection]);

                    var pos = new monaco.Position(range.startLineNumber, text.length + 1)
                    setTimeout(() => {
                        editor.setPosition(pos)
                    },0)
                }
            }     
          });
        window.denkSetKeyValue(id, editor);

        const onEditorCreate = window.denkGetKey('onEditorCreate')
        if (onEditorCreate && typeof onEditorCreate === 'function') {
            onEditorCreate(editor)
        }

    }
    for (
        let x = 0;
        x < document.getElementsByClassName("editor_view").length;
        x++
    ) {
        document.getElementsByClassName("editor_view")[x].style.display =
            "none";
    }
    editorView.style.display = "";

    return editor;
};

denkSetKeyValue('getEditorFunc', getEditor)

let styleNode = document.createElement('style')
styleNode.innerHTML = `
    .header_btn_close_btn:hover {
        background: #aaaaaa;
        border-radius: 3px;
    }

    .header_btn_close_btn_dark:hover {
        background: #efefef;
        border-radius: 3px;
    }

    #editor_header_bar {
        position: fixed;
        z-index: 2;
    }

    #editor_container_holder {
        margin-top: 40px;
        display:flex;
    }

    body {
        display:flex;
        flex-direction: column;
    }
    html {
        overflow-y: hidden;
    }
    .markdown_preview {
        // margin: 0 50%;
    }
    .editor_view {
        display: flex;
    }
`
window.denkSetKeyValue('styleNode', styleNode)

window.denkSetKeyValue("insertIntoEditor", (content, filePath, force) => {
    console.info('insertIntoEditor', filePath)
    const targetEditor = window.denkGetKey('getEditorFunc')(filePath)
    if (targetEditor.getValue().trim() === "" || filePath.endsWith('.config.md'))
        targetEditor.setValue(content)
    if (force) {
        targetEditor.setValue(content)
    }

    window.denkGetKey('funcUpdateHeader')()
    let func = window.denkGetKey('funcMarkdownPreview')
    if (func) {
        func()
    }
});


{
    const windowOnloadResolve = window.denkGetKey("windowOnloadResolve");

    if (windowOnloadResolve) {
        windowOnloadResolve();
    }

    const monaco = window.denkGetKey("monaco");
    // Register a new language
    monaco.languages.register({ id: "kfmarkdown" });

    // folder

    monaco.languages.registerFoldingRangeProvider('kfmarkdown', {
        provideFoldingRanges: function (model, context, token) {
            const lines = model.getLinesContent();

            const res = [];

            const FoldingHeaderPattern = /^#+/
            const FoldingHeaderListItemPattern = /^- /
            let lastListItemLineIndex = -1
            let lastListItemStatus = false
            let lastLineIndex = -1
            lines.forEach((line, lineIndex) => {
                let regRes = FoldingHeaderPattern.exec(line);
                if (regRes != null) {
                    if (lastLineIndex === -1) {
                        lastLineIndex = lineIndex
                    } else {
                        res.push({
                            start: lastLineIndex + 1,
                            end: lineIndex,
                            kind: monaco.languages.FoldingRangeKind.Comment
                        })
                        lastLineIndex = lineIndex
                    }
                }


                if (lastListItemStatus) {
                    if (line.indexOf('- ') === -1) {
                        lastListItemStatus = false;
                        res.push({
                            start: lastListItemLineIndex + 1, // index 和 行数的开始值不一样
                            end: lineIndex,
                            kind: monaco.languages.FoldingRangeKind.Comment
                        })
                    }
                }

                regRes = FoldingHeaderListItemPattern.exec(line)
                if (regRes != null) {
                    if (lastListItemLineIndex === -1 || !lastListItemStatus) {
                        lastListItemLineIndex = lineIndex
                    } 
                    lastListItemStatus = true
                }
            })
            if (lastLineIndex !== -1) {
                res.push({
                    start: lastLineIndex + 1,
                    end: lines.length,
                    kind: monaco.languages.FoldingRangeKind.Comment
                })
            }

            return res;
        }
    });


    const legend = {
        tokenTypes: [
            'comment',
            'string',
            'keyword',
            'number',
            'regexp',
            'operator',
            'namespace',
            'type',
            'struct',
            'class',
            'interface',
            'enum',
            'typeParameter',
            'function',
            'member',
            'macro',
            'variable',
            'parameter',
            'property',
            'label'
        ],
        tokenModifiers: [
            'declaration',
            'documentation',
            'readonly',
            'static',
            'abstract',
            'deprecated',
            'modification',
            'async'
        ]
    };


    /** @type {(type: string)=>number} */
    function getType(type) {
        return legend.tokenTypes.indexOf(type);
    }

    /** @type {(modifier: string[]|string|null)=>number} */
    function getModifier(modifiers) {
        if (typeof modifiers === 'string') {
            modifiers = [modifiers];
        }
        if (Array.isArray(modifiers)) {
            let nModifiers = 0;
            for (let modifier of modifiers) {
                const nModifier = legend.tokenModifiers.indexOf(modifier);
                if (nModifier > -1) {
                    nModifiers |= (1 << nModifier) >>> 0;
                }
            }
            return nModifiers;
        } else {
            return 0;
        }
    }
    const myTokensRegs = [
        [/- .*?\[DONE\]/, "custom-done"],
        [/\---/, "custom-title-bar"],
        [/^(title) ?: ?(.*)/, "custom-title-bar"],
        [/^(date) ?: ?(.*)/, "custom-title-bar"],
        [/^(tags) ?: ?(.*)/, "custom-title-bar"],
        [/^#{1,6} .*/, "custom-header"],
        [/- (.| )*$/, "custom-list-item"],
        [/\*\*(.*?)\*\*/, "custom-blod"],
        [/\*.*?\*/, "custom-italic"],
        [/\[error.*/, "custom-error"],
        [/0x([a-z]|[A-Z]|\d)+/, "custom-number-16"],
        [/\d+$/, "custom-number"],
        [/\[notice.*/, "custom-notice"],
        [/\[info.*/, "custom-info"],
        [/\[[a-zA-Z 0-9:]+\]/, "custom-date"],
        [/const/, "custom-date"],
        [/".*?"/, "custom-date"]]

    const tokenPattern = new RegExp('([a-zA-Z]+)((?:\\.[a-zA-Z]+)*)', 'g');
    monaco.languages.registerDocumentSemanticTokensProvider('kfmarkdown', {
        getLegend: function () {
            return legend;
        },
        provideDocumentSemanticTokens: function (model, lastResultId, token) {
            const lines = model.getLinesContent();
            console.info('provideDocumentSemanticTokens')
            /** @type {number[]} */
            const data = [];

            let prevLine = 0;
            let prevChar = 0;

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i];
                for (let match = null; (match = tokenPattern.exec(line));) {
                    // translate token and modifiers to number representations
                    let type = getType(match[1]);
                    if (type === -1) {
                        continue;
                    }
                    let modifier = match[2].length ? getModifier(match[2].split('.').slice(1)) : 0;
                    data.push(
                        i - prevLine,
                        prevLine === i ? match.index - prevChar : match.index,
                        match[0].length,
                        type,
                        modifier
                    );

                    prevLine = i;
                    prevChar = match.index;
                }
                myTokensRegs.forEach((pattern) => {
                    let res = pattern.exec(line)
                    if (res !== null) {

                    }
                })
            }
            return {
                data: new Uint32Array(data),
                resultId: null
            };
        },
        releaseDocumentSemanticTokens: function (resultId) { }
    });
    // // Register a tokens provider for the language
    monaco.languages.setMonarchTokensProvider("kfmarkdown", {
        tokenizer: {
            root: [
                [/- .*?\[DONE\]/, "custom-done"],
                [/\---/, "custom-title-bar"],
                [/^(title) ?: ?(.*)/, "custom-title-bar"],
                [/^(date) ?: ?(.*)/, "custom-title-bar"],
                [/^(tags) ?: ?(.*)/, "custom-title-bar"],
                [/^#{1,6} .*/, "custom-header"],
                [/\*\*.*?\*\*/, "custom-blod"],
                [/- (.| )*$/, "custom-list-item"],
                [/\*.*?\*/, "custom-italic"],
                [/\[error.*/, "custom-error"],
                [/0x([a-z]|[A-Z]|\d)+/, "custom-number-16"],
                [/\d+$/, "custom-number"],
                [/\[notice.*/, "custom-notice"],
                [/\[info.*/, "custom-info"],
                [/\[[a-zA-Z 0-9:]+\]/, "custom-date"],
                [/const/, "custom-date"],
                [/".*?"/, "custom-date"],

            ],
        },
    });

    // Define a new theme that contains only rules that match this language
    monaco.editor.defineTheme("denk", {
        base: "vs",
        inherit: true,
        rules: [
            { token: "custom-done", foreground: "aaaaaa" },
            { token: "custom-info", foreground: "808080" },
            { token: "custom-title-bar", foreground: "808080" },
            { token: "custom-header", foreground: "ffbcd4" },
            { token: "custom-list-item", foreground: "FFA5aa" },
            { token: "custom-title-bar", foreground: "808080" },
            { token: "custom-blod", foreground: "00aaff", fontStyle: "bold" },
            { token: "custom-italic", foreground: "ffaabb", fontStyle: "italic" },
            { token: "custom-error", foreground: "ff0000", fontStyle: "bold" },
            { token: "custom-number", foreground: "aa0000" },
            { token: "custom-number-16", foreground: "aaaa00" },
            { token: "custom-notice", foreground: "FFA500" },
            { token: "custom-date", foreground: "008800" },
        ],
        colors: {
            'editor.foreground': '#000000'
        }
    });

    monaco.editor.defineTheme("denk-dark", {
        base: "vs-dark",
        inherit: true,
        rules: [
            { token: "custom-done", foreground: "aaaaaa" },
            { token: "custom-info", foreground: "808080" },
            { token: "custom-title-bar", foreground: "808080" },
            { token: "custom-header", foreground: "ffbcd4" },
            { token: "custom-list-item", foreground: "FFA5aa" },
            { token: "custom-title-bar", foreground: "808080" },
            { token: "custom-blod", foreground: "00aaff", fontStyle: "bold" },
            { token: "custom-italic", foreground: "ffaabb", fontStyle: "italic" },
            { token: "custom-error", foreground: "ffaaaa", fontStyle: "bold" },
            { token: "custom-number", foreground: "00aaaa" },
            { token: "custom-number-16", foreground: "00cccc" },
            { token: "custom-notice", foreground: "00A500" },
            { token: "custom-date", foreground: "ff8888" },
        ],
        colors: {
            'editor.foreground': '#ffffff',
            'editor.background': '#333333',
        }
    });


    const initCodeLens = (editor) => {
        console.info('initCodeLens')

        // monaco.languages.registerCodeLensProvider("javascript", codeLensProvider);
        // monaco.languages.registerCodeLensProvider("kfmarkdown", codeLensProvider);
    };


    const initCommands = (editor) => {

        editor.addAction({
            // An unique identifier of the contributed action.
            id: 'save',

            // A label of the action that will be presented to the user.
            label: 'Save',

            // An optional array of keybindings for the action.
            keybindings: [
                monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS
            ],

            // A precondition for this action.
            precondition: null,

            // A rule to evaluate on top of the precondition in order to dispatch the keybindings.
            keybindingContext: null,

            contextMenuGroupId: 'navigation',

            contextMenuOrder: 1.5,

            // Method that will be executed when the action is triggered.
            // @param editor The editor instance is passed in as a convenience
            run: function (ed) {
                window.denkGetKey('sendIpcMessage')({
                    name: 'editorSave'
                })
            }
        });

        // editor.addAction({
        //     // An unique identifier of the contributed action.
        //     id: 'refresh',

        //     // A label of the action that will be presented to the user.
        //     label: 'refresh',

        //     // An optional array of keybindings for the action.
        //     keybindings: [
        //         monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyR
        //     ],

        //     // A precondition for this action.
        //     precondition: null,

        //     // A rule to evaluate on top of the precondition in order to dispatch the keybindings.
        //     keybindingContext: null,

        //     contextMenuGroupId: 'navigation',

        //     contextMenuOrder: 1.5,

        //     // Method that will be executed when the action is triggered.
        //     // @param editor The editor instance is passed in as a convenience
        //     run: function (ed) {
        //         location.reload(false)
        //     }
        // });

        // editor.addAction({
        //     // An unique identifier of the contributed action.
        //     id: 'kfmarkdown preview',

        //     // A label of the action that will be presented to the user.
        //     label: 'kfmarkdown preview',

        //     // An optional array of keybindings for the action.
        //     keybindings: [
        //         monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyM
        //     ],

        //     // A precondition for this action.
        //     precondition: null,

        //     // A rule to evaluate on top of the precondition in order to dispatch the keybindings.
        //     keybindingContext: null,

        //     contextMenuGroupId: 'navigation',

        //     contextMenuOrder: 1.5,

        //     // Method that will be executed when the action is triggered.
        //     // @param editor The editor instance is passed in as a convenience
        //     run: function (ed) {
        //         let func = window.denkGetKey('funcToggleMarkdownPreviewView')
        //         if (func) {
        //             func()
        //         }
        //     }
        // });
    }

    window.denkSetKeyValue('onEditorCreate', (editor) => {
        console.info('onEditorCreate', editor)
        initCodeLens(editor)
        initCommands(editor)
        denkSetKeyValue('editornew', editor)
        window.denkGetKey('funcSwitchDarkMode')(window.denkGetKey('isDarkMode'))
    })

    // Register a completion item provider for the new language
    monaco.languages.registerCompletionItemProvider("kfmarkdown", {
        provideCompletionItems: () => {
            var suggestions = [];

            const headerMaxLv = 6;
            let headerPrefix = "";
            for (let x = 1; x <= headerMaxLv; x++) {
                headerPrefix += "#";
                suggestions.push({
                    label: "_#" + x,
                    kind: monaco.languages.CompletionItemKind.Text,
                    insertText: headerPrefix + " ${1:header}",
                    insertTextRules:
                        monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    documentation: "Header levele " + x,
                });
            }
            suggestions.push({
                label: "···",
                kind: monaco.languages.CompletionItemKind.Text,
                insertText: "``` ${1:language}\n${2:code}\n\n```",
                insertTextRules:
                    monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                documentation: "Code Here",
            })
            suggestions.push({
                label: "```",
                kind: monaco.languages.CompletionItemKind.Text,
                insertText: "``` ${1:language}\n${2:code}\n\n```",
                insertTextRules:
                    monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                documentation: "Code Here",
            })
            return { suggestions: suggestions };
        },
    });

    const prepareInjectJsResolve = window.denkGetKey("prepareInjectJsResolve");
    if (prepareInjectJsResolve) {
        prepareInjectJsResolve();
        let styleNode = window.denkGetKey('styleNode')
        if (styleNode != undefined) {
            window.document.body.appendChild(styleNode)
        }

        setTimeout(() => {
            try {

                let darkMode = localStorage.getItem('isDarkMode')
                if (darkMode !== undefined) {
                    window.denkGetKey('funcSwitchDarkMode')(darkMode === "true")
                    window.denkSetKeyValue('isDarkMode', darkMode === "true")
                } else {
                    console.info('kfdebug darkMode', darkMode)
                }
            } catch (err) {
                console.error(err)
            }
        }, 50)

    }
}


const generateHeaderBar = () => {

    const holder = document.getElementById('editor_container_holder')
    if (holder === undefined) {
        setTimeout(generateHeaderBar, 5000)
    }

    let header = document.getElementById('editor_header_bar')
    if (header) {
        return header
    }

    header = document.createElement('div')
    header.id = 'editor_header_bar'
    header.style = 'display:flex;width: 100%; background:#fefefe33; overflow-x: scroll;'

    holder.parentNode.insertBefore(header, holder)

    return header
}

const getEditors = () => {
    return window.denkAllKeys().filter(key => key.startsWith('editor') 
    && key !== 'editornew' 
    && key !== 'editor' 
    && !key.startsWith('editoreditor')
    && !key.startsWith('editorpreview')).filter(key => window.denkGetKey(key) !== undefined)
}

window.denkSetKeyValue("funcGetEditors", getEditors)
const updateHeader = () => {
    generateHeaderBar().innerHTML = ''
    let markdownPreviewModeBtn = document.createElement('div')
    markdownPreviewModeBtn.className = 'header_btn_markdown_preview_mode_btn header_btn_close_btn';
    markdownPreviewModeBtn.innerHTML = '<img src="markdown_preview_mode.png" height="20"/></div>'
    markdownPreviewModeBtn.style = 'display:flex; padding: 8px; border-radius:2px; margin-right: 4px;height: 20px;justify-content: space-between;'
    markdownPreviewModeBtn.onclick = () => {
        let func = window.denkGetKey('funcToggleMarkdownPreviewView')
        if (func) {
            func()
        }
    }
    generateHeaderBar().appendChild(markdownPreviewModeBtn)
    getEditors().map(id => {
        let key = id

        console.info('kfdebug getEditors item', key)

        key = key.replace('editor_', '_')
        key = key.replace('editorpreview', 'preview')


        let btn = document.createElement('div')
        btn.id = id + '_header_btn'
        btn.className = 'header_btn'

        let prefix = "/"
        if (key.lastIndexOf(prefix) == -1) {
            prefix = "\\"
        }

        let btnClass = 'header_btn_close_btn';//window.denkGetKey('isDarkMode') ? 'header_btn_close_btn' : 'header_btn_close_btn_dark'
        btn.innerHTML = `<div>${key.substring(key.lastIndexOf(prefix) + 1)}</div><div id="${id}_header_btn_close_btn" class="${btnClass}"><img src="close.png" height="20"/></div>`//+ '<div id="' + key +'_close" style="margin:0 4px; background: rgba(255,255,255,0.9); padding: 0 8px;" >close</div>'
        if (key.startsWith('preview')) {
            btn.innerHTML = 'preview:' + btn.innerHTML
        }
        let editorView = document.getElementById(id)
        btn.style = 'display:flex; padding: 8px; border-radius:2px; margin-right: 4px;height: 20px;min-width: 200px;justify-content: space-between;'
        if (editorView && editorView.style.display === '') {
            btn.style.background = window.denkGetKey('isDarkMode') ? '#333333' : '#ffffff';
            // btn.style.background = 'rgb(' + (Math.random() * 100 + 155) + "," + (Math.random() * 100 + 155) + "," + (Math.random() * 100 + 155) + ")"
        } else {
            btn.style.background = window.denkGetKey('isDarkMode') ? '#444444' : '#efefef';
        }
        btn.style.color = window.denkGetKey('isDarkMode') ? '#ffffff' : '#333333';
        btn.onclick = () => {
            window.denkGetKey('funcShowEditor')(id)
        }

        return [btn, id]
    }).forEach(arr => {
        const [btn, id] = arr
        generateHeaderBar().appendChild(btn)
        let closeBtn = document.getElementById(`${id}_header_btn_close_btn`)
        if (closeBtn !== undefined) {
            closeBtn.onclick = () => {
                console.info('onclose', id)
                //close this editor
                window.denkSetKeyValue(id, undefined)
                //
                window.denkSetKeyValue('editorpreview' + id, undefined)
                document.getElementById(id).innerHTML = ''
                updateHeader()

                for (
                    let x = 0;
                    x < document.getElementsByClassName("editor_view").length;
                    x++
                ) {
                    document.getElementsByClassName("editor_view")[x].style.display =
                        "none";
                }

            }

        }
    })
}
window.denkSetKeyValue('funcUpdateHeader', updateHeader)

window.denkSetKeyValue('funcUpdateSuggestions', () => {
    const dataJson = JSON.parse(window.denkGetKey('dataList'))
    const monaco = window.denkGetKey('monaco')
    const createCompletion = (info, range) => {
        const { title, path, tags } = info
        return {
            label: '@' + title,
            kind: monaco.languages.CompletionItemKind.Text,
            documentation: JSON.stringify(info, null, 2),
            insertText: `[${title}](#${path})`,
            commitCharacters: ['@'],
            detail: tags.join(','),
            range: range
        }
    }
    const createSuggestions = (range) => {
        return dataJson.headerInfos.map((info) => {
            return createCompletion(info, range)
        })
    }

    let disposeable = window.denkGetKey('disposeableUpdateSuggestions')
    if (disposeable) {
        disposeable.dispose()
    }
    disposeable = monaco.languages.registerCompletionItemProvider('kfmarkdown', {
        provideCompletionItems: function (model, position) {
            // find out if we are completing a property in the 'dependencies' object.
            var textUntilPosition = model.getValueInRange({
                startLineNumber: position.lineNumber,
                startColumn: 1,
                endLineNumber: position.lineNumber,
                endColumn: position.column
            });
            var match = textUntilPosition.match(
                /@/
            );
            if (!match) {
                return { suggestions: [] };
            }
            var word = model.getWordUntilPosition(position);
            var range = {
                startLineNumber: position.lineNumber,
                endLineNumber: position.lineNumber,
                startColumn: word.startColumn - 1,
                endColumn: word.endColumn
            };
            return {
                suggestions: createSuggestions(range)
            };
        }
    });

    window.denkSetKeyValue('disposeableUpdateSuggestions', disposeable)
})


window.denkSetKeyValue('funcSwitchDarkMode', (isDarkMode, from) => {
    console.info('kfdebug funcSwitchDarkMode', isDarkMode, from)
    window.denkSetKeyValue('isDarkMode', isDarkMode)
    if (isDarkMode !== undefined) {

        localStorage.setItem('isDarkMode', isDarkMode)
    }
    let editor = denkGetKey('monaco').editor
    let editor_header_bar = document.getElementById('editor_header_bar')
    if (isDarkMode) {
        editor.setTheme('denk-dark')
        document.body.style.background = '#333333'
        editor_header_bar && (editor_header_bar.style.background = '#444444')
    } else {
        document.body.style.background = '#ffffff'
        editor_header_bar && (editor_header_bar.style.background = '#efefef')
        editor.setTheme('denk')
    }
    window.denkGetKey('funcUpdateHeader')()
    let func = window.denkGetKey('funcMarkdownPreview')
    if (func) {
        func()
    }
})
window.denkSetKeyValue('funcShowEditor', (id) => {
    console.info(id)
    // get editorView
    if (window.denkGetKey(id) === undefined) {
        return
    }
    let editorView = document.getElementById(id)
    if (!editorView) {
        return
    }

    // hide all editor


    for (
        let x = 0;
        x < document.getElementsByClassName("editor_view").length;
        x++
    ) {
        const el = document.getElementsByClassName("editor_view")[x];
        // if (el.className.indexOf('markdown_preview') == -1) {
            el.style.display =
                "none";
        // }
    }


    window.denkGetKey('funcUpdateHeader')()

    // document.getElementById(id + '_header_btn').style.background = 'rgb(' + (Math.random() * 50 + 155) + "," + (Math.random() *  50 + 155) + "," + (Math.random() *  50 + 155) + ")"
    let currentBtn = document.getElementById(id + '_header_btn')
    currentBtn.style.background = window.denkGetKey('isDarkMode') ? '#333333' : '#ffffff';
    currentBtn.style.color = window.denkGetKey('isDarkMode') ? '#ffffff' : '#333333';


    editorView.style.display = ''

    window.denkGetKey('sendIpcMessage')({
        name: 'onShowEditor',
        data: {
            id: window.denkGetKey('funcGetFilePathById')(id)
        }
    })


    window.denkGetKey('funcSwitchDarkMode')(window.denkGetKey('isDarkMode'))
    let func = window.denkGetKey('funcMarkdownPreview')
    if (func) {
        func()
    }
})

