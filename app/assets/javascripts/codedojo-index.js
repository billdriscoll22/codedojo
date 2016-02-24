$(function () {
  if (window.openDatabase) {
    db = openDatabase('codedojo_input', '1.0', 'Emscripted input', 1024);
    db.transaction(function(tx) {
      tx.executeSql('DROP TABLE IF EXISTS input');
      tx.executeSql('CREATE TABLE input (text)');
    });
  }

  var jqconsole = $('#console').jqconsole('', '>>> ');
  jqconsole.Write('Welcome to the CodeDojo console!\n\n', 'jqconsole-output');

  var worker;

  var runButton = document.getElementById("runButton");
  var demoTabs = [$('#cd-demo-p1')[0],
                  $('#cd-demo-p2')[0],
                  $('#cd-demo-p3')[0],
                  $('#cd-demo-p4')[0] ];

  runButton.onclick = function() {
    jqconsole.Reset();

    var activeIndex = 0;
    for (var i = 0; i < demoTabs.length; i++) {
      if (demoTabs[i].classList.contains("active")) {
        console.log("activeIndex: " + i);
        activeIndex = i;
        break;
      }
    }

    runButton.disabled = true;
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
          jqconsole.Write(oEvent.data.details + "\n", 'jqconsole-error');
        }
        if (oEvent.data.notification) {
          if (oEvent.data.notification == "starting") {
            jqconsole.Write("Starting your program\n", 'jqconsole-info');
          }
          else if (oEvent.data.notification == "done") {
            jqconsole.Write("\nFinished running\n", 'jqconsole-info');
            runButton.disabled = false;
            worker.postMessage({command: "quit"});
            if (worker)
              worker = null;
          }
        }
        console.log(oEvent.data);
      }
    };
    worker.postMessage({demo: activeIndex});
  };
});
