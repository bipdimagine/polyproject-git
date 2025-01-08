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


dojo.require("dojo.cookie");
dojo.require("dijit.form.Button");
dojo.require("dijit.form.TextBox");
dojo.require("dojo.data.ItemFileWriteStore");
dojo.require("dojo.data.api.Write");
dojo.require("dojox.grid.enhanced.plugins.Pagination");
dojo.require("dojox.grid.EnhancedGrid");
dojo.require("dojox.grid.enhanced.plugins.DnD");
dojo.require("dojox.grid.enhanced.plugins.Menu");
dojo.require("dojox.grid.enhanced.plugins.NestedSorting");
dojo.require("dojox.grid.enhanced.plugins.IndirectSelection");
dojo.require("dojox.widget.Standby");


//################# Return Main window
function goMain(){
	this.location.href ="index.html";
}

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
		field: "macName",
		name: "Sequencing Machine",
		width: '12',
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
		formatter:icon_progressTip,
		width: '31',
		styles: 'text-align:center;'
	}

];

var yearData ={
	identifier: "year",
	items: [
		{year: "2013"},
		{year: "2012"},
		{year: "2011"},
		{year: "2010"},
		{year: "2009"},
	]
}

var standby;


function init(){
//################# Standby for loading ######################################

	standby = new dojox.widget.Standby({
	       	target: "winStandby"
	});
	document.body.appendChild(standby.domNode);
	standby.startup();
//############################################################################
	var yearStore = new dojo.data.ItemFileReadStore({
                data: yearData
	});


	var yearFilterSelect = new dijit.form.FilteringSelect({
		id: "yearSelect",
		name: "year",
		value: "",
		store: yearStore,
		searchAttr: "year"
	},dojo.byId("yearSelect"));

	var showTooltip = function(e) {
		var msg;
		if (e.rowIndex < 0) { // header grid
			msg = e.cell.name;
            	};
		if (msg) {
			var classmsg = "<i class='tooltip'>";
			if(msg=="Progression") {
				//dijit.showTooltip("commmp", e.cellNode);
				dijit.showTooltip(classmsg + 
				"<img src='/icons/Polyicons/green_rectangle.png'>" +
				" Valid step " +
				"<img src='/icons/Polyicons/red_rectangle.png'>" + 
				" Failed step" + "<br>" +
				"1:Raw Sequence" + "<br>" +
				"2:Alignment method" + "<br>" +
				"3:Calling variation"+ "<br>" +
				"4:Calling indel"+ "<br>" +
				"5:Insert variation"+ "<br>" +
				"6:Insert insertion"+ "<br>" +
				"7:Insert deletion"+ "<br>" +
				"8:Cache gene"+ "<br>" +
				"9:Cache variation"+ "<br>" +
				"</i>", e.cellNode,['above']);		
			} 
		}

	}; 
	var hideTooltip = function(e) {
		dijit.hideTooltip(e.cellNode);
        }; 
	dojo.connect(gridProject, "onMouseOver", showTooltip);
	dojo.connect(gridProject, "onMouseOut", hideTooltip); 
}
dojo.addOnLoad(init);


function yearSel() {
	var yearFormvalue = dijit.byId("yearForm").getValues();
	if (yearFormvalue.year.length ==0){		
			textError.setContent("Select a year");
			myError.show();
			return;
	}

	var url_progress = url_path+"/progress_projects.pl?yearSel=" + yearFormvalue.year;
	standbyShow();
	var jsonStore = new dojo.data.ItemFileWriteStore({ url: url_progress });
	gridProject.setStore(jsonStore);
	gridProject.store.fetch({onComplete:standbyHide});

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

		function gotProject(items, request) {
			var itemProj = gridProject.selection.getSelected();
			if (itemProj.length) {
				dojo.forEach(itemProj, function(selectedItem) {
					if (selectedItem !== null) {

						dojo.forEach(gridProject.store.getAttributes(selectedItem), function(attribute) {
							var Projvalue = gridProject.store.getValues(selectedItem, attribute);
							var list0 = dojo.byId("list0");
							var list1 = dojo.byId("list1");
							var list2 = dojo.byId("list2");
							if (attribute == "name" ) {
								var bold = document.createElement("b");
								bold.appendChild(document.createTextNode(" Name :  "));
								bold.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "name")));
								list0.appendChild(bold);
								list0.appendChild(document.createElement("br"));
								divProj._relativePosition={t:0,l:0};
								divProj.show();

								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("ID"));
								list1.appendChild(bold);
								list1.appendChild(document.createElement("br"));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "id")));
								list1.appendChild(document.createElement("br"));


								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("Run "));
								list1.appendChild(bold);
								list1.appendChild(document.createTextNode("("));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "nbRun")));
								list1.appendChild(document.createTextNode(")"));						

								list1.appendChild(document.createElement("br"));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "Run")));
								list1.appendChild(document.createElement("br"));



								list1.appendChild(document.createElement("br"));
								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("Description"));
								list1.appendChild(bold);
								list1.appendChild(document.createElement("br"));
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "description")));
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
								list1.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "macName")));
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



								//list2.appendChild(document.createElement("br"));
								bold = document.createElement("b");
								bold.appendChild(document.createTextNode("Patients "));
								list2.appendChild(bold);
								list2.appendChild(document.createTextNode("("));
								list2.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "nbPat")));
								list2.appendChild(document.createTextNode(")"));						
								list2.appendChild(document.createElement("br"));
								list2.appendChild(document.createTextNode(gridProject.store.getValue(selectedItem, "patients")));
								list2.appendChild(document.createElement("br"));

								standbyShow();
								var jsonStoreName = new dojo.data.ItemFileReadStore({ url: url_path + "/progress_projects.pl?" + "&ProjSel="+ Projvalue});
								gridProjectName0.setStore(jsonStoreName);
								gridProjectName0.store.fetch({onComplete:standbyHide});
								gridProjectName0b.setStore(jsonStoreName);
								gridProjectName1.setStore(jsonStoreName);
								gridProjectName2.setStore(jsonStoreName);
								gridProjectName3.setStore(jsonStoreName);
								gridProjectName4.setStore(jsonStoreName);
								gridProjectName5.setStore(jsonStoreName);
								gridProjectName6.setStore(jsonStoreName);
								gridProjectName7.setStore(jsonStoreName);
								gridProjectName8.setStore(jsonStoreName);

								ProjId=gridProject.store.getValue(selectedItem, "id");
								var teamStore = new dojo.data.ItemFileReadStore({
								url: url_path + "/manageData.pl?option=userProject"+"&ProjSel="+ ProjId
								});
								grid2.setStore(teamStore);
								dijit.byId(grid2)._refresh();

							}
						});
					} 
//					standbyHide();			
				});
			} else {
				textError.setContent("Please select a project !");
				myError.show();
				return;
			}

		} // End of gotProject

		function fetchFailed(error, request) {
			alert("lookup failed.");
			alert(error);
		}

		//Fetch the data.
		jsonStore.fetch({
			onBegin: clearOldCList,
//			onComplete: {gotProject,standbyHide },
			onComplete: gotProject,
			onError: fetchFailed,
			queryOptions: {
				deep: true
			}
		});
	}
	dojo.connect(buttonEditProgress, "onClick", getItems);
	dojo.connect(gridProject, "onRowDblClick", getItems);
//	gridProject.store.fetch({onComplete:standbyHide});
}


function standbyShow() {
	myStandby.show(); 
 	standby.show(); 
}

function standbyHide() {
	standby.hide();
	myStandby.hide();
};




