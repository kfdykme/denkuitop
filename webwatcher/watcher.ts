/**
 * watcher.ts
 */
import path from 'node:path'; 
import { copyFile, constants } from 'node:fs';
const watchPath =  path.resolve('../denkui')
console.info('watch path ',watchPath)

const debugPath = '../build/macos/Build/Products/Debug/LowHumming.app/Contents/Resources'
const watcher = Deno.watchFs(watchPath);

for await (const event of watcher) {
//   console.log(">>>> event", event);
  if (event.kind == 'modify') {
    const files = event.paths.map((filePath: string) => {
        return {
            source: filePath,
            target: debugPath + filePath.replace(watchPath, ''),
        } 
    })

    
    
function callback(source, target, err) {
    if (err) throw err;
    // console.log(`${source} was copied to ${target}.txt`);
  }
  
  // destination.txt will be created or overwritten by default.
  files.forEach(element => {
    copyFile(element.source, element.target, (err) => {
        callback(element.source, element.target, err)
    });
  });

  }
  // Example event: { kind: "create", paths: [ "/home/alice/deno/foo.txt" ] }
}