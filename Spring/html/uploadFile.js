/**
 * @author plaza
 */
dojo.require("dijit.form.Button");
dojo.require("dojo.parser");
dojo.require("dijit.Dialog");
dojo.require("dijit.ProgressBar");

function sendUploadSimpleFileForm() {
 	var type_file = dojo.byId('param_file').value;
 	var force = dojo.byId('param_force').value;
	var user_dir = dojo.byId('param_user').value;
	if(username != user_dir) {
		textError.setContent("Error User account. Please Reload or re-Connect...");
		myError.show();
		div_uploadFile.hide();
		hide_logout();
		return;
	}
	standbyShow();
	var directory = dojo.byId('param_dir').value;
	dojo.style(dojo.byId('inputLoadField'), "display", "none");    
	dojo.style(dojo.byId('progressLoadFile'), "display", "inline");
	dojo.byId('preambleFile').innerHTML = "Uploading ...";
 	var upfoped =  document.getElementById("uploadFormFile");

//	dojo.byId('param_source').value ="/poly-disk/poly-src/Spring/cgi-bin/SPRING_dev";
	sendDataLoadFile(url_loadfile,upfoped,directory,type_file,user_dir);
// 	sendDataLoadFile(url_loadfile2,upfoped,directory,type_file,user_dir);
	dojo.style(dojo.byId('inputLoadField'), "display", "inline");
	dojo.style(dojo.byId('progressLoadFile'), "display", "none");
	div_uploadFile.hide();
}

function sendDataLoadFile(url,upfoped,directory,type_file,user_dir){
	dojo.io.iframe._currentDfd = null;
	if (this._deferred) {
    		this._deferred.cancel();
	}
	this._deferred=dojo.io.iframe.send({
        	url: url,
                contentType: "multipart/form-data",
		method: "post",
		handleAs: "text",
        	form: upfoped,  
		load: function(response, ioArgs){
           		var foo = dojo.fromJson(response);
			if (foo.status == "OK") {
				var filename=response.split(":")[3].split(" ")[0];
				if (type_file == "firstFile") {dojo.byId('firstFile').value =filename;}
				if (type_file == "secondFile") {dojo.byId('secondFile').value =filename;}
				if (type_file == "cellsFile") {dojo.byId('cellsFile').value =filename;}
				if (type_file == "genesetsFile") {dojo.byId('genesetsFile').value ="geneset_"+filename;}
				//if (type_file == "customColorFile") {dojo.byId('customColorFile').value ="customcolor_"+filename;}
				if (type_file == "customColorFile") {dojo.byId('customColorFile').value =filename;}
				dijit.byId("btn_force").set('checked', false);
				textMessage.setContent(foo.message);
				myMessage.show();
				checkButton(type_file);
            		} else {
				textError.setContent(foo.message);
				myError.show();
            		}   
 			standbyHide();
 		},
		error:function(response, ioArgs){
			console.log(response);
			console.log("Not Good in sendDataLoadFile");
		} 
    	}); 
}

