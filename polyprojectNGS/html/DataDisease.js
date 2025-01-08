/**
 * @author plaza
 */
dojo.require("dijit.form.Form");
dojo.require("dijit.form.FilteringSelect");
dojo.require("dojox.grid.DataGrid");
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dijit.Dialog");
dojo.require("dijit.form.Button");
dojo.require("dijit.form.ValidationTextBox");
dojo.require("dojo.parser");

dojo.require("dojo.date.locale");

dojo.require("dijit.Tooltip");
dojo.require("dijit.Menu");
dojo.require("dijit.MenuItem");
dojo.require("dijit.MenuSeparator");
dojo.require("dojox.widget.PlaceholderMenuItem");

dojo.require("dijit.DropDownMenu");


dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.layout.BorderContainer");
dojo.require("dojox.layout.ExpandoPane");
dojo.require("dijit.layout.AccordionContainer");
dojo.require("dijit.layout.TabContainer");

dojo.require("dojox.grid.EnhancedGrid");
dojo.require("dojox.grid.enhanced.plugins.DnD");
dojo.require("dojox.grid.enhanced.plugins.Menu");
dojo.require("dojox.grid.enhanced.plugins.NestedSorting");
dojo.require("dojox.grid.enhanced.plugins.IndirectSelection");
dojo.require("dojox.grid.enhanced.plugins.Pagination");

dojo.addOnLoad(function() {
//    var url_path = "/cgi-bin/plaza/polyprojectNGS";
	//################# Init Capture
	var diseaseStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=disease"
	});
	// set the layout structure:
	gridDis.setStore(diseaseStore);
	dijit.byId(gridDis)._refresh();
});


dojo.addOnLoad(function() {
	formDisDBDlg = dijit.byId("divDiseaseDB");
	dojo.connect(dijit.byId("buttonAddDiseaseDB"), "onClick", formDisDBDlg, "show");
});

//################# Return Main window
function goMain(){
//	this.location.href ="polyprojectNGS.html";
	this.location.href ="index.html";
}

function newDisease() {
	var disFormvalue = dijit.byId("disForm").getValues();
	//test no blank for abb
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var alphanum=/^[a-zA-Z0-9-_ \.]+$/;
	var check_abb = disFormvalue.abb;
	var check_dis = disFormvalue.disease;
	if (check_dis.search(alphanum) == -1) {
			textError.setContent("Enter a French disease name with no accent");
			myError.show();
			return;
	}

	if(! disFormvalue.abb.length ==0) {
		if (check_abb.search(regexp) == -1) {
			textError.setContent("No spaces permitted");
			myError.show();
			return;
		}
	}
	if (disFormvalue.disease.length ==0){		
			textError.setContent("Enter a disease name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=Newdisease"+"&disease="+disFormvalue.disease+
	"&abb="+disFormvalue.abb;
	sendData(url_insert);
	var diseaseStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=disease"
	});
	gridDis.setStore(diseaseStore);
	gridDis.store.close();
	dijit.byId(gridDis)._refresh();
	refreshDiseaseList();
};

function deleteDisease() {
	var itemDisease = gridDis.selection.getSelected();
	var DiseaseGroups = new Array(); 
	if (itemDisease.length) {
		dojo.forEach(itemDisease, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridDis.store.getAttributes(selectedItem), function(attribute) {
					var Diseasevalue = gridDis.store.getValues(selectedItem, attribute);
					if (attribute == "diseaseId" ) {
							DiseaseGroups.push(Diseasevalue);
					}				});
			} 
		});
	} else {
		textError.setContent("Please select one or more diseases");
		myError.show();
		return;
	} 
	var url_insert = url_path + "/manageData.pl?option=Deldisease"+"&diseaseId="+DiseaseGroups;
	//console.log(url_insert);
	sendData(url_insert);
	var diseaseStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=disease"
	});
	gridDis.setStore(diseaseStore);
	gridDis.store.close();
	dijit.byId(gridDis)._refresh();
	refreshDiseaseList();

}; // End of removeDiseaseProject

function refreshDiseaseList() {
//	var url_path = "/cgi-bin/plaza/polyprojectNGS";
	var diseaseStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=disease"
	});
	gridDis.setStore(diseaseStore);
	gridDis.store.close();
	dijit.byId(gridDis)._refresh();
};








