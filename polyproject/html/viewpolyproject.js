/**
 * @author plaza
 * viewpolyproject.js
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
dojo.require("dojox.grid.DataGrid");
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
	var polyStore = new dojo.data.ItemFileReadStore({
              url: url_path + "/createPolyproject.pl?option=polyU"+"&ProjSel="+ projectName
	});
	var projDiseaseStore = new dojo.data.ItemFileReadStore({
        url: url_path + "/createPolyproject.pl?option=polyD"+"&ProjSel="+ projectName
	});	
	gridD.setStore(projDiseaseStore);
	dijit.byId(gridD)._refresh();

	function clearOldCList(size, request) {
                    var list1 = dojo.byId("list1");
                    if (list1) {
                        while (list1.firstChild) {
                            list1.removeChild(list1.firstChild);
                        }
                    }
	}
	//Callback for processing a returned list of items.
	function gotProject(items, request) {
		var list0 = dojo.byId("list0");
		var list1 = dojo.byId("list1");
		if (list1) {
			var i;
			for (i = 0; i < items.length; i++) {
				var item = items[i];

				var bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Description"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "projDes")));
				list1.appendChild(document.createElement("br"));
				
				list1.appendChild(document.createElement("br"));
				bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Total patient"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "nbPatient")));

				list1.appendChild(document.createElement("br"));
				bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Capture"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "capName")));

				list1.appendChild(document.createElement("br"));
				bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Type"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "Type")));

				list1.appendChild(document.createElement("br"));
				bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Alignment Method"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "MethAln")));

				list1.appendChild(document.createElement("br"));
				bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Calling Method"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "MethSnp")));

				list1.appendChild(document.createElement("br"));
				bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Release"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "Rel")));

				list1.appendChild(document.createElement("br"));
				bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Database"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "Database")));

				list1.appendChild(document.createElement("br"));
				bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Sequencing Machine"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "macName")));

				list1.appendChild(document.createElement("br"));
				bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Sequencing Plateform"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "plateformName")));

				list1.appendChild(document.createElement("br"));
				bold = document.createElement("b");
				bold.appendChild(document.createTextNode("Creation Date"));
				list1.appendChild(bold);
				list1.appendChild(document.createElement("br"));
				list1.appendChild(document.createTextNode(polyStore.getValue(item, "cDate")));
				list1.appendChild(document.createElement("br"));							
			}
		}
	}
	//Callback for if the lookup fails.
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	//Fetch the data.
	polyStore.fetch({
		onBegin: clearOldCList,
		onComplete: gotProject,
		onError: fetchFailed,
		queryOptions: {
                        deep: true
		}
	});
}
dojo.addOnLoad(init1);

//#################Init2
function init2() {
	var projectName = parent.haut.document.getElementById('project_name').value;
	document.getElementById("titre").textContent = "Project Name : "+projectName;
	var teamStore = new dojo.data.ItemFileReadStore({
              url: url_path + "/createPolyproject.pl?option=polyT"+"&ProjSel="+ projectName
	});
	grid2.setStore(teamStore);
	dijit.byId(grid2)._refresh();
	
	var patientStore = new dojo.data.ItemFileReadStore({
	        url: url_path + "/createPolyproject.pl?option=polyP"+"&ProjSel="+ projectName
	});	
	gridP.setStore(patientStore);
	dijit.byId(gridP)._refresh();
}
dojo.addOnLoad(init2);
//################# button
function goBack(){
	parent.bas.location.href ="Polyproject.html";
}

//########################################################################
//################## Add Patient
//########################################################################
dojo.addOnLoad(function() {
	formPatDlg = dijit.byId("patDialog");
	// connect to the button so we display the dialog on click:
	dojo.connect(dijit.byId("buttonAddPat"), "onClick", formPatDlg, "show");
});

function newPatient() {
	var projectName = parent.haut.document.getElementById('project_name').value;
	var itemProj= gridP.selection.getSelected();
	var patFormvalue = dijit.byId("patForm").getValues();
	var lines=patFormvalue.patient.split("\n");
	if (patFormvalue.patient.length ==0){		
			textError.setContent("Enter a patient name");
			myError.show();
			return;
	}
	var lines=patFormvalue.patient.split("\n");
 	var url_insert = url_path + "/new_patient.pl?opt=addPatient" +
		 			"&projectName="+ projectName +
		 			"&patient="+ lines
//		 			"&patient="+ patFormvalue.patient
		 			
	//alert(url_insert);	 			
 	sendData(url_insert);
};

//########################################################################

function refreshPatientList() {
	var projectName = parent.haut.document.getElementById('project_name').value;
	var patientStore = new dojo.data.ItemFileReadStore({url: url_path + "/createPolyproject.pl?option=polyP"+"&ProjSel="+ projectName});
	gridP.setStore(patientStore);
	dijit.byId(gridP)._refresh();
}; // End of refreshPolyList
