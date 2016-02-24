$(function () {
  if (window.openDatabase) {
    db = openDatabase('codedojo_input', '1.0', 'Emscripted input', 1024);
    db.transaction(function(tx) {
      tx.executeSql('DROP TABLE IF EXISTS input');
      tx.executeSql('CREATE TABLE input (text)');
    });
  }

  var jqconsole = $('#console').jqconsole('Welcome to the CodeDojo console!\n\n', '>>> ');

  var usercodeTextarea = document.getElementById("usercode_textarea");
  var worker;
  usercodeTextarea.value = "#include <stdio.h>\n\nint main(int argc, char *argv[]) {\n\tprintf(\"Hello, world!\\n\");\n\treturn 0;\n}\n";
  var codeMirrorOpts = {mode: "text/x-csrc", theme: "solarized light", lineNumbers: true, indentUnit: 4, indentWithTabs: true,
                        styleActiveLine: true, autoCloseBrackets: true, matchBrackets: true, continueComments: true};
  var codeMirrorInstance = CodeMirror.fromTextArea(usercodeTextarea, codeMirrorOpts);

  var termButton = document.getElementById("termButton");
  var compileButton = document.getElementById("compileButton");

  document.getElementById("compileButton").onclick = function() {
    compileButton.disabled = true;
    termButton.disabled = false;
    worker = new Worker("/js/emscripten_worker.js");
    worker.onmessage = function(oEvent) {
      if (oEvent.data) {
        if (oEvent.data.readline) {
          // readline requested by worker
          console.log("Requesting input");
          if (db) {
            jqconsole.Input(function(input) {
              //worker.postMessage({channel: "stdin", line: input});
              db.transaction(function (tx) {
                tx.executeSql("INSERT INTO input (text) VALUES (?)", [input]);
              });
            });
          }
        }
        if (oEvent.data.channel) {
          if (oEvent.data.channel == "stdout") {
            jqconsole.Write(oEvent.data.line, 'jqconsole-output');
          }
          else if (oEvent.data.channel == "stderr") {
            jqconsole.Write(oEvent.data.line, 'jqconsole-error');
          }
        }
        if (oEvent.data.error) {
          jqconsole.Write(oEvent.data.error, 'jqconsole-runtimeerror');
        }
        if (oEvent.data.result) {
          if (oEvent.data.result.exit != 0) {
            jqconsole.Write("We couldn't compile your program!\n", 'jqconsole-info');
            jqconsole.Write(oEvent.data.result.stderr + "\n", 'jqconsole-error');
          }
          else {
            if (oEvent.data.result.stderr) {
              jqconsole.Write("We compiled your program, but there were some warnings...\n", 'jqconsole-info');
              jqconsole.Write(oEvent.data.result.stderr + "\n", 'jqconsole-warning');
            }
          }
        }
        if (oEvent.data.notification) {
          if (oEvent.data.notification == "compiling") {
            jqconsole.Write("Compiling your program...\n", 'jqconsole-info');
          }
          else if (oEvent.data.notification == "starting") {
            jqconsole.Write("Starting your program\n", 'jqconsole-info');
          }
          else if (oEvent.data.notification == "done") {
            termButton.disabled = true;
            compileButton.disabled = false;
            worker.postMessage({command: "quit"});
            worker = null;
          }
        }
        console.log(oEvent.data);
      }
    };
    worker.postMessage({"usercode": codeMirrorInstance.getValue()});
  };
  termButton.onclick = function() {
    if (worker) {
      termButton.disabled = true;
      compileButton.disabled = false;
      jqconsole.Write("Terminating...\n", 'jqconsole-info');
      worker.terminate();
      worker = null;
    }
  };
  document.getElementById("clearButton").onclick = function() {
    jqconsole.Reset();
  };
});
