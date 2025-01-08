/**
 * @author plaza
 */
//chargement de modules dojo necessaires
dojo.require("dojox.grid.DataGrid");
dojo.require("dojo.cookie");
dojo.require("dijit.Dialog");
dojo.require("dijit.form.Button");
dojo.require("dijit.form.TextBox");
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dijit.layout.TabContainer");
dojo.require("dijit.layout.ContentPane");
dojo.require("dojo.data.ItemFileWriteStore");
dojo.require("dojo.data.api.Write");
dojo.require("dijit.Tooltip");
	    
var layoutProject = [
	{
		name: "Row",
		get: getRow,
		width: 3,
		styles: 'text-align:center;'
	},
	{
		field: "id",
		name: "ID",
		width: 4,
		styles: 'text-align:center;'
	},
	{
		field: "name",
		name: "Name",
		width: '13',
		styles: 'text-align:center;'
	},
	{
		field: "plateform",
		name: "Plateform",
		width: '10',
		styles: 'text-align:center;'
	},
	{
		field: "seqName",
		name: "seqName",
		width: '10',
		styles: 'text-align:center;'
	},
	{
		field: "description",
		name: "Description",
		width: '20',
		styles: 'text-align:center;'
	},
	{
		field: "progress",
		name: "Progression",
		formatter:icon_progress,
		width: '31',
		styles: 'text-align:center;'
	},
];
		  
function init(){
	var url_path = "/cgi-bin/plaza/polyproject";
	var jsonStore = new dojo.data.ItemFileWriteStore({ url: url_progress });
	gridProject.setStore(jsonStore);
	//##################  Tooltip
	var showTooltip = function(e) {
		var msg;
		if (e.rowIndex < 0) { // header grid
			msg = e.cell.name;
		};
		if (msg) {
			var classmsg = "<i class='tooltip'>";
			if(msg=="Progression") {
				dijit.showTooltip(classmsg + 
				"<img src='/icons/myicons5/green_rectangle.png'>" +
				" Valid step " +
				"<img src='/icons/myicons5/red_rectangle.png'>" + 
				" Failed step" + "</i>", e.cellNode,"before");			
			} 			//dijit.showTooltip(msg, e.cellNode, ["below", "above", "after", "before"]);
		}
	}; 
	var hideTooltip = function(e) {
		dijit.hideTooltip(e.cellNode);
        }; 
	dojo.connect(gridProject, "onMouseOver", showTooltip);
	dojo.connect(gridProject, "onMouseOut", hideTooltip); 
	//################## End  Tooltip

	function getItems() {
		function clearOldCList(size, request) {
			var list0 = dojo.byId("list0");
			var list1 = dojo.byId("list1");
			var list2 = dojo.byId("list2");
			if (list0) {
				while (list0.firstChild) {
					list0.removeChild(list0.firstChild);
				}
			}
			if (list1) {
				while (list1.firstChild) {
					list1.removeChild(list1.firstChild);
				}
			}
			if (list2) {
				while (list2.firstChild) {
					list2.removeChild(list2.firstChild);
				}
			}
		}
		//########################################################################
		//################## Edit Progress Project
		//########################################################################

		//Callback for processing a returned list of items.
		function gotProject(items, request) {
			var itemProj = gridProject.selection.getSelected();
			//##################  Tooltip
			dojo.connect(gridProjectName0, "onMouseOver", showTooltip);
			dojo.connect(gridProjectName0, "onMouseOut", hideTooltip); 
			//################## End  Tooltip
			if (itemProj.length) {
				dojo.forEach(itemProj, function(selectedItem) {
					if (selectedItem !== null) {
						dojo.forEach(gridProject.store.getAttributes(selectedItem), function(attribute) {
							var Projvalue = gridProject.store.getValues(selectedItem, attribute);
							var list0 = dojo.byId("list0");
							var list1 = dojo.byId("list1");
							var list2 = dojo.byId("list2");
					//if (list1) { 
							if (attribute == "name" ) {
								var bold = document.createElement("b");
								bold.appendChild(document.createTextNode("ID"));
								list1.appendChild(bold);
								list1.appendChild(document.createElement("br"));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "id")));
								list1.appendChild(document.createElement("br"));
								ProjId=gridProject.store.getValue(selectedItem, "id")

								bold = document.createElement("b");
								bold.appendChild(document.createTextNode(" Name :  "));
								bold.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "name")));
								list0.appendChild(bold);
								list0.appendChild(document.createElement("br"));
						
								list1.appendChild(document.createElement("br"));
								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("Description"));
								list1.appendChild(bold);
								list1.appendChild(document.createElement("br"));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "description")));
								list1.appendChild(document.createElement("br"));

								list1.appendChild(document.createElement("br"));
								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("Type"));
								list1.appendChild(bold);
								list1.appendChild(document.createElement("br"));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "ptype")));
								list1.appendChild(document.createElement("br"));

								list1.appendChild(document.createElement("br"));
								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("Database"));
								list1.appendChild(bold);
								list1.appendChild(document.createElement("br"));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "database")));
								list1.appendChild(document.createElement("br"));
								
								list1.appendChild(document.createElement("br"));
								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("Sequencing Machine"));
								list1.appendChild(bold);
								list1.appendChild(document.createElement("br"));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "seqName")));
								list1.appendChild(document.createElement("br"));

								list1.appendChild(document.createElement("br"));
								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("Sequencing Plateform"));
								list1.appendChild(bold);
								list1.appendChild(document.createElement("br"));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "plateform")));
								list1.appendChild(document.createElement("br"));

								list1.appendChild(document.createElement("br"));
								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("Creation Date"));
								list1.appendChild(bold);
								list1.appendChild(document.createElement("br"));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "cdate")));
								list1.appendChild(document.createElement("br"));

								list2.appendChild(document.createElement("br"));
								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("Patients "));
								list2.appendChild(bold);
								list2.appendChild(document.createTextNode("("));
								list2.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "nbpatients")));
								list2.appendChild(document.createTextNode(")"));						
								list2.appendChild(document.createElement("br"));
								list2.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "patients")));
								list2.appendChild(document.createElement("br"));
								divProj._relativePosition={t:0,l:0};
								divProj.show();
								var jsonStoreName = new dojo.data.ItemFileReadStore({ url: url_path + "/progress_projects.pl?" + "&ProjSel="+ Projvalue});
								gridProjectName0.setStore(jsonStoreName);
								gridProjectName0b.setStore(jsonStoreName);
								gridProjectName1.setStore(jsonStoreName);
								gridProjectName2.setStore(jsonStoreName)
								gridProjectName3.setStore(jsonStoreName)
								gridProjectName4.setStore(jsonStoreName)
								gridProjectName5.setStore(jsonStoreName)
								gridProjectName6.setStore(jsonStoreName)
								gridProjectName7.setStore(jsonStoreName)
								gridProjectName8.setStore(jsonStoreName)
								var teamStore = new dojo.data.ItemFileReadStore({
						              url: url_path + "/createPolyproject.pl?option=polyT"+"&ProjSel="+ Projvalue
								});
								grid2.setStore(teamStore);
								dijit.byId(grid2)._refresh();
							}
						});
					} 			
				});
				//return itemProj;
			} else {
				textError.setContent("Please select a project !");
				myError.show();
				return;
			}

		} // End of gotProject
		
		//Callback for if the lookup fails.
		function fetchFailed(error, request) {
			alert("lookup failed.");
			alert(error);
		}

		//Fetch the data.
		jsonStore.fetch({
			onBegin: clearOldCList,
			onComplete: gotProject,
			onError: fetchFailed,
			queryOptions: {
				deep: true
			}
		});
	}
	dojo.connect(buttonProgress, "onClick", getItems);
	dojo.connect(gridProject, "onRowDblClick", getItems);
}
dojo.addOnLoad(init);


//########################################################################
//################# button
function goBack(){
	parent.bas.location.href ="Polyproject.html";
}

function refreshProgressList() {
	var jsonStore = new dojo.data.ItemFileReadStore({ url: url_progress });
	gridProject.setStore(jsonStore);
	dijit.byId(gridProject)._refresh();
}; // End of refreshProgressList

//########################################################################
