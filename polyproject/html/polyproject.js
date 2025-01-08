/**
 * @author plaza
 */

dojo.require("dijit.form.ComboBox");
dojo.require("dijit.form.CheckBox");
dojo.require("dijit.form.Form");
dojo.require("dijit.form.FilteringSelect");
dojo.require("dojox.grid.DataGrid");
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dijit.Dialog");
dojo.require("dijit.form.Button");
dojo.require("dijit.form.ValidationTextBox");
dojo.require("dojo.parser");
dojo.require("dijit.TitlePane");
dojo.require("dijit.form.TextBox");
dojo.require("dijit.form.Textarea");
dojo.require("dojo.data.ItemFileWriteStore");
dojo.require("dojo.date.locale");
dojo.require("dojox.grid.DataGrid");
dojo.require("dojox.grid.cells.dijit");
dojo.require("dojox.grid.EnhancedGrid");
dojo.require("dojox.grid.enhanced.plugins.DnD");
dojo.require("dojox.grid.enhanced.plugins.Menu");
dojo.require("dojox.grid.enhanced.plugins.NestedSorting");
dojo.require("dojox.grid.enhanced.plugins.IndirectSelection");
dojo.require("dijit.Tooltip");
dojo.require("dijit.Menu");
dojo.require("dijit.MenuItem");
dojo.require("dijit.MenuSeparator");
dojo.require("dojox.widget.PlaceholderMenuItem");

//dojo.require = function(module) {
//	if (module == "dijit.Editor") return;
//		_dr(module);
//};


dojo.addOnLoad(function() {
	//#################Init User
	var userStore = new dojo.data.ItemFileReadStore({
	url: url_path + "/createPolyproject.pl?option=user"
	});
	// set the layout structure:
	var layoutUser = [{field: 'Name',name: 'Name',width: '15em'},
	                  {field: 'Firstname',name: 'First Name',width: '15em'},
	                  {field: 'Code',name: 'Unit',width: 'auto'}
	];

	groups_Table = new dojox.grid.EnhancedGrid({
//	groups_Table = new dojox.grid.DataGrid({
			query: {UserId: '*'},
			store: userStore,
			rowSelector: '2em',
			structure: layoutUser,
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
	//################# Init Meth
	var methStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/createPolyproject.pl?option=method"
	});
	// set the layout structure:
	var layoutMeth = [{field: 'methName',name: 'Method Name',width: 'auto'}];

	groups_MTable = new dojox.grid.EnhancedGrid({
			query: {methType: 'SNP'},
			store: methStore,
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
	
	groups_ATable = new dojox.grid.EnhancedGrid({
		query: {methType: 'ALIGN'},
		store: methStore,
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
			url: url_path + "/createPolyproject.pl?option=plateform"
	});
	// set the layout structure:
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

	//################# Init Disease
	var diseaseStore = new dojo.data.ItemFileReadStore({
        url: url_path + "/createPolyproject.pl?option=disease"
	});
	var layoutDisease = [{field: 'diseaseName',name: "Disease Name",width: '45em'},
	                     {field: 'diseaseAbb',name: "Abbrev",width: '5em'}
	];

	groups_DTable = new dojox.grid.EnhancedGrid({
//	groups_DTable = new dojox.grid.DataGrid({
			query: {diseaseId: '*'},
			store: diseaseStore,
			rowSelector: '20px',
			structure: layoutDisease,
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


});

//################# Polyproject : Init Filter, Grid List, tooltip and gridMenu on grid List

function init() {	
//	createFilter(url_path + "/createPolyproject.pl?option=polyU",["MethAln","Type","Rel","Database"],grid,"filterTable",{projName:"Name",projDes:"Description",MethSnp:"Calling Method",userName:"User"});
	createFilter(url_path + "/createPolyproject.pl?option=polyU",
			["MethAln","Type","Rel","Database"],grid,"filterTable",
			{projName:"Name",projDes:"Description",MethSnp:"Calling Method",plateformName:"Plateform",userName:"User",Disease:"Disease"});
	var showTooltip = function(e) {
		var msg;
		if (e.rowIndex < 0) { // header grid
			msg = e.cell.name;
            	};
		if (msg) {
			var classmsg = "<i class='tooltip'>";
			if(msg=="All") {
				dijit.showTooltip(classmsg + 
				"<img src='/icons/myicons2/bullet_green.png'>" +
				" Complete Line" + "<br>" +
				"<img src='/icons/myicons2/bullet_red.png'>" + 
				" No User Account" + ' OR ' + "No Patient for Type ngs"+"</i>", e.cellNode,"above");			
			} else if(msg=="Rel") {
				dijit.showTooltip(classmsg + msg +
				': Release Human Genome' + '<br>' +
				'GoldenPath' + '</i>', e.cellNode,"above");
			}
			//dijit.showTooltip(msg, e.cellNode, ["below", "above", "after", "before"]);
		}
	}; 
	var hideTooltip = function(e) {
		dijit.hideTooltip(e.cellNode);
        }; 
	dojo.connect(grid, "onMouseOver", showTooltip);
	dojo.connect(grid, "onMouseOut", hideTooltip); 
	
//####	gridMenu for right click on header grid
	var checkBoxes = [];
	var container = dojo.byId('checkBoxContainer');
	dojo.forEach(grid.layout.cells, function(cell, index){
		var cb = new dijit.form.CheckBox({
			checked: !cell.hidden
		});
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
};

dojo.addOnLoad(init); 
function getRow(inRowIndex){
			return inRowIndex+1;
};

var layoutProjects = [
	{ field: "Row", name: "Row", get: getRow, width:3},
	{ field: "statut", name: "All", formatter:changeHtml ,width: 2 },
	{ field: "projId", name: "ID", width: 4},
//	{ field: "nbPatient", name: "nbPatient", width: 4},	
	{ field: "projName", name: "Name", width: 10},
	{ field: "projDes", name: "Description", width: 13},
	{ field: "Disease", name: "Disease", width: 20},
	{ field: "plateformName", name: "Plateform", width: 8},
	{ field: "MethAln", name: "Aln Method", width: 8},
	{ field: "MethSnp", name: "Calling Method", width: 10},
	{ field: "Type", name: "Type", width: 4},
	{ field: "capName", name: "Capture", width: 8},
	{ field: "macName", name: "SeqMachine", width: 6},
	{ field: "Rel", name: "Rel", width: 4},
	{ field: "Database",  name: "Database", width: 6},
	{ field: "userName",  name: "Users", width: 15}
];

//########################################################################
//################## Add User
//########################################################################
function selProject(ProjSelected) {
	var itemProj = grid.selection.getSelected();
	var okId=0;
	var okName=0;
	var selProjId;
	var selProjName;
	if (itemProj.length) {
		dojo.forEach(itemProj, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "projId" ) {
							selProjId = Projvalue;
							okId=1;
					}
					else if (attribute == "projName" ) {
						selProjName = Projvalue;
						okName=1;
					}
//					else if (okId==1 && okName==1){
					if (okId==1 && okName==1){
							addUser(selProjId,selProjName);
					}							
				});
			} 			
		});
	} else {
		textError.setContent("Please select a project !");
		myError.show();
		return;
	} 
}; //End of selProject

function addUser(id,name){
	var sp = dojo.byId("projid");
	sp.innerHTML= id;
	var jp = dojo.byId("projname");
	jp.innerHTML= name;
	var h = dojo.byId("projpname");
	h.value= name;
	divProj.show();
	dojo.byId("gridDiv").appendChild(groups_Table.domNode);
	// Call startup, in order to render the grid:
	groups_Table.startup();
}; // End of AddUser

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
//	alert("Users :"+UserGroups+" for Project :"+ProjSelected);
	var url_insert = url_path + "/upPoly.pl?type=addUserpoly"+"&ProjSel="+ProjSelected+"&User="+UserGroups;
	sendData(url_insert);
	refreshPolyList();
}; // End of newUserProject

//########################################################################
//################## Add Method Call
//########################################################################

function selMethCall(ProjSelected) {
	var itemProj = grid.selection.getSelected();
	var okId=0;
	var okName=0;
	var selProjId;
	var selProjName;
	if (itemProj.length) {
		dojo.forEach(itemProj, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "projId" ) {
						selProjId = Projvalue;
						okId=1;
					}
					else if (attribute == "projName" ) {
//					else if (attribute == "name" ) {
						selProjName = Projvalue;
						okName=1;
					}
					if (okId==1 && okName==1){
						addMeth(selProjId,selProjName);
					}
				});
			} 			
		});
	} else {
		textError.setContent("Please select a project !");
		myError.show();
		return;
	} 
}; //End of selMethCall

function addMeth(id,name){

	var spM = dojo.byId("projMid");
	spM.innerHTML= id;
	var jpM = dojo.byId("projMname");
	jpM.innerHTML= name;
	var hM = dojo.byId("projMpname");
	hM.value= name;
	divMeth.show();
	dojo.byId("gridMDiv").appendChild(groups_MTable.domNode);
	// Call startup, in order to render the grid:
	groups_MTable.startup();
}; // End of AddMeth

function newMethProject() {
	var ProjSelected = document.getElementById("projMid").innerHTML;
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
//	alert("Meth Call :"+MethGroups+" for Project :"+ProjSelected);
	var url_insert = url_path + "/upPoly.pl?type=addMethpoly"+"&ProjSel="+ProjSelected+"&Mcall="+MethGroups;
	sendData(url_insert);
	refreshPolyList();
}; // End of newMethProject

//########################################################################
//################## Add Aln Call
//########################################################################

function selAlnCall(ProjSelected) {
	var itemProj = grid.selection.getSelected();
	var okId=0;
	var okName=0;
	var selProjId;
	var selProjName;
	if (itemProj.length) {
		dojo.forEach(itemProj, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "projId" ) {
						selProjId = Projvalue;
						okId=1;
					}
					else if (attribute == "projName" ) {
						selProjName = Projvalue;
						okName=1;
					}
//					else if (okId==1 && okName==1){
					if (okId==1 && okName==1){
						addAln(selProjId,selProjName);
					}							
				});
			} 			
		});
	} else {
		textError.setContent("Please select a project !");
		myError.show();
		return;
	} 
}; //End of selAlnCall

function addAln(id,name){
	var spA = dojo.byId("projAid");
	spA.innerHTML= id;
	var jpA = dojo.byId("projAname");
	jpA.innerHTML= name;
	var hA = dojo.byId("projApname");
	hA.value= name;
	divAln.show();
	dojo.byId("gridADiv").appendChild(groups_ATable.domNode);
	// Call startup, in order to render the grid:
	groups_ATable.startup();
}; // End of AddMeth

function newAlnProject() {
	var ProjSelected = document.getElementById("projAid").innerHTML;
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
//	alert("Meth Call :"+MethGroups+" for Project :"+ProjSelected);
	var url_insert = url_path + "/upPoly.pl?type=addMethpoly"+"&ProjSel="+ProjSelected+"&Mcall="+AlnGroups;
	sendData(url_insert);
	refreshPolyList();
}; // End of newMethProject

//########################################################################
//################## Add Plateform
//########################################################################
function selPlateform(ProjSelected) {
	var itemProj = grid.selection.getSelected();
	var okId=0;
	var okName=0;
	var selProjId;
	var selProjName;
	if (itemProj.length) {
		dojo.forEach(itemProj, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "projId" ) {
						selProjId = Projvalue;
						okId=1;
					}
					else if (attribute == "projName" ) {
						selProjName = Projvalue;
						okName=1;
					}
//					else if (okId==1 && okName==1){
					if (okId==1 && okName==1){
						addPlateform(selProjId,selProjName);
					}							
				});
			} 			
		});
	} else {
		textError.setContent("Please select a project !");
		myError.show();
		return;
	} 
}; //End of selPlateform

function addPlateform(id,name){
	var spF = dojo.byId("projFid");
	spF.innerHTML= id;
	var jpF = dojo.byId("projFname");
	jpF.innerHTML= name;
	var hF = dojo.byId("projFpname");
	hF.value= name;
	divPlateform.show();
	dojo.byId("gridFDiv").appendChild(groups_FTable.domNode);
	// Call startup, in order to render the grid:
	groups_FTable.startup();
}; // End of AddPlateform

function newPlateformProject() {
	var ProjSelected = document.getElementById("projFid").innerHTML;
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
	//alert("Plateform :"+PlateformGroups+" for Project :"+ProjSelected);
		var url_insert = url_path + "/upPoly.pl?type=addPlateformpoly"+"&ProjSel="+ProjSelected+"&Fcall="+PlateformGroups;
		sendData(url_insert);
		refreshPolyList();
}; // End of newMethProject



//########################################################################
    
dojo.addOnLoad(function() {
	formDlg = dijit.byId("projDialog");
	// connect to the button so we display the dialog on click:
	dojo.connect(dijit.byId("buttonAddProj"), "onClick", formDlg, "show");
});

//########################################################################
//################## Add Polyproject 
//########################################################################
dojo.addOnLoad(function() {
	//	var plateformStore = new dojo.data.ItemFileReadStore({
	//		url: url_path + "/createPolyproject.pl?option=plateform"
	//});
	var typeStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/createPolyproject.pl?option=type"
	});
	var capStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/createPolyproject.pl?option=capture"
	});
	var macStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/createPolyproject.pl?option=machine"
	});
	var dbStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/createPolyproject.pl?option=database"
	});
	var typefilterSelect = new dijit.form.FilteringSelect({
		id: "typeSelect",
		name: "type",
		value: "ngs",
		store: typeStore,
		searchAttr: "typeName"
		},"typeSelect");
	var macfilterSelect = new dijit.form.FilteringSelect({
		id: "captureSelect",
		name: "capture",
		value: "agilent_v50",
		store: capStore,
		searchAttr: "capTitle"
	},"captureSelect");
	var macfilterSelect = new dijit.form.FilteringSelect({
		id: "machineSelect",
		name: "machine",
		value: "SOLID5500",
		store: macStore,
		searchAttr: "macDes"
	},"machineSelect");
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
		url: url_path + "/createPolyproject.pl?option=release"
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
				var defLabel = dojo.doc.createElement('label');
				defLabel.innerHTML = cbname ;
				defSpan.appendChild(defLabel);
				dojo.place(cb.domNode, dojo.byId("relRadio"), "last");
				dojo.place(defLabel, dojo.byId("relRadio"), "last");
			}
		}
	}
	//Callback for if the lookup fails.
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}
	//Fetch the data
	relStore.fetch({
		onBegin: clearOldCList,
		onComplete: gotRelease,
		onError: fetchFailed,
		queryOptions: {
			deep: true
		}
	});
}//End of initRadioButton
dojo.addOnLoad(initRadioButton);

function newProject() {
//Description project
	var projFormvalue = dijit.byId("projForm").getValues();
	 if (projFormvalue.description.length ==0){		
		textError.setContent("Enter a project Description");
		myError.show();
		return;
	}
//	var projDes = '"' + projFormvalue.description + '"';
//	var projDes = projFormvalue.description;

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
			}); // end forEach
		} // end if
	}); // end forEach
	} else {
		textError.setContent("Select an Alignment method");
		myError.show();
		return;
	}// end if

//Method Call field
	var itemMeth = methGrid.selection.getSelected();
	var MethGroups = new Array(); 
	if (itemMeth.length) {
	dojo.forEach(itemMeth, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(methGrid.store.getAttributes(selectedItem), function(attribute) {
				var Methvalue = methGrid.store.getValues(selectedItem, attribute);
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
	//Plateform field
	//	var plateformStore = new dojo.data.ItemFileReadStore({
	//		url: url_path + "/createPolyproject.pl?option=plateform"
	//});
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
	
	//Disease field
	var itemDisease = diseaseGrid.selection.getSelected();
	//	var selDisease;
	var DiseaseGroups = new Array(); 
	if (itemDisease.length) {
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
	} 
	//else {
	//	textError.setContent("Select a Disease");
	//	myError.show();
	//	return;
	//}	
	
//Project type field
	var typeFormvalue = dijit.byId("typeForm").getValues();
//Capture field
	var capFormvalue = dijit.byId("capForm").getValues();
//Machine field
	var macFormvalue = dijit.byId("macForm").getValues();
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
	var ptype=typeFormvalue.type;
	//	console.log('new_polyproject.pl opt=addPoly type=' + typeFormvalue.type + 
	//			' golden_path=' + gp + 
	//		    ' plateform=' + selPlateform +
	//			' method_align=' + AlnGroups +
	//			' method_call=' + MethGroups +
	//			' description=' + projFormvalue.description +
	//			' disease=' + DiseaseGroups +			
	//			' capture=' + capFormvalue.capture +
	//			' sequencing_machines=' + macFormvalue.machine +
	//			' database=' + dbFormvalue.database);
	var url_insert = url_path + "/new_polyproject.pl?opt=addPoly" +
					"&type="+ typeFormvalue.type +
					"&golden_path="+ gp +
					"&plateform="+ selPlateform +
					"&method_align="+ AlnGroups +
					"&method_call="+ MethGroups +
					"&description="+ projFormvalue.description +
					"&disease=" + DiseaseGroups +			
					"&capture=" + capFormvalue.capture +
					"&sequencing_machines="+ macFormvalue.machine +
					"&database=" + dbFormvalue.database;
	sendData(url_insert);
};

//########################################################################
//#################### view Polyproject : Calling viewPolyproject.html
//########################################################################
dojo.addOnLoad(function() {
			dojo.connect(grid,'onRowDblClick' , dblclickGrid);		
});

dblclickGrid = function (e) {
	// 3 for project Name
	var prj = grid.getCell(3).getNode(e.rowNode.gridRowIndex).textContent;
	viewPolyproject(prj);
}

function viewPolyproject(prj){
	parent.haut.document.getElementById('project_name').value = prj;	
	parent.bas.location.href ="viewPolyproject.html"
}   


function clickViewPolyproject(){
	var itemProj= grid.selection.getSelected();
//	var z= grid.selection.getSelected()[0];
//	var prj = grid.model.data[z]['projId'];
	var prj;
	if (itemProj.length) {
			dojo.forEach(itemProj, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
						var Projvalue = grid.store.getValues(selectedItem, attribute);
//						if (attribute == "projId" ) {
						if (attribute == "name" ) {
							prj = Projvalue;
						}
					});
				} 			
			});
	} else {
			textError.setContent("Please select a project !");
			myError.show();
			return;
	} 
	viewPolyproject(prj);
}
//########################################################################
//#################### view Progress Project : Calling ProgressProj.html
//########################################################################
function clickViewProgressProj(){
	parent.haut.document.getElementById('project_name').value = 111;	
	parent.bas.location.href ="ProgressProj.html"
}

//########################################################################

function refreshPolyList() {
	var polyStore = new dojo.data.ItemFileReadStore({url: url_path + "/createPolyproject.pl?option=polyU"});
	grid.setStore(polyStore);
	dijit.byId(grid)._refresh();
}; // End of refreshPolyList

//########################################################################
//########################################################################
//#################### view Disease : Calling viewDisease.html
//########################################################################
function viewDisease(prj){
	parent.haut.document.getElementById('project_name').value = prj;	
	parent.bas.location.href ="viewDisease.html"
}   

function clickViewDisease(){
	var itemProj= grid.selection.getSelected();
//	var z= grid.selection.getSelected()[0];
//	var prj = grid.model.data[z]['projId'];
	var prj;
	if (itemProj.length) {
			dojo.forEach(itemProj, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
						var Projvalue = grid.store.getValues(selectedItem, attribute);
//						if (attribute == "projId" ) {
						if (attribute == "name" ) {
							prj = Projvalue;
						}
					});
				} 			
			});
	} else {
			textError.setContent("Please select a project !");
			myError.show();
			return;
	} 
	viewDisease(prj);
}
