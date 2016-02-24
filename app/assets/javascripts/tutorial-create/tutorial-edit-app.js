debug=false;
editor=null;
var testFileTemplate = "#include <stdio.h>\n\n/* Add function prototypes that you expect the user to have. For example:\n   int sum(int, int); */\n\n/* This function is called by the runtime to validate the user's program.\n   Fill in the body yourself, and return 0 for success, nonzero for failure\n   Call printf to give feedback to the user's console. */\n\n#ifdef __cplusplus\nextern \"C\"\n#endif\nint runTests() {\n    return 0;\n}\n";
var sourceFileTemplate = "/* Replace this template with your own content */\n\nint main(int argc, char *argv[]) {\n    return 0;\n}"
var validatorTemplate = "/* Validators are JavaScript snippets that will ensure a program's output matches\n   what was expected.\n   You can use the following arguments in your code:\n      stdout: a string containing all output from stdout\n      stderr: a string containing all output from stderr\n      args: an array of strings containing arguments to the program\n      retVal: an integer, the return value of main\n\n   Use 'return true;' to indicate success; otherwise use 'throw \"message here\";' */\n\n";

var tutorialEditApp = angular.module('tutorialEditApp',['ui.codemirror','ngResource']);

tutorialEditApp.config(['$routeProvider','$httpProvider',function($routeProvider,$httpProvider){
	  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);
editor=null;
tutorialEditApp.factory('tutorialFactory',['$http','$resource',function($http,$resource){
	
	factory={};
	var tutorialData={};
	var TutorialResource = $resource('/tutorials/'+tutorialID+'.json');
	tutorialData=TutorialResource.get(function(data,headers){
		for (var i=0;i<tutorialData.sections.length;i++){
			section = tutorialData.sections[i]
			for (var j=0; j<section.exercises.length;j++){
				exercise=section.exercises[j]
				if (exercise.test_files.length==0){
					exercise.test_files.push({file_name:"test.c",content:testFileTemplate})
				}
			}
		}
	});
		
	factory.getTutorial=function(){
			return tutorialData;
	}
	
	return factory;
}]);

tutorialEditApp.controller('TutorialEditController',['$scope', '$http','tutorialFactory',function($scope,$http,tutorialFactory){
	var tutorial=tutorialFactory.getTutorial();
	$scope.tutorial = tutorial;
	$scope.difficultyLevels=[{name:'Beginner',value:0},{name:'Advanced Beginner',value:1},{name:'Competent',value:2},{name:'Proficient',value:3},{name:'Expert',value:4}];
	$scope.difficulty=0;
	$scope.editorOpts={mode: "text/x-csrc", theme: "solarized light", lineNumbers: true, indentUnit: 4, indentWithTabs: true,
            styleActiveLine: true, autoCloseBrackets: true, matchBrackets: true, continueComments: true};
	$scope.jsEditorOpts={mode: "text/javascript", theme: "solarized light", lineNumbers: true, indentUnit: 4, indentWithTabs: true,
            styleActiveLine: true, autoCloseBrackets: true, matchBrackets: true, continueComments: true};
	editor = new EpicEditor({container:'epiceditor',clientSideStorage:false,basePath:'/tutorials/epiceditor'}).load();
	$scope.activeFile=null;
	$scope.addSection=function(){
		newSection = {subtitle:"New Section",content:"Describe what your section does.",exercises:[]}
		$scope.tutorial.sections.push(newSection);
	};
	
	$scope.displayData=function(){
		alert(JSON.stringify($scope.tutorial));
	}
	
	$scope.addExercise=function(section){
		var numExercises = section.exercises.length;
		var newExercise = {proj_type:'c',content:'Write your lesson text for this exercise here.', template_files:[{file_name:'template.c', should_compile:true, content:sourceFileTemplate}],test_files:[{file_name:"test.c",content: testFileTemplate}]};
		section.exercises.push(newExercise);
	}
	
	$scope.addTemplate=function(exercise){
		var newTemplate={file_name:'template.c',should_compile:true,content:sourceFileTemplate};
		exercise.template_files.push(newTemplate);
	}
	$scope.removeSection=function(sectionIndex){
		$scope.saveEditor();
		$scope.activeFile=null;
		$scope.tutorial.sections.splice(sectionIndex,1);
		$('.fade').addClass('in')
	}
	
	$scope.submitTutorial=function(){
		$scope.saveEditor();
		var validates= $scope.validateTemplateNames();
		if(validates!=null){
			$('#template-names-error-message').html(validates);
			$('#template-names-error').modal('show');
			return;
		}
		tagsList = $("[name='hidden-tags']").val()
		$http({method:'PUT', url:'/tutorials/'+$scope.tutorial.id,data:{tutorial:$scope.tutorial,tags:tagsList}}).
			success(function(data,status,headers,config){
				window.location.replace('/tutorials/'+$scope.tutorial.id);
			}).
			error(function(data,status,headers,config){
				$('#template-names-error-message').html('A server error occurred while submitting the tutorial.');
				$('#template-names-error').modal('show');
				if(debug==true){
					$('#errors').html(data);
				}
			});
	}
	
	$scope.deleteTemplate=function(exercise,templateIndex){
		exercise.template_files.splice(templateIndex,1);
		$('.template-modal').modal('hide');
	}
	$scope.setRefreshEventOnModals=function(){
		$('.modal').on('shown',refreshCodeMirror);
	}
	$scope.removeExercise=function(section,index){
		$scope.saveEditor();
		$scope.activeFile=null;
		section.exercises.splice(index,1)
		$('.fade').addClass('in')
	}
	$scope.addValidator=function(exercise){
		if (exercise['output_validators']==null)
			exercise['output_validators']=[]
		exercise.output_validators.push({validator:validatorTemplate,args:''})
	}
	$scope.removeValidator=function(exercise,index){
		exercise.output_validators.splice(index,1);
		$('.template-modal').modal('hide');
	}	
	$scope.loadEpicEditor=function(sectionIndex,exerciseIndex){		
		if($scope.activeFile==null){
			$scope.activeFile={section:sectionIndex,exercise:exerciseIndex}
			lessonText = $scope.tutorial.sections[sectionIndex].exercises[exerciseIndex].content
			editor.importFile('file',lessonText)
			return
		}
		
		if(sectionIndex==$scope.activeFile.section && exerciseIndex==$scope.exercise){
			//$scope.saveEditor();
			return
		}
		
		$scope.saveEditor();
		nextExercise=$scope.tutorial.sections[sectionIndex].exercises[exerciseIndex]
		editor.importFile('file',nextExercise.content);
		$scope.activeFile={section:sectionIndex,exercise:exerciseIndex}
	}
	
	$scope.saveEditor=function(){
		if ($scope.activeFile==null)
			return
		aFile=$scope.activeFile;
		exercise=$scope.tutorial.sections[aFile.section].exercises[aFile.exercise];
		exercise.content=editor.exportFile();
	}
	$scope.validateTemplateNames=function(){
		for(var i=0;i<$scope.tutorial.sections.length;i++){
			section=$scope.tutorial.sections[i];
			for(var j=0;j<section.exercises.length;j++){
				exercise=section.exercises[j];
				var pattern=null;
				if(exercise.proj_type=='c')
					pattern=new RegExp('^[0-9a-zA-Z_]+(.c|.h)$')
				else
					pattern=new RegExp('^[0-9a-zA-Z_]+(.cpp|.h|.hpp)$')
				var existingnames={};
				for(var k=0; k<exercise.template_files.length;k++){
					template=exercise.template_files[k];
					if(!pattern.test(template.file_name))
						return 'Template name \''+template.file_name+
								'\' is invalid. Template names must only have letters, numbers and underscores. It must also end in .c for c exercises and .cpp for c++ exercises.'
					if (existingnames[template.file_name]!=null)
						return 'Template name \''+template.file_name+
								'\' is not unique within its exercise.';
						
					existingnames[template.file_name]=true
				}
			}
		}
		
		return null;
	}
	
}]);


window.onload=function(){
	setRefreshEventOnModals();
};

function setRefreshEventOnModals(){
	$('.modal').on('shown',refreshCodeMirror);
}


function refreshCodeMirror(){
	$('.CodeMirror').each(function(i, el){
	    el.CodeMirror.refresh();
	});
}

function reflowEditors(){
	$('.modal').on('shown',function(){
		editor.reflow();
	})
}
