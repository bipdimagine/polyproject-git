/**
 * @author plaza
 */

dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.layout.BorderContainer");
dojo.require("dojox.layout.ExpandoPane");
dojo.require("dijit.layout.AccordionContainer");
dojo.require("dijit.layout.TabContainer");

dojo.require("dijit.form.Button");
dojo.require("dijit.DropDownMenu");
dojo.require("dijit.PopupMenuItem");
dojo.require("dijit.MenuItem");
dojo.require("dijit.Menu");
dojo.require("dijit.form.FilteringSelect");

dojo.require("dojox.grid.DataGrid");
dojo.require("dojox.grid.EnhancedGrid");
dojo.require("dojox.grid.enhanced.plugins.exporter.CSVWriter");
dojo.require("dojox.grid.enhanced.plugins.exporter.TableWriter");



dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dojo.data.ItemFileWriteStore");
dojo.require("dojox.data.AndOrReadStore");
dojo.require("dojox.data.AndOrWriteStore");
dojo.require("dojox.data.CsvStore");
dojo.require("dijit.Dialog");
dojo.require("dijit.form.ValidationTextBox");
dojo.require("dojo.parser");
dojo.require("dojo.date.locale");
dojo.require("dijit.form.ComboBox");
dojo.require("dijit.form.CheckBox");
dojo.require("dijit.form.Form");
dojo.require("dijit.TitlePane");
dojo.require("dijit.form.TextBox");
dojo.require("dijit.form.Textarea");
dojo.require("dijit.Toolbar");
dojo.require("dojox.widget.Standby");

//url_path = "/cgi-bin/plaza/polyprojectNGS";

var standby;
var tmpStore;
var gridtmp;
var gridtmpR;
var libFlowcell;

function init(){
//################# Standby for loading : use sendData_v2 #############################

	standby = new dojox.widget.Standby({
	       	target: "winStandby"
	});
	document.body.appendChild(standby.domNode);
	standby.startup();
	libFlowcell = dojo.byId("LibFlowcell");
	libFlowcell.innerHTML= "File Name";


}
dojo.addOnLoad(init);

var fcId;
var Rapid;
var sheetType;
function newSampleSheet() {
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var regexp2 = /^[a-zA-Z0-9_]+$/;
	var regexp3 = /^[A-Z0-9]+$/;
	var desFormvalue = dijit.byId("desForm").getValues();
	
//	sheetType = dijit.byId("desForm").attr("value").sheet_input;
	var cD=dijit.byId("pat_dual");
	var cF=dijit.byId("pat_file");
	var cC=dijit.byId("pat_col");
	if (cD.checked == 1) {
		Rapid= 2;
	} else if (cF.checked) {
		Rapid= 1;
	} else {
		Rapid= 0;		
	}
	var sw_sampleFormvalue = dijit.byId("sampleForm").attr("value").sheet_input;
	fcId = desFormvalue.Rname;
	if (fcId.search(regexp) == -1) {		
		textError.setContent("FlowCell Id: No spaces permitted");
		myError.show();
		return;
    	}

	var reg =new RegExp("\t","g");
	var LinesPatient=desFormvalue.Rpatient.split("\n");
	var SampleGroups=[];
	var IndexGroups=[];
	var DesGroups=[];
	var ProjectGroups=[];
	var LaneGroups=[];
	var BCIndexGroups=[];

	var Index2Groups=[];
	var BCIndex2Groups=[];


	for(var i=0; i<LinesPatient.length; i++) {
		var fieldPatient=LinesPatient[i].split(new RegExp("\\s+"));
		if (fieldPatient[0] == ""){
			continue;
		}
		var ExpATGC = /^[atgcATGC]+$/;
		if (fieldPatient.length!=5 && !Rapid ) {
			textError.setContent("Normal Patient Flowcell List must contain 5 fields");
			myError.show();
			return;
		}
		if (fieldPatient.length!=6 && Rapid==1) {
			textError.setContent("Rapid Patient Flowcell List must contain 6 fields");
			myError.show();
			return;
		}

		if (fieldPatient.length!=7 && Rapid==2) {
			textError.setContent("Dual Patient List must contain 7 fields");
			myError.show();
			return;
		}
		if (Rapid==2) {
			for(var j=0; j<fieldPatient.length; j++) {
				switch (j){
				case 0:
					if (fieldPatient[j].search(regexp2) == -1) {		
						textError.setContent("Patient: no accent, no ambiguous character");
						myError.show();
						clearResForm();
						return;
    					}

					SampleGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 1: case 3:
					if (fieldPatient[j].search(regexp3) == -1) {
						textError.setContent("Error BarCode Id: Alphanumeric & Uppercase");
						myError.show();
						clearResForm();
						return;
					}
					if (j==1) {BCIndexGroups.push(fieldPatient[j].replace(/ /g,""))};
					if (j==3) {BCIndex2Groups.push(fieldPatient[j].replace(/ /g,""))};
					break;
				case 2: case 4:
					if (fieldPatient[j].search(ExpATGC) == -1) {
						textError.setContent("Error Bar Code: range =>[atgcATGC]");
						myError.show();
						clearResForm();
						return;
					}
					if (j==2) {IndexGroups.push(fieldPatient[j].replace(/ /g,""))};
					if (j==4) {Index2Groups.push(fieldPatient[j].replace(/ /g,""))};
					break;
				case 5:ProjectGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 6: 
					var rg= /[,]+/g;
					var rg2= /^,/;
					var rg3= /,$/;
					fieldPatient[j]=fieldPatient[j].replace(rg,",");
					fieldPatient[j]=fieldPatient[j].replace(rg2,"");
					fieldPatient[j]=fieldPatient[j].replace(rg3,"");
					var ln=fieldPatient[j].split(",");
					// redundancy dedondant uniq
					if (ln.length != ln.unique().length) {
						textError.setContent("Error Lane: redundancy between lane number");
						myError.show();
						clearResForm();
						return;
					}
					for (x = 0; x < ln.length; x++) {
						if(ln[x]>8){
							textError.setContent("Error Lane: range =>[1-8]");
							myError.show();
							clearResForm();
							return;
						}
					}
					if (ln.length >8 ) {
						textError.setContent("Error Lane: Max number of lanes =>8");
						myError.show();
						clearResForm();
						return;
					}
					LaneGroups.push(fieldPatient[j].replace(/,/g,"_"));
					break;
				}
			}
		} else if (Rapid==1) {
			for(var j=0; j<fieldPatient.length; j++) {
				switch (j){
				case 0:
					if (fieldPatient[j].search(regexp2) == -1) {		
						textError.setContent("Patient: no accent, no ambiguous character");
						myError.show();
						clearResForm();
						return;
    					}

					SampleGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 1:
					if (fieldPatient[j].search(regexp3) == -1) {
						textError.setContent("Error BarCode Id: Alphanumeric & Uppercase");
						myError.show();
						clearResForm();
						return;
					}
					BCIndexGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 2:
					if (fieldPatient[j].search(ExpATGC) == -1) {
						textError.setContent("Error Bar Code: range =>[atgcATGC]");
						myError.show();
						clearResForm();
						return;
					}
					IndexGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 3:DesGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 4:ProjectGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 5: 
					var rg= /[,]+/g;
					var rg2= /^,/;
					var rg3= /,$/;
					fieldPatient[j]=fieldPatient[j].replace(rg,",");
					fieldPatient[j]=fieldPatient[j].replace(rg2,"");
					fieldPatient[j]=fieldPatient[j].replace(rg3,"");
					var ln=fieldPatient[j].split(",");
					// redundancy dedondant uniq
					if (ln.length != ln.unique().length) {
						textError.setContent("Error Lane: redundancy between lane number");
						myError.show();
						clearResForm();
						return;
					}
					for (x = 0; x < ln.length; x++) {
						if(ln[x]>8){
							textError.setContent("Error Lane: range =>[1-8]");
							myError.show();
							clearResForm();
							return;
						}
					}
					if (ln.length >8 ) {
						textError.setContent("Error Lane: Max number of lanes =>8");
						myError.show();
						clearResForm();
						return;
					}
					LaneGroups.push(fieldPatient[j].replace(/,/g,"_"));
					break;
				}
			}
		} else {
			for(var j=0; j<fieldPatient.length; j++) {
			switch (j){
				case 0:
					if (fieldPatient[j].search(regexp2) == -1) {		
						textError.setContent("Patient: no accent, no ambiguous character");
						myError.show();
						clearResForm();
						return;
    					}

					SampleGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 1:
					if (fieldPatient[j].search(ExpATGC) == -1) {
						textError.setContent("Error Bar Code: range =>[atgcATGC]");
						myError.show();
						clearResForm();
						return;
					}
					IndexGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 2:DesGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 3:ProjectGroups.push(fieldPatient[j].replace(/ /g,""));
					break;
				case 4: 
					var rg= /[,]+/g;
					var rg2= /^,/;
					var rg3= /,$/;
					fieldPatient[j]=fieldPatient[j].replace(rg,",");
					fieldPatient[j]=fieldPatient[j].replace(rg2,"");
					fieldPatient[j]=fieldPatient[j].replace(rg3,"");
					var ln=fieldPatient[j].split(",");
					// redundancy dedondant uniq
					if (ln.length != ln.unique().length) {
						textError.setContent("Error Lane: redundancy between lane number");
						myError.show();
						clearResForm();
						return;
					}
					for (x = 0; x < ln.length; x++) {
						if(ln[x]>8){
							textError.setContent("Error Lane: range =>[1-8]");
							myError.show();
							clearResForm();
							return;
						}
					}
					if (ln.length >8 ) {
						textError.setContent("Error Lane: Max number of lanes =>8");
						myError.show();
						clearResForm();
						return;
					}
					
					LaneGroups.push(fieldPatient[j].replace(/,/g,"_"));
					break;
				}
			}
		}
	}

	var url_insert = url_path + "/sampleSheet_file.pl?opt=create" +
				"&fcId="  + fcId +
				"&sampleId=" + SampleGroups +
				"&BCindex=" + BCIndexGroups.toString().toUpperCase() +
				"&index=" + IndexGroups.toString().toUpperCase() +
				"&BCindex2=" + BCIndex2Groups.toString().toUpperCase() +
				"&index2=" + Index2Groups.toString().toUpperCase() +
				"&des=" + DesGroups + 
				"&project=" + ProjectGroups +
				"&lane=" + LaneGroups;
	var res=sendData_noStatusText(url_insert);
	res.addCallback(
		function(response) {
			var cpatient = dijit.byId("Cpatient");
			cpatient.set("disabled",false);
			var responseB;
			if (Rapid) {			
				var sup_car=new RegExp(/#[\r\n]*/);
				var response_aff=response.replace(sup_car,'');	
				cpatient.set("value",response_aff);
				var Dual1=new RegExp(/(\[Header\][^\#]*)/);
				var responseA=response.replace(Dual1,'');	
				var Dual2=new RegExp(/#[\r\n]*/);
				responseB=responseA.replace(Dual2,'');
			} else {
				cpatient.set("value",response);
				responseB=response;
			}	


			var responseR=responseB.split("\r\n");
			var rep="";
			if (Rapid== 2) {
				for(var j=1; j<responseR.length; j++) {
					rep += responseR[j]+"\r\n";
				}
				var cpatientD = dijit.byId("CpatientD");
				cpatientD.set("value",rep);
			}  else if (Rapid==1) {

				for(var j=1; j<responseR.length; j++) {
					rep += responseR[j]+"\r\n";
				}
				var cpatientR = dijit.byId("CpatientR");
				cpatientR.set("value",rep);
			} else {
				for(var j=0; j<responseR.length; j++) {
					rep += responseR[j]+"\r\n";
				}
			}
		}
	);
}

var gridtmp;
var gridtmpR;
function downloadSampleSheet() {
	var desFormvalue = dijit.byId("desForm").getValues();
	var sampleFormvalue = dijit.byId("sampleForm").getValues();
    	var layouttmp = [
         	{ field: "FCID", name: "FCID"},
        	{ field: "Lane", name: "Lane"},
        	{ field: "SampleID", name: "SampleID"},
        	{ field: "SampleRef", name: "SampleRef"},
		{ field: "Index", name: "Index"},
        	{ field: "Description", name: "Description"},
        	{ field: "Control", name: "Control"},
        	{ field: "Recipe", name: "Recipe"},
        	{ field: "Operator", name: "Operator"},
        	{ field: "SampleProject", name: "SampleProject"},
    	];
	var cpatient = dijit.byId("Cpatient");
	var cpatientR;
	var cpatientD;
	var layouttmpR;
	if (sampleFormvalue.sheet_input.toString()=="Dual" ) {
		cpatientD = dijit.byId("CpatientD");
	}
	if (sampleFormvalue.sheet_input.toString()=="Rapid" ) {
		cpatientR = dijit.byId("CpatientR");
	}


	var tmpRStore;
	if (sampleFormvalue.sheet_input.toString()=="Dual") {
		tmpRStore = new dojox.data.CsvStore({data: cpatientD.value});
	    	var layouttmpR = [
        	{ field: "Lane", name: "Lane"},
        	{ field: "Sample_ID", name: "Sample_ID"},
        	{ field: "Sample_Name", name: "Sample_Name"},
        	{ field: "Sample_Plate", name: "Sample_Plate"},
		{ field: "Sample_Well", name: "Sample_Well"},
		{ field: "I7_Index_ID", name: "I7_Index_ID"},
		{ field: "index", name: "index"},
		{ field: "I5_Index_ID", name: "I5_Index_ID"},
		{ field: "index2", name: "index2"},
		{ field: "Sample_Project", name: "Sample_Project"},
        	{ field: "Description", name: "Description"},
    		];
	}

	if (sampleFormvalue.sheet_input.toString()=="Rapid") {
		tmpRStore = new dojox.data.CsvStore({data: cpatientR.value});
	    	var layouttmpR = [
        	{ field: "Lane", name: "Lane"},
        	{ field: "Sample_ID", name: "Sample_ID"},
        	{ field: "Sample_Name", name: "Sample_Name"},
        	{ field: "Sample_Plate", name: "Sample_Plate"},
		{ field: "Sample_Well", name: "Sample_Well"},
		{ field: "I7_Index_ID", name: "I7_Index_ID"},
		{ field: "index", name: "index"},
		{ field: "Sample_Project", name: "Sample_Project"},
        	{ field: "Description", name: "Description"},
    		];
	}
	var tmpStore = new dojox.data.CsvStore({data: cpatient.value});
	var id_grid=dijit.byId('gridtmpid');
 	if (id_grid) {
		id_grid.destroyRecursive();
	}
	gridtmp = new dojox.grid.EnhancedGrid({
		id:'gridtmpid',
		store: tmpStore,
		structure: layouttmp,
		plugins: {exporter: true}
	},document.createElement('div'));
	dojo.byId("gridtmp").appendChild(gridtmp.domNode);

	if (sampleFormvalue.sheet_input.toString()!="Normal") {
		var id_gridR=dijit.byId('gridtmpidR');
 		if (id_gridR) {
			id_gridR.destroyRecursive();
		}
		gridtmpR = new dojox.grid.EnhancedGrid({
			id:'gridtmpidR',
			store: tmpRStore,
			structure: layouttmpR,
			plugins: {exporter: true}
		},document.createElement('div'));
		dojo.byId("gridtmpR").appendChild(gridtmpR.domNode);
	}

	var in_header;
	var d=new Date();
	var my_date=formatDateToString(d);

	if (sampleFormvalue.sheet_input.toString()=="Dual") {
		in_header="[Header]"+"\r\n"+"IEMFileVersion,5"+"\r\n"+"Date,"+my_date+
		"\r\n"+"Workflow,GenerateFASTQ"+"\r\n"+"Application,HiSeq FASTQ Only"+
		"\r\n"+"Instrument Type,HiSeq 1500/2500"+
		"\r\n"+"Assay,Nextera XT Index Kit(24 Indexes 96 Samples)"+"\r\n"+"Description,"+
		"\r\n"+"Chemistry,Amplicon"+
		"\r\n"+","+"\r\n"+"[Reads]"+"\r\n"+"125"+"\r\n"+"125"+
		"\r\n"+"[Settings]"+"\r\n"+"ReverseComplement,0"+"\r\n"+"\r\n"+
		"[Data]"+"\r\n";
	} else if (sampleFormvalue.sheet_input.toString()=="Rapid") {
		in_header="[Data]"+"\r\n";
	} else {
		in_header="";
	}
	var tempGrid;
	if (Rapid) {
		tempGrid=gridtmpR;
	} else {
		tempGrid=gridtmp;
	}

//	dijit.byId(gridtmpR).exportGrid("csv",{writerArgs: {separator: ";"}}, function(str){
	dijit.byId(tempGrid).exportGrid("csv",{writerArgs: {separator: ","}}, function(str){
		var reg=new RegExp('"',"g");
		str=str.replace(reg,'');
		var form = document.createElement('form');
		dojo.attr(form, 'method', 'POST');
		var f_input=document.createElement('input');
		f_input.type="hidden";
		f_input.name="my_input";
		f_input.value=str;
		form.appendChild(f_input);

		var f_ifcid=document.createElement('input');
		f_ifcid.type="hidden";
		f_ifcid.name="my_fcid";
		f_ifcid.value=fcId;			
		form.appendChild(f_ifcid);

		var f_header=document.createElement('input');
		f_header.type="hidden";
		f_header.name="my_header";
		f_header.value=in_header;			
		form.appendChild(f_header);

		document.body.appendChild(form);
		dojo.io.iframe._currentDfd = null;
		if (this._deferred) {
    			this._deferred.cancel();
		}
		this._deferred=dojo.io.iframe.send({
			url: url_path + "/CSVexportSampleSheetR.pl",
 			form: form,
 			method: "POST",
			handleAs: "text",
			content: {exp: str},
		});
		document.body.removeChild(form);
	});
}

function chgTypeD(a){
	libFlowcell = dojo.byId("LibFlowcell");
	var desFormvalue = dijit.byId("desForm").getValues();
	if(this.checked) {
		libFlowcell.innerHTML= "File Name";
		dojo.style('Rpatient_labelD', 'display', '');
		dojo.style('Rpatient_labelR', 'display', 'none');
		dojo.style('Rpatient_labelN', 'display', 'none');
		
	}
}

function chgTypeR(a){
	libFlowcell = dojo.byId("LibFlowcell");
	var desFormvalue = dijit.byId("desForm").getValues();
	if(this.checked) {
		libFlowcell.innerHTML= "Flowcell Id";
		dojo.style('Rpatient_labelD', 'display', 'none');
		dojo.style('Rpatient_labelR', 'display', '');
		dojo.style('Rpatient_labelN', 'display', 'none');
		
	} 
}

function chgTypeN(a){
	libFlowcell = dojo.byId("LibFlowcell");
	var desFormvalue = dijit.byId("desForm").getValues();
	if(this.checked) {
		libFlowcell.innerHTML= "Flowcell Id";
		dojo.style('Rpatient_labelD', 'display', 'none');
		dojo.style('Rpatient_labelR', 'display', 'none');
		dojo.style('Rpatient_labelN', 'display', '');
	} 
}

function clearForm() {
	dijit.byId('Rname').set('value',"");
	dijit.byId('Rpatient').set('value',"");
	clearResForm();
	clearResRapidForm();
	clearResDualForm();
	dijit.byId("pat_dual").set('checked', true);
	dijit.byId("pat_file").set('checked', false);
	dijit.byId("pat_col").set('checked', false);
}

function clearResForm() {
	var cpatient = dijit.byId("Cpatient");
	cpatient.set("disabled",true);
	cpatient.set("value",'');
}

function clearResRapidForm() {
	var cpatientR = dijit.byId("CpatientR");
	cpatientR.set("value",'');
}

function clearResDualForm() {
	var cpatientD = dijit.byId("CpatientD");
	cpatientD.set("value",'');
}

function formatDateToString(date){
   // 01, 02, 03, ... 29, 30, 31
   var dd = (date.getDate() < 10 ? '0' : '') + date.getDate();
   // 01, 02, 03, ... 10, 11, 12
   var MM = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
   // 1970, 1971, ... 2015, 2016, ...
   var yyyy = date.getFullYear();
 //pull the last two digits of the year
   var yy = yyyy.toString().substr(-2);
   // create the format you want
   return (dd + "/" + MM + "/" + yy);
}

Array.prototype.unique = function()
{
    var tmp = {}, out = [];
    for(var i = 0, n = this.length; i < n; ++i)
    {
        if(!tmp[this[i]]) { tmp[this[i]] = true; out.push(this[i]); }
    }
    return out;
}

function standbyShow() {
	myStandby.show(); 
 	standby.show(); 
}

function standbyHide() {
	standby.hide();
	myStandby.hide();
};

