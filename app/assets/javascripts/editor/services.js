angular.module('Editor.services', ['ngResource']).
  factory('File', ['$resource', 'exercise_id', function($resource, exercise_id) {
  var FileResource = $resource('/user_files/:fileID.json', {fileID: '@id'},
                               {'query': {method: 'GET', params: {fileID: 'all', exerciseID: exercise_id.toString()}, isArray: true},
                                'save': {method: 'PUT', params: {fileID: '@id'}, isArray: false},
                                'revert': {method: 'DELETE', params: {fileID: '@id'}, isArray: false}});
  var files;
  var origContents = [];
  return {
    getFiles: function() {
      if (files) {
        return files;
      }
      else {
        files = FileResource.query(function() {
          for (var i = 0; i < files.length; i++) {
            files[i].isClean = true;
            origContents.push(files[i].content);
          }
        });
        return files;
      }
    },
    revertFile: function(index) {
      files[index].content = origContents[index];
    }
  };
}
]);
