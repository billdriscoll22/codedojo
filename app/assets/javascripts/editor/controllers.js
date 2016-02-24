angular.module('Editor.controllers', ['Editor.services']).
  controller('FileController', ['$scope', '$routeParams', '$window', '$timeout', 'File', 'exercise_id', 'isLoggedIn', 'proj_type',
             function($scope, $routeParams, $window, $timeout, File, exercise_id, isLoggedIn, proj_type) {
  $scope.files = File.getFiles();
  $scope.isLoggedIn = isLoggedIn;

  $window.codeFiles = $scope.files;
  $scope.save = function() {
    console.log($scope.files[$routeParams.index]);
    $scope.files[$routeParams.index].$save(function() {
      $scope.files[$routeParams.index].isClean = true;
      $window.codeFiles = $scope.files;
    });
  };

  $scope.revert = function() {
    if (isLoggedIn) {
      var file = $scope.files[$routeParams.index];
      file.$revert();
    }
    else {
      File.revertFile($routeParams.index);
    }
    $scope.files[$routeParams.index].isClean = true;
  };

  $scope.dirtiedFile = function() {
    $timeout(function() {
      $scope.files[$routeParams.index].isClean = false;
    }, 1);
  };

  if (proj_type == 'c++')
    mode = "text/x-c++src";
  else
    mode = "text/x-csrc";

  $scope.editorOpts = {onChange: $scope.dirtiedFile, mode: mode, theme: "solarized light", lineNumbers: true, indentUnit: 4, indentWithTabs: true,
                        styleActiveLine: true, autoCloseBrackets: true, matchBrackets: true, continueComments: true};

  $scope.selectedIndex = $routeParams.index;
}]);
