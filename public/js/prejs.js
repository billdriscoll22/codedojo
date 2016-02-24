var input_item = null;
var stdout_buf = "";
var stderr_buf = "";
var stdout_grade = "";
var stderr_grade = "";

if (self.openDatabaseSync) {
  var DB = self.openDatabaseSync('codedojo_input', '1.0', 'Emscripted input', 1024);
  self.codedojo_requestinput = function () {
    self.postMessage({readline: true});
    var t = null;
    DB.transaction(function (tx) {t=tx});
    var i, j, res;
    while (!(res = t.executeSql('SELECT * FROM input').rows).length) {
      for (i = 0; i < 100000000; i++);
    }
    t.executeSql('DELETE FROM input');
    return res.item(0).text;
  }
}


if (typeof(Module) === "undefined") Module = {};
var doTrace = true;
//Module["print"] =    function(s) { self.postMessage({channel: "stdout", line: s}); };
//Module["printErr"] =   function(s) { self.postMessage({channel: "stderr", line: s}); };

var flushWaitThreshold = null;
function waitToFlush() {
  var start = new Date();
  if (flushWaitThreshold) {
      for (var i = 0; i < 1e7; i++) {
        if (new Date() > flushWaitThreshold) {
          break;
        }
      }
  }
  var end = new Date();
  flushWaitThreshold = new Date(end.getTime() + 20);
}

if (doGrade) {
  Module["stdout"] =   function(c) {
    if (c != null && c != 10 && stdout_buf.length < 100) {
      stdout_buf += String.fromCharCode(c);
      return;
    }
    if (c == 10) {
      stdout_buf += '\n';
    }
    stdout_grade += stdout_buf;
    waitToFlush();
    stdout_buf = "";
  };
}
else {
  Module["stdout"] =   function(c) {
    if (c != null && c != 10 && stdout_buf.length < 100) {
      stdout_buf += String.fromCharCode(c);
      return;
    }
    if (c == 10) {
      stdout_buf += '\n';
    }
    self.postMessage({channel: "stdout", line: stdout_buf});
    waitToFlush();
    stdout_buf = "";
  };
}

if (doGrade) {
  Module["stderr"] =   function(c) {
    if (c != null && c != 10 && stdout_buf.length < 100) {
      stderr_buf += String.fromCharCode(c);
      return;
    }
    if (c == 10) {
      stderr_buf += '\n';
    }
    stderr_grade += stdout_buf;
    waitToFlush();
    stderr_buf = "";
  };
}
else {
  Module["stderr"] =   function(c) {
    if (c != null && c != 10 && stdout_buf.length < 100) {
      stderr_buf += String.fromCharCode(c);
      return;
    }
    if (c == 10) {
      stderr_buf += '\n';
    }
    self.postMessage({channel: "stderr", line: stderr_buf});
    waitToFlush();
    stderr_buf = "";
  };
}

if (doGrade) {
  /* TODO: add support for stdin */
}
else {
  Module["stdin"] =  function() {
    Module["stdout"](null);
    Module["stderr"](null);
    if (input_item && input_item.length != 0) {
      return input_item.shift().charCodeAt(0);
    }
    input_item = (codedojo_requestinput() + '\n').split('');
    return input_item.shift().charCodeAt(0);
  };
}

Module['noInitialRun'] = true;
Module['noExitRuntime'] = true;

