/**
 * @author plaza
 */
	
dojo.require("dojo.io.iframe");
dojo.require("dijit.ProgressBar");
dojo.require("dijit.form.Button");
dojo.require("dojo.parser");

var href = window.location.href;

var url_path = "/cgi-bin/polyprojectNGS";

if (href.indexOf("plaza", 1) > -1) {
	url_path = "/cgi-bin/plaza/polyprojectNGS";
}

var loc=0;
if (href.indexOf("102", 1) > -1) {loc=1} else {loc=0};
var url_loadSamplefile = url_path + "/upload_SampleSheetfile.pl";

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
	
/* version sans standby car probleme Link Projet to run creation répertoire*/

function sendData(url){
	var xhrArgs = {
       		url: url,
 		handleAs: "json",
		preventCache: false,
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
				myMessage.show();
			} else {
				textError.setContent(data["message"]);
				myError.show();
			}            
		},
		error: function(error) {
//			console.log(error);
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

// Method POST
function sendDataPost(){
	var folderFormvalue= dijit.byId("folderForm").getValues();
	//console.log(folderFormvalue.CopyPasteF);
	var cum=0;
	var cCum=dijit.byId("cumul_input");
	if (cCum.checked) {
		cum=1;
	}
	var xhrArgs = {
     		url: url_loadSamplefile,
       		postData: "opt=copypaste" +
				"&folder="  + folderFormvalue.folderName +
				"&rfile=" + replaceSpecialChar(folderFormvalue.CopyPasteF) +
				"&stype=" + folderFormvalue.sample_input +
				"&controlbc=" + folderFormvalue.bc_input +
				"&cumul=" + cum,
		handleAs: "json",
//		preventCache: false,
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
				myMessage.show();
			} else {
				textError.setContent(data["message"]);
				myError.show();
			}            
		},
		error: function(error) {
			console.log(error);
			return;
		}		
	}
	var deferred = dojo.xhrPost(xhrArgs);
	return deferred;
}

// Method POST
function sendDataPost_noStatus(prog,parameters){
	myStandby.show(); 
 	standby.show(); 
	var xhrArgs = {
     		url: prog,
       		postData: parameters,
//		handleAs: "json",
		handleAs: "text",
		preventCache: false,

       		load: function(data, ioargs){
			standby.hide();
 			myStandby.hide(); 
		},
		error: function(error){
			console.log("error");
			console.log(error);
		}

	}
	var deferred = dojo.xhrPost(xhrArgs);
	return deferred;
}

function sendDataPostV2(prog,parameters){
	var xhrArgs = {
     		url: prog,
       		postData: parameters,
		handleAs: "json",
		preventCache: false,
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
				myMessage.show();
			} else {
				textError.setContent(data["message"]);
				myError.show();
			}            
		},
		error: function(error) {
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
	var deferred = dojo.xhrPost(xhrArgs);
	return deferred;
}

function replaceSpecialChar(str){
// a compléter avec tous les accents
//	var reg0 =new RegExp(",","g");
	var reg01 =new RegExp(";","g");
	var reg1 =new RegExp("é","g");
	var reg1A =new RegExp("Ã©","g");//UTF8
	var reg2 =new RegExp("è","g");
	var reg2A =new RegExp("Ã¨","g");//UTF8
	var reg3 =new RegExp("à","g");
	var reg4 =new RegExp("’","g");
	var reg5 =new RegExp("µ","g");
	var reg6 =new RegExp("°","g");
	var reg6A =new RegExp("Â","g");//UTF8
	var reg7 =new RegExp("ê","g");
	var reg7A =new RegExp("Ãª","g");//UTF8
	var reg8 =new RegExp("#","g");
//	var reg9 =new RegExp("'","g");
	var reg10 =new RegExp("%","g");
	var reg11 =new RegExp("œ","g");
	var reg12 =new RegExp("Œ","g");
	var reg13 =new RegExp("Å","g");//UTF8
	var reg14 =new RegExp("&","g");
	var reg99A =new RegExp("Ã","g");//UTF8
//	var reg98A =new RegExp("\t\t","g");//UTF8
//	str=str.replace(reg0,',');
	str=str.replace(reg01,' ');
	str=str.replace(reg1,'e');
	str=str.replace(reg1A,'e');
	str=str.replace(reg2,'e');
	str=str.replace(reg2A,'e');
	str=str.replace(reg3,'a');
	str=str.replace(reg4,' ');
	str=str.replace(reg5,'mi');
	str=str.replace(reg6,' ');
	str=str.replace(reg6A,' ');
	str=str.replace(reg7,'e');
	str=str.replace(reg7A,'e');
	str=str.replace(reg8,'_');
//	str=str.replace(reg9,' ');
	str=str.replace(reg10,'');
	str=str.replace(reg11,'oe');
	str=str.replace(reg12,'OE');
	str=str.replace(reg13,'oe');
	str=str.replace(reg14,'');
	str=str.replace(reg99A,'a');
//	str=str.replace(reg98A,'\t');

	return str;
}

function sendData_v2(url){
	myStandby.show(); 
 	standby.show(); 
	var xhrArgs = {
       		url: url,
 		handleAs: "json",
		preventCache: false,
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
				myMessage.show();
			} else {
				textError.setContent(data["message"]);
				myError.show();
			}            
			standby.hide();
 			myStandby.hide(); 
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

function sendData_noError(url){
	myStandby.show(); 
 	standby.show(); 
	var xhrArgs = {
       		url: url,
 		handleAs: "json",
		preventCache: false,
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
				myMessage.show();
			} else {
				textError.setContent(data["message"]);
				myError.show();
			}            
			standby.hide();
 			myStandby.hide(); 
		},
	}
	var deferred = dojo.xhrGet(xhrArgs);
	return deferred;
}

function sendData_noStatusText(url){
	myStandby.show(); 
 	standby.show(); 
	var xhrArgs = {
       		url: url,
 		handleAs: "text",
       		load: function(data, ioargs){
			standby.hide();
 			myStandby.hide(); 
		},
		error: function(error){
			console.log("error");
			console.log(error);
		}
		
	}
	var deferred = dojo.xhrGet(xhrArgs);
	return deferred;
}

function getLocation_v2(url){
	myStandby.show(); 
 	standby.show(); 
	var xhrArgs = {
       		url: url,
 		handleAs: "json",
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
				myMessage.show();
			} else {
				textError.setContent(data["message"]);
				myError.show();
			}            
			standby.hide();
 			myStandby.hide(); 
		}
		
	}
	var deferred = dojo.xhrGet(xhrArgs);
	return deferred;
}

function getRow(inRowIndex){
	return ' ' + (inRowIndex+1);
}

function getRowProgress(inRowIndex,items){
	return ' ' + (inRowIndex+1)  + '-' ;
}

function getRowName(inRowIndex,items){
	return ' ' + (inRowIndex+1)  + '-' ;
}

var messageBoxEnter="<B>Select in Box or Enter</B>";

function extension(value) {
	if(value == "xls" || value == "xlsx") {
		return "<img align='top' src='icons/Excel-icon-16.png'>";
	} 
	else if (value == "doc") {
		return "<img align='top' src='icons/page_word.png'>";
	} 
	else { return value}
}

function colorRun(value,rowIdx,cell) {
	cell.customStyles.push("background-color: #D18383");
	return value;
}

function empty(value) {
	if(value == "") {
		return "<img align='top' src='icons/exclamation.png'>";
	} else { return value}
}

function emptyA(value) {
	if(value == undefined) {
		return "";
	} else { return value}
}

function zero(value) {
	if (value == "0") {
		return "";
	} else { return value}
}

function colorField(value,idx,cell,row) {
	if(value == "2") {
		cell.customStyles.push("color: red");
		if (cell.field == "Sex") {
			cell.customStyles.push("color: #FF69B4");
		}	
	} 
	if(value == "1") {
		cell.customStyles.push("color: blue");
		if (cell.field == "Status") {
			cell.customStyles.push("color: green");
		}	
	} 
	else if(value == "0") {
		cell.customStyles.push("color: grey");
	}

	if (cell.field == "RunId" || cell.field == "name" || cell.field == "capName" || cell.field == "bunName" || cell.field == "patientName" || cell.field == "ensemblId" || cell.field == "Name" ) {
		cell.customStyles.push("color: #323322","font-weight:900");
	}
 
	return value;
}


// Enable key Tab inside Textarea
function keyTab(e){
	var tab="\t";
	var t = e.target;
	var ss = t.selectionStart;
	var se = t.selectionEnd;

	if(e.keyCode === 9 ){
		e.preventDefault();
        	if (ss != se && t.value.slice(ss,se).indexOf("\n") != -1) {
            // In case selection was not of entire lines (e.g. selection begins in the middle of a line)
            // we ought to tab at the beginning as well as at the start of every following line.
            		var pre = t.value.slice(0,ss);
            		var sel = t.value.slice(ss,se).replace(/\n/g,"\n"+tab);
            		var post = t.value.slice(se,t.value.length);
            		t.value = pre.concat(tab).concat(sel).concat(post);
                   
            		t.selectionStart = ss + tab.length;
            		t.selectionEnd = se + tab.length;
        	} // "Normal" case (no selection or selection on one line only)
		else {
            		t.value = t.value.slice(0,ss).concat(tab).concat(t.value.slice(ss,t.value.length));
            		if (ss == se) {
                		t.selectionStart = t.selectionEnd = ss + tab.length;
			}
             		else {
                		t.selectionStart = ss + tab.length;
                		t.selectionEnd = se + tab.length;
            		}
		}	
	}
}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

//Formatter
function exportAllExon(grid){
	dijit.byId(grid).exportGrid("csv",{writerArgs: {separator: ";"}}, function(str){
		var reg1=new RegExp('"',"g");
		var reg2=new RegExp("'","g");
		var reg3=new RegExp("NaN","g");
		var reg4h=new RegExp("<img align=middle src=icons/exclamation.png>","gi");
		var reg4v=new RegExp("<img align=middle src=icons/bullet_green.png>","gi");
		var reg4r=new RegExp("<img align=middle src=icons/bullet_red.png>","gi");
		var reg5=new RegExp("<div class[a-z0-9\-/._= ]*>...</div>","gi");
		str=str.replace(reg1,'');
		str=str.replace(reg2,'');
		str=str.replace(reg3,'');
		str=str.replace(reg4h,'');
		str=str.replace(reg4v,'E');
		str=str.replace(reg4r,'N');
		str=str.replace(reg5,'');
		var form = document.createElement('form');
		dojo.attr(form, 'method', 'POST');
		var f_input=document.createElement('input');
		f_input.type="hidden";
		f_input.name="my_input";
		f_input.value=str;
		form.appendChild(f_input);
		document.body.appendChild(form);
		dojo.io.iframe._currentDfd = null;
		if (this._deferred) {
    			this._deferred.cancel();
		}
		this._deferred=dojo.io.iframe.send({
//			url: url_path + "/CSVexport.php",
			url: url_path + "/XLSexport.pl",
 			form: form,
 			method: "POST",
			handleAs: "text",
			content: {exp: str},
		});
		document.body.removeChild(form);
	});
}

function exportSelectedExon(grid){
	dijit.byId(grid).exportSelected("csv",{writerArgs: {separator: ";"}}, function(str){
		var reg1=new RegExp('"',"g");
		var reg2=new RegExp("'","g");
		var reg3=new RegExp("NaN","g");
		var reg4h=new RegExp("<img align=middle src=icons/exclamation.png>","gi");
		var reg4v=new RegExp("<img align=middle src=icons/bullet_green.png>","gi");
		var reg4r=new RegExp("<img align=middle src=icons/bullet_red.png>","gi");
		var reg5=new RegExp("<div class[a-z0-9\-/._= ]*>...</div>","gi");
		var regSep=new RegExp(',',"g");
		str=str.replace(reg1,'');
		str=str.replace(reg2,'');
		str=str.replace(reg3,'');
		str=str.replace(reg4h,'');
		str=str.replace(reg4v,'E');
		str=str.replace(reg4r,'N');
		str=str.replace(reg5,'');
		str=str.replace(regSep,';');
		var form = document.createElement('form');
		dojo.attr(form, 'method', 'POST');
		var f_input=document.createElement('input');
		f_input.type="hidden";
		f_input.name="my_input";
		f_input.value=str;
		form.appendChild(f_input);
		document.body.appendChild(form);
		dojo.io.iframe._currentDfd = null;
		if (this._deferred) {
    			this._deferred.cancel();
		}
		this._deferred=dojo.io.iframe.send({
//			url: url_path + "/CSVexport.php",
			url: url_path + "/XLSexport.pl",
 			form: form,
 			method: "POST",
			handleAs: "text",
			content: {exp: str},
		});
		document.body.removeChild(form);
	});
}




