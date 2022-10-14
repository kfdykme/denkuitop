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
    content = content.replaceAll(regLink, `<a href="\$2" target="_blank">\$1</a>`)
    return content
}

const convertMarkdownTagDatIntoHTML = (line) => {
    let [tag, content] = line;


    // 转义
    content = content.replace(/[<>&"]/g, function (c) {
        return { '<': '&lt;', '>': '&gt;', '&': '&amp;', '"': '&quot;' }[c];
    });
    
    
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
                result =  converters[x](content, res);
                break;
            }
        }
        
        // console.info(tag, x, new RegExp(x).exec(tag), x instanceof RegExp)
    }
    var regInlineCode = /`(.+?)`/g
    var regInlineCodeSplit = /`.+?`/g
    // result = result.replaceAll(regInlineCode, `__CODE_S__\$1__CODE_E__`)
    const lineSpliteByCode = result.split(regInlineCodeSplit)
    result = result.replaceAll(regInlineCode, `<code class="inline">\$1</code>`)
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
        this.headerList = []
        this.init()
    }

    init() {

        registerConverter("/titleHeader_(.)/", (line, res) => {
            return `<h${res[1]} id="${line.replaceAll(' ', '-')}">${line}</h${res[1]}>`;
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
            return `<div class="toc">${content}</div>`
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
    }

    convertLineContent(line) {
        line = line.replace('- ', '').trimLeft()
        line = line.replace('[DONE]', '<input type="checkbox" checked>')
        line = line.replace('[TODO]', '<input type="checkbox">')
        return line
    }

    getLevel(line) {
        // console.info('getLevel', line)
        return /^( *)/.exec(line)[1].length / this.tagBlankSize
    }
    init() {
        registerConverter("list_start", (line) => {
            this.currentLevel == 0
            return `<${this.listTag}>\n<li><p>${this.convertLineContent(line)}<p></li>`
        });
        registerConverter("list", (line) => {
            let lv = this.getLevel(line)
            // console.info('getLevel', lv)
            if (this.currentLevel < 0) {
                this.currentLevel = 0
            }
            line = this.convertLineContent(line)
            // if (line.endsWith('[DONE]')) {
            // }
            if (lv === this.currentLevel) {
                return `<li><p>${line}</p></li>`
            }
            if (lv > this.currentLevel) {
                let buf = ''
                while (lv > this.currentLevel) {
                    buf += `<${this.listTag}>\n`
                    this.currentLevel++
                }
                buf += `<li><p>${line}</p></li>`
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
                buf += `<li><p>${line}</p></li>`
                return buf
            }
            return line;
        });
        registerConverter("list_end", (line) => {
            let buf = ''

            if (this.currentLevel < 0) {
                this.currentLevel = 0
            }

            while (0 <= this.currentLevel) {
                buf += `\n</${this.listTag}>`
                this.currentLevel--
            }
            return buf
        });
    }
}

new ListItemConvertHelper()

class CoastTimer {
    constructor() {
        this.time = new Date().getTime();
    }

    delay(tag) {
        const n = new Date().getTime();
        const coast = n - this.time;
        this.time = n;
        console.info(`${tag} coast ${coast} ms`);
    }
}

const myct = new CoastTimer();

const colorMaps = [['@bgWhite', '#fefefe', '#333333'], 
['@linkColor', '#fac03d', '#fac03d'], ['@bgNote', '#33333333', '#efefef33'],
['@colorH','#333333', '#aed0ee'],
['@colorInlineBGCode','#f9f2f4', '#555555'],
['@colorInlineCode','#f9f2f4', '#f9a0a0'],
['@colorIt','#aabcd3', '#ffbcd3'],
 ['@colorSI','#aa56d3', '#ff56d3'],
 ['@colorPreview', '#2c3f51', '#CCCCCC']];

const resolveColor = (text) => {
    colorMaps.forEach(colorItem => {
        const [key, light, dark] = colorItem
        const darkMode = localStorage.getItem('isDarkMode') === 'true'
        const color = darkMode ? dark : light
        text = text.replaceAll(key, color)
    })
    return text
}

const handleMarkdown = (content) => {
    myct.delay("start handleMarkdown");
    var stateIsHeader = false;
    var regHeader = /^---$/;

    var regTitleHeader = /^(#+) (.*)/;

    var stateIsCode = false;
    var currentCodeTag = "";
    var regCodeStart = /^``` (.*)/;
    var regCodeEnd = /^``` *$/;

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
    content.split("\n").forEach((line) => {
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

        regRes = regCodeStart.exec(line);
        if (regRes !== null) {
            currentCodeTag = regRes[1].trim();
            stateIsCode = true;
            res.push([`code_start_${currentCodeTag}`, line]);
            return;
        }

        if (stateIsCode) {
            regRes = regCodeEnd.exec(line);
            if (regRes !== null) {
                // console.info('has regCodeEnd', line)
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
                res.push([`list_start`, line]);
                return;
            }
        }

        if (stateIsList) {
            regRes = regListContinue.exec(line);
            if (regRes !== null) {
                // console.info('regListContinue')
                res.push(["list", line]);
                return;
            } else {
                // console.info('list_end')
                res.push(["list_end", line]);
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
    style = `
    <style>
    ul ul, ol ul, ul ol, ol ol {
        margin-bottom: .55em;
        line-height: 0.1em;
    }
    ui {
        display: block;
        list-style-type: disc;
        // padding: 0;
    }
    li {
        line-height: 1.6;
        // margin:0;
    }
    li>p {
        margin:0px;
    }
    li:hover {
        list-style-type: none;
    }
    ul, ol {
        // background: #efefef;

        font-size: 16.11111111111111px;
    }
    .preview {
        font-size: 15.11111111111111px;
        color: @colorPreview;
        font-family: ui-monospace;
        padding:1em;
        width:90%;
        background: @bgWhite;
        display:inline-flex;
        flex-direction:column;
    }

    .preview > text, blockquote, ul, li, h1,h2,h3,h4,h5,h6, span{ white-space: normal; width: 100%;word-break: break-all; line-height: 1.5}
    
    .preview > ul {
        line-height:1.7px;
    }
    

    .preview> h1, h2, h3, h4, h5, h6 {
        font-weight: bold;
        color: @colorH;
        margin: 1.2em 0 .6em 0;
    }

    .markdown_code {
        overflow-x: visible !important;
    }

    a {
        color: @linkColor;
        text-decoration: none;
        font-size: 14.222222222222221px;
    }

    .toc > p {
        margin-block:0;
        margin-inline: 0;
    }

    .note_tag {
        // background: @bgNote;
        padding: 4px;
        padding-left: 16px;
        margin: 0px;
        // border-radius: 8px;
        border-left: 4px solid #e27e7dee;
    }

    i {
        font-weight: bold;
        color: @colorIt;
    }

    strong {
        color: #00aaff
    }

    .inline {
        color: @colorInlineCode;
        background-color: @colorInlineBGCode;
        border-radius: 4px;
        padding: 0px 4px;
        // margin:4px;
    }

    strong > i {
        color: @colorSI
    }

    h1 {
        font-size:31px; 
        border-bottom: 1px solid #aaaaaa;
        padding-bottom: 8px;
    }
    h2 {
        font-size:28px; 
        border-bottom: 1px solid #aaaaaa;
        padding-bottom: 8px;
    }
    h3 {
        font-size:25px; 
    }
    h4 {
        font-size:22px; 
    }
    h5 {
        font-size:19px; 
    }
    h6 {
        font-size:16px; 
    }

    .preview a:hover{
        border-bottom: 1px solid;
    }

    </style>
    `
    myct.delay("finish convertMarkdownTagDatIntoHTML");
    const darkMode = localStorage.getItem('isDarkMode') == 'true'
    const cssStyleFile = !darkMode ? 'solarized-light.min.css' : 'railscasts.min.css'
    const header = `<link rel="stylesheet" href="${cssStyleFile}">
     ${resolveColor(style)}`
    
    output = `${header}<pre class="preview">${output}</pre>`;
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
    console.info('funcMarkdownPreview')
    let editor = window.denkGetKey('funcGetCurrentShowingEditor')()
    console.info(editor)
    let fileId = editor.id.replace('editor_', '')
    console.info('fileId', fileId)
    let content = window.denkGetKey('getEditorByFilePath')(fileId).getValue()
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
    titleHeaderConverter.headerList = []
    var oldScrollTop = preview.scrollTop
    preview.innerHTML = handleMarkdown(content)
    preview.scrollTop = oldScrollTop
    // window.hljs.highlightAll();
    document.querySelectorAll('code').forEach((el) => {
    if (el.className.indexOf('inline') === -1) {
        hljs.highlightElement(el);
    }
    });
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

