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
    // Étape 1 : Nettoyer la réponse textuelle de l'iframe si nécessaire
    // L'iframe encapsule parfois la réponse dans des balises <pre> ou <html>
		var rawText = response;
		if(typeof response === "string") {
			rawText = response.replace(/<\/?[^>]+(>|$)/g, ""); // Supprime le HTML résiduel
		}
    // Étape 2 : Parser STRICTEMENT le JSON
		var foo = dojo.fromJson(rawText);
		var headers = foo.message.headers; // ["Patient", "Family", "Sex", "Status"]
		var items = foo.message.items;
		var tmpStore = new dojo.store.Memory({
    			data: items,
    			idProperty: foo.message.identifier
		});

		// Même dictionnaire qu'en Perl pour savoir quelle clé JSON correspond à quel en-tête
		var headerMapping = {
		    'Patient': 'patname',
		    'Family' : 'family',
		    'Sex'    : 'sex',
		    'Status' : 'status',
        	    'Group'  : 'group',
        	    'BC'     : 'bc',
        	    'BC2'    : 'bc2',
        	    'IV'     : 'iv',
        	    'Person' : 'person',
		    'Lane'   : 'lane',
		    'Reads'  : 'reads'
		};
		// On commence par écrire la ligne d'en-tête réelle ("Patient\tFamily\tSex...")
		var resPat = headers.join("\t") + "\n";

		tmpStore.query().forEach(function(item, index){
    			var lineValues = [];    
    			// On boucle sur les en-têtes réels
    			dojo.forEach(headers, function(realHeader){
        		// On trouve la clé JSON correspondante (ex: 'Patient' -> 'patname')
				var jsonKey = headerMapping[realHeader] || realHeader.toLowerCase();    
        			// 1. On récupère la valeur brute ou une chaîne vide si elle est undefined/null
       				var value = (item[jsonKey] !== undefined && item[jsonKey] !== null) ? item[jsonKey] : "";
				// 2. Traitement des cas particuliers si la valeur est vide ("")
        			if (value === "") {
            				if (jsonKey === "sex") {
                				value = "1";
            				} else if (jsonKey === "status") {
                				value = "2";
            				}
        			}
        			lineValues.push(value);
    			}); 
    			resPat += lineValues.join("\t") + "\n";
		});
		// 5. Assignation de la valeur au widget SimpleTextarea de Dijit
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

