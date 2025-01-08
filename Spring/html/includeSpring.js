/**
 * @author plaza
 */
	
dojo.require("dojo.io.iframe");
dojo.require("dijit.ProgressBar");
dojo.require("dijit.form.Button");
dojo.require("dojo.parser");

var href = window.location.href;

var url_path = "/cgi-bin/Spring";

if (href.indexOf("plaza", 1) > -1) {
	url_path = "/cgi-bin/plaza/Spring";
}

var url_loadfile = url_path + "/upload_file.pl";
//var url_loadfile2 = url_path + "/upload_file2.pl";
var url_pythonSpring = url_path + "/SPRING_dev/";
var url_passwd = url_path + "/user_app.pl";

function param( name )
{
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );

  if( results == null )
    return "";
  else
    return results[1];
}
var href = window.location.href;

function standbyShow() {
	myStandby.show(); 
 	standby.show(); 
}

function standbyHide() {
	standby.hide();
	myStandby.hide();
};

function sendData_noOKwindow(url){
	var xhrArgs = {
       		url: url,
 		handleAs: "json",
		preventCache: false,
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
			}
			if (data["status"] == "Error"){
				textError.setContent(data["message"]);
				myError.show();

			}            
		},
		error: function(error) {
			if (error=="504") {
				textError.setContent("Reload Spring because of <b>Time-out Error:</b> " + error);
			} else if (error=="414") {
				textError.setContent("<b>Request too long:</b> Split your Request please" + error);
			} else {
				textError.setContent("Reload Spring because of <b>Status Error:</b> " + error);
			}
			myError.show();
			return;
		}
	}
	var deferred = dojo.xhrGet(xhrArgs);
	return deferred;
}

function sendData_noWindow(url){
	var xhrArgs = {
       		url: url,
 		handleAs: "json",
		preventCache: false,
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
			}
			if (data["status"] == "Error"){
				textError.setContent(data["message"]);

			}            
		},
		error: function(error) {
			if (error=="504") {
				textError.setContent("Reload Spring because of <b>Time-out Error:</b> " + error);
			} else if (error=="414") {
				textError.setContent("<b>Request too long:</b> Split your Request please" + error);
			} else {
				textError.setContent("Reload Spring because of <b>Status Error:</b> " + error);
			}
		}
	}
	var deferred = dojo.xhrGet(xhrArgs);
	return deferred;
}

function sendData(url,no_winOK,no_standby){
	if (no_standby==0) {
		myStandby.show(); 
 		standby.show();
	}
	var xhrArgs = {
       		url: url,
 		handleAs: "json",
		preventCache: false,
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
				//if ( ! no_winOK) {myMessage.show() };
				//myMessage.hide();
				if (no_winOK==0) {myMessage.show() };
			} else {
				textError.setContent(data["message"]);
				myError.show();
			}            
			if (no_standby==0) {
				standby.hide();
 				myStandby.hide();
			}
		},
		error: function(error) {
			if (no_standby==0) {
				standby.hide();
 				myStandby.hide();
			}
			if (error=="504") {
				textError.setContent("Reload polyProjectNGS because of <b>Time-out Error:</b> " + error);
			} else if (error=="414") {
				textError.setContent("<b>Request too long:</b> Split your Request please" + error);
			} else {
				textError.setContent("Reload polyProjectNGS because of <b>Status Error:</b> " + error);
			}
			myError.show();
			return;
		}
	}
	var deferred = dojo.xhrGet(xhrArgs);
	return deferred;
}

function sendData_nomessage(url){
	var xhrArgs = {
       		url: url,
 		handleAs: "json",
		preventCache: false,
       		load: function(data, ioargs){
			return
		},
		error: function(error) {
			standby.hide();
 			myStandby.hide(); 
			if (error=="504") {
				textError.setContent("Reload polyProjectNGS because of <b>Time-out Error:</b> " + error);
			} else if (error=="414") {
				textError.setContent("<b>Request too long:</b> Split your Request please" + error);
			} else {
				textError.setContent("Reload polyProjectNGS because of <b>Status Error:</b> " + error);
			}
			myError.show();
			return;
		}
	}
	var deferred = dojo.xhrGet(xhrArgs);
	return deferred;
}

var hideTooltipField = function(e) {
	dijit.hideTooltip(e.cellNode);
};


var showTooltipField = function(e) {
	var msgfield;
	if (e.rowIndex < 0) { // header grid
		msgfield = e.cell.field;
	};
	if (msgfield) {
		var classmsg = "<i class='tooltip'>";
		if(msgfield=="out") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_green.png'>" +
			"<B>Complete Project"  + "<br>" +
			"<img src='icons/bullet_red.png'>" +
			"<B>Failed Project" + "<br>" +
			"</i>", e.cellNode,['above']);		
		} 

	}
}; 







