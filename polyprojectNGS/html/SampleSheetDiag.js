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
var tempStore;
var gridtemp;
var libFlowcell;
var site;

function init(){
//################# Standby for loading : use sendData_v2 #############################

	standby = new dojox.widget.Standby({
	       	target: "winStandby"
	});
	document.body.appendChild(standby.domNode);
	standby.startup();

	var domBtRun=dojo.byId("domBt_runFile");
	var w_runFile =dijit.byId("bt_runFile");
	if (w_runFile) {
		domBtRun.removeChild(w_runFile.domNode);
		w_runFile.destroyRecursive();
	}
	w_runFile = new dijit.form.Button({
		id:"bt_runFile",
		label:"<span><img align='top' src='icons/document_small_upload.png'></span>",
		onClick:function() {
			uploadFile(which="runFile");
		}
	},"bt_runFile");
	domBtRun.appendChild(w_runFile.domNode);
	dijit.byId("btn_dual").set('checked', true);

//loc=1 local
	site="Laboratoire de Diag";
	create_TitleHeader(site,loc);
}
dojo.addOnLoad(init);

function create_TitleHeader(site,loc){
	var h_span=document.getElementById("headerID")
	var table = document.createElement('table');
	table.setAttribute('style', 'color:grey;');
	var tr = document.createElement('tr');   
 	var td1 = document.createElement('td');
 	var td2 = document.createElement('td');

  	td1.textContent = "..." + site;
	if (loc) {
 		td2.textContent = "Local Sample Sheet";
	} else {
 		td2.textContent = "Sample Sheet";
	}
	td1.style.fontWeight = 'bold';
	td2.style.fontWeight = 'bold';
	td1.setAttribute('style', 'font-weight:bold;font-size:3em;text-align: center');
	td2.setAttribute('style', 'font-weight:bold;font-size:1.5em;text-align: center');

  	tr.appendChild(td1);
  	tr.appendChild(td2);

  	table.appendChild(tr);
	h_span.appendChild(table);
}

function uploadFile(which) {
	dojo.byId('opt').value ="insert";
	dojo.byId('param_file').value =which;
	var folderFormvalue = dijit.byId("folderForm").attr("value");
	if (! folderFormvalue.folderName) {
		textError.setContent("Enter a Run Name Folder please...");
		myError.show();
		return;
	}
	dojo.byId('param_dir').value =folderFormvalue.folderName;

	div_uploadFile.show();
}


function newResumeFile() {
	var cCum=dijit.byId("cumul_input");
	if (cCum.checked) {
		dijit.byId("folderName").set('disabled', false);
	}

	var folderFormvalue= dijit.byId("folderForm").getValues();
	if (! folderFormvalue.folderName) {
		textError.setContent("Enter a Run Name Folder please...");
		myError.show();
		return;
	}
	if (! folderFormvalue.machine_input) {
		textError.setContent("Select a Sequencing Machine please...");
		myError.show();
		return;
	}
	var cum=0;
	var cCum=dijit.byId("cumul_input");
	if (cCum.checked) {
		cum=1;
	}

	var dual=0;
	var cDual=dijit.byId("btn_dual");
	if (cDual.checked) {
		dual=1;
	}

	var prog_url=url_path + "/upload_SampleSheetfile.pl";
	var options="opt=copypastediag" +
				"&site=" + site +
				"&folder="  + folderFormvalue.folderName +
				"&rfile=" + replaceSpecialChar(folderFormvalue.CopyPasteF) +
				"&stype=" + folderFormvalue.machine_input +
				"&cumul=" + cum +
				"&dual=" + dual;
	var res=sendDataPostV2(prog_url,options);
	res.addCallback(
		function(response) {
			var samplef = dijit.byId("SampleF");
			var pedigreef = dijit.byId("PedigreeF");
			if(response.status=="OK"){
				samplef.set("disabled",false);
				pedigreef.set("disabled",false);
				var f_samplesheet=response.header + response.sheet;
				samplef.set("value",f_samplesheet);
				var  cpatient= dijit.byId("Cpatient");
				cpatient.set("disabled",false);
				cpatient.set("value",response.sheet);
				var f_pedigree=response.pedigree;
				pedigreef.set("value",f_pedigree);
				var  cpedigree= dijit.byId("Cpedigree");
				cpedigree.set("disabled",false);
				cpedigree.set("value",response.pedigree);
			}
		}
	);
}

var fcId;
var gridtmp;
function downloadSampleSheet() {
	var folderFormvalue= dijit.byId("folderForm").getValues();
	var cDual=dijit.byId("btn_dual");
	var layouttmp;
	if (cDual.checked) {
		layouttmp = [
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
	} else {
		layouttmp = [
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

	var cpatient = dijit.byId("Cpatient");
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
//	gridtmp.startup();
	var in_header;
	var d=new Date();
	var my_date=formatDateToString(d);
	if (folderFormvalue.machine_input.toString()=="nextseq") {
		in_header="[Header]"+"\r\n"+"IEMFileVersion,4"+"\r\n"+"Date,"+my_date+
		"\r\n"+"Workflow,NextSeq FASTQ Only"+"\r\n"+"Application,NextSeq FASTQ Only"+
//		"\r\n"+"Description,RENOME_V4-S51"+
		"\r\n"+"Description,"+folderFormvalue.folderName +
		"\r\n"+"Chemistry,Twist"+
		"\r\n"+"\r\n"+"[Reads]"+"\r\n"+"149"+"\r\n"+"149"+
		"\r\n"+"[Settings]"+"\r\n"+"Adapter,AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"+"\r\n"+"AdapterRead2,AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"+"\r\n"+"\r\n"+
		"[Data]"+"\r\n";
	} else if (folderFormvalue.machine_input.toString()=="miseq") {
		in_header="[Header]"+"\r\n"+"IEMFileVersion,4"+
		"\r\n"+"Investigator Name,CD"+"\r\n"+"Experiment Name,Projet NGS CD"+
		"\r\n"+"Date,"+my_date+
		"\r\n"+"Workflow,GenerateFASTQ"+"\r\n"+"Application,FASTQ Only"+
		"\r\n"+"Assay,Gendx"+
		"\r\n"+"Description,PLAQUE IV 96 samples"+
		"\r\n"+"Chemistry,Amplicon"+
		"\r\n"+"\r\n"+"[Reads]"+"\r\n"+"151"+"\r\n"+"151"+
		"\r\n"+"[Settings]"+"\r\n"+"Adapter,AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"+"\r\n"+"AdapterRead2,AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"+"\r\n"+"\r\n"+
		"[Data]"+"\r\n";
	}

	dijit.byId(gridtmp).exportGrid("csv",{writerArgs: {separator: ","}}, function(str){
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
		fcId=folderFormvalue.folderName;		
		f_ifcid.value=fcId;			
		form.appendChild(f_ifcid);

		var f_header=document.createElement('input');
		f_header.type="hidden";
		f_header.name="my_header";
		f_header.value=in_header;			
		form.appendChild(f_header);

		var f_suffix=document.createElement('input');
		f_suffix.type="hidden";
		f_suffix.name="my_suffix";
		f_suffix.value="SampleSheet";			
		form.appendChild(f_suffix);

		document.body.appendChild(form);
		dojo.io.iframe._currentDfd = null;
		if (this._deferred) {
    			this._deferred.cancel();
		}
		this._deferred=dojo.io.iframe.send({
			url: url_path + "/CSVexportSampleSheet.pl",
 			form: form,
 			method: "POST",
			handleAs: "text",
			content: {exp: str},
		});
		document.body.removeChild(form);
	});
}

var gridtemp;
function downloadPedigree() {
	var folderFormvalue= dijit.byId("folderForm").getValues();
   	var layouttemp = [
        	{ field: "Patient", name: "Patient"},
        	{ field: "Family", name: "Family"},
        	{ field: "Mother", name: "Mother"},
		{ field: "Father", name: "Father"},
		{ field: "Status", name: "Status"},
		{ field: "Sex", name: "Sex"},
		{ field: "IV", name: "IV"},
    	];
	var cpedigree = dijit.byId("Cpedigree");
	var tempStore = new dojox.data.CsvStore({data: cpedigree.value});
	var id_grid=dijit.byId('gridtempid');
 	if (id_grid) {
		id_grid.destroyRecursive();
	}
	gridtemp = new dojox.grid.EnhancedGrid({
		id:'gridtempid',
		store: tempStore,
		structure: layouttemp,
		plugins: {exporter: true}
	},document.createElement('div'));
	dojo.byId("gridtemp").appendChild(gridtemp.domNode);
//	gridtmp.startup();
	dijit.byId(gridtemp).exportGrid("csv",{writerArgs: {separator: ","}}, function(str){
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
		fcId=folderFormvalue.folderName;		
		f_ifcid.value=fcId;			
		form.appendChild(f_ifcid);

		var f_header=document.createElement('input');
		f_header.type="hidden";
		f_header.name="my_header";
		f_header.value="";			
		form.appendChild(f_header);

		var f_suffix=document.createElement('input');
		f_suffix.type="hidden";
		f_suffix.name="my_suffix";
		f_suffix.value="Pedigree";			
		form.appendChild(f_suffix);
		document.body.appendChild(form);
		dojo.io.iframe._currentDfd = null;
		if (this._deferred) {
    			this._deferred.cancel();
		}
		this._deferred=dojo.io.iframe.send({
			url: url_path + "/CSVexportSampleSheet.pl",
 			form: form,
 			method: "POST",
			handleAs: "text",
			content: {exp: str},
		});
		document.body.removeChild(form);
	});
}

function clearAllForm() {
	dijit.byId('runFile').set('value',"");
	dijit.byId('folderName').set('value',"");
	dijit.byId('SampleF').set('value',"");
	dijit.byId('SampleF').set("disabled",true);
	dijit.byId('PedigreeF').set('value',"");
	dijit.byId('PedigreeF').set("disabled",true);
	dijit.byId('CopyPasteF').set('value',"");
	dijit.byId("machine_nextseq").set('checked', false);
	dijit.byId("machine_miseq").set('checked', false);
	dijit.byId("btn_dual").set('checked', true);
	clearHidenForm();
}

function clearHidenForm() {
	var cpatient = dijit.byId("Cpatient");
	cpatient.set("disabled",true);
	cpatient.set("value",'');
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

