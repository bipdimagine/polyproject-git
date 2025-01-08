/**
 * @author plaza
 */
dojo.require("dijit.form.Button");
dojo.require("dojo.parser");
dojo.require("dijit.Dialog");
dojo.require("dijit.ProgressBar");

function sendUploadSimpleFileForm() {
 	var type_file = dojo.byId('param_file').value;
 	standbyShow();
	var directory = dojo.byId('param_dir').value;
	dojo.style(dojo.byId('inputLoadField'), "display", "none");    
	dojo.style(dojo.byId('progressLoadFile'), "display", "inline");
	dojo.byId('preambleFile').innerHTML = "Uploading ...";
 	var upfoped =  document.getElementById("uploadFormFile");

	sendDataLoadFile(url_loadSamplefile,upfoped,directory,type_file);
	dojo.style(dojo.byId('inputLoadField'), "display", "inline");
	dojo.style(dojo.byId('progressLoadFile'), "display", "none");
	div_uploadFile.hide();
}

function sendDataLoadFile(url,upfoped,directory,type_file){
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
			var shortf = dijit.byId("ShortF");
          		var foo = dojo.fromJson(response);
			if (foo.status == "OK") {
				var filename=response.split(":")[4].split(" ")[0];
				if (type_file == "runFile") {dojo.byId('runFile').value =filename;}
				shortf.set("value",foo.sheet);
				textMessage.setContent(foo.message);
				myMessage.show();
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

