import 'dart:io';

class ChildProcessArg {
  String command;
  String cwd; 
  
  ChildProcessArg.from(String command, { String cwd = '.'}) {
    this.command = command;
    this.cwd = cwd;
  }
}

class ChildProcess {

    static ChildProcessArg DENO_COMMAND = ChildProcessArg.from('deno run -A --import-map=import_map.json --unstable .\\src\\start\\run.ts', cwd: './denkui');
    static ChildProcessArg PRE_PARE_DENKUI = ChildProcessArg.from('git clone -b dev git@github.com:kfdykme/denkui.git denkui');
    static ChildProcessArg UPDATE_DENKUI = ChildProcessArg.from('git pull --force', cwd: './denkui');
    var command = '';
    var cwd = '.';
    ChildProcess(ChildProcessArg arg) { 
      this.command = arg.command;
      this.cwd = arg.cwd;
    }


    void run ({ Function callback = (null)}) {
      print('ChildProcess run command: ${this.command} cwd: ${this.cwd}');
      var commandListItem = this.command.split(' ');
      if (commandListItem.isNotEmpty) {
        // DEBUG
        
        Process.run(commandListItem[0], commandListItem.sublist(1), workingDirectory: this.cwd, runInShell: true).then((value) {
          stderr.write(value.stderr);
          stdout.write(value.stdout);
          print('ChildProcess ${this.command} finish\n');
          if (callback != null) {
            callback();
          }
        });
         
      }
    }

}