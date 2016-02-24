angular.module('Editor', ['Editor.controllers', 'Editor.services', 'ui.codemirror']).
  config(['$routeProvider', '$httpProvider', function($routeProvider, $httpProvider) {
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
  $routeProvider.
    when('/:index', {templateUrl: '/ngpartials/editor.html', controller: 'FileController'}).
    otherwise({redirectTo: '/0'});
}]).
  constant('exercise_id', window.CDGlobals.exercise_id).
  constant('proj_type', window.CDGlobals.proj_type).
  constant('isLoggedIn', window.CDGlobals.isLoggedIn);

