import 'dart:io';

class ChildProcess {

    static String DENO_COMMAND = 'deno run -A --import-map=import_map.json --unstable .\\src\\start\\run.ts';
    var command = '';

    ChildProcess(String command) {
      this.command = command;
    }


    void run () {
      var commandListItem = this.command.split(' ');
      if (commandListItem.isNotEmpty) {
        // DEBUG
        
        // Process.run(commandListItem[0], commandListItem.sublist(1), workingDirectory: '..\\denkui\\').then((value) {
        //   stderr.write(value.stderr);
        //   stdout.write(value.stdout);
        // });
         
      }
    }

}