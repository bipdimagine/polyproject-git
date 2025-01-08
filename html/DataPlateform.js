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

dojo.addOnLoad(function() {
	//################# Init Plateform
	var plateformStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=plateform"
	});
	// set the layout structure:
	gridPlt.setStore(plateformStore);
	dijit.byId(gridPlt)._refresh();
});

dojo.addOnLoad(function() {
	//DB Plateform
	formPltDBDlg = dijit.byId("divPlateformDB");
	dojo.connect(dijit.byId("buttonAddPlateformDB"), "onClick", formPltDBDlg, "show");
});

//################# Return Main window
function goMain(){
//	this.location.href ="polyprojectNGS.html";
	this.location.href ="index.html";
}

function newPlateform() {
	var pltFormvalue = dijit.byId("pltForm").getValues();
	//test no blank
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var check = pltFormvalue.plateform;
	if (check.search(regexp) == -1){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
	}

	if (pltFormvalue.plateform.length ==0){		
			textError.setContent("Enter a plateform name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=Newplateform"+"&plateform="+pltFormvalue.plateform;
//	sendData(url_insert);
//	refreshPlateformList();
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divPlateformDB').reset();
				dijit.byId('divPlateformDB').hide();
				refreshPlateformList();
			}
		}
	);




};

function refreshPlateformList() {
	var plateformStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=plateform"
	});
	gridPlt.setStore(plateformStore);
	gridPlt.store.close();
	gridPlt._refresh();
};








