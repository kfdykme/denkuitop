import fs from 'npm:fs-extra'

console.info(fs.copyFileSync)
fs.copyFileSync('/Applications/LowBee.app/Contents/Resources/manoco-editor/inject/inject.js', './denkui/manoco-editor/inject/inject.js')
fs.copyFileSync('/Applications/LowBee.app/Contents/Resources/manoco-editor/inject/markdown.js', './denkui/manoco-editor/inject/markdown.js')
fs.copyFileSync('/Applications/LowBee.app/Contents/Resources/manoco-editor/index.html', './denkui/manoco-editor/index.html')