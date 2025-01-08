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
dojo.require("dijit.MenuItem");
dojo.require("dijit.Menu");
dojo.require("dijit.form.FilteringSelect");

dojo.require("dojox.grid.DataGrid");
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dojo.data.ItemFileWriteStore");
dojo.require("dijit.Dialog");
dojo.require("dijit.form.Button");
dojo.require("dijit.form.ValidationTextBox");
dojo.require("dojo.parser");
dojo.require("dojo.date.locale");

dojo.require("dojox.grid.LazyTreeGrid");
dojo.require("dijit.tree.ForestStoreModel");
dojo.require("dojox.grid.LazyTreeGridStoreModel");

dojo.require("dijit.form.ComboBox");
dojo.require("dijit.form.CheckBox");
dojo.require("dijit.form.Form");
dojo.require("dijit.TitlePane");
dojo.require("dijit.form.TextBox");
dojo.require("dijit.form.Textarea");
dojo.require("dojox.grid.cells.dijit");
dojo.require("dojox.grid.EnhancedGrid");
dojo.require("dojox.grid.enhanced.plugins.DnD");
dojo.require("dojox.grid.enhanced.plugins.Menu");
dojo.require("dojox.grid.enhanced.plugins.NestedSorting");
dojo.require("dojox.grid.enhanced.plugins.IndirectSelection");
dojo.require("dojox.grid.enhanced.plugins.Pagination");

dojo.require("dijit.Tooltip");
dojo.require("dijit.Menu");
dojo.require("dijit.MenuSeparator");
dojo.require("dojox.widget.PlaceholderMenuItem");

dojo.require("dojox.grid.enhanced.plugins.exporter.CSVWriter");
dojo.require("dojox.grid.enhanced.plugins.exporter.TableWriter");
dojo.require("dojox.grid.enhanced.plugins.Printer");

/*
 * Databases
 * 
 */
function viewNewPlateform(){
	this.location.href = "DataPlateform.html"
}

function viewNewMachine(){
	this.location.href = "DataMachine.html";
}

function viewNewMethAlign(){
	this.location.href = "DataMethAlign.html";
}

function viewNewMethCall(){
	this.location.href = "DataMethCall.html";
}

function viewNewMethSeq(){
	this.location.href = "DataMethSeq.html";
}

function viewNewTypeSeq(){
	this.location.href = "DataTypeSeq.html";
}

function viewNewCapture(){
	this.location.href = "DataCapture.html";
}

function viewNewDisease(){
	this.location.href = "DataDisease.html";
}

function viewProgressProj(){
	this.location.href = "ProgressProj.html";
}

function viewNewUser(){
	var href = window.location.href;
	if (href.indexOf("plaza", 1) > -1) {
		location.href = "http://mendel.necker.fr/plaza/polyusers/index.html";
	} else {
		location.href = "http://mendel.necker.fr/polyusers/index.html";		
	}
}


var layoutProject = [
	{ field: "Row", name: "Row",get: getRow, width: '5'},
	{ field: "statut",name: "All",width: '2'},
	{ field: "name",name: "Name",width: '8'},
	{ field: "id",name: "ID",width: '4'},
	{ field: "description", name: "Description", width: '10'},
	{ field: "diseases", name: "Disease", width: '10', formatter:empty},
	{ field: "Rel", name: "Rel", width: '3'},
	{ field: "database", name: "Database", width: '6'},
	{ field: "nbRun", name: "#Run", width: '2.5'},
	{ field: "nbPat", name: "#Pat", width: '2.5'},
	{ field: "runId", name: "runId", width: '3'},
//	{ field: "Type", name: "Type", width: '3'},
	{ field: "capName", name: "Capture", width: '6'},
	{ field: "plateform", name: "Plateform", width: '8'},
	{ field: "macName", name: "Machine", width: '10'},
	{ field: "MethAln", name: "Alignment", width: '6'},
	{ field: "MethSnp", name: "Calling", width: '6'},
	{ field: "MethSeq", name: "MethSeq", width: '6'},
	{ field: "Users", name: "Users", width: '10'},
	{ field: "Unit", name: "Unit", width: '5'},
	{ field: "Site", name: "Site", width: '5'},
];

var layoutPrint = [
	{ field: "Row", name: "Row", width: '3'},
	{ field: "name",name: "Name",width: '6'},
//	{ field: "id",name: "ID",width: '4',sortDesc: true},
	{ field: "description", name: "Description", width: '10'},
//	{ field: "diseases", name: "Disease", width: '10', formatter:empty},
	{ field: "nbPat", name: "#Pat", width: '2'},
	{ field: "plateform", name: "Plateform", width: '6'},
	{ field: "macName", name: "Machine", width: '10'},
	{ field: "MethAln", name: "Alignment", width: '8'},
	{ field: "MethSnp", name: "Calling", width: '8'},
	{ field: "MethSeq", name: "MethSeq", width: '8'},
	{ field: "Users", name: "Users", width: '8'},
	{ field: "Unit", name: "Unit", width: '4'},
	{ field: "Site", name: "Site", width: '5'},
];
var layoutFreeRun = [
		{field: 'Row', name: 'Row', get: getRow, width:'3em'},
		{ field: "RunId",name: "Run", width: '4'},
		{ field: "patientName",name: "Patient", width: '10'},
		{ field: "plateformName", name: "Plateform", width: '10'},
		{ field: "capName", name: "Capture", width: '12'},
		{ field: "macName", name: "Machine", width: '8'},
		{ field: "methAln", name: "Alignment", width: '10'},
		{ field: "methSnp", name: "Calling", width: '10'},
		{ field: "methSeqName", name: "MethSeq", width: '8'},
		{ field: "cDate", name: "Date", width: '8'},
];

var layoutPatientProject = [
		{ field: "Row", name: "Row",get: getRow, width: 3},
		{ field: "Name",name: "Patient",width: '10'},
		{ field: "RunId",name: "Run",width: '4'},
		{ field: "macName",name: "macName",width: '8'},
		{ field: "capName", name: "Capture", width: '12'},
		{ field: "methAln",name: "Alignment",width: '13'},
		{ field: "methSnp",name: "Calling",width: '13'},
		{ field: "methSeqName", name: "MethSeq", width: '8'},
		{ field: "plateformName", name: "Plateform", width: '8'},
		{ field: "cDate", name: "Date", width: '6'},
];


function empty(value) {
	if(value == "") {
		return "<img align='top' src='/icons/Polyicons/exclamation.png'>";
	} else { return value}
}


var grid;
var freeRun_Table;
var patientprojectGrid;

function init(){
//#################Init Project List #############################
	var jsonStore = new dojo.data.ItemFileReadStore({ 
		url: url_path + "/polyprojectNGS_view.pl",
	});
	var Model = new dijit.tree.ForestStoreModel({store: jsonStore, childrenAttrs: ['children']});
	grid = new dojox.grid.LazyTreeGrid({
        	id: "grid",
		sortInfo:-4,
        	treeModel: Model,
        	structure: layoutProject,
		headerMenu:gridMenu,
		selectionMode:"single",
		rowSelector: "0.2em",
		plugins: {printer:true}
	}, document.createElement('div'));
	dojo.byId("gridDiv").appendChild(grid.domNode);
	grid.startup();
	dojo.connect(grid, 'onRowDblClick', editProject);

// Filters on grid (Utility: TableFilter2.js utilGrid2.js)
	createFilter(url_path + "/polyprojectNGS_view.pl",
		["database","Rel","Site"],grid,"filterTable",
	{name:"Name",projDes:"Description",diseases:"Disease",MethSeq:"Sequencing Method",MethSnp:"Calling Method",MethAln:"Alignment Method",
		plateform:"Plateform",Users:"User",Unit:"Unit"}
	);

	var showTooltip = function(e) {
		var msg;
		if (e.rowIndex < 0) { // header grid
			msg = e.cell.name;
            	};
		if (msg) {
			var classmsg = "<i class='tooltip'>";
			if(msg=="All") {
				//dijit.showTooltip("commmp", e.cellNode);
				dijit.showTooltip(classmsg + 
				"<img src='/icons/Polyicons/bullet_green.png'>" +
				" Complete Line" + "<br>" +
				"<img src='/icons/Polyicons/bullet_orange.png'>" +
				"No User Account" + "<br>" +
				"<img src='/icons/Polyicons/bullet_red.png'>" + 
				" No User Account, No Run/Patient linked"+"</i>", e.cellNode);		
			} 
		}

	}; 
	var hideTooltip = function(e) {
		dijit.hideTooltip(e.cellNode);
        }; 
	dojo.connect(grid, "onMouseOver", showTooltip);
	dojo.connect(grid, "onMouseOut", hideTooltip); 
//#############################
	function clearOldPrintList(size, request) {
                    var listPrint = dojo.byId("grid2PDiv");
                    if (listPrint) {
                        while (listPrint.firstChild) {
                           listPrint.removeChild(listPrint.firstChild);
                        }
                    }
	}
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	jsonStore.fetch({
		onBegin: clearOldPrintList,
		onError: fetchFailed,
		onComplete: function(items){
			grid2P = new dojox.grid.EnhancedGrid({
				id:'grid2P',
				store: jsonStore,
				structure: layoutPrint,
				plugins: {
					exporter: true,
					printer:true
				}
			},document.createElement('div'));
			dojo.byId("grid2PDiv").appendChild(grid2P.domNode);
			grid2P.startup();
		}
	});
	document.getElementById("grid2PDiv").style.display="none";  


//####	gridMenu for right click on header grid
	var checkBoxes = [];
	var container = dojo.byId('checkBoxContainer');
	dojo.forEach(grid.layout.cells, function(cell, index){
		if ( index==18 || index==19 ) {
			var cb = new dijit.form.CheckBox({
				checked: false
			});
		} else {
 			var cb = new dijit.form.CheckBox({
				checked: true
			});
		}
		if (index==18 || index==19 ) {
 			grid.layout.setColumnVisibility(index, false);
		} else {
 			grid.layout.setColumnVisibility(index, true);
		}
		dojo.connect(cb, "onChange", function(newValue){
 			grid.layout.setColumnVisibility(index, newValue);
		});

		var label = dojo.doc.createElement('label');
		label.innerHTML = cell.name;
		dojo.attr(label, 'for', cb.id);
 
		dojo.place(cb.domNode, container);
		dojo.place(label, container);
		dojo.place(dojo.doc.createElement("br"), container);
		checkBoxes.push(cb);
	});




//#################Init User #####################################
	var userStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=user"
	});
	var layoutUser = [{field: 'Name',name: 'Last Name',width: '15em'},
	                  {field: 'Firstname',name: 'First Name',width: '15em'},
			  {field: 'Site',name: 'Site',width: 'auto'},
	                  {field: 'Code',name: 'Lab Code',width: 'auto'}
	];

	groups_Table = new dojox.grid.EnhancedGrid({
			query: {UserId: '*'},
			store: userStore,
			rowSelector: '2em',
			structure: layoutUser,
			plugins: {
          			pagination: {
              				pageSizes: ["25", "50", "100", "All"],
              				description: true,
              				sizeSwitch: true,
              				pageStepper: true,
              				gotoButton: true,
              				maxPageStep: 5,
					defaultPageSize: 25,
              				position: "bottom"
          			},				
				nestedSorting: true,
				dnd: true,
				indirectSelection: {
					name: "Sel",
					width: "30px",
					styles: "text-align: center;",
				}
			}
	},document.createElement('div'));

//################# Init Meth #####################################
	var AlnStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=methodAln"
	});
	alnGrid.setStore(AlnStore);
	var CallStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=methodCall"
	});

	callGrid.setStore(CallStore);	
	var layoutMeth = [{field: 'methName',name: 'Method Name',width: 'auto'}];
	// Method Call
	groups_MTable = new dojox.grid.EnhancedGrid({
			query: {methType: 'SNP'},
			store: CallStore,
			rowSelector: '20px',
			structure: layoutMeth,
			plugins: {
				nestedSorting: true,
				dnd: true,
				indirectSelection: {
					name: "Sel",
					width: "30px",
					styles: "text-align: center;",
				}
			}
	},document.createElement('div'));
	// Method Aln
	groups_ATable = new dojox.grid.EnhancedGrid({
		query: {methType: 'ALIGN'},
		store: AlnStore,
		rowSelector: '20px',
		structure: layoutMeth,
		plugins: {
			nestedSorting: true,
			dnd: true,
			indirectSelection: {
				name: "Sel",
				width: "30px",
				styles: "text-align: center;",
			}
		}
	},document.createElement('div'));

	//################# Init Plateform
	var plateformStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=plateform"
	});
	plateformGrid.setStore(plateformStore);

	var layoutPlateform = [{field: 'plateformName',name: 'Plateform Name',width: 'auto'}];

	groups_FTable = new dojox.grid.EnhancedGrid({
		query: {plateformId: '*'},
		store: plateformStore,
		rowSelector: '20px',
		structure: layoutPlateform,
		plugins: {
			nestedSorting: true,
			dnd: true,
			indirectSelection: {
				name: "Sel",
				width: "30px",
				styles: "text-align: center;",
			}
		}
	},document.createElement('div'));

	//################# Init Machine

	var macStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=machine"
	});
	machineGrid.setStore(macStore);


	//################# Init Meth Seq
	var methSeqStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=methodSeq"
	});
	mseqGrid.setStore(methSeqStore);
	var layoutMethSeq = [{field: 'methSeqName',name: 'MethodSeq Name',width: 'auto'}];
	
	groups_STable = new dojox.grid.EnhancedGrid({
			query: {methodSeqId: '*'},
			store: methSeqStore,
			rowSelector: '20px',
			structure: layoutMethSeq,
			selectionMode: 'single',
			plugins: {
				nestedSorting: true,
				dnd: true,
				indirectSelection: {
					name: "Sel",
					width: "30px",
					styles: "text-align: center;",
				}
			}
	},document.createElement('div'));
	//################ Init Capture
	var capStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=capture"
	});
	capGrid.setStore(capStore);


	//################ Init Run Type
	var rtypeStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=runtype"
	});

	var rtypefilterSelect = new dijit.form.FilteringSelect({
		id: "rtypeInput",
		jsId:"rtypeInput",
		name: "runTypeName",
		value: "ngs",
		store: rtypeStore,
		searchAttr: "runTypeName"
	},"rtypeInput");

	//################# Init Disease
	var diseaseStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=disease"
	});
	diseaseGrid.setStore(diseaseStore);
	var layout2Disease = [{field: 'diseaseName',name: "Disease Name",width: '25em'},
	                     {field: 'diseaseAbb',name: "Abbrev",width: '5em'}
	];

	groups_DTable = new dojox.grid.EnhancedGrid({
			query: {diseaseId: '*'},
			store: diseaseStore,
			rowSelector: '20px',
			structure: layout2Disease,
			selectionMode: 'multiple',
			plugins: {
          			pagination: {
              				pageSizes: ["50", "100", "All"],
              				description: true,
              				sizeSwitch: true,
              				pageStepper: true,
              				gotoButton: true,
              				maxPageStep: 4,
					defaultPageSize: 25,
              				position: "bottom"
          			},				
				nestedSorting: true,
				dnd: true,
				indirectSelection: {
					name: "Add",
					width: "30px",
					styles: "text-align: center;",
				}
			}
	},document.createElement('div'));

//######## Init List Run Free ######################################
	var freeRunStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=freeRun"
	});

	freeRun_Table = new dojox.grid.EnhancedGrid({
			store: freeRunStore,
			structure: layoutFreeRun,
			selectionMode: 'multiple',
			plugins: {
 				nestedSorting: true,
				dnd: true,
				indirectSelection: {
					name: "Sel",
					width: "30px",
					styles: "text-align: center;",
				}
			}
	},document.createElement('div'));


}
dojo.addOnLoad(init);

function selProject(type,grid) {
	var itemProj = grid.selection.getSelected();
	var okId=0;
	var okName=0;
	var okRid=0;
	var oknbR=0;
	var selProjId;
	var selProjName;
	var selRunId;
	var selnbRun;
	if (itemProj.length) {
		dojo.forEach(itemProj, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "id" ) {
							selProjId = Projvalue;
							okId=1;
					}
					else if (attribute == "name" ) {
						selProjName = Projvalue;
						okName=1;
					}
					else if (attribute == "runId" ) {
						selRunId = Projvalue;
						okRid=1;
					}					
					else if (attribute == "nbRun" ) {
						selnbRun = Projvalue;
						if (selnbRun>0) {
							oknbR=1;
						}
					}
					if ((okId==1 && okName==1)){
							if(type=="user") {
									addUser(selProjId,selProjName);
							}
							if(type=="call") {
								if(okRid==1) {
									addMeth(selProjId,selProjName,selRunId);
								} else {
							textError.setContent("Please select a Run, not a Project !");
									myError.show();
									return;
								}
							}
							if(type=="aln") {
								if(okRid==1) {
									addAln(selProjId,selProjName,selRunId);
								} else {
							textError.setContent("Please select a Run, not a Project !");
									myError.show();
									return;
								}
							}
							if(type=="plt") {
								if(okRid==1) {
									addPlateform(selProjId,selProjName,selRunId);
								} else {
							textError.setContent("Please select a Run, not a Project !");
									myError.show();
									return;
								}
							}
							if(type=="seq") {
								if(okRid==1) {
									chgMethSeq(selProjId,selProjName,selRunId);
								} else {
							textError.setContent("Please select a Run, not a Project !");
									myError.show();
									return;
								}
							}
							if(type=="pat") {
								if(okRid==1) {
									addPat(selProjId,selProjName,selRunId);
								} else {
							textError.setContent("Please select a Run, not a Project !");
									myError.show();
									return;
								}
							}
					}
				});
			} 			
		});
	} else {
		textError.setContent("Please select a Project !");
		myError.show();
		return;
	} 
};


/*########################################################################
##################### New Run/Patient
##########################################################################*/
dojo.addOnLoad(function() {
	formRunDlg = dijit.byId("runDialog");
	// connect to the button so we display the dialog on click:
	dojo.connect(dijit.byId("buttonAddRun"), "onClick", formRunDlg, "show");
});
function newRun() {
	var itemPlateform = plateformGrid.selection.getSelected();
	var selPlateform;
	if (itemPlateform.length) {
	dojo.forEach(itemPlateform, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(plateformGrid.store.getAttributes(selectedItem), function(attribute) {
				var Plateformvalue = plateformGrid.store.getValues(selectedItem, attribute);
				if (attribute == "plateformName" ) {
					selPlateform = Plateformvalue;
					return selPlateform;
				}
			});
		}
	}); 
	} else {
		textError.setContent("Select a sequencing Plateform");
		myError.show();
		return;
	}
//Machine 
	var itemMachine = machineGrid.selection.getSelected();
	var selMachine;
	if (itemMachine.length) {
	dojo.forEach(itemMachine, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(machineGrid.store.getAttributes(selectedItem), function(attribute) {
				var Machinevalue = machineGrid.store.getValues(selectedItem, attribute);
				if (attribute == "macName" ) {
					selMachine = Machinevalue;
					return selMachine;
				}
			});
		}
	}); 
	} else {
		textError.setContent("Select a sequencing Machine");
		myError.show();
		return;
	}
//MethodSeq
	var itemMethodSeq = mseqGrid.selection.getSelected();
	var selMethodSeq;
	if (itemMethodSeq.length) {
	dojo.forEach(itemMethodSeq, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(mseqGrid.store.getAttributes(selectedItem), function(attribute) {
				var MethodSeqvalue = mseqGrid.store.getValues(selectedItem, attribute);
				if (attribute == "methSeqName" ) {
					selMethodSeq = MethodSeqvalue;
					return selMethodSeq;
				}
			});
		}
	}); 
	} else {
		textError.setContent("Select a sequencing Method");
		myError.show();
		return;
	}
//Alignment Method field
	var itemAln = alnGrid.selection.getSelected();
	var AlnGroups = new Array(); 
	if (itemAln.length) {
	dojo.forEach(itemAln, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(alnGrid.store.getAttributes(selectedItem), function(attribute) {
				var Alnvalue = alnGrid.store.getValues(selectedItem, attribute);
				if (attribute == "methName" ) {
					AlnGroups.push(Alnvalue);
					return AlnGroups;
				}
			});
		}
	});
	} else {
		textError.setContent("Select an Alignment method");
		myError.show();
		return;
	}
//Method Call field
	var itemMeth = callGrid.selection.getSelected();
	var MethGroups = new Array(); 
	if (itemMeth.length) {
	dojo.forEach(itemMeth, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(callGrid.store.getAttributes(selectedItem), function(attribute) {
				var Methvalue = callGrid.store.getValues(selectedItem, attribute);
				if (attribute == "methName" ) {
					MethGroups.push(Methvalue);
					return MethGroups;
				}
			});
		}
	}); 
	} else {
		textError.setContent("Select a method call");
		myError.show();
		return;
	}
//Capture
	var itemCapture = capGrid.selection.getSelected();
	var selCapture;
	if (itemCapture.length) {
	dojo.forEach(itemCapture, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(capGrid.store.getAttributes(selectedItem), function(attribute) {
				var Capvalue = capGrid.store.getValues(selectedItem, attribute);
				if (attribute == "capName" ) {
					selCapture = Capvalue;
					return selCapture;
				}
			});
		}
	}); 
	} else {
		textError.setContent("Select an Exon Capture");
		myError.show();
		return;
	}
//Patient
	var patFormvalue = dijit.byId("patForm").getValues();
	var lines=patFormvalue.patient.split("\n");
	if (patFormvalue.patient.length ==0){		
			textError.setContent("Enter a patient name");
			myError.show();
			return;
	}
	var patientForm=patFormvalue.patient.split("\n");
// Run type
	var rtypeFormvalue = dijit.byId('rtypeInput').get('value');
	if (!(rtypeFormvalue.length)) {
		textError.setContent("Select a run Type");
		myError.show();
		return;
	}

	var url_insert = url_path + "/new_polyproject.pl?opt=newRun" +
					"&plateform="+ selPlateform +
					"&machine="+ selMachine  +
					"&method_align="+ AlnGroups +
					"&method_call="+ MethGroups +
					"&mseq="+ selMethodSeq +
					"&type="+ rtypeFormvalue +
					"&capture="+ selCapture +
					"&patient="+ patientForm;
					
	sendData(url_insert);
	refreshFreeRunList();
}

/*########################################################################
##################### Link Project/Run Free Run
##########################################################################*/
var selProjId;
function linkRunProject() {
	var itemRP = grid.selection.getSelected();
	var selProjName;
	if (itemRP.length) {
		dojo.forEach(itemRP, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var RPvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "id" ) {
							selProjId = RPvalue;
					}
					else if (attribute == "name" ) {
						selProjName = RPvalue;
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select Project !");
		myError.show();
		return;
	} 
	addRun(selProjId,selProjName);
};


function addRun(id,name){
	var sp = dojo.byId("runProjId");
	sp.innerHTML= id;
	var jp = dojo.byId("runName");
	jp.innerHTML= name;
	var h = dojo.byId("runpName");
	h.value= name;
	projectrunDialog.show();
//Grid of Free Run
	dojo.byId("freerunGridDiv").appendChild(freeRun_Table.domNode);
	freeRun_Table.startup();

//Grid of Project Run
	var patientProjectStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=patientProject"+"&ProjSel="+ id
	});

	function clearOldPatientList(size, request) {
                    var listPat = dojo.byId("runpatientprojectGridDiv");
                    if (listPat) {
                        while (listPat.firstChild) {
                           listPat.removeChild(listPat.firstChild);
                        }
                    }
	}

	patientProjectStore.fetch({
		onBegin: clearOldPatientList,
		onError: fetchFailed,
		onComplete: function(items){
			patientprojectGrid = new dojox.grid.EnhancedGrid({
				store: patientProjectStore,
				structure: layoutPatientProject,
				rowSelector: '0.5em',
				plugins: {
					nestedSorting: true,
					dnd: true,
				}
			},document.createElement('div'));
			dojo.byId("runpatientprojectGridDiv").appendChild(patientprojectGrid.domNode);
			patientprojectGrid.startup();
		}
	});

//---------------------------- Fetch Data Grid Project -----------------------------------
	var projStore = new dojo.data.ItemFileReadStore({
              url: url_path + "/polyprojectNGS_view.pl?"+"&ProjSel="+ id
	});

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearOldPList(size, request) {
                    var list2 = dojo.byId("ProjectInfo");
                    if (list2) {
                        while (list2.firstChild) {
                            list2.removeChild(list2.firstChild);
                        }
                    }
	}

	function gotProjectInfo(items, request) {
		var list2 = dojo.byId("ProjectInfo");
		if (list2) {
			var i;
			for (i = 0; i < items.length; i++) {
				var item = items[i];
				var bold = document.createElement("b");
				var table1 = document.createElement("table");
				table1.border = 0;
				var tdAwidth=400;
				var trA1 = document.createElement("tr");
				var trA2 = document.createElement("tr");
				var tdA1 = document.createElement('td');
				var tdA2 = document.createElement('td');
				tdA2.width = tdA1.width = tdAwidth;
				tdA1.setAttribute('style','font-weight: bold');
				tdA2.setAttribute('style','font-weight: bold');

				var tdA11 = document.createElement('td');
				var tdA12 = document.createElement('td');
				tdA12.width = tdA11.width =tdAwidth;
				if (projStore.getValue(item, "description")|| projStore.getValue(item, "diseases")) {
					tdA1.appendChild(document.createTextNode('Description'));
					tdA2.appendChild(document.createTextNode('Diseases'));
					trA1.appendChild(tdA1);
					trA1.appendChild(tdA2);
					table1.appendChild(trA1);
					tdA11.appendChild(document.createTextNode(projStore.getValue(item, "description")));
					trA2.appendChild(tdA11);
 					table1.appendChild(trA2);
					tdA12.appendChild(document.createTextNode(projStore.getValue(item, "diseases")));
					trA2.appendChild(tdA12);
 					table1.appendChild(trA2);
					list2.appendChild(table1);

				}

				var table2 = document.createElement("table");
				table2.border = 0;
				var tdBwidth=200;
				var trB1 = document.createElement("tr");
				var trB2 = document.createElement("tr");
				var trB3 = document.createElement("tr");
				var tdB1 = document.createElement('td');
				var tdB2 = document.createElement('td');
				var tdB3 = document.createElement('td');
				var tdB11 = document.createElement('td');
				var tdB12 = document.createElement('td');
				var tdB13 = document.createElement('td');
				tdB3.width = tdB2.width = tdB1.width = tdBwidth;
				tdB1.setAttribute('style','font-weight: bold');
				tdB2.setAttribute('style','font-weight: bold');
				tdB3.setAttribute('style','font-weight: bold');
				tdB13.width = tdB12.width = tdB11.width =tdBwidth;

				if (projStore.getValue(item, "Rel")|| projStore.getValue(item, "database")||
					projStore.getValue(item, "cDate")) {
					tdB1.appendChild(document.createTextNode('Release'));
					tdB2.appendChild(document.createTextNode('Database'));
					tdB3.appendChild(document.createTextNode('Project Date'));
					trB1.appendChild(tdB1);
					trB1.appendChild(tdB2);
					trB1.appendChild(tdB3);
					table2.appendChild(trB1);
					tdB11.appendChild(document.createTextNode(projStore.getValue(item, "Rel")));
					trB2.appendChild(tdB11);
 					table2.appendChild(trB2);
					tdB12.appendChild(document.createTextNode(projStore.getValue(item, "database")));
					trB2.appendChild(tdB12);
 					table2.appendChild(trB2);
					tdB13.appendChild(document.createTextNode(projStore.getValue(item, "cDate")));
					trB2.appendChild(tdB13);
 					table2.appendChild(trB2);
					list2.appendChild(table2);
				}
			}
		}
	}
	projStore.fetch({
		onBegin: clearOldPList,
		onComplete: gotProjectInfo,
		onError: fetchFailed,
		queryOptions: {
                        deep: true
		}
	});


			
};

function newProjetRun() {
	var ProjSelected = document.getElementById("runProjId").innerHTML;
	var itemFRun = freeRun_Table.selection.getSelected();
	var PatGroups = new Array(); 
	if (itemFRun.length) {
		dojo.forEach(itemFRun, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(freeRun_Table.store.getAttributes(selectedItem), function(attribute) {
					var Runvalue = freeRun_Table.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatGroups.push(Runvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select one or more Run/Patient from the List of Patient !");
		myError.show();
		return;
	} 

	var url_insert = url_path + "/new_polyproject.pl?opt=addProjPat"+"&project="+ProjSelected+ "&patient="+PatGroups;
	sendData(url_insert);

	var patientProjectStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=patientProject"+"&ProjSel="+ ProjSelected
	});
	patientprojectGrid.setStore(patientProjectStore);
	patientprojectGrid.store.close();
	dijit.byId(patientprojectGrid)._refresh();
	refreshFreeRunList();
	refreshPolyList();
}
function selectAll() {
	freeRun_Table.rowSelectCell.toggleAllSelection(true);
}
function removeAll() {
	freeRun_Table.rowSelectCell.toggleAllSelection(false);
}




/*########################################################################
##################### Add Patient
##########################################################################*/
function addPat(id,name,rid){
	var sp = dojo.byId("patProjId");
	sp.innerHTML= id;
	var jp = dojo.byId("patName");
	jp.innerHTML= name;
	var rp = dojo.byId("patRunId");
	rp.innerHTML= rid;
	var h = dojo.byId("patpName");
	h.value= name;
	patDialog.show();

	// set the layout structure:
	var layoutPatient = [
		{field: 'Row', name: 'Row', get: getRow, width:'3em'},
		{field: 'patientName',name: 'Patient',width: '15em'}
	];

	var patientStore = new dojo.data.ItemFileReadStore({
	        url: url_path + "/manageData.pl?option=patient"+"&RunSel="+ rid
	});

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearOldPatientList(size, request) {
                    var listPatient = dojo.byId("patGridDiv");
                    if (listPatient) {
                        while (listPatient.firstChild) {
                           listPatient.removeChild(listPatient.firstChild);
                        }
                    }
	}

	patientStore.fetch({
		onBegin: clearOldPatientList,
		onError: fetchFailed,
		onComplete: function(items){
			patGrid = new dojox.grid.DataGrid({
				query: {patientName: '*'},
				store: patientStore,
				rowSelector: '2em',
				structure: layoutPatient,
				plugins: {
					nestedSorting: true,
					dnd: true,
					indirectSelection: {
						name: "Sel",
						width: "30px",
						styles: "text-align: center;",
					}
				}
			},document.createElement('div'));
			dojo.byId("patGridDiv").appendChild(patGrid.domNode);
			patGrid.startup();		
		}
	});
};

function newPat(patGrid) {
	var selRunId = patGrid.getItem(0).RunId;
	var selProjId = patGrid.getItem(0).ProjectId;
	var selCapId = patGrid.getItem(0).CaptureId;

	var patFormvalue = dijit.byId("patFormAdd").getValues();
	var lines=patFormvalue.patient.split("\n");
	if (patFormvalue.patient.length ==0){		
			textError.setContent("Enter a patient name");
			myError.show();
			return;
	}
	var patientForm=patFormvalue.patient.split("\n");
	var url_insert = url_path + "/new_polyproject.pl?opt=newPat" +
					"&project="+ selProjId +
					"&run="+ selRunId +
					"&capture="+ selCapId +
					"&patient="+ patientForm;

	sendData(url_insert);
	var patientStore = new dojo.data.ItemFileReadStore({
	        url: url_path + "/manageData.pl?option=patient"+"&RunSel="+ selRunId
	});
	patGrid.setStore(patientStore);
	dijit.byId(patGrid)._refresh();
	refreshPolyList();
}


/*########################################################################
				New Polyproject 
##########################################################################*/
dojo.addOnLoad(function() {
	formDlg = dijit.byId("projDialog");
	// connect to the button so we display the dialog on click:
	dojo.connect(dijit.byId("buttonAddProj"), "onClick", formDlg, "show");
});

dojo.addOnLoad(function() {
	var dbStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=database"
	});
	var dbfilterSelect = new dijit.form.FilteringSelect({
		id: "databaseSelect",
		name: "database",
		value: "Polyexome",
		store: dbStore,
		searchAttr: "dbName"
	},"databaseSelect");
});

function initRadioButton() {
	var relStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=release"
	});
	function clearOldCList(size, request) {
		var list = dojo.byId("relRadio");
		if (list) {
			while (list.firstChild) {
				list.removeChild(list.firstChild);
			}
		}
	}
	function gotRelease(items, request) {
		var list = dojo.byId("relRadio");
		if (list) {
			var i;
			var defSpan = dojo.doc.createElement('div');
			for (i = 0; i < items.length; i++) {
				var item = items[i];
				var name = 'db';
				var cbname = items[i].relName;
				var id = name + i;
				var title =cbname;
				var cb = new dijit.form.RadioButton({
					id: id,
					name: name,
					title:cbname,
				});
				if (item.relName[0]=="HG19"){
					cb.attr('checked', true);
				}
				var defLabel = dojo.doc.createElement('label');
				defLabel.innerHTML = cbname ;
				defSpan.appendChild(defLabel);
				dojo.place(cb.domNode, dojo.byId("relRadio"), "last");
				dojo.place(defLabel, dojo.byId("relRadio"), "last");
			}
		}
	}
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	relStore.fetch({
		onBegin: clearOldCList,
		onComplete: gotRelease,
		onError: fetchFailed,
		queryOptions: {
			deep: true
		}
	});
}
dojo.addOnLoad(initRadioButton);


function newProject() {
	var alphanum=/^[a-zA-Z0-9-_ \.\>]+$/;
	
//Description project
	var projFormvalue = dijit.byId("projForm").getValues();
	var check_des = projFormvalue.description;
	if (check_des.search(alphanum) == -1) {
		textError.setContent("Enter a project Description with no accent");
		myError.show();
		return;
	}
	if (projFormvalue.description.length ==0){		
		textError.setContent("Enter a project Description");
		myError.show();
		return;
	}
//Disease
	var itemDisease = diseaseGrid.selection.getSelected();
	var DiseaseGroups = new Array(); 
	dojo.forEach(itemDisease, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(diseaseGrid.store.getAttributes(selectedItem), function(attribute) {
				var Diseasevalue = diseaseGrid.store.getValues(selectedItem, attribute);
				if (attribute == "diseaseId" ) {
					DiseaseGroups.push(Diseasevalue);
				}
			});
		}
	}); 
//Database field
	var dbFormvalue = dijit.byId("dbForm").getValues();
//Release field
	var f = dojo.byId("relForm");
	var gp = "";
	for (var i = 0; i < f.elements.length; i++) {
		var elem = f.elements[i];
		if (elem.name == "button") {
			continue;
		}
		if (elem.type == "radio" && !elem.checked) {
			continue;
		}
		gp += elem.title;
	}
	if (!gp.length) {
		textError.setContent("Select a Human Genome release number");
		myError.show();
		return;
	}
	var url_insert = url_path + "/new_polyproject.pl?opt=newPoly" +
					"&golden_path="+ gp +
					"&description="+ projFormvalue.description +
					"&disease=" + DiseaseGroups +			
					"&database=" + dbFormvalue.database;
	sendData(url_insert);
	refreshPolyList();
};

/*########################################################################
##################### Add User
##########################################################################*/

function addUser(id,name){
	var sp = dojo.byId("projid");
	sp.innerHTML= id;
	var jp = dojo.byId("projname");
	jp.innerHTML= name;
	var h = dojo.byId("projpname");
	h.value= name;
	divUser.show();
	dojo.byId("gridUserDiv").appendChild(groups_Table.domNode);
	groups_Table.startup();
};

function newUserProject() {
	var ProjSelected = document.getElementById("projid").innerHTML;
	var itemUser = groups_Table.selection.getSelected();
	var UserGroups = new Array(); 
	if (itemUser.length) {
		dojo.forEach(itemUser, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(groups_Table.store.getAttributes(selectedItem), function(attribute) {
					var Uservalue = groups_Table.store.getValues(selectedItem, attribute);
					if (attribute == "UserId" ) {
						UserGroups.push(Uservalue);
					}
				});
			} 
		});
	}
	var url_insert = url_path + "/manageData.pl?option=addUser"+"&ProjSel="+ProjSelected+"&User="+UserGroups;
	sendData(url_insert);
	refreshPolyList();
};


//########################################################################
//################## Add Method Call
//########################################################################

function addMeth(id,name,rid){

	var spM = dojo.byId("projMid");
	spM.innerHTML= id;
	var jpM = dojo.byId("projMname");
	jpM.innerHTML= name;
	var hM = dojo.byId("projMpname");
	hM.value= name;
	var rc = dojo.byId("callRunId");
	rc.innerHTML= rid;
	divMeth.show();
	dojo.byId("gridMDiv").appendChild(groups_MTable.domNode);

	groups_MTable.startup();
};

function newMethRun() {
	var ProjSelected = document.getElementById("projMid").innerHTML;
	var RunSelected = document.getElementById("callRunId").innerHTML;
	var itemMeth = groups_MTable.selection.getSelected();
	var MethGroups = new Array(); 
	if (itemMeth.length) {
		dojo.forEach(itemMeth, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(groups_MTable.store.getAttributes(selectedItem), function(attribute) {
					var Methvalue = groups_MTable.store.getValues(selectedItem, attribute);
					if (attribute == "methodId" ) {
						MethGroups.push(Methvalue);
					}
				});
			} 
		});
	}
	//alert("Meth Call :"+MethGroups+" for Project :"+ProjSelected);
	var url_insert = url_path + "/manageData.pl?option=AddAlnCalling"+"&ProjSel="+ProjSelected+"&RunSel="+RunSelected+"&Mcall="+MethGroups;
//	var url_insert = url_path + "/manageData.pl?option=Addcalling"+"&ProjSel="+ProjSelected+"&Mcall="+MethGroups;
	sendData(url_insert);
	refreshPolyList();
};

//########################################################################
//################## Add Aln Call
//########################################################################

function addAln(id,name,rid){
	var spA = dojo.byId("projAid");
	spA.innerHTML= id;
	var jpA = dojo.byId("projAname");
	jpA.innerHTML= name;
	var hA = dojo.byId("projApname");
	hA.value= name;
	var ra = dojo.byId("alnRunId");
	ra.innerHTML= rid;
	divAln.show();
	dojo.byId("gridADiv").appendChild(groups_ATable.domNode);

	groups_ATable.startup();
};

function newAlnRun() {
	var ProjSelected = document.getElementById("projAid").innerHTML;
	var RunSelected = document.getElementById("alnRunId").innerHTML;
	var itemAln = groups_ATable.selection.getSelected();
	var AlnGroups = new Array(); 
	if (itemAln.length) {
		dojo.forEach(itemAln, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(groups_ATable.store.getAttributes(selectedItem), function(attribute) {
					var Alnvalue = groups_ATable.store.getValues(selectedItem, attribute);
					if (attribute == "methodId" ) {
						AlnGroups.push(Alnvalue);
					}
				});
			} 
		});
	}
	var url_insert = url_path + "/manageData.pl?option=AddAlnCalling"+"&ProjSel="+ProjSelected+"&RunSel="+RunSelected+"&Mcall="+AlnGroups;
	sendData(url_insert);
	refreshPolyList();
}; // End of newAlnProject

//########################################################################
//################## Add Plateform
//########################################################################

function addPlateform(id,name,rid){
	var spF = dojo.byId("projFid");
	spF.innerHTML= id;
	var jpF = dojo.byId("projFname");
	jpF.innerHTML= name;
	var hF = dojo.byId("projFpname");
	hF.value= name;
	var rp = dojo.byId("pltRunId");
	rp.innerHTML= rid;
	divPlateform.show();
	dojo.byId("gridFDiv").appendChild(groups_FTable.domNode);
	// Call startup, in order to render the grid:
	groups_FTable.startup();

};

function newPlateformRun() {
	var RunSelected = document.getElementById("pltRunId").innerHTML;
	var itemPlateform = groups_FTable.selection.getSelected();
	var PlateformGroups = new Array();
	if (itemPlateform.length) {
		dojo.forEach(itemPlateform, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(groups_FTable.store.getAttributes(selectedItem), function(attribute) {
					var Plateformvalue = groups_FTable.store.getValues(selectedItem, attribute);
					if (attribute == "plateformId" ) {
						PlateformGroups.push(Plateformvalue);
					}
				});
			} 
		});
	}
	var url_insert = url_path + "/manageData.pl?option=Addplateform"+"&RunSel="+RunSelected+"&Fcall="+PlateformGroups;
	sendData(url_insert);
	refreshPolyList();
};

/*########################################################################
##################### Add Disease
##########################################################################*/
function AddRemDisease() {
	var itemProj = grid.selection.getSelected();
	var selProjId;
	var selProjName;
	if (itemProj.length) {
		dojo.forEach(itemProj, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "id" ) {
							selProjId = Projvalue;
					}
					else if (attribute == "name" ) {
						selProjName = Projvalue;
					}
				});
			} 			
		});
	} else {
		textError.setContent("Please select a Project !");
		myError.show();
		return;
	} 
	addDisease(selProjId,selProjName);
}


function addDisease(id,name){
	var sp = dojo.byId("disProjId");
	sp.innerHTML= id;
	var jp = dojo.byId("disName");
	jp.innerHTML= name;
	var h = dojo.byId("dispName");
	h.value= name;
	disDialog.show();
	//Grid of List of Diseases
	dojo.byId("disprojGridDiv").appendChild(groups_DTable.domNode);
	groups_DTable.startup();

	//Grid of Project's diseases
	var diseaseProjStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=projDisease"+"&ProjSel="+ id
	});
	var layoutDisease = [{field: 'diseaseName',name: "Disease Name",width: '25em'},
	                     {field: 'diseaseAbb',name: "Abbrev",width: '5em'}
	];

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearOldDiseaseList(size, request) {
                    var listDisease = dojo.byId("disGridDiv");
                    if (listDisease) {
                        while (listDisease.firstChild) {
                           listDisease.removeChild(listDisease.firstChild);
                        }
                    }
	}

	diseaseProjStore.fetch({
		onBegin: clearOldDiseaseList,
		onError: fetchFailed,
		onComplete: function(items){
			disGrid = new dojox.grid.EnhancedGrid({
				query: {diseaseName: '*'},
				store: diseaseProjStore,
				rowSelector: '2em',
				selectionMode: 'multiple',
				structure: layoutDisease,
				plugins: {
					nestedSorting: true,
					dnd: true,
					indirectSelection: {
						name: "Del",
						width: "30px",
						styles: "text-align: center;",
					}
				}
			},document.createElement('div'));
			dojo.byId("disGridDiv").appendChild(disGrid.domNode);
			disGrid.startup();		
		}
	});
};


function addDiseaseProject() {
	var ProjSelected = document.getElementById("disName").innerHTML;
	var ProjId = document.getElementById("disProjId").innerHTML;
	var itemDis = groups_DTable.selection.getSelected();
	var DisGroups = new Array(); 
	if (itemDis.length) {
		dojo.forEach(itemDis, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(groups_DTable.store.getAttributes(selectedItem), function(attribute) {
					var Disvalue = groups_DTable.store.getValues(selectedItem, attribute);
					if (attribute == "diseaseId" ) {
						DisGroups.push(Disvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select one or more diseases from the List of Diseases !");
		myError.show();
		return;
	} 

	var url_insert = url_path + "/manageData.pl?option=addDisease"+"&ProjSel="+ProjSelected+ "&Disease="+DisGroups;
	sendData(url_insert);
	var diseaseProjStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=projDisease"+"&ProjSel="+ ProjId
	});
	disGrid.setStore(diseaseProjStore);
	disGrid.store.close();
	dijit.byId(disGrid)._refresh();
	refreshPolyList();
	groups_DTable.setStore(diseaseStore);
}

function removeDiseaseProject() {
	var ProjSelected = document.getElementById("disName").innerHTML;
	var ProjId = document.getElementById("disProjId").innerHTML;
	var itemDisease = disGrid.selection.getSelected();
	var DiseaseGroups = new Array(); 
	if (itemDisease.length) {
		dojo.forEach(itemDisease, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(disGrid.store.getAttributes(selectedItem), function(attribute) {
					var Diseasevalue = disGrid.store.getValues(selectedItem, attribute);
					if (attribute == "diseaseId" ) {
							DiseaseGroups.push(Diseasevalue);
					}				});
			} 
		});
	} else {
		textError.setContent("Please select one or more diseases from Project's Diseases !");
		myError.show();
		return;
	} 

	var url_insert = url_path + "/manageData.pl?option=remDisease"+"&ProjSel="+ProjId+"&Disease="+DiseaseGroups;
	sendData(url_insert);
	var diseaseProjStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=projDisease"+"&ProjSel="+ ProjId
	});
	disGrid.setStore(diseaseProjStore);
	disGrid.store.close();
	disGrid._refresh();
	refreshPolyList();
};



function refreshDiseaseList(disGrid) {
	var ProjId = document.getElementById("disProjId").innerHTML;
	var ProjName = document.getElementById("disName").innerHTML;
	var diseaseProjStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=projDisease"+"&ProjSel="+ ProjId
	});

	disGrid.setStore(diseaseProjStore,query={diseaseName: '*'});
	dijit.byId(disGrid).setQuery({diseaseName: '*'});
	disGrid.store.fetch();
	disGrid.store.close();
	disGrid.sort();
	disGrid._refresh();
}

/*########################################################################
##################### Add Rem MethSeq
##########################################################################*/
function chgMethSeq(id,name,rid) {
	var spS = dojo.byId("projSid");
	spS.innerHTML= id;
	var jpS = dojo.byId("projSname");
	jpS.innerHTML= name;
	var hS = dojo.byId("projSpname");
	hS.value= name;
	var rS = dojo.byId("seqRunId");
	rS.innerHTML= rid;
	divMethSeq.show();
	dojo.byId("gridSDiv").appendChild(groups_STable.domNode);
	groups_STable.startup();


};

function chgMethSeqRun() {
	var RunSelected = document.getElementById("seqRunId").innerHTML;
	var itemMethSeq = groups_STable.selection.getSelected();
	var MethSeqGroups = new Array();
	if (itemMethSeq.length) {
		dojo.forEach(itemMethSeq, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(groups_STable.store.getAttributes(selectedItem), function(attribute) {
					var MethSeqvalue = groups_STable.store.getValues(selectedItem, attribute);
					if (attribute == "methodSeqId" ) {
						MethSeqGroups.push(MethSeqvalue);
					}
				});
			} 
		});
	}
	var url_insert = url_path + "/manageData.pl?option=chgMethSeq"+"&RunSel="+RunSelected+"&Scall="+MethSeqGroups;
	sendData(url_insert);
	refreshPolyList();
}; 

/*########################################################################
##################### Edit Project
##########################################################################*/

function editProject() {
	var itemProj = grid.selection.getSelected();
	var selProjId;
	var selProjName;
	if (itemProj.length) {
		dojo.forEach(itemProj, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "id" ) {
							selProjId = Projvalue;
					}
					else if (attribute == "name" ) {
						selProjName = Projvalue;
					}
				});
			} 			
		});
	} else {
		textError.setContent("Please select a Project !");
		myError.show();
		return;
	} 
	showProject(selProjId,selProjName);
}

function showProject(id,name){
	var spU = dojo.byId("projUid");
	spU.innerHTML= id;
	var jpU = dojo.byId("projUname");
	jpU.innerHTML= name;
	var hU = dojo.byId("projUpname");
	hU.value= name;
	viewProj.show();
//---------------------------- Fetch Data Grid User Project -------------------------------

	var userProjectStore = new dojo.data.ItemFileWriteStore({
		clearOnClose:true,
	        url: url_path + "/manageData.pl?option=userProject"+"&ProjSel="+ id
	});

	var subU1 = [
		{field: 'Row',name: "Row",width: '3em', rowSpan: 2},
		{field: 'Name',name: "Name",width: '15em'},
		{field: 'Firstname',name: "First Name",width: '20em'},
		{field: 'Email',name: "Email",width: '20em'},
		{field: 'Code',name: "Code",width: '10em'},
		{field: 'Organisme',name: "Institute",width: '10em'},
		{field: 'Site',name: "Site",width: '10em'}
	];
	var subU2 = [
		{ field: "Team", name: "Team",colSpan:2},
		{ field: "Responsable", name: "Team Leader"},
		{ field: "Director", name: "Director",colSpan:3}
	];

	var layoutUserProject = {
		rows:[
			subU1,
			subU2
		]
	};
	function clearOldUserList(size, request) {
                    var listUser = dojo.byId("userprojectGridDiv");
                    if (listUser) {
                        while (listUser.firstChild) {
                           listUser.removeChild(listUser.firstChild);
                        }
                    }
	}

	userProjectStore.fetch({
		onBegin: clearOldUserList,
		onError: fetchFailed,
		onComplete: function(items){
			userprojectGrid = new dojox.grid.EnhancedGrid({
				query: {Name: '*'},
				store: userProjectStore,
				structure: layoutUserProject,
				rowSelector: '0.5em',
				plugins: {
					nestedSorting: true,
					dnd: true,
				}
			},document.createElement('div'));
			dojo.byId("userprojectGridDiv").appendChild(userprojectGrid.domNode);
			userprojectGrid.startup();
		}
	});

//---------------------------- Fetch Data Grid Patient Project -------------------------------
		
	var patientProjectStore = new dojo.data.ItemFileWriteStore({
		clearOnClose:true,
	        url: url_path + "/manageData.pl?option=patientProject"+"&ProjSel="+ id
	});

	function clearOldPatientList(size, request) {
                    var listPat = dojo.byId("patientprojectGridDiv");
                    if (listPat) {
                        while (listPat.firstChild) {
                           listPat.removeChild(listPat.firstChild);
                        }
                    }
	}

	patientProjectStore.fetch({
		onBegin: clearOldPatientList,
		onError: fetchFailed,
		onComplete: function(items){
			patientprojectGrid = new dojox.grid.EnhancedGrid({
				query: {Row: '*'},
				store: patientProjectStore,
				structure: layoutPatientProject,
				rowSelector: '0.5em',
				plugins: {
					nestedSorting: true,
					dnd: true,
				}
			},document.createElement('div'));
			dojo.byId("patientprojectGridDiv").appendChild(patientprojectGrid.domNode);
			patientprojectGrid.startup();			
		}
	});

//---------------------------- Fetch Data Grid Project -----------------------------------
	var polyStore = new dojo.data.ItemFileReadStore({
              url: url_path + "/polyprojectNGS_view.pl?"+"&ProjSel="+ id
	});

	function gotProject(items, request) {
		var list1 = dojo.byId("ProjectList");
		if (list1) {
			var i;
			for (i = 0; i < items.length; i++) {
				var item = items[i];
				var bold = document.createElement("b");
				if (polyStore.getValue(item, "description")) {
					bold.appendChild(document.createTextNode("Description"));
					list1.appendChild(bold);
					list1.appendChild(document.createElement("br"));
					list1.appendChild(document.createTextNode(polyStore.getValue(item, "description")));
					list1.appendChild(document.createElement("br"));
				}
				if (polyStore.getValue(item, "diseases")) {
					list1.appendChild(document.createElement("br"));
					bold = document.createElement("b");
					bold.appendChild(document.createTextNode("Disease"));
					list1.appendChild(bold);
					list1.appendChild(document.createElement("br"));
					list1.appendChild(document.createTextNode(polyStore.getValue(item, "diseases")));
					list1.appendChild(document.createElement("br"));
				}
				if (polyStore.getValue(item, "nbPat") && i==0) {
					list1.appendChild(document.createElement("br"));
					bold = document.createElement("b");
					bold.appendChild(document.createTextNode("Total patient"));
					list1.appendChild(bold);
					list1.appendChild(document.createElement("br"));
					list1.appendChild(document.createTextNode(polyStore.getValue(item, "nbPat")));
				}
				if (polyStore.getValue(item, "nbRun") && i==0) {
					list1.appendChild(document.createElement("br"));
					bold = document.createElement("b");
					bold.appendChild(document.createTextNode("Total Run"));
					list1.appendChild(bold);
					list1.appendChild(document.createElement("br"));
					list1.appendChild(document.createTextNode(polyStore.getValue(item, "nbRun")));
				}
				if (polyStore.getValue(item, "MethAln") && i==0) {
					list1.appendChild(document.createElement("br"));
					bold = document.createElement("b");
					bold.appendChild(document.createTextNode("Alignment Method"));
					list1.appendChild(bold);
					list1.appendChild(document.createElement("br"));
					list1.appendChild(document.createTextNode(polyStore.getValue(item, "MethAln")));
				}
				if (polyStore.getValue(item, "MethSnp") && i==0) {
					list1.appendChild(document.createElement("br"));
					bold = document.createElement("b");
					bold.appendChild(document.createTextNode("Calling Method"));
					list1.appendChild(bold);
					list1.appendChild(document.createElement("br"));
					list1.appendChild(document.createTextNode(polyStore.getValue(item, "MethSnp")));
				}
				if (polyStore.getValue(item, "Rel")) {
					list1.appendChild(document.createElement("br"));
					bold = document.createElement("b");
					bold.appendChild(document.createTextNode("Release"));
					list1.appendChild(bold);
					list1.appendChild(document.createElement("br"));
					list1.appendChild(document.createTextNode(polyStore.getValue(item, "Rel")));
				}
				if (polyStore.getValue(item, "database")) {
					list1.appendChild(document.createElement("br"));
					bold = document.createElement("b");
					bold.appendChild(document.createTextNode("Database"));
					list1.appendChild(bold);
					list1.appendChild(document.createElement("br"));
					list1.appendChild(document.createTextNode(polyStore.getValue(item, "database")));
				}
				if (polyStore.getValue(item, "cDate")) {
					list1.appendChild(document.createElement("br"));
					bold = document.createElement("b");
					bold.appendChild(document.createTextNode("Creation Date"));
					list1.appendChild(bold);
					list1.appendChild(document.createElement("br"));
					list1.appendChild(document.createTextNode(polyStore.getValue(item, "cDate")));
				}
			}
		}
	}

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearOldCList(size, request) {
                    var list1 = dojo.byId("ProjectList");
                    if (list1) {
                        while (list1.firstChild) {
                            list1.removeChild(list1.firstChild);
                        }
                    }
	}

	polyStore.fetch({
		onBegin: clearOldCList,
		onComplete: gotProject,
		onError: fetchFailed,
		queryOptions: {
                        deep: true
		}
	});
}; 



/*########################################################################
					END
##########################################################################*/

dojo.addOnLoad(function() {
	formDlg = dijit.byId("projDialog");
	// connect to the button so we display the dialog on click:
	dojo.connect(dijit.byId("buttonAddProj"), "onClick", formDlg, "show");
});



function printGrid() {
	document.getElementById("grid2PDiv").style.display="block"; 
	dijit.byId("grid2P").printGrid({
		title: "NGS Sequencing Project list",
//		cssFiles: ["print_style1.css","print_style2.css"]
		cssFiles: ["print_style1.css"]

		});
};


function printPreview(){
	document.getElementById("grid2PDiv").style.display="block"; 
	var g = dijit.byId("grid2P");
	g.exportToHTML({
		title: "NGS Sequencing Project list",
		cssFiles: ["print_style1.css"]
	}, function(str){
			var win = window.open();
			win.document.open();
			win.document.write(str);
			g.normalizePrintedGrid(win.document);
			win.document.close();
	});

}

function saveGridtoCSV() {
	document.getElementById("grid2PDiv").style.display="block"; 
	dijit.byId("grid2P").exportGrid("csv",{
 		writerArgs: {
 			separator: ";"
		}
		}, function(str){
			var reg=new RegExp('"',"g");
			var reg2=new RegExp("<img .*>","g");
			str=str.replace(reg,'');
			str=str.replace(reg2,'');
			var form = document.createElement('form');
                    	dojo.attr(form, 'method', 'POST');
                    	document.body.appendChild(form);
                    	dojo.io.iframe.send({
                            url: url_path + "/CSVexport.php",
                            form: form,
                            method: "POST",
                            content: {exp: str},
                    });
                    document.body.removeChild(form);
	});
};

function launchPrint() {
	printDialog.show();
};


function refreshPolyList() {
	var jsonStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/polyprojectNGS_view.pl"
	});
	grid.setStore(jsonStore);
	grid.store.close();
	grid.refresh();
};

function refreshFreeRunList() {	
	var freeRunStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=freeRun"
	});
	freeRun_Table.setStore(freeRunStore);
	freeRun_Table.store.close();
	dijit.byId(freeRun_Table)._refresh();
};

function refreshProjectRun() {
	var patientProjectStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=patientProject"+"&ProjSel="+ selProjId
	});
	patientprojectGrid.setStore(patientProjectStore);
	patientprojectGrid.store.close();
	dijit.byId(patientprojectGrid)._refresh();
	
};

function changeHtml(value){
	var l = value.length;
	var s = value.indexOf(";");
	var res1 = value.substring(s+1,l);
			
	return"<"+res1;
}
