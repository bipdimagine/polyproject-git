/**
 * @author plaza
 * viewdisease.js
 */
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dijit.form.Button");
dojo.require("dojox.grid.DataGrid");
dojo.require("dijit.layout.BorderContainer");
dojo.require("dijit.layout.TabContainer");
dojo.require("dijit.layout.ContentPane");
dojo.require("dojox.layout.ExpandoPane");
dojo.require("dijit.form.Form");
dojo.require("dijit.form.TextBox");
dojo.require("dijit.form.Textarea");
dojo.require("dijit.Dialog");
dojo.require("dijit.form.ComboBox");
dojo.require("dijit.form.CheckBox");
dojo.require("dijit.form.FilteringSelect");
dojo.require("dijit.form.ValidationTextBox");
dojo.require("dojo.parser");
dojo.require("dijit.TitlePane");
dojo.require("dojo.data.ItemFileWriteStore");
dojo.require("dojo.date.locale");
dojo.require("dojox.grid.DataGrid");
dojo.require("dojox.grid.cells.dijit");
dojo.require("dojox.grid.EnhancedGrid");
dojo.require("dojox.grid.enhanced.plugins.DnD");
dojo.require("dojox.grid.enhanced.plugins.Menu");
dojo.require("dojox.grid.enhanced.plugins.NestedSorting");
dojo.require("dojox.grid.enhanced.plugins.IndirectSelection");


function init1() {
	var projectName = parent.haut.document.getElementById('project_name').value;
	document.getElementById("titre").textContent = "Project Name : "+projectName;

	
	var projDiseaseStore = new dojo.data.ItemFileReadStore({
        url: url_path + "/createPolyproject.pl?option=polyD"+"&ProjSel="+ projectName
	});	
	gridP.setStore(projDiseaseStore);
	dijit.byId(gridP)._refresh();
	
	
	var diseaseStore = new dojo.data.ItemFileReadStore({
        url: url_path + "/createPolyproject.pl?option=disease"
	});	
	gridD.setStore(diseaseStore);
	dijit.byId(gridD)._refresh();
}
dojo.addOnLoad(init1);

//########################################################################
//################## Add Disease
//########################################################################
function init2() {
	var projectName = parent.haut.document.getElementById('project_name').value;
	
	document.getElementById("titre").textContent = "Project Name : "+projectName;
	
	
	var diseaseStore = new dojo.data.ItemFileReadStore({
        url: url_path + "/createPolyproject.pl?option=disease"
	});
	var layoutDisease = [{field: 'diseaseName',name: "Disease Name",width: '45em'},
	                     {field: 'diseaseAbb',name: "Abbrev",width: '5em'}
	];
	//
	//Callback for processing a returned list of items.
	//	function gotDisease(items, request) {
	//		var disease = dojo.byId("disease");
	//	}

	//	function clearOldCList(size, request) {
	//        var disease = dojo.byId("disease");
	//        if (disease) {
        	//            while (disease.firstChild) {
	//               disease.removeChild(disease.firstChild);
	//           }
	//        }
	//	}
	//Callback for if the lookup fails.
	//	function fetchFailed(error, request) {
	//		alert("lookup failed.");
	//		alert(error);
	//	}

	//Fetch the data.
	//	diseaseStore.fetch({
	//		onBegin: clearOldCList,
	//		onComplete: gotDisease,
	//		onError: fetchFailed,
	//		queryOptions: {
	//                       deep: true
	//		}
//	});

	groups_DTable = new dojox.grid.EnhancedGrid({
//	groups_DTable = new dojox.grid.DataGrid({
			query: {diseaseId: '*'},
			store: diseaseStore,
			rowSelector: '20px',
			structure: layoutDisease,
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
	
	function addDiseaseform(projectName){
		var jp = dojo.byId("projDname");
		jp.innerHTML= projectName;
		var h = dojo.byId("projDpname");
		h.value= projectName;
		divDisease.show();
		dojo.byId("gridDDiv").appendChild(groups_DTable.domNode);
	// Call startup, in order to render the grid:
		groups_DTable.startup();
	}; // End of AddPlateform

	formDisDlg = dijit.byId("divDisease");
	// connect to the button so we display the dialog on click:
	dojo.connect(dijit.byId("buttonAddDisease"), "onClick", formDisDlg, function(){addDiseaseform(projectName)});

	//DB Disease
	formDisDBDlg = dijit.byId("divDiseaseDB");
	dojo.connect(dijit.byId("buttonAddDiseaseDB"), "onClick", formDisDBDlg, "show");
}
dojo.addOnLoad(init2);



function newDiseaseProject() {
	var ProjSelected = document.getElementById("projDname").innerHTML;
	var itemDisease = groups_DTable.selection.getSelected();
	var DiseaseGroups = new Array(); 
	if (itemDisease.length) {
		dojo.forEach(itemDisease, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(groups_DTable.store.getAttributes(selectedItem), function(attribute) {
					var Diseasevalue = groups_DTable.store.getValues(selectedItem, attribute);
					if (attribute == "diseaseId" ) {
						DiseaseGroups.push(Diseasevalue);
					}
				});
			} 
		});
	}
//	alert("Diseases :"+DiseaseGroups+" for Project :"+ProjSelected);
	var url_insert = url_path + "/upPoly.pl?type=addDiseasepoly"+"&ProjSel="+ProjSelected+"&Disease="+DiseaseGroups;
	sendData(url_insert);
	refreshProjectDiseaseList();
}; // End of newUserProject

function refreshProjectDiseaseList() {
	var projectName = parent.haut.document.getElementById('project_name').value;
	document.getElementById("titre").textContent = "Project Name : "+projectName;
//	document.getElementById("titre").textContent = projectName;
	var projDiseaseStore = new dojo.data.ItemFileReadStore({
        url: url_path + "/createPolyproject.pl?option=polyD"+"&ProjSel="+ projectName
	});	
	gridP.setStore(projDiseaseStore);
	dijit.byId(gridP)._refresh();
}; // End of refreshProjectDiseaseList


function newDisease() {
	var disFormvalue = dijit.byId("disForm").getValues();
	if (disFormvalue.disease.length ==0){		
			textError.setContent("Enter a disease name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/upPoly.pl?type=newDiseasepoly"+"&disease="+disFormvalue.disease+"&abb="+disFormvalue.abb;
	refreshDiseaseList();
	sendData(url_insert);
};// End of newDisease

function refreshDiseaseList() {
	var projectName = parent.haut.document.getElementById('project_name').value;
	document.getElementById("titre").textContent = "Project Name : "+projectName;
	var diseaseStore = new dojo.data.ItemFileReadStore({
        url: url_path + "/createPolyproject.pl?option=disease"
	});
	gridD.setStore(diseaseStore);
	dijit.byId(gridD)._refresh();
}; // End of refreshProjectDiseaseList

function refreshDiseaseListgridDDiv() {
	var projectName = parent.haut.document.getElementById('project_name').value;
	document.getElementById("titre").textContent = "Project Name : "+projectName;
	var diseaseStore = new dojo.data.ItemFileReadStore({
        url: url_path + "/createPolyproject.pl?option=disease"
	});
	groups_DTable.setStore(diseaseStore);
	dijit.byId(groups_DTable)._refresh();
}; // End of refreshProjectDiseaseListgridDDiv


function removeDiseaseProject() {
	var itemDisease = gridP.selection.getSelected();
	var selProjId;
	var DiseaseGroups = new Array(); 
	if (itemDisease.length) {
		dojo.forEach(itemDisease, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridP.store.getAttributes(selectedItem), function(attribute) {
					var Diseasevalue = gridP.store.getValues(selectedItem, attribute);
					if (attribute == "diseaseId" ) {
							DiseaseGroups.push(Diseasevalue);
					}	else if (attribute == "projId" ) {
							selProjId = Diseasevalue;
					}
				});
			} 
		});
	}
//	alert("Delete Diseases :"+DiseaseGroups+" for Project :"+ selProjId);
	var url_insert = url_path + "/upPoly.pl?type=delDiseasepoly"+"&ProjSel="+selProjId+"&Disease="+DiseaseGroups;
	sendData(url_insert);
	refreshProjectDiseaseList();
}; // End of removeDiseaseProject


//################# button
function goBack(){
	parent.bas.location.href ="Polyproject.html";
}
