
if (doGrade) {
  // run normal tests
  var numFailed = 0;
  if (Module['_runTests']) {
    runTests = Module.cwrap('runTests', 'number', []);
    try {
      numFailed = runTests();
      Module["stdout"](null);
      Module["stderr"](null);
    }
    catch (e) {
      self.postMessage({error: "Oops! Your program didn't finish running. Check your code and try again.\n", details: e.toString()});
      numFailed++;
    }
  }
  var runTests_stdout = stdout_grade;
  var runTests_stderr = stderr_grade;
  var validator_e;

  if (numFailed == 0 && validators) {
    // run validators
    for (var i = 0; i < validators.length; i++) {
      var validator = new Function("stdout", "stderr", "args", "retVal", validators[i].validator);
      var args = validators[i].args;
      if (args && args.length > 0)
        args = args.split(" ");
      else
        args = [];
      try {
        var retVal = Module.callMain(args);
        if (!validator(stdout_grade, stderr_grade, args, retVal))
          numFailed++;
      }
      catch (e) {
        validator_e = e.toString();
        numFailed++;
        break;
      }
    }
  }
  self.postMessage({notification: "done", failed: numFailed, rt_stdout: runTests_stdout, rt_stderr: runTests_stderr, validator_e: validator_e});
}
else {
  if (Module["_main"]) {
    try {
      var retVal = Module.callMain(args);
    }
    catch (e) {
      self.postMessage({error: "Oops! Your program didn't finish running. Check your code and try again.\n", details: e.toString()});
    }
  }
  else {
    /* No main function */
      self.postMessage({error: "Couldn't run your program!\n", details: "No main() function was found"});
  }
}

// Force flushing of stdout and stderr, otherwise we may miss
// some output

Module["stdout"](null);
Module["stderr"](null);
