console.info('makrdown js')

window.denkSetKeyValue('isMarkdownLoaded', true)


const converters = {};

const registerConverter = (tag, func) => {
    converters[tag] = func;
};
function HTMLEncode(s) {
    return (typeof s != "string") ? s :
        s.replace(this.REGX_HTML_ENCODE,
            function ($0) {
                var c = $0.charCodeAt(0), r = ["&#"];
                c = (c == 0x20) ? 0xA0 : c;
                r.push(c); r.push(";");
                return r.join("");
            });
};

const handleInline = (content) => {
    let regBig = /\*\*(.*?)\*\*/g
    let regI = /\*(.*?)\*/g
    var regImg = /!\[(.*?)\]\((.*?)\)/g
    var regLink = /\[(.*?)\]\((.*?)\)/g

    content = content.replaceAll(regBig, `<strong>\$1</strong>`)
    content = content.replaceAll(regI, `<i>\$1</i>`)
    content = content.replaceAll(regImg, `<img src="\$2" alt="\$1"/>`)
    content = content.replaceAll(regLink, `<span href="\$2" target="_blank" class="markdown_link">\$1</span>`)
    return content
}

const convertMarkdownTagDatIntoHTML = (line) => {
    var [tag, content] = line;

    if (typeof content === 'object' && content instanceof Array) {
        // console.error(content)
        content[0] = content[0].replace(/[<>&"]/g, function (c) {
            return { '<': '&lt;', '>': '&gt;', '&': '&amp;', '"': '&quot;' }[c];
        });
    } else {

        // 转义
        content = content.replace(/[<>&"]/g, function (c) {
            return { '<': '&lt;', '>': '&gt;', '&': '&amp;', '"': '&quot;' }[c];
        });
    }



    let result = line
    for (let x in converters) {
        // console.info('kfdebug convertMarkdownTagDatIntoHTML key:', x)
        if ((typeof x === "string")) {
            if (x === tag) {
                result = converters[x](content);
                break;
            } else {
                // return
                // return ''
                // console.error(x, tag, content)
            }
        }
        // register regexp text 
        if (x.endsWith("/") && x.startsWith("/")) {
            let res = new RegExp(x.substring(1, x.length - 1)).exec(tag);
            if (res !== null) {
                result = converters[x](content, res);
                break;
            }
        }

        // console.info(tag, x, new RegExp(x).exec(tag), x instanceof RegExp)
    }
    var regInlineCode = /`(.+?)`/g
    var regInlineCodeSplit = /`.+?`/g
    // result = result.replaceAll(regInlineCode, `__CODE_S__\$1__CODE_E__`)
    const lineSpliteByCode = result.split(regInlineCodeSplit)
    result = result.replaceAll(regInlineCode, `<span class="inline">\$1</span>`)
    lineSpliteByCode.forEach(i => {
        result = result.replace(i, handleInline(i))
    })

    return result;
};

registerConverter("headerConfig", (line) => "");
registerConverter("normal", (line) => `<text>${line.trim(0)}</text>`);
registerConverter("empty", (line) => `<text>${line.trim(0)}</text><br/>`);
registerConverter(
    "/code_start_(.*)/",
    (line, res) => `<code class="language_${res[1]} markdown_code">`,
);
registerConverter("/code_/", (line) => {
    if (line.trim() === "```") {
        return `</code>`;
    } else {
        return line;
    }
});
registerConverter("code_end_", (line) => `</code>`);
registerConverter("line", (line) => `<hr>`);

registerConverter('note_tag', (line) => {
    console.info('kfdbeug note_tag', line)
    return `<blockquote class="note_tag"><div>${line}</div></blockquote>`
}
)
class TitleHearConvertHelper {
    constructor() {
        this.init()
    }

    reset() {
        this.convertedCount = 0;
        this.headerList = []
    }

    init() {

        registerConverter("/titleHeader_(.)/", (line, res) => {
            let head = ``
            let tile = ``
            const id = line.replaceAll(' ', '-')
            // if (this.convertedCount == 0) {
            //     head = `<div id="header-container-${id}" class="header-container-item">`
            // } else if (this.convertedCount == this.headerList.length) {
            //     tile = `</div>`
            // } else {
            //     tile = `</div>`
            //     head = `<div id="header-container-${id}" class="header-container-item">`
            // } 
            this.convertedCount++
            return `${tile}<h${res[1]} id="${id}">${line}</h${res[1]}>${head}`;
        });

        registerConverter('toc', (line) => {
            // getallheader
            let content = this.headerList.map(header => {
                const { level, content } = header
                let prefixString = ''
                for (let x = 0; x < level; x++) {
                    prefixString += `  `
                }
                prefixString += `+ `
                return `<p>${prefixString}<a href="#${content.replaceAll(' ', '-')}">${content}</a><\p>`
            }).join('\n')
            return `<div class="toc" style="overflow-x:scroll; min-height: ${this.headerList.length * 36}px ;">${content}</div>`
        })

    }
}

let titleHeaderConverter = new TitleHearConvertHelper()
window.denkSetKeyValue('makrdownTitleHeaderConvertHelper', titleHeaderConverter)
// registerConverter('link', (line) => {

//     var regLink = /\[(.*?)\]\((.*?)\)/
//     console.info('kfdebug', line, regLink.exec(line))
//     const [normal, text, link] = regLink.exec(line)
//     return `<a href="${link}" target="_blank">${text}</a>`
// })

class ListItemConvertHelper {

    constructor(listTag = 'ul', tagBlankSize = 4) {
        this.init();
        this.currentLevel = 0
        this.listTag = listTag
        this.tagBlankSize = tagBlankSize
        this.isCheckList = false
        this.isNeedAddBar = false
        // this.tagTODO = '[TODO]'
        // this.tagDONE = '[DONE]'
        this.tagTODO = '[-]'
        this.tagDONE = '[x]'
        this.tagAddBar = '[bar]'
    }

    


    convertLineContent(line, lineNumber) {
        line = line.replace('- ', '').trimLeft()
        if (this.isCheckList) {
            // line = line.replace(this.tagDONE, `<div id="list-item-${lineNumber}" class="list-item-checkbox react-list-item-checkbox" type="checkbox" checked="true"/>`)
            // line = line.replace(this.tagTODO, `<div id="list-item-${lineNumber}" class="list-item-checkbox react-list-item-checkbox" type="checkbox"/>`)
            // if (line.indexOf('checkbox') === -1) {
                //     line = `<div id="list-item-${lineNumber}" class="list-item-checkbox react-list-item-checkbox" type="checkbox" content=${encodeURIComponent(line)} />` + line 
                // }
            let checked = false
            if (line.indexOf(this.tagDONE) > 0) {
                checked = true
            }
            line = line.replace(this.tagDONE, ``)
            line = line.replace(this.tagTODO, ``)
            line = `<div id="list-item-${lineNumber}" class="list-item-checkbox react-list-item-checkbox" type="checkbox" ${checked ? 'checked=\"true\"' : ''} content=${encodeURIComponent(line)} />`
        }
        // line += `<div class="react-list-item-checkbox" />"`
        return line
    }

    getLevel(line) {
        // console.info('getLevel', line)
        return /^( *)/.exec(line)[1].length / this.tagBlankSize
    }
    init() {
        registerConverter("list_start", (i) => {
            let [line, lineNumber] = i
            this.currentLevel == 0
            let className = ''
            if (line.indexOf(this.tagDONE) > 0 || line.indexOf(this.tagTODO) > 0) {
                this.isCheckList = true
                className = 'list-todo'
            } else {
                this.isCheckList = false
            }
            if (line.indexOf(this.tagAddBar) > 0) {
                this.isNeedAddBar = true
                line = line.replace(this.tagAddBar, '')
            } else {
                this.isNeedAddBar = false
            }
            
            
            return `<${this.listTag} class=${className}>\n<li><div style="display:flex" ><p>${this.convertLineContent(line, lineNumber)}<p></div></li>`
        });
        registerConverter("list", (i) => {
            var [line, lineNumber] = i
            let lv = this.getLevel(line)
            // console.info('getLevel', lv)
            if (this.currentLevel < 0) {
                this.currentLevel = 0
            }
            line = this.convertLineContent(line, lineNumber)
            // if (line.endsWith('[DONE]')) {
            // }
            if (lv === this.currentLevel) {
                return `<li><div style="display:flex" ><p>${line}</div></p></li>`
            }
            if (lv > this.currentLevel) {
                let buf = ''
                while (lv > this.currentLevel) {
                    buf += `<${this.listTag}>\n`
                    this.currentLevel++
                }
                buf += `<li><div style="display:flex" ><p>${line}</div></p></li>`
                return buf
            }
            if (lv < this.currentLevel) {
                let buf = ''
                while (lv < this.currentLevel) {
                    buf += `\n</${this.listTag}>`
                    this.currentLevel--
                }
                if (this.currentLevel < 0) {
                    this.currentLevel = 0
                }
                buf += `<li><div style="display:flex" ><p>${line}</div></p></li>`
                return buf
            }
            return line;
        });
        registerConverter("list_end", (i) => {
            const [line, lineNumber] = i
            let buf = ''

            if (this.currentLevel < 0) {
                this.currentLevel = 0
            }

            while (0 <= this.currentLevel) {
                buf += `\n</${this.listTag}>`
                this.currentLevel--
            }

            if (this.isCheckList && this.isNeedAddBar){
                buf += `<div class="list-item-add-button" line="${lineNumber}"></div>`
            }
            return buf
        });
    }
}

const listItemConvertHepler = new ListItemConvertHelper()

class CoastTimer {
    allCoastTime = 0
    constructor() {
        this.time = new Date().getTime();
    }

    delay(tag) {
        const n = new Date().getTime();
        const coast = n - this.time;
        this.time = n;
        console.info(`${tag} coast ${coast} ms`);
        this.allCoastTime += coast
    }
}

const myct = new CoastTimer();

const colorMaps = [['@bgWhite', '#fefefe', '#333333'],
['@linkColor', '#fac03d', '#fac03d'], ['@bgNote', '#efefef33', '#fefefe33'],
['@colorH', '#333333', '#aed0ee'],
['@colorInlineBGCode', '#f9f2f4', '#555555'],
['@colorInlineCode', '#ffbcd4', '#f9a0a0'],
['@colorIt', '#aabcd3', '#ffbcd3'],
['@colorSI', '#aa56d3', '#ff56d3'],
['@colorPrimary', '#ffffff', '#333333'],
['@colorPreview', '#2c3f51', '#eeeeee']];

const resolveColor = () => {
    const colors = {}
    const darkMode = localStorage.getItem('isDarkMode') === 'true'
    colorMaps.forEach(colorItem => {
        const [key, light, dark] = colorItem
        const color = darkMode ? dark : light
        // text = text.replaceAll(key, color)
        colors[key] = color
    })
    colors[ '@isDarkMode'] = darkMode

    less.modifyVars(colors)
}

const handleMarkdown = (content) => {
    myct.delay("start handleMarkdown");
    var stateIsHeader = false;
    var regHeader = /^---$/;

    var regTitleHeader = /^(#+) (.*)/;

    var stateIsCode = false;
    var currentCodeTag = "";
    var regCodeStart = /^``` (.*)/;
    var regCodeEnd = /^```( *)$/;

    var stateIsList = false;
    var regListStart = /^- .*/;
    var regListContinue = /^ *- .*/;

    var res = [];
    var regRes = null;

    //[https://www.denojs.cn/](https://www.denojs.cn/)
    var regLink = /\[(.*?)\]\((.*?)\)/

    var regToc = /^\[TOC\]/

    var regNote = /^\> (.*)/

    var regLine = /^----+/;

    myct.delay("inited handleMarkdown reg");
    content.split("\n").forEach((line, lineNumber) => {
        // header Condfig start&end
        if (regHeader.exec(line) !== null) {
            stateIsHeader = !stateIsHeader;
            res.push(["headerConfig", line]);
            return;
        }
        // header Config middle
        if (stateIsHeader) {
            res.push(["headerConfig", line]);
            return;
        }

        regRes = regTitleHeader.exec(line);
        if (regRes !== null) {
            res.push([`titleHeader_${regRes[1].length}`, regRes[2]]);

            window.denkGetKey('makrdownTitleHeaderConvertHelper').headerList.push({
                level: regRes[1].length,
                content: regRes[2]
            })
            return;
        }

        // ------------

        if (!stateIsCode) {
            regRes = regCodeStart.exec(line);
            if (regRes !== null) {
                currentCodeTag = regRes[1].trim();
                stateIsCode = true;
                res.push([`code_start_${currentCodeTag}`, line]);
                return;
            }
        }

        if (stateIsCode) {
            regRes = regCodeEnd.exec(line);
            // console.info('has regCodeEnd', line, regRes)
            if (regRes !== null) {
                currentCodeTag = regRes[1];
                stateIsCode = false;
                res.push([`code_end_${currentCodeTag}`, line]);
                currentCodeTag == "";
            } else {
                res.push([`code_${currentCodeTag}`, line]);
            }
            return;
        }


        // ------------

        if (!stateIsList) {
            regRes = regListStart.exec(line);
            if (regRes !== null) {
                stateIsList = true;
                res.push([`list_start`, [line, lineNumber]]);
                return;
            }
        }

        if (stateIsList) {
            regRes = regListContinue.exec(line);
            if (regRes !== null) {
                // console.info('regListContinue')
                res.push(["list", [line, lineNumber]]);
                return;
            } else {
                // console.info('list_end')
                res.push(["list_end", [line, lineNumber]]);
                stateIsList = false;
                return;
            }
        }
        // ------------
        // regRes = regLink.exec(line)
        // if (regRes !== null) {
        //     res.push(["link", line])
        //     return
        // }

        // ------------
        regRes = regToc.exec(line)
        if (regRes !== null) {
            res.push(["toc", line])
            return
        }

        // ------------
        regRes = regNote.exec(line)
        if (regRes !== null) {
            res.push(['note_tag', regRes[1]])
            return
        }
        // ------------
        regRes = regLine.exec(line)
        if (regRes !== null) {
            res.push(['line', line])
            return
        }

        // ------------

        if (line.trim() != "") {
            res.push(["normal", line]);
            return
        }

        let lastIsEmpty = false;
        if (res.length > 1) {
            lastIsEmpty = res[res.length - 1][0] === 'empty'
        }
        if (line.trim() == "" && !lastIsEmpty) {
            res.push(["empty", line]);
        }

    });

    myct.delay("finish parse line data into markdown tag data");
    // console.info(res)

    let output = res.map(convertMarkdownTagDatIntoHTML).filter((line) =>
        line !== ""
    ).join("\n");

    myct.delay("finish convertMarkdownTagDatIntoHTML");
    const darkMode = localStorage.getItem('isDarkMode') == 'true'
    const cssStyleFile = !darkMode ? 'solarized-light.min.css' : 'railscasts.min.css'
    const header = `<link rel="stylesheet" href="${cssStyleFile}">`

    resolveColor();


    output = `${header}<pre class="lowbee-markdown-preview">${output}</pre>`;
    return output
};


const getCurrentShowingEditor = () => {
    let editor = undefined
    for (
        let x = 0;
        x < document.getElementsByClassName("editor_view").length;
        x++
    ) {
        const el = document.getElementsByClassName("editor_view")[x]
        if (el.style.display === '' & el.className.indexOf('markdown_preview') === -1) {
            editor = el
        }
    }
    return editor
}

window.denkSetKeyValue('funcGetCurrentShowingEditor', getCurrentShowingEditor)


let lastMarkdownPreview = 0

const innerMarkdownPreview = () => {

    const monaco = window.denkGetKey("monaco");
    console.info('funcMarkdownPreview')
    let editor = window.denkGetKey('funcGetCurrentShowingEditor')()
    console.info(editor)
    let fileId = editor.id.replace('editor_', '')
    console.info('fileId', fileId)
    let currentShowingEditor = window.denkGetKey('getEditorByFilePath')(fileId)
    let content = currentShowingEditor.getValue()
    const id = ('editorpreview' + fileId)
    let preview = document.getElementById(id);

    for (
        let x = 0;
        x < document.getElementsByClassName("markdown_preview").length;
        x++
    ) {
        const el = document.getElementsByClassName("markdown_preview")[x];
        el.style.display =
            "none";

    }
    if (!preview) {

        preview = document.createElement('div')
        preview.id = ('editorpreview' + fileId)
        preview.style.width = "50%";
        preview.style.height = "100%";
        preview.style.overflow = "scroll";
        preview.className = "editor_view markdown_preview";
        const holder = document.getElementById("editor_container_holder");

        holder.appendChild(preview);
        document.querySelectorAll('.editor_view').forEach(i => {
            refreshWidthByMarkdownPreviewMode(i)
        })
    } else {
        preview.style.display = ''
    }




    console.info('preview', preview)
    window.denkSetKeyValue(id, preview)
    window.denkGetKey('funcUpdateHeader')()
    // titleHeaderConverter.headerList = []
    titleHeaderConverter.reset()
    var oldScrollTop = preview.scrollTop
    preview.innerHTML = handleMarkdown(content)
    preview.scrollTop = oldScrollTop
    // window.hljs.highlightAll();
    document.querySelectorAll('code').forEach((el) => {
        if (el.className.indexOf('inline') === -1) {
            hljs.highlightElement(el);
        }
    });
    document.querySelectorAll('.markdown_link').forEach((el) => {
        console.info(el.attributes.href.value)
        el.onclick = () => {

            window.denkGetKey('sendIpcMessage')({
                name: 'openLink',
                data: {
                    url: el.attributes.href.value
                }
            })
        }
    })
    document.querySelectorAll('.react-list-item-checkbox').forEach((el) => {
        const onchange = (e) => {
            var lineNumber = /item-(\d*)/.exec(el.id)[1]
            lineNumber = Number.parseInt(lineNumber)
            lineNumber += 1
            console.info('onchange', lineNumber)
            const lineContent = currentShowingEditor.getModel().getLineContent(lineNumber)

            let newContent = ''
            if (/\[x\]/.exec(lineContent)) {
                newContent = lineContent.replace(/\[x\]/g, listItemConvertHepler.tagTODO)
            } else if (/\[-\]/.exec(lineContent)) {
                newContent = lineContent.replace(/\[-\]/g, listItemConvertHepler.tagDONE)
            } else {
                newContent = lineContent + ' ' + listItemConvertHepler.tagDONE
            }
            console.info('onchange', lineNumber, lineContent, newContent)
            var range = new monaco.Range(lineNumber, 0, lineNumber, lineContent.length + 1);
            var id = { major: 1, minor: 1 };
            var op = { identifier: id, range: range, text: newContent, forceMoveMarkers: true };

            currentShowingEditor.executeEdits("my-source-checkbox", [op]);
            // currentShowingEditor.ex
        }

        window.reactRenderSwitch(el, el.attributes.checked, onchange, el.attributes.content)
    })


    document.querySelectorAll('.list-item-add-button').forEach((el) => {
        window.reactRenderAddBar(el, (content, lineNumber) => {
            lineNumber = Number.parseInt(lineNumber)
            // const lineContent = currentShowingEditor.getModel().getLineContent(lineNumber)
            content = '- '+ content + '\n'
            var range = new monaco.Range(lineNumber +1 , 0, lineNumber+1, 0);
            var id = { major: 1, minor: 1 };
            var op = { identifier: id, range: range, text: content, forceMoveMarkers: true };

            currentShowingEditor.executeEdits("my-source-add", [op]);
            console.info(content, line)
        }, 'AddTo')
    })

    // handle react material
    // {

    //     document.querySelectorAll('.react-list-item-checkbox').forEach((el) => {

    //     })
    // }
}

window.denkSetKeyValue('funcMarkdownPreview', () => {

    lastMarkdownPreview = new Date().getTime()

    setTimeout(() => {
        const currentMarkdownPreviewTime = new Date().getTime()
        if (currentMarkdownPreviewTime - lastMarkdownPreview >= 100) {
            innerMarkdownPreview()
        }
    }, 200)
})


const refreshWidthByMarkdownPreviewMode = (el) => {
    const markdownPreviewMode = window.denkGetKey('markdownPreviewMode') || 0
    if (markdownPreviewMode === 0) {
        el.style.width = "50%"
    } else if (markdownPreviewMode === 1) {
        if (el.className.indexOf('markdown_preview') === -1) {
            el.style.width = "100%"
        } else {
            el.style.width = "0%"
        }

    } else if (markdownPreviewMode === 2) {

        if (el.className.indexOf('markdown_preview') === -1) {
            el.style.width = "0%"
        } else {
            el.style.width = "100%"
        }
    }
}
window.denkSetKeyValue('funcToggleMarkdownPreviewView', () => {
    let mode = window.denkGetKey('markdownPreviewMode')
    if (mode === undefined) {
        mode = 1
    } else {
        mode = (mode + 1) % 3
    }
    window.denkSetKeyValue('markdownPreviewMode', mode)

    // refresh width
    document.querySelectorAll('.editor_view').forEach(i => {
        refreshWidthByMarkdownPreviewMode(i)
    })
})

window.denkSetKeyValue('insertMarkdownImage', (value) => {
    if (!value || value === '') {
        return
    }
    let editor = window.denkGetKey('funcGetCurrentShowingEditor')()
    let fileId = editor.id.replace('editor_', '')
    let currentShowingEditor = window.denkGetKey('getEditorByFilePath')(fileId)
    let pos = currentShowingEditor.getPosition()
    console.info(pos)

    const monaco = window.denkGetKey("monaco");
    var range = new monaco.Range(pos.lineNumber, pos.column, pos.lineNumber, pos.column + 1);
    var id = { major: 1, minor: 1 };
    const imageName = 'image'
    var op = { identifier: id, range: range, text: `![${imageName}](lowh://${value})`, forceMoveMarkers: true };

    currentShowingEditor.executeEdits("my-source-checkbox", [op]);
    setTimeout(() => {
        window.denkGetKey('funcMarkdownPreview')()
    }, 50)
})

