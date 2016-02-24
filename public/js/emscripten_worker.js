var csrf_token = "";
var doGrade = false;
var demo = false;

responseHandler = function() {
  if (this.status == 200 && this.readyState == this.DONE) {
    var result = JSON.parse(this.responseText);
    self.postMessage(result);
    if (result["result"].exit == 0) {
      try {
        self.postMessage({notification: "starting"});
        var emFunc = new Function("doGrade", "validators", result["result"].programtext);
//        eval(result["result"].programtext);
        var validators = result["result"].validators;
        emFunc(doGrade, validators);
      }
      catch (e) {
        self.postMessage({error: "Oops! Your program didn't finish running. Check your code and try again.\n", details: e.toString()});
      }
    }
  }
  if ((this.readyState == this.DONE) && !doGrade) {
    self.postMessage({notification: "done"});
  }
};

demoHandler = function() {
  if (this.status == 200 && this.readyState == this.DONE) {
    try {
      self.postMessage({notification: "starting"});
      var emFunc = new Function("doGrade", "validators", this.responseText);
      emFunc(false, []);
    }
    catch (e) {
      self.postMessage({error: "Oops! Your program didn't finish running. Check your code and try again.\n", details: e.toString()});
    }
  }
  if ((this.readyState == this.DONE)) {
    self.postMessage({notification: "done"});
  }
};


onmessage = function (oEvent) {
  if (oEvent.data.csrf_token) {
    csrf_token = oEvent.data.csrf_token;
  }
  else if ('exercise_id' in oEvent.data) {
    if (oEvent.data.doGrade) {
      doGrade = oEvent.data.doGrade;
    }
    var req = new XMLHttpRequest();
    req.open("POST", "/exercises/" + oEvent.data.exercise_id + "/compile", true);
    req.onreadystatechange = responseHandler;
    req.setRequestHeader("Accept", "application/json");
    req.setRequestHeader("Content-Type", "application/json");
    req.setRequestHeader("X-CSRF-Token", csrf_token);
    req.send(JSON.stringify({code: oEvent.data.code}));
    self.postMessage({notification: "compiling (POST)"});
  }
  else if ('demo' in oEvent.data) {
    demo = true;
    var req = new XMLHttpRequest();
    req.open("GET", "/js/demo" + oEvent.data.demo + ".js", true);
    req.onreadystatechange = demoHandler;
    req.setRequestHeader("Accept", "text/plain,text/javascript");
    req.send();
  }
  else if (oEvent.data.command) {
    if (oEvent.data.command == "quit") {
      self.close();
    }
  }
};

