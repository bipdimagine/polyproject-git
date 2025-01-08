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

//var projectName = param("type");
//console.log(projectName);
dojo.addOnLoad(function() {
	//################# Init Plateform
	var machineStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=machine"
	});
	gridMac.setStore(machineStore);
	dijit.byId(gridMac)._refresh();
});

dojo.addOnLoad(function() {
	formMacDBDlg = dijit.byId("divMachineDB");
	dojo.connect(dijit.byId("buttonAddMachineDB"), "onClick", formMacDBDlg, "show");
});

//################# Return Main window
function goMain(){
//	this.location.href ="polyprojectNGS.html";
	this.location.href ="index.html";
}

function newMachine() {
	var macFormvalue = dijit.byId("macForm").getValues();
	//test no blank
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var check_machine = macFormvalue.machine;
	var check_mactype = macFormvalue.mactype;
	if ((check_machine.search(regexp) == -1)|| (check_mactype.search(regexp) == -1)){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
	}

	if (macFormvalue.machine.length ==0){		
			textError.setContent("Enter a machine name");
			myError.show();
			return;
	}
	if (macFormvalue.mactype.length ==0){		
		textError.setContent("Enter a machine type name");
		myError.show();
		return;
	}
	var url_insert = url_path + "/manageData.pl?option=Newmachine"+"&machine="+macFormvalue.machine+"&mactype="+macFormvalue.mactype;
	sendData(url_insert);
	refreshMachineList();
};

function refreshMachineList() {
	var machineStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=machine"
	});
	gridMac.setStore(machineStore);
	gridMac.store.close();
	gridMac._refresh();
};








