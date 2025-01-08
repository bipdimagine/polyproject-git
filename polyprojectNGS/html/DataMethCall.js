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

dojo.addOnLoad(function() {
	var methCallStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=methodCall"
	});
	gridCall.setStore(methCallStore);
	gridCall._refresh();
});

dojo.addOnLoad(function() {
	formMethDBDlg = dijit.byId("divMethodDB");
	dojo.connect(dijit.byId("buttonAddMethodDB"), "onClick", formMethDBDlg, "show");
});

//################# Return Main window
function goMain(){
//	this.location.href ="polyprojectNGS.html";
	this.location.href ="index.html";
}

function newCallMethod() {
	var methFormvalue = dijit.byId("methForm").getValues();
	//test no blank
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var check = methFormvalue.method;
	if ((check.search(regexp) == -1)){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
    }

	if (methFormvalue.method.length ==0){		
			textError.setContent("Enter a method name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=Newcalling"+"&method="+methFormvalue.method;
	sendData(url_insert);
	refreshCallMethodList();
};

function refreshCallMethodList() {
	var methCallStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=methodCall"
	});
	gridCall.setStore(methCallStore);
	gridCall.store.close();
	gridCall._refresh();
};

