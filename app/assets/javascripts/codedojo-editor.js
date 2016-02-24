$(function () {
  if (window.openDatabase) {
    db = openDatabase('codedojo_input', '1.0', 'Emscripted input', 1024);
    db.transaction(function(tx) {
      tx.executeSql('DROP TABLE IF EXISTS input');
      tx.executeSql('CREATE TABLE input (text)');
    });
  }
  var resultHandler = function() {
    if (this.status == 200 && this.readyState == this.DONE) {
      /* TODO actually handle returning from result POST call */
    }
  };

  var jqconsole = $('#console').jqconsole('', '>>> ');
  jqconsole.Write('Welcome to the CodeDojo console!\n\n', 'jqconsole-output');

  var worker;

  var termButton = document.getElementById("termButton");
  var compileButton = document.getElementById("compileButton");
  var gradeButton = document.getElementById("gradeButton");
  var clearButton = document.getElementById("clearButton");
  var nextButton = document.getElementById("nextButton");
  var csrf_token = $('meta[name="csrf-token"]')[0].getAttribute("content");

  compileButton.onclick = function() {
    compileButton.disabled = true;
    gradeButton.disabled = true;
    termButton.disabled = false;
    worker = new Worker("/js/emscripten_worker.js");
    worker.postMessage({csrf_token: csrf_token});
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
        if (oEvent.data.result) {
          if (oEvent.data.result.exit != 0) {
            jqconsole.Write("We couldn't compile your program!\n", 'jqconsole-info');
            jqconsole.Write(oEvent.data.result.stderr + "\n", 'jqconsole-error');
            termButton.disabled = true;
            compileButton.disabled = false;
            gradeButton.disabled = false;
          }
          else {
            if (oEvent.data.result.stderr) {
              jqconsole.Write("We compiled your program, but there were some warnings...\n", 'jqconsole-info');
              jqconsole.Write(oEvent.data.result.stderr + "\n", 'jqconsole-warning');
            }
          }
        }
        if (oEvent.data.notification) {
          if (oEvent.data.notification.indexOf("compiling") != -1) {
            jqconsole.Write("Compiling your program...\n", 'jqconsole-info');
          }
          else if (oEvent.data.notification == "starting") {
            jqconsole.Write("Starting your program\n", 'jqconsole-info');
          }
          else if (oEvent.data.notification == "done") {
            jqconsole.Write("\nFinished running\n", 'jqconsole-info');
            termButton.disabled = true;
            compileButton.disabled = false;
            gradeButton.disabled = false;
            worker.postMessage({command: "quit"});
            if (worker)
              worker = null;
          }
        }
        console.log(oEvent.data);
      }
    };
    worker.postMessage({doGrade: false, exercise_id: window.CDGlobals.exercise_id, code: window.codeFiles, loggedIn: window.CDGlobals.isLoggedIn});
  };
  gradeButton.onclick = function() {
    compileButton.disabled = true;
    gradeButton.disabled = true;
    termButton.disabled = false;
    worker = new Worker("/js/emscripten_worker.js");
    worker.postMessage({csrf_token: $('meta[name="csrf-token"]')[0].getAttribute("content")});
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
        if (oEvent.data.result) {
          if (oEvent.data.result.exit != 0) {
            jqconsole.Write("We couldn't compile your program!\n", 'jqconsole-info');
            jqconsole.Write(oEvent.data.result.stderr + "\n", 'jqconsole-error');
            termButton.disabled = true;
            compileButton.disabled = false;
            gradeButton.disabled = false;
          }
          else {
            if (oEvent.data.result.stderr) {
              jqconsole.Write("We compiled your program, but there were some warnings...\n", 'jqconsole-info');
              jqconsole.Write(oEvent.data.result.stderr + "\n", 'jqconsole-warning');
            }
          }
        }
        if (oEvent.data.notification) {
          if (oEvent.data.notification.indexOf("compiling") != -1) {
            jqconsole.Write("Compiling your program...\n", 'jqconsole-info');
          }
          else if (oEvent.data.notification == "starting") {
            jqconsole.Write("Grading your program\n", 'jqconsole-info');
          }
          else if (oEvent.data.notification == "done") {
            termButton.disabled = true;
            compileButton.disabled = false;
            gradeButton.disabled = false;
            if (worker)
              worker.postMessage({command: "quit"});
            worker = null;

            var passed;
            if (oEvent.data.failed == 0) {
              passed = true;
              jqconsole.Write("Pass!\n", 'jqconsole-info');
							$('#passModal').modal('show');
              /* Report status */
            }
            else {
              passed = false;
              jqconsole.Write("We found some problems with your program...\n", 'jqconsole-warning');
              if (oEvent.data.rt_stdout)
                jqconsole.Write(oEvent.data.rt_stdout, 'jqconsole-error');
              if (oEvent.data.rt_stderr)
                jqconsole.Write(oEvent.data.rt_stderr, 'jqconsole-error');
              if (oEvent.data.validator_e)
                jqconsole.Write(oEvent.data.validator_e + '\n', 'jqconsole-error');
            }
            /* Don't POST to server if user has already finished this exercise */
            if (window.CDGlobals.isLoggedIn && !window.CDGlobals.exerciseCorrect) {
              var req = new XMLHttpRequest();
              req.open("POST", "/results.json", true);
              req.onreadystatechange = resultHandler;
              req.setRequestHeader("Accept", "application/json");
              req.setRequestHeader("Content-Type", "application/json");
              req.setRequestHeader("X-CSRF-Token", csrf_token);
              req.send(JSON.stringify({exercise_id: window.CDGlobals.exercise_id, is_correct: passed}));
            }
            if (passed)
              window.CDGlobals.exerciseCorrect = true;
          }
        }
        console.log(oEvent.data);
      }
    };
    worker.postMessage({doGrade: true, exercise_id: window.CDGlobals.exercise_id, code: window.codeFiles, loggedIn: window.CDGlobals.isLoggedIn});
  };
  termButton.onclick = function() {
    if (worker) {
      termButton.disabled = true;
      compileButton.disabled = false;
      gradeButton.disabled = false;
      jqconsole.Write("Terminating...\n", 'jqconsole-info');
      worker.terminate();
      worker = null;
    }
  };
  clearButton.onclick = function() {
    jqconsole.Reset();
  };
  nextButton.onclick = function() {
    if (window.CDGlobals.exerciseCorrect)
      window.location.href='/exercises/' + window.CDGlobals.exercise_id + '/next';
    else
      $('#nextModal').modal('show');
  };
});
