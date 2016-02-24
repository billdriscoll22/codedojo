debug=false;
editor=null;
var testFileTemplate = "#include <stdio.h>\n\n/* Add function prototypes that you expect the user to have. For example:\n   int sum(int, int); */\n\n/* This function is called by the runtime to validate the user's program.\n   Fill in the body yourself, and return 0 for success, nonzero for failure\n   Call printf to give feedback to the user's console. */\n\n#ifdef __cplusplus\nextern \"C\"\n#endif\nint runTests() {\n    return 0;\n}\n";
var sourceFileTemplate = "/* Replace this template with your own content */\n\nint main(int argc, char *argv[]) {\n    return 0;\n}"
var validatorTemplate = "/* Validators are JavaScript snippets that will ensure a program's output matches\n   what was expected.\n   You can use the following arguments in your code:\n      stdout: a string containing all output from stdout\n      stderr: a string containing all output from stderr\n      args: an array of strings containing arguments to the program\n      retVal: an integer, the return value of main\n\n   Use 'return true;' to indicate success; otherwise use 'throw \"message here\";' */\n\n";

var tcApp = angular.module('tcApp',['ui.codemirror']);
tcApp.config(['$routeProvider','$httpProvider',function($routeProvider,$httpProvider){
	  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

tcApp.controller('TutorialController',['$scope', '$http', function($scope,$http){
	$scope.tutorialName='Sample Tutorial';
	$scope.category_id=1;
	$scope.description='Description';
	$scope.difficultyLevels=[{name:'Beginner',value:0},{name:'Advanced Beginner',value:1},{name:'Competent',value:2},{name:'Proficient',value:3},{name:'Expert',value:4}];
	$scope.difficulty=0;
	$scope.editorOpts={mode: "text/x-csrc", theme: "solarized light", lineNumbers: true, indentUnit: 4, indentWithTabs: true,
            styleActiveLine: true, autoCloseBrackets: true, matchBrackets: true, continueComments: true};
	$scope.jsEditorOpts={mode: "javascript", theme: "solarized light", lineNumbers: true, indentUnit: 4, indentWithTabs: true,
            styleActiveLine: true, autoCloseBrackets: true, matchBrackets: true, continueComments: true};
	$scope.sections=[	{title:'section 0', 
						content:'content 0', 
						subtitle:'Description 0', 
						exercises:[{proj_type:'c',content:'Econtent 0', 
									templates:[{fileName:'template',should_compile:true,code:sourceFileTemplate}], 
									testing_file:testFileTemplate,validators:[{validator:validatorTemplate,args:''}]}]}];
	editor = new EpicEditor({container:'epiceditor',clientSideStorage:false,basePath:'/tutorials/epiceditor'}).load();
	$scope.activeFile=null;
	$scope.addSection=function(){
		sectionIndex=$scope.sections.length;
		//var newExercise = {content:'Econtent ', templates:[{fileName:'template0', should_compile:true, code:'#include <stdio.h>\n\n//Write the template of this exercise here.'}], testing_file:'//Write your testing file here (e.g. validate/print out values returned\n //by functions and programs implemented by the user)'};
		var newSection = {	title:'section '+sectionIndex, 
							subtitle:'Description '+sectionIndex,
							content:'content '+sectionIndex,
							exercises:[]};
		$scope.sections.push(newSection);
	};
	
	$scope.displayData=function(){
		alert(JSON.stringify({name:$scope.tutorialName,description:$scope.description,category_id:$scope.category_id,difficulty:$scope.difficulty})+'\n'+
			  JSON.stringify($scope.sections));
	}
	
	$scope.addExercise=function(section){
		var numExercises = section.exercises.length;
		var newExercise = {proj_type:'c',content:'Econtent '+numExercises, templates:[{fileName:'template', should_compile:true, code:sourceFileTemplate}], testing_file:testFileTemplate,validators:[]};
		section.exercises.push(newExercise);
	
	}
	
	$scope.addTemplate=function(exercise){
		var newTemplate={fileName:'template',should_compile:true,code:sourceFileTemplate};
		exercise.templates.push(newTemplate);
	}
	
	$scope.submitTutorial=function(){
		var validates = $scope.validateTemplateNames();
		if(validates!=null){
			$('#template-names-error-message').html(validates);
			$('#template-names-error').modal('show');
			return;
		}
			
		$scope.saveEditor();
		var tags_list = $("[name='hidden-tags']").val()
		var newTutorial={title:$scope.tutorialName,description:$scope.description,difficulty:$scope.difficulty,category_id:$scope.category_id,sections:$scope.sections};
		$http({method:'POST', url:'/tutorials.json',data:{tutorial:newTutorial,tags:tags_list}}).
			success(function(data,status,headers,config){
				window.location.replace('/tutorials/'+data.id);
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
		exercise.templates.splice(templateIndex,1);
		$('.template-modal').modal('hide');
	}
	$scope.setRefreshEventOnModals=function(){
		$('.modal').on('shown',refreshCodeMirror);
	}
	$scope.removeSection=function(index){
		$scope.saveEditor();
		$scope.activeFile=null;
		$scope.sections.splice(index,1)
		$('.fade').addClass('in')
	}
	
	$scope.removeExercise=function(section,index){
		$scope.saveEditor();
		$scope.activeFile=null;
		section.exercises.splice(index,1)
		$('.fade').addClass('in')
	}
	
	$scope.addValidator=function(exercise){
		if (exercise['validators']==null)
			exercise['validators']=[]
		exercise.validators.push({validator:validatorTemplate,args:''})
	}
	$scope.removeValidator=function(exercise,index){
		exercise.validators.splice(index,1);
		$('.template-modal').modal('hide');
	}
	
	$scope.loadEpicEditor=function(sectionIndex,exerciseIndex){
		if($scope.activeFile==null){
			$scope.activeFile={section:sectionIndex,exercise:exerciseIndex}
			lessonText = $scope.sections[sectionIndex].exercises[exerciseIndex].content
			editor.importFile('file',lessonText)
			return
		}
		
		if(sectionIndex==$scope.activeFile.section && exerciseIndex==$scope.exercise)
			return
		
		$scope.saveEditor();
		nextExercise=$scope.sections[sectionIndex].exercises[exerciseIndex]
		editor.importFile('file',nextExercise.content);
		$scope.activeFile={section:sectionIndex,exercise:exerciseIndex}
	}
	
	$scope.saveEditor=function(){
		if ($scope.activeFile==null)
			return
		aFile=$scope.activeFile;
		exercise=$scope.sections[aFile.section].exercises[aFile.exercise];
		exercise.content=editor.exportFile();
	}
	$scope.validateTemplateNames=function(){
		for(var i=0;i<$scope.sections.length;i++){
			section=$scope.sections[i];
			for(var j=0;j<section.exercises.length;j++){
				exercise=section.exercises[j];
				var pattern=null;
				if(exercise.proj_type=='c')
					pattern=new RegExp('^[0-9a-zA-Z_]+(.c|.h)$')
				else
					pattern=new RegExp('^[0-9a-zA-Z_]+(.cpp|.h|.hpp)$')
				var existingnames={}
				for(var k=0; k<exercise.templates.length;k++){
					template=exercise.templates[k];
					if(!pattern.test(template.fileName))
						return 'Template name \''+template.fileName+
								'\' is invalid. Template names must only have letters, numbers and underscores. It must also end in .c for c exercises and .cpp for c++ exercises.'
					if (existingnames[template.fileName]!=null)
						return 'Template name \''+template.file_name+
						'\' is not unique within its exercise.';
					
					existingnames[template.fileName]=true
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
