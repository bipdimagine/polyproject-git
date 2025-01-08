/**
 * @author plaza
 */
dojo.require("dijit.form.Button");
dojo.require("dojo.parser");
dojo.require("dijit.Dialog");
dojo.require("dijit.ProgressBar");

function refreshTable(url1,grid){
	if (!allstore[url1]) {
		var store = readStore(url1);	
		grid.setStore(store);	
	}
	else {
		grid.setStore(allstore[url1]);
	}	
	return 1;
}

function sendDocForm(){
	dojo.style(dojo.byId('inputField'), "display", "none");
	dojo.style(dojo.byId('progressField'), "display", "inline");
	dojo.byId('preamble').innerHTML = "Uploading ...";
	var upfo =  document.getElementById("uploadForm");
	var el = document.getElementById("file_Runid");
    	el.value = selrun;
   	var rep=sendDocFile(url_ftpfile,upfo);
	dojo.style(dojo.byId('inputField'), "display", "inline");
    	dojo.byId('fileInput').value = '';
                
	dojo.style(dojo.byId('progressField'), "display", "none");
	div_addDocument.hide();
}

function sendDocFile(url,upfoped){
	dojo.io.iframe._currentDfd = null;
	var er= document.getElementById("runSamplesheet");
  	er.value = "";
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
				refreshOneRunDoc();
				textMessage.setContent(foo.message);
				myMessage.show();
            		} else {
				textError.setContent(foo.message);
				myError.show();
            		}
 		},
 		error:function(response, ioArgs){
			console.log(response);
			console.log("Not Good in sendDocFile");
		} 
    	}); 
}

function sendSampleForm(){
	dojo.style(dojo.byId('sampleinputField'), "display", "none");
	dojo.style(dojo.byId('sampleprogressField'), "display", "inline");
	dojo.byId('samplepreamble').innerHTML = "Uploading ...";
	var upfo =  document.getElementById("uploadSampleForm");

	var s_runName = document.getElementById("Rname").value;
	var s_runPltName = document.getElementById("PLTname").value;
	var en= document.getElementById("runName");
   	en.value = s_runName;
	var epn = document.getElementById("runPltName");
   	epn.value = s_runPltName;
 	var rep=sendSampleFile(url_ftpfile,upfo);
	dojo.style(dojo.byId('sampleinputField'), "display", "inline");
    	dojo.byId('samplefileInput').value = '';
                
	dojo.style(dojo.byId('sampleprogressField'), "display", "none");
	div_addSampleSheet.hide();
}

function sendSampleFile(url,upfoped){
	dojo.io.iframe._currentDfd = null;
	var er= document.getElementById("runSamplesheet");
  	er.value = "";
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
				var fileName=foo.message.split(" ")[1];
  				er.value = fileName;
				textMessage.setContent(foo.message);
				myMessage.show();
            		} else {
				textError.setContent(foo.message);
				myError.show();
            		}
 		},
 		error:function(response, ioArgs){
			console.log(response);
			console.log("Not Good in sendSampleFile");
		} 
    	}); 
}

function sendDataFile(url,upfo){
	dojo.io.iframe.send({
        url: url,
        method: "post",
	handleAs: "json",
        form: upfo   
    }); 
}

function sendPatientFileForm(){
	var o_optPat = document.getElementById("optPat").value;

    //Hide the file input field
	dojo.style(dojo.byId('inputField2'), "display", "none");
    
    //Show the progress bar
	dojo.style(dojo.byId('progressField2'), "display", "inline");
	dojo.byId('preamble2').innerHTML = "Uploading ...";
 	var upfoped =  document.getElementById("uploadForm2");
	var rep;
   	if (o_optPat=="insert") {rep=sendDataPatientFile(url_patientfile,upfoped);}
 	if (o_optPat=="insertBCG") {rep=sendDataPatientFileBCG(url_patientfile,upfoped);}

	//Show the file input field
	dojo.style(dojo.byId('inputField2'), "display", "inline");
    	dojo.byId('fileInput2').value = '';
                
	//Hide the progress bar
	dojo.style(dojo.byId('progressField2'), "display", "none");
	div_uploadPatientfile.hide();
	if (o_optPat=="insert") {
		dijit.byId("pat_col").set('checked', true);
		dijit.byId("pat_file").set('checked', false);
		dojo.style('patForm', 'display', '');
		dojo.style(dijit.byId('loadF').domNode, {visibility:'hidden'});
		//dojo.style('loadF', 'display', 'none');
		dijit.byId("a_pat_col").set('checked', true);
		dijit.byId("a_pat_file").set('checked', false);
		dojo.style('a_patForm', 'display', '');
		dojo.style(dijit.byId('a_loadF').domNode, {visibility:'hidden'});
	}
	if (o_optPat=="insertBCG") {
		dijit.byId("bcg_col").set('checked', true);
		dijit.byId("bcg_file").set('checked', false);
		dojo.style('bcgForm', 'display', '');
		dojo.style(dijit.byId('loadBCG').domNode, {visibility:'hidden'});
		//dojo.style('loadBCG', 'display', 'none');
	}
}

function sendDataPatientFile(url,upfoped){
	dojo.io.iframe.send({
        url: url,
        method: "post",
//	sync: true,
	handleAs: "text",
        form: upfoped,  
	load: function(response, ioArgs){
            	var foo = dojo.fromJson(response);
		var tmpStore = new dojo.store.Memory({data: foo.message});
		var resPat="";
		tmpStore.query({patname:/\w+/}).forEach(function(item, index){
			if (typeof(item.family)=="undefined"||item.family== null||/\s/.test(item.family)) {item.family=item.patname}
			if(index=="0") {
				if ((typeof(item.sex)=="undefined" || typeof(item.bc)=="undefined" || typeof(item.bc2)=="undefined")){
					item.family="Family";
					item.father="Father";
					item.mother="Mother";
					item.sex="Sex";
					item.status="Status";
					item.bc="BC";
					item.bc2="BC2";
					item.iv="IV";
					item.person="Person";
				}
			}
			if (typeof(item.sex)=="undefined"||item.sex==null||/\s/.test(item.sex)) {item.sex=1}
			if (typeof(item.status)=="undefined"||item.status==null||/\s/.test(item.status)) {item.status=2}
			if (typeof(item.bc)=="undefined"||item.bc==null||/\s/.test(item.bc)) {item.bc=""}
			if (typeof(item.bc2)=="undefined"||item.bc2==null||/\s/.test(item.bc2)) {item.bc2=""}
			if (typeof(item.iv)=="undefined"||item.iv==null||/\s/.test(item.iv)) {item.iv=""}
			if (typeof(item.person)=="undefined"||item.person==null||/\s/.test(item.person)) {item.person=""}
			resPat += item.patname+"\t"+item.family+"\t"+item.father+"\t"+item.mother+"\t"+item.sex+"\t"+item.status+"\t"+item.bc+"\t"+item.bc2+"\t"+item.iv+"\t"+item.person+"\n";
		});		
		//var lpat = dijit.byId("Rpatient");
		Rpatient.value=resPat;
		a_Rpatient.value=resPat;		
 		if (foo.status == "OK") {
			return foo.message;
            	} else {
			textError.setContent(foo.message);
			myError.show();
            	}          
	},
	error:function(response, ioArgs){
		console.log("Not Good in sendDataPatientFile");
	} 
    }); 
}

function sendDataPatientFileOld(url,upfoped){
	dojo.io.iframe.send({
        url: url,
        method: "post",
//	sync: true,
	handleAs: "text",
        form: upfoped,  
	load: function(response, ioArgs){
            	var foo = dojo.fromJson(response);
		var tmpStore = new dojo.store.Memory({data: foo.message});
		var resPat="";
		tmpStore.query({patname:/\w+/}).forEach(function(item, index){
			if (typeof(item.family)=="undefined"||item.family== null||/\s/.test(item.family)) {item.family=item.patname}
			if(index=="0") {
				if ((typeof(item.sex)=="undefined" || typeof(item.bc)=="undefined")){
				item.family="Family";
				item.father="Father";
				item.mother="Mother";
				item.sex="Sex";
				item.status="Status";
				item.bc="BC";
				item.iv="IV";
				}
			}
			if (typeof(item.sex)=="undefined"||item.sex==null||/\s/.test(item.sex)) {item.sex=1}
			if (typeof(item.status)=="undefined"||item.status==null||/\s/.test(item.status)) {item.status=2}
			if (typeof(item.bc)=="undefined"||item.bc==null||/\s/.test(item.bc)) {item.bc=""}
			if (typeof(item.iv)=="undefined"||item.iv==null||/\s/.test(item.iv)) {item.iv=""}

			resPat += item.patname+"\t"+item.family+"\t"+item.father+"\t"+item.mother+"\t"+item.sex+"\t"+item.status+"\t"+item.bc+"\t"+item.iv+"\n";
		});
		//var lpat = dijit.byId("Rpatient");
		Rpatient.value=resPat;
		a_Rpatient.value=resPat;
		
 		if (foo.status == "OK") {
			return foo.message;
            	} else {
			textError.setContent(foo.message);
			myError.show();
            	}          
	},
	error:function(response, ioArgs){
		console.log("Not Good in sendDataPatientFile");
	} 
    }); 
}

function sendDataPatientFileBCG(url,upfoped){
	dojo.io.iframe.send({
        url: url,
        method: "post",
//	sync: true,
	handleAs: "text",
        form: upfoped,  
	load: function(response, ioArgs){
            	var foo = dojo.fromJson(response);
		var tmpStore = new dojo.store.Memory({data: foo.message});
		var resPat="";
		tmpStore.query({patname:/\w+/}).forEach(function(item, index){
			resPat += item.patname+"\t"+item.iv+"\n";
		});
		RpatientBCG.value=resPat;
		
 		if (foo.status == "OK") {
			return foo.message;
            	} else {
			textError.setContent(foo.message);
			myError.show();
            	}          
	},
	error:function(response, ioArgs){
		console.log("Not Good in sendDataPatientFileBCG");
	} 
    }); 
}

function sendDataPedFile(url,upfoped){
	dojo.io.iframe.send({
        url: url,
        method: "post",
	handleAs: "text",
        form: upfoped,  
	load: function(response, ioArgs){
            	var foo = dojo.fromJson(response);
 		if (foo.status == "OK") {
 			textMessage.setContent(foo.message);
			myMessage.show();
            	} else {
			textError.setContent(foo.message);
			myError.show();
            	}          
	},
	error:function(response, ioArgs){
		console.log(response);
		console.log("Not Good in sendDataPedFile");
	} 
    }); 
}

//#########################################################################################
function sendUploadFileForm(type_file){
 	dojo.style(dojo.byId('inputLoadField'), "display", "none");    
	dojo.style(dojo.byId('progressLoadFile'), "display", "inline");
	dojo.byId('preambleFile').innerHTML = "Uploading ...";
 	var upfoped =  document.getElementById("uploadFormFile");

//update data
	switch (type_file) {
		case "capture":
			var s_capName = document.getElementById("capture").value;
			dojo.byId('param_out').value =s_capName+".bed";
			var name_File = dojo.byId('param_out').value;
			dojo.byId('FileNameCap').value =name_File;
			dojo.byId('FileNameCap').innerHTML =name_File;
			dojo.byId('capFile').value =name_File;
			//dojo.byId('param_analyse').value =s_analyse;
		break;
		case "primer":
			div_uploadFile.hide();
			var s_capName = document.getElementById("capture").value;
			dojo.byId('param_out').value =s_capName+".bed.primers";
			var name_File = dojo.byId('param_out').value;
			dojo.byId('FileNameCap').value =name_File;
			dojo.byId('FileNameCap').innerHTML =name_File;
			dojo.byId('capFilePrimer').value =name_File;
			//dojo.byId('param_analyse').value =s_analyse;
		break;
	}	
  	sendDataLoadFile(url_loadfile,upfoped,type_file);
	dojo.style(dojo.byId('inputLoadField'), "display", "inline");
	dojo.style(dojo.byId('progressLoadFile'), "display", "none");
	switch (type_file) {
		case "capture":
			div_uploadFile.hide();
			//refreshCaptureList(stand=1);
			document.getElementById("AccMain").style.display = "block";
			dijit.byId("AccMain").domNode.style.display = 'block';
			dijit.byId("AccMain").resize();
			divCaptureFile.hide();
			viewAddBundle();
		break;
		case "primer":
			div_uploadFile.hide();
			//refreshCaptureList(stand=1);
			divCaptureFile.hide();
		break;
		case "trs_file":
			div_uploadFile.hide();
			//refreshBundleTransList(save=1);
		break;
		default:
		return;
	}			
}

function sendDataLoadFile(url,upfoped,type_file){
	dojo.io.iframe.send({
        	url: url,
                contentType: "multipart/form-data",
		method: "post",
		handleAs: "text",
        	form: upfoped,  
		load: function(response, ioArgs){
           		var foo = dojo.fromJson(response);
			if (foo.status == "OK") {
				textMessage.setContent(foo.message);
				myMessage.show();
            		} else {
				textError.setContent(foo.message);
				myError.show();
            		} 
			if (type_file =="capture" || type_file =="primer") {
 				refreshCaptureList(stand=1);
			} 
			if (type_file =="trs_file") {
 				refreshBundleTransList(save=1);
			}			    
		},
		error:function(response, ioArgs){
			console.log(response);
			console.log("Not Good in sendDataLoadFile");
		} 
    	}); 
}

