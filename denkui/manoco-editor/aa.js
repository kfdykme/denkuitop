__webpack_require__.r(__webpack_exports__);
/* harmony import */ var monaco_editor__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! monaco-editor */ \"../node_modules/monaco-editor/esm/vs/editor/editor.main.js\");


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

// Register a new language
monaco_editor__WEBPACK_IMPORTED_MODULE_0__.languages.register({ id: 'markdown' });

// Register a tokens provider for the language
monaco_editor__WEBPACK_IMPORTED_MODULE_0__.languages.setMonarchTokensProvider('markdown', {
    tokenizer: {
        root: [
            [/- .*?\\[DONE\\]/, 'custom-done'],
            [/\\---/, 'custom-title-bar'],
            [/^(title) ?: ?(.*)/, 'custom-title-bar'],
            [/^(date) ?: ?(.*)/, 'custom-title-bar'],
            [/^(tags) ?: ?(.*)/, 'custom-title-bar'],
            [/^#{1,6} .*/, 'custom-header'],
            [/- .*? /, 'custom-list-item'],
            [/\\*\\*.*\\*\\*/, 'custom-blod'],
            [/\\*.*\\*/, 'custom-italic'],
            [/\\[error.*/, 'custom-error'],
            [/\\[notice.*/, 'custom-notice'],
            [/\\[info.*/, 'custom-info'],
            [/\\[[a-zA-Z 0-9:]+\\]/, 'custom-date']
        ]
    }
});

// Define a new theme that contains only rules that match this language
monaco_editor__WEBPACK_IMPORTED_MODULE_0__.editor.defineTheme('myCoolTheme', {
    base: 'vs',
    inherit: false,
    rules: [
        { token: 'custom-done', foreground: 'aaaaaa' },
        { token: 'custom-info', foreground: '808080' },
        { token: 'custom-title-bar', foreground: '808080' },
        { token: 'custom-header', foreground: '00bcd4' },
        { token: 'custom-list-item', foreground: 'FFA500' },
        { token: 'custom-title-bar', foreground: '808080' },
        { token: 'custom-blod', foreground: '00aaff', fontStyle: 'bold' },
        { token: 'custom-italic', foreground: 'ffaabb', fontStyle: 'italic' },
        { token: 'custom-error', foreground: 'ff0000', fontStyle: 'bold' },
        { token: 'custom-notice', foreground: 'FFA500' },
        { token: 'custom-date', foreground: '008800' }
    ],
    colors: {
        'editor.foreground': '#000000'
    }
});

// Register a completion item provider for the new language
monaco_editor__WEBPACK_IMPORTED_MODULE_0__.languages.registerCompletionItemProvider('mySpecialLanguage', {
    provideCompletionItems: () => {
        var suggestions = [
            {
                label: 'simpleText',
                kind: monaco_editor__WEBPACK_IMPORTED_MODULE_0__.languages.CompletionItemKind.Text,
                insertText: 'simpleText'
            },
            {
                label: 'testing',
                kind: monaco_editor__WEBPACK_IMPORTED_MODULE_0__.languages.CompletionItemKind.Keyword,
                insertText: 'testing(${1:condition})',
                insertTextRules: monaco_editor__WEBPACK_IMPORTED_MODULE_0__.languages.CompletionItemInsertTextRule.InsertAsSnippet
            },
            {
                label: 'ifelse',
                kind: monaco_editor__WEBPACK_IMPORTED_MODULE_0__.languages.CompletionItemKind.Snippet,
                insertText: ['if (${1:condition}) {', '\    $0', '} else {', '\    ', '}'].join('\
'),
                insertTextRules: monaco_editor__WEBPACK_IMPORTED_MODULE_0__.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                documentation: 'If-Else Statement'
            }
        ];
        return { suggestions: suggestions };
    }
});

const codeEditor = monaco_editor__WEBPACK_IMPORTED_MODULE_0__.editor.create(document.getElementById('container'), {
    theme: 'myCoolTheme',
    value: '',
    language: 'markdown'
});


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

window.denkGetKey = denkGetKey
window.denkSetKeyValue = denkSetKeyValue

window.denkSetKeyValue('editor', codeEditor)
window.denkSetKeyValue('monaco', monaco_editor__WEBPACK_IMPORTED_MODULE_0__)
window.denkAllKeys = () => {
    initDenkui()
    const res = []
    for(let x in window.denkui) {
        res.push(x)
    }
    return res
}


//# sourceURL=webpack://browser-esm-webpack/./index.js?
