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

var url_ftpfile = url_path + "/uploadFile.pl";
var url_patientfile = url_path + "/uploadpatient_file.pl";
var url_pedigreefile = url_path + "/pedigree_file.pl";
var url_loadfile = url_path + "/upload_file.pl";
var url_passwd = url_path + "/user_app.pl";
var url_bungroup = url_path + "/script_grpbun/script_BunGrp.pl";

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
	
function sendDataMulti(url){
	dojo.io.iframe.send({
        	url: url,
        	method: "get",
        	handleAs: "text",
        	load: function(rep, ioArgs){
 			return 1;
        	}, 
        	error: function(rep, ioArgs){
			return -1;
        	}     
	}); 
}

function sendData2(url){
	dojo.io.iframe.send({
        url: url,
        method: "get",
        handleAs: "text",
        load: function(data, ioArgs){
            var foo = dojo.fromJson(data);
            if (foo.status == "OK") {
				alert(foo.message);
				return 1;                
            }
            else {
				 return -1;
            }          
        }     
    }); 
}

function sendData6(url){
	dojo.xhrGet({
        	url: url,
        	method: "get",
		handleAs: "json",
        	load: function(data, ioArgs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
				myMessage.show();

			} else {
				textError.setContent(data["message"]);
				myError.show();
			}            
        	},
	}); 
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

// Method POST
function sendDataPost(prog,parameters){
	myStandby.show(); 
 	standby.show(); 
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
	var deferred = dojo.xhrPost(xhrArgs);
	return deferred;
}

// Method POST
function senDataExtendedPost(prog,parameters){
	myStandby.show(); 
 	standby.show(); 
	var xhrArgs = {
     		url: prog,
       		postData: parameters,
		handleAs: "json",
		preventCache: false,
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
				myMessage.show();
			} else if (data["status"] == "Extended") {
//				console.log("includedev.js sendDataExtendPost load Extended");
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
	var deferred = dojo.xhrPost(xhrArgs);
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

function sendData_noStatusTextStandby(url){
	var xhrArgs = {
       		url: url,
 		handleAs: "text",
       		load: function(data, ioargs){
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

//fonction pour connaitre le numéro de la ligne
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

var showTooltip = function(e) {
	var msg;
	var msgfield;
	if (e.rowIndex < 0) { // header grid
		msg = e.cell.name;
		msgfield = e.cell.field;
	};
	if (msg) {
		var classmsg = "<i class='tooltip'>";
		if(msg=="Free") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_red.png'>" +
			 "<B>Project with no Run</B>" + "<br>" +
			 "<img src='icons/bullet_green.png'>" +
			 "<B>Project with Run</B>" + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="#L/T") {
			dijit.showTooltip(classmsg + 
			"Number Linked Patient-Project/Total Number Patient with Exon Capture" + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="#pat") {
			dijit.showTooltip(classmsg + 
			"Total Number of Patient" + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="G Machine") {
			dijit.showTooltip(classmsg + 
			" Genome Plateform machine"+"<br>" + "</i>", e.cellNode,['above']);		
		}			
		if(msg=="G Run") {
			dijit.showTooltip(classmsg + 
			" Genome Run machine"+"<br>" + "</i>", e.cellNode,['above']);		
		}
		if(msg=="Doc") {
			dijit.showTooltip(classmsg + 
			"Excel Document send by the Genomic Plateform"+"<br>" + 
			"To add or visualize document, go to Edit Run" + "<br>" + 
			"</i>", e.cellNode,['above']);		
		}
		if(msg=="BC") {
			dijit.showTooltip(classmsg + 
			"Bar Code (ex: BC1)"+"<br>" + 
			"Nugen Bar Code (ex: A6)"+"<br>" + 
			"</i>", e.cellNode,['above']);		
		}
		if(msg=="FC") {
			dijit.showTooltip(classmsg + 
			"Flowcell"+"<br>" + "</i>", e.cellNode,['above']);		
		}
		if(msg=="G") {
			dijit.showTooltip(classmsg + 
			"Group Number Patient for new Project (Max:12 groups)"+"<br>" +
			"It will give the Today NewProject Name of a Group: NGSg_date_GroupNumber"+"<br>" +
			"</i>", e.cellNode,['above']);		
		}
		if(msg=="Sex") {
			dijit.showTooltip(classmsg + 
			"0: Unknown"+"<br>" + 
			"1: Male"+"<br>" +
			"2: Female"+"<br>" +
			 "</i>", e.cellNode,['above']);		
		}
		if(msg=="Status") {
			dijit.showTooltip(classmsg + 
			"0: Unknown"+"<br>" + 
			"1: Unaffected"+"<br>" +
			"2: Affected"+"<br>" +
			 "</i>", e.cellNode,['above']);		
		}
		if(msg=="Project") {
			dijit.showTooltip(classmsg + 
			"Project for Patient to be in the same project"+"<br>" +
			"Get a Project for a Patient by Button Old or New Project (New : it creates a new Project)"+"<br>" +
			"Rule: Each Project must have a Project"+"<br>" +
			"</i>", e.cellNode,['above']);		
		}
		if(msg=="Temporary Project") {
			dijit.showTooltip(classmsg + 
			"Project created but patients of current Run are still not affected to the project"+"<br>" +
			"</i>", e.cellNode,['above']);		
		}
		if(msg=="Father") {
			dijit.showTooltip(classmsg + 
			"Patient Father entered or selected from Projet"+"<br>" +
			"</i>", e.cellNode,['above']);		
		}
		if(msg=="Mother") {
			dijit.showTooltip(classmsg + 
			"Patient Mother entered or selected from Projet"+"<br>" +
			"</i>", e.cellNode,['above']);		
		}
		if(msg=="Users") {
			dijit.showTooltip(classmsg + 
			"Users from Existing Project"+"<br>" +
			"</i>", e.cellNode,['above']);		
		}
		if(msg=="Plt Run") {
			dijit.showTooltip(classmsg + 
			"Plateform Run Name" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="macName") {
			dijit.showTooltip(classmsg + 
			"Machine Name" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="Cap") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_red.png'>" +
			 "<B>Bundle with no Exon Capture</B>" + "<br>" +
			 "<img src='icons/bullet_green.png'>" +
			 "<B>Bundle with Exon Capture</B>" + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="projRel") {
			dijit.showTooltip(classmsg + 
			"Genome Release from Project" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="capRel") {
			dijit.showTooltip(classmsg + 
			"Genome Release from Capture" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="CapMeth") {
			dijit.showTooltip(classmsg + 
			"Method Capture" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="Annot") {
			dijit.showTooltip(classmsg + 
			"Annotation Release" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="MethSeq") {
			dijit.showTooltip(classmsg + 
			"Sequencing Method" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="Tr") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_red.png'>" +
			 "<B>Bundle with no Transcript</B>" + "<br>" +
			 "<img src='icons/bullet_green.png'>" +
			 "<B>Bundle with Transcript</B>" + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="#Tr") {
			dijit.showTooltip(classmsg + 
			 "Number of Transcrit"+
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="#bun") {
			dijit.showTooltip(classmsg + 
			 "Number of Bundle"+
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="Bundle") {
			dijit.showTooltip(classmsg + 
			"<table witdth=15em>"+
			"<tr><td style='color:red;'>Bundle with its Gene Release</td><td style='background:#b2f2bb;width:1em'>19</td></tr>"+
			"</table>" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="Gn") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_red.png'>" +
			 "<B>Trancript with no Gene Annotation</B>" + "<br>" +
			 "<img src='icons/bullet_green.png'>" +
			 "<B>Trancript with Gene Annotation</B>" + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="Trans") {
			dijit.showTooltip(classmsg + 
			 "<B>Transcript - Transmission Mode</B>" + "<br>" +
			 "<B>AR </B>" + " Autosomal Recessive<br>" +
			 "<B>AD </B>" + " Autosomal Dominant<br>" +
			 "<B>XL </B>" + " X Linked<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="B-Trans") {
			dijit.showTooltip(classmsg + 
			 "<B>Specific Bundle Transcript - Transmission Mode</B>" + "<br>" +
			 "<B>AR </B>" + " Autosomal Recessive<br>" +
			 "<B>AD </B>" + " Autosomal Dominant<br>" +
			 "<B>XL </B>" + " X Linked<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="Vu") {
			dijit.showTooltip(classmsg + 
			 "<B>When Toggled, Project will be seen on PolyDejaVu" + "<br>" +
			 "<B>To Change toggle switch, Edit Project then update on Tab Project" + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="So") {
			dijit.showTooltip(classmsg + 
			 "<B>When Toggled, Project concern Somatic Tissue in Oncology" + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="Group") {
			dijit.showTooltip(classmsg + 
			"<b>Attribution Group on each Patient Line: </b>" + "<br>" +
			messageBoxEnter + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="IV") {
			dijit.showTooltip(classmsg + 
			"<b>Identity Vigilance " + "<br>" +
			"15 digits from 1 to 4" + "<br>" +
			"Example: 312323332312321</b>" + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="IV_VCF") {
			dijit.showTooltip(classmsg + 
			"<b>Identity Vigilance calculated</b>" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="gRNA") {
			dijit.showTooltip(classmsg + 
			"<b>RNA guide</b>" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="Profile") {
			dijit.showTooltip(classmsg + 
			"<b>Profile</b> for Perspective Technology Preparation" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="PC") {
			dijit.showTooltip(classmsg + 
			"<b>Patient considered as Control when Button checked</b>" + "</i>", e.cellNode,['above']);		
		} 
		if(msg=="#occ") {
			dijit.showTooltip(classmsg + 
			 "Number of times a transcript is found from Location in Exon Capture File" + "<br>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="Ana") {
			dijit.showTooltip(classmsg + 
			 "<b>Analyse in </b>"+ "<br>" +
			"<table witdth=15em>"+
			"<tr><td style='background:#66CC00;width:2em'></td><td><b>E</b></td><td>Exome</td></tr>"+
			"<tr><td style='background:#FFFF00;width:2em'></td><td><b>G</b></td><td>Genome</td></tr>"+
			"<tr><td style='background:#009966;width:2em'></td><td><b>T</b></td><td>Target Validation</td></tr>"+
			"<tr><td style='background:#6666FF;width:2em'></td><td><b>R</b></td><td>RNAseq</td></tr>"+
			"<tr><td style='background:#33CCFF;width:2em'></td><td><b>S</b></td><td>SingleCell</td></tr>"+
			"<tr><td style='background:#F18973;width:2em'></td><td><b>A</b></td><td>Amplicon</td></tr>"+
			"<tr><td style='background:#618685;width:2em'></td><td><b>O</b></td><td>Other</td></tr>"+
			"<tr><td style='background:orange;width:2em'></td><td><b></b></td><td>Multiple</td></tr>"+
			"</table>"
			 , e.cellNode,['above']);		
		} 
		if(msg=="SP") {
			dijit.showTooltip(classmsg + 
			 "<b>Species in </b>"+ "<br>" +
			"<table witdth=18em>"+
			"<tr><td style='background:#A0DAA9;width:2em'></td><td><b>HS</b></td><td>Homo Sapiens (Human)</td></tr>"+
			"<tr><td style='background:#BDB76B;width:2em'></td><td><b>UN</b></td><td>Unknown</td></tr>"+
			"<tr><td style='background:#B0C4DE;width:2em'></td><td><b>MM</b></td><td>Mus Musculus (Mouse)</td></tr>"+
			"<tr><td style='background:#FFEBCD;width:2em'></td><td><b>RN</b></td><td>Rattus Norvegicus (Rat)</td></tr>"+
			"<tr><td style='background:#DEB887;width:2em'></td><td><b>DR</b></td><td>Danio Rerio (Zebrafish)</td></tr>"+
			"<tr><td style='background:#B8860B;width:2em'></td><td><b>FC</b></td><td>Felis Catus (Cat)</td></tr>"+
			"<tr><td style='background:#b2ad7f;width:2em'></td><td><b>GG</b></td><td>Gallus Gallus (Chicken)</td></tr>"+
			"<tr><td style='background:#FFF0F5;width:2em'></td><td><b>VI</b></td><td>Virus</td></tr>"+
			"<tr><td style='background:#E0FFFF;width:2em'></td><td><b>SY</b></td><td>Synthetic</td></tr>"+
			"<tr><td style='background:#e6e2d3;width:2em'></td><td><b>CF</b></td><td>Canis Familiaris (Dog)</td></tr>"+
			"<tr><td style='background:orange;width:2em'></td><td><b></b></td><td>Multiple Species</td></tr>"+
			"</table>"
			 , e.cellNode,['above']);		
		} 
	}
}; 

var hideTooltip = function(e) {
	dijit.hideTooltip(e.cellNode);
};

var showTooltipField = function(e) {
	var msgfield;
	if (e.rowIndex < 0) { // header grid
		msgfield = e.cell.field;
	};
	if (msgfield) {
		var classmsg = "<i class='tooltip'>";
		if(msgfield=="FreeCap") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_green.png'>" +
			"<b>Capture File:</b> Uploaded " + "<b>Primer File:</b> Uploaded for Target Analyse"+ "<br>" +
			"<img src='icons/bullet_blue.png'>" +
			"<b>Capture File:</b> Uploaded "+ "<b>Primer File:</b> Not Uploaded for Target Analyse" + "<br>" +
			"<img src='icons/bullet_red.png'>" + 
			"<b>Capture File:</b> Not Uploaded"+"</i>", e.cellNode,['above']);		
		} 
		if(msgfield=="FreeRun") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_blue.png'>" +
			"<B>Patient with No Method assigned </B>(Aligment and Calling)<br>" +
			"<img src='icons/bullet_red.png'>" +
			"<B>Patient not assigned</B> to a project" + "<br>" +
			"<img src='icons/bullet_green.png'>" +
			"<B>Patient assigned</B> to a project" + "<br>" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msgfield=="statRun") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_blue.png'>" +
			"<B>Run where Patient with No Method assigned </B>(Aligment and Calling)<br>" +
			"<img src='icons/bullet_red.png'>" +
			"<B>Run where no Patient assigned</B> to a project" + "<br>" +
			"<img src='icons/bullet_orange.png'>" +
			"<B>Run where not all Patient assigned</B> to a project" + "<br>" +
			"<img src='icons/bullet_green.png'>" +
			"<B>Run where Patient assigned</B> to a project" + "<br>" +
			"</i>", e.cellNode,['above']);		
		} 

		if(msgfield=="luser") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_green.png'>" +
			" User assigned" + "<br>" +
			"<img src='icons/ledred.png'>" + 
			" No User assigned"+"</i>", e.cellNode,['above']);		
		} 
		if(msgfield=="statut") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_green.png'>" +
			" Patient linked" + "<br>" +
			"<img src='icons/bullet_red.png'>" + 
			" No Run/Patient linked"+"</i>", e.cellNode,['above']);		
		} 
		if(msgfield=="capRelGene") {
			dijit.showTooltip(classmsg + 
			"Gene Release from Capture"+"</i>", e.cellNode,['above']);		
		} 
		if(msgfield=="relGene") {
			dijit.showTooltip(classmsg + 
			"Gene Release from Bundle"+"</i>", e.cellNode,['above']);		
		} 

	}
}; 

var hideTooltipField = function(e) {
	dijit.hideTooltip(e.cellNode);
};

var showRowTooltip = function(e) {
	var msg;
	var tmp;
	if (e.rowIndex >= 0) { // Row
		var item = e.grid.getItem(e.rowIndex);
		if (e.cell.field == "desRun" || e.cell.field == "capDes" || e.cell.field == "description") {
			msg = e.grid.store.getValue(item, e.cell.field);
		}
		if (e.cell.field == "pltRun") {
			msg = e.grid.store.getValue(item, e.cell.field);
		}
		if (e.cell.field == "Users") {
			tmp = e.grid.store.getValue(item, e.cell.field);
			if (tmp) {
				var value_sp=tmp.split(",");
				var cpt=1;
				for(var i=0; i<value_sp.length; i++) {
					var concat_value="";
					var cpt=1;
					for(var i=0; i<value_sp.length; i++) {
						var value_sp2=value_sp[i].split(":");
						concat_value += value_sp2[0];					
						if((cpt%5 == 0) && (cpt >0)) {
							concat_value +=  "<br>";
						} else {
							concat_value +=  " ";
						}
						cpt++;					
					}
				}
				msg=concat_value;
			}			
		}
		if (e.cell.field == "UserGroups" || e.cell.field == "Group") {
			msg = e.grid.store.getValue(item, e.cell.field);
		}
		if (e.cell.field == "Team") {
			msg = e.grid.store.getValue(item, e.cell.field);
		}
		if (e.cell.field == "Rel"|| e.cell.field == "projRel") {
			msg = e.grid.store.getValue(item, e.cell.field);
		}
		if (e.cell.field == "capFile") {
			msg = e.grid.store.getValue(item, e.cell.field);
		}
		if (e.cell.field == "capFilePrimers") {
			msg = e.grid.store.getValue(item, e.cell.field);
		}
		if (e.cell.field == "capD") {
			msg = "Click to Upload Capture File ("+item.capFile.toString()+ ")";
			if (item.capFile.toString() =="") {msg = "Click to Upload Capture File"};
		}
		if (e.cell.field == "capPrimers") {
			msg = "Click to Upload Primer File ("+item.capFilePrimers.toString()+ ")";
			if (item.capFilePrimers.toString() =="") {msg = "Click to Upload Primer File"};
		}
		if (e.cell.field == "capName" || e.cell.field == "capDes" || e.cell.field == "umi") {
			msg = e.grid.store.getValue(item, e.cell.field);
		}
		if (e.cell.field == "Bam") {
			msg = e.grid.store.getValue(item, e.cell.field);
			tmp = e.grid.store.getValue(item, e.cell.field);
			if (tmp) {
				var value_sp=tmp.split(",");
				var concat_value="";
				for(var i=0; i<value_sp.length; i++) {
					concat_value += value_sp[i] +"</br>";
				}
				msg=concat_value;
			}			
		}
	};
	if (msg) {
		dijit.showTooltip(msg, e.cellNode);
	}
};

var hideRowTooltip = function(e) {
            dijit.hideTooltip(e.cellNode);
};

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

function colorPerson(value,rowIdx,cell) {
	cell.customStyles.push("background-color: #b8a9c9");
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

function colorFieldAnalyse(value,idx,cell,row) {
	if (!value) {value=""};
	var value_sp=value.toLowerCase().split(" ");
	var v_color="";
	if (value_sp != "") {
		if (value_sp.length> 1) {
			var newTable = document.createElement('table');
			var concat_value="";
			for(var i=0; i<value_sp.length; i++) {
				if (value_sp[i] != "exome" && value_sp[i] != "genome" && value_sp[i] != "rnaseq" && value_sp[i] != "singlecell" && value_sp[i] != "amplicon" && value_sp[i] != "other") {
					value_sp[i]="target";
				} 
				concat_value += value_sp[i].substring(0,1).toUpperCase()+" ";
			}
			concat_value = concat_value.slice(0, -1);
			value=concat_value;
			var sp_val=value.split(" ");
			var f_value=sp_val.filter((e, i, a) => a.indexOf(e) === i);
			var sp_concat_value="";
			for(var i=0; i<f_value.length; i++) {
				var sp_color=getColorAnalyse(f_value[i]);
				sp_concat_value += "<span style='background-color:"+sp_color+";display:block;'>" + f_value[i] +"</span>";
			}
			value=sp_concat_value;	
		} else {
			if (value_sp != "exome" && value_sp != "genome" && value_sp != "rnaseq" && value_sp != "singlecell" && value_sp != "amplicon" && value_sp != "other") {
				value="T";
			}
			value=value.substring(0,1).toUpperCase();
		}
	} else { value="0"}

	if(value == "0") {
		value="";
	} else if(value == "R") {
		v_color=getColorAnalyse(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "S") {
		v_color=getColorAnalyse(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "T") {
		v_color=getColorAnalyse(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "E") {
		v_color=getColorAnalyse(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "G") {
		v_color=getColorAnalyse(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "A") {
		v_color=getColorAnalyse(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "O") {
		v_color=getColorAnalyse(value);
		cell.customStyles.push("background: "+v_color);
	} else {
		cell.customStyles.push("background: orange");//mixte
	}
	return value;
}

function getColorAnalyse(value) {
	var color="";
	if(value == "R") {color="#6666FF"} //purple
	if(value == "S") {color="#33CCFF"} //blue
	if(value == "T") {color="#009966"} //dark green
	if(value == "E") {color="#66CC00"} //light green
	if(value == "G") {color="#FFFF00"} //yellow
	if(value == "A") {color="#f18973"} //amplicon#d64161
	if(value == "O") {color="#618685"} //other
	return color;
}

function colorFieldSpecies(value,idx,cell,row) {
	var v_color="";
	if( value == null ) {value=""}
	if(value == "HS") {
		//cell.customStyles.push("background: #A0DAA9");//Green Ash
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "UN") {
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "MM") {
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "RN") {
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "DR") {
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "FC") {
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "GG") {
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "VI") {
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "SY") {
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "CF") {
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else if(value == "") {
		v_color=getColorSpecies(value);
		cell.customStyles.push("background: "+v_color);
	} else {
	var value_sp=value.split(" ");
		if (value_sp != "") {
			if (value_sp.length> 1) {
				var sp_concat_value="";
				for(var i=0; i<value_sp.length; i++) {
					var sp_color=getColorSpecies(value_sp[i]);
					sp_concat_value += "<span style='background-color:"+sp_color+";padding:2px 1px 2px 1px;'>" + value_sp[i] +"</span>";
				}
				value=sp_concat_value;	
			}
		}
		cell.customStyles.push("background: orange");
	}
	return value;
}

function getColorSpecies(value) {
	var color="";
	if(value == "HS") {color="#A0DAA9"}//Green Ash
	if(value == "UN") {color="#BDB76B"}//DarkKhaki  #B0C4DE
	if(value == "MM") {color="#B0C4DE"}//LightSteelBlue 
	if(value == "RN") {color="#FFEBCD"}
	if(value == "DR") {color="#DEB887"}
	if(value == "FC") {color="#B8860B"}
	if(value == "GG") {color="#b2ad7f"}
	if(value == "VI") {color="#FFF0F5"}
	if(value == "SY") {color="#E0FFFF"}
	if(value == "CF") {color="#e6e2d3"}
	if(value == "") {color="white"}
	return color;
}

function newPerson(value,idx,cell,row) {
	if (value.toString().match(/^(New Person)/)) {
		var sp_value=value.toString().split("/");
		value="<table align='center' style='border:1px solid #ae3ec9;width:10em;'>"+
			"<tr><td align='center' style='color:#191970;'><b>"+sp_value[0]+"</b></td></tr>"+
			"</table>";	

	}
	return value;
}

function bundleColorRel(value,idx,cell,row) {
	var value_sp=value.split(" ");
	if (value && value_sp.length>= 1) {
		var concat_value="";
		for(var i=0; i<value_sp.length; i++) {
			var value_sp2=value_sp[i].split(":");
			concat_value += "<span>" + value_sp2[0] +"</span>" + "<span style='border:1px solid #009966;background-color:#b2f2bb'>" + value_sp2[1] +"</span>" + " ";
		}
		value=concat_value;
	} 
	return value;
}

function backgroundCell(value,idx,cell,row) {
	if (cell.field == "capRelGene" || cell.field == "relGene") {
		cell.customStyles.push("background: #b2f2bb");
	}
	if (cell.field == "group") {
		if (value) {
			cell.customStyles.push("background: #B0E0E6;color:#000fb3;");
		}
	}
	if (cell.field == "phenotype") {
		if (value) {
			cell.customStyles.push("background: #CCCC99;");
		}
	}
	if (value==0) {value=""}
	return value;
}

function userColorGroup(value,idx,cell,row) {
	var value_sp;
	if( value == null ) {value=""}
	if (value){
		if (cell.field == "Users") {
			value_sp=value.split(",");
			if (value_sp.length>= 1) {
				var concat_value="";
				for(var i=0; i<value_sp.length; i++) {
					var value_sp2=value_sp[i].split(":");
					if (value_sp2[1]) {
						concat_value += "<span style='border:1px solid #00BFFF;background-color:#B0E0E6;color:#000fb3;'>" + value_sp2[0] +"</span>" + " ";
					} else {
						//concat_value +=value_sp2[0] + " ";
						concat_value += "<span style='border:1px solid #00BFFF;background-color:#99ccff;color:#000fb3;'>" + value_sp2[0] +"</span>" + " ";
					}
				}
				value=concat_value;
			}
		}
		if (cell.field == "UserGroups") {
			value_sp=value.split(" ");
			if (value_sp.length>= 1) {
				var concat_value="";
				for (var i=0; i<value_sp.length; i++) {
					concat_value += "<span style='border:1px solid #00BFFF;background-color:#B0E0E6;color:#000fb3;'>" + value_sp[i] +"</span>" + " ";
				}
				value=concat_value;
			}
		}		
	}
	return value;
}

function IconSex(value) {
	if(value == "2") {
		return "<img align='top' src='icons/Sex-Female-icon.png'>";
	} 
	if(value == "1") {
		return "<img align='top' src='icons/Sex-Male-icon.png'>";
	} 
	else if(value == "0") {
		return "<img align='top' src='icons/Sex-Unknown-icon.png'>";
	} 
}

function IconStatus(value) {
	if(value == "2") {
		return "<img align='top' src='icons/Equipment-Capsule-Red-icon.png'>";
	} 
	if(value == "1") {
		return "<img align='top' src='icons/Unaffected_1.png'>";
	} 
	else if(value == "0") {
		return "<img align='top' src='icons/Unknown_1.png'>";
	} 
}

function linkRunName(value,idx,cell) {
	var val_button;
	if (cell.field == "name") {
		var hrefU="https://www.polyweb.fr/polyweb/demultiplex_view/demultiplex_view_run.html?name=" + value + "&json=https://www.polyweb.fr/NGS/demultiplex/" + value + "/json/demultiplex.json";
		val_button="<a href='"+ hrefU +"' target='_blank'><img align='top' src='icons/link.png'></a>"+" "+value;
	}		
	return val_button
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

function initRadioRel(def) {
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearOldList(size, request) {
		var listRel = dojo.byId("relRadioNew");
		if (listRel) {
			while (listRel.firstChild) {
				listRel.removeChild(listRel.firstChild);
			}
		}
	}

	function gotRelease(items, request) {
		var listRel = dojo.byId("relRadioNew");
		if (listRel) {
			if (def=="HG19") {def="HG19_MT"};
			var i;
			var defSpan = dojo.doc.createElement('div');
			var cpt=1;
			for (i = 0; i < items.length; i++) {
			//	if(items[i].relName=="HG18") {cpt--;continue;}
				if(items[i].relName=="HG18") {continue;}
				if(cpt==0) {cpt=1};
				var item = items[i];
				var iname = 'cDB';
				var cbname = items[i].relName;
				var id = iname + i;
				var title =cbname;
				var cb=dijit.byId(id);
				if(typeof(cb)!=="undefined") {
					cb.destroy();
				}
				cb = new dijit.form.RadioButton({
					id: id,
					name: iname,
					title:cbname
				});
				
				if (def) {
					if (item.relName[0]==def){
						cb.attr('checked', true);
					}
				}
				if (!def) {
					if (item.relName[0]=="HG19"){
						cb.attr('checked', true);
					}
				}
				var defLabel = dojo.doc.createElement('label');
				// write next line when multiple 4
				if((cpt%4 == 0) && (cpt >0)) {
					cbname=cbname + "<br>";
				}
				cpt++;
				defLabel.innerHTML = cbname ;
				defSpan.appendChild(defLabel);
				dojo.place(cb.domNode, dojo.byId("relRadioNew"), "last");
				dojo.place(defLabel, dojo.byId("relRadioNew"), "last");
			}
		}
	}

	relStore.fetch({
		onBegin: clearOldList,
		onComplete: gotRelease,
		onError: fetchFailed,
		queryOptions: {
			deep: true
		}
	});
}

var showRowTrTooltip = function(e) {
	var msg;
	var classmsg = "<i class='tooltip'>";
	if (e.rowIndex < 0) { // header grid
		if (e.cell.field.indexOf("col_") != -1) {
			msg = classmsg +"Exon_"+e.cell.name;
		}
		if (e.cell.field == "nbExon") {
			msg = classmsg +"Number of Exons";
		}
		if (e.cell.field == "nbSub") {
			msg = classmsg +"Total Number of Exons when Exon List is split";
		}
	} else if (e.rowIndex >= 0) { // Row
		var selectedItem = captureTrGrid.getItem(e.rowIndex);
		dojo.forEach(captureTrGrid.store.getAttributes(selectedItem), function(attribute) {
			if (e.cell.field==attribute) {
				var valfield=captureTrGrid.store.getValue(selectedItem, e.cell.field).toString();
				if(typeof(valfield) != 'undefined'|| valfield !="") {
					if ((valfield.indexOf("M:") != -1)|| (valfield.indexOf("U:") != -1)) {
						var pos=valfield.split(":");
						var chr=pos[1].split("ex");
						valfield="Exon"+chr[1]+" Chr"+chr[0]+" "+pos[2] + " Probe: "+ pos[3];
						msg=valfield;
					}
				}
				if (e.cell.field == "nbExon") {
					if (parseInt(valfield)>= 100){
						msg=classmsg +"<b>Maximum Exons/line = 100<br>"+
						"The Complete List of Exons from a Transcript is split into several lines</b>"
					}
				}
				if (e.cell.field == "nbSub") {
					if (parseInt(valfield)>= 100){
						msg=classmsg +"<b>Total Number of Exons of a Transcript</b>"
					}
				}
			}
		
		});
	};
	if (msg) {
		dijit.showTooltip(msg, e.cellNode);
	}
};

var hideRowTrTooltip = function(e) {
	dijit.hideTooltip(e.cellNode);
};

//Formatter

function bullet(value) {
	if(value == "3") {
		return "<img align='top' src='icons/bullet_blue.png'>";
	} 
	if(value == "2") {
		return "<img align='top' src='icons/bullet_orange.png'>";
	} 
	else if(value == "1") {
		return "<img align='top' src='icons/bullet_red.png'>";
	} 
	else { 
		return "<img align='top' src='icons/bullet_green.png'>";
	}
}

function ifbullet(value) {
	if(value == "3") {
		return "<img align='top' src='icons/bullet_blue.png'>";
	} 
	if(value == "2") {
		return "<img align='top' src='icons/bullet_orange.png'>";
	} 
	if(value == "1") {
		return "<img align='top' src='icons/bullet_red.png'>";
	} 
	if(value == "0") {
		return "<img align='top' src='icons/bullet_green.png'>";
	} 
	else { 
		return "";
	}
}

function ledbullet(value) {
	if(value == "1") {
		return "<img align='top' src='icons/ledred.png'>";
	} 
	else { 
		return "<img align='top' src='icons/bullet_green.png'>";
	}
}

function bulletGene(value) {
	if(value == "1") {
		return "<img align='middle' src='icons/bullet_red.png'>";
	} 
	else if(value == "0") {
		return "<img align='middle' src='icons/bullet_green.png'>";
	} 
	else { 
		return "";
	}
}

var cssFiles = ["print_style1.css"];

function previewAll(grid){
	var gPat=dijit.byId(grid);
	gPat.exportToHTML({
		title: "Grid View - All",
		cssFiles: cssFiles
	}, function(str){
			var win = window.open();
			win.document.open();
			win.document.write(str);
			gPat.normalizePrintedGrid(win.document);
			win.document.close();
	});
}

function previewSelected(grid){
	var gPat=dijit.byId(grid);
	gPat.exportSelectedToHTML({
		title: "Grid View - Selected",
		cssFiles: cssFiles
	}, function(str){
			var win = window.open();
			win.document.open();
			win.document.write(str);
			gPat.normalizePrintedGrid(win.document);
			win.document.close();
	});
}

function exportAll(grid){
	dijit.byId(grid).exportGrid("csv",{writerArgs: {separator: ";"}}, function(str){
		var reg1=new RegExp('"',"g");
		var reg2=new RegExp("'","g");
		var reg3=new RegExp("NaN","g");
		var reg4=new RegExp("<img [a-z0-9\-/._= ]*>","gi");
		var reg5=new RegExp("<div class[a-z0-9\-/._= ]*>...</div>","gi");
		var reg6=new RegExp("<span>","gi");
		var reg7=new RegExp("</span>","gi");
		var reg8=new RegExp("<span style=border:1px solid #009966;background-color:#b2f2bb>","gi");
		var regA=new RegExp("<a [a-z0-9\-/._\?&:= ]*></a> ?","gi");
		var regSpan=new RegExp("<span [a-z0-9\-/._\?&;#:= ]*>","gi");
		var regSep=new RegExp(',',"g");
		str=str.replace(reg1,'');
		str=str.replace(reg2,'');
		str=str.replace(reg3,'');
		str=str.replace(reg4,'');
		str=str.replace(reg5,'');
		str=str.replace(reg6,'');
		str=str.replace(reg7,'');
		str=str.replace(reg8,':');
		str=str.replace(regA,'');
		str=str.replace(regSpan,'');
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

function lines(text) {  
	return text.split('\n')
}

function exportSelected(grid,withShift){
	dijit.byId(grid).exportSelected("csv",{writerArgs: {separator: ";"}}, function(str){
		var reg1=new RegExp('"',"g");
		var reg2=new RegExp("'","g");
		var reg3=new RegExp("NaN","g");
		var reg4=new RegExp("<img [a-z0-9\-/._= ]*>","gi");
		var reg5=new RegExp("<div class[a-z0-9\-/._= ]*>...</div>","gi");
		var reg6=new RegExp("<span>","gi");
		var reg7=new RegExp("</span>","gi");
		var reg8=new RegExp("<span style=border:1px solid #009966;background-color:#b2f2bb>","gi");
		var regA=new RegExp("<a [a-z0-9\-/._\?&:= ]*></a> ?","gi");
		var regSpan=new RegExp("<span [a-z0-9\-/._\?&;#:= ]*>","gi");		
		var regSep=new RegExp(',',"g");
		str=str.replace(reg1,'');
		str=str.replace(reg2,'');
		str=str.replace(reg3,'');
		str=str.replace(reg4,'');
		str=str.replace(reg5,'');
		str=str.replace(reg6,'');
		str=str.replace(reg7,'');
		str=str.replace(reg8,':');
		str=str.replace(regA,'');
		str=str.replace(regSpan,'');
		str=str.replace(regSep,';');
/*
		if (withShift) {
			console.log("==========================================================");
			var str_lines = lines(str);
			var newArray=new Array();
			for (var i = 0; i < str_lines.length; i++) {
				var tmp1=str_lines[i];
				var tmp2=tmp1.split(";");
				tmp2.shift();
				if (i>0) {tmp2.shift();}
				newArray.push(tmp2);
			}
			str=newArray;
		}
*/
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




