function Ajaxhelper(id) {
	this.xhr = new XMLHttpRequest();
	this.idField = id;
}

Ajaxhelper.prototype.setIdField = function(id) {
	this.idField = id;
}

Ajaxhelper.prototype.getIdField = function() {
	return this.id;
}

Ajaxhelper.prototype.sendGet = function (url, params, values, callback) {
	this.xhr.abort();
	this.xhr = new XMLHttpRequest();
	this.xhr.parent = this;
	this.xhr.onreadystatechange = callback;
	var queryString = url + '?';
	if(params.length != values.length) {
		console.log('params and values arrays must contain the same number of elements.');
		return;
	}
	for(var i = 0; i < params.length; ++i) {
		queryString += '&' + params[i] + '=' + encodeURIComponent(values[i]);
	}
	this.xhr.open("GET", queryString, true);
	this.xhr.send();
	console.log('Sent: ' + queryString); //to comment
}

Ajaxhelper.prototype.renderHtml = function() {
	if(this.readyState != 4) {
		return;
	}
	if(this.status != 200) {
		console.log('Request returns status: ' + this.status.toString());
		return;
	}
	var response = this.responseText;
	var container = document.getElementById(this.parent.idField);
	container.innerHTML = response;
	//console.log('Request returns: ' + response.toString()); //to comment
}

function searchClick(id) {
	var tagText = $('#tagText')[0];
	var categorySelect = $('#categorySelect')[0];
	var category = categorySelect.options[categorySelect.selectedIndex].value;
	var difficultySelect = $('#difficultySelect')[0];
	var difficulty = difficultySelect.options[difficultySelect.selectedIndex].value;
	var orderSelect = $('#orderSelect')[0];
	var order = orderSelect.options[orderSelect.selectedIndex].value;
	var isInverted = $('#isInverted')[0].checked;
	xhr.sendGet('/tutorials/search_tutorials', ['new_tag', 'remove_tag', 'category', 'difficulty', 'order', 'isInverted'], [tagText.value, id, category, difficulty, order, isInverted], xhr.renderHtml);
	tagText.value = "";
}

function rateClick(rating, userID, tutorialID) {
	xhr_rating.sendGet('/ratings/merge_rating', ['rating', 'userID', 'tutorialID'], [rating, userID, tutorialID], xhr_rating.renderHtml);
	$('#rating')[0].classList.add("label-warning");
}