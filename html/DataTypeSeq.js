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
	formTypeSeqDBDlg = dijit.byId("divTypeSeqDB");
	dojo.connect(dijit.byId("buttonAddTypeSeqDB"), "onClick", formTypeSeqDBDlg, "show");
});

//################# Return Main window
function goMain(){
//	this.location.href ="polyprojectNGS.html";
	this.location.href ="index.html";
}

function newSeqType() {
	var typeSeqFormvalue = dijit.byId("typeSeqForm").getValues();
	//test no blank
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var check = typeSeqFormvalue.type;
	if ((check.search(regexp) == -1)){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
	}

	if (typeSeqFormvalue.type.length ==0){		
			textError.setContent("Enter a sequencing type name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=NewTypeSeq"+"&type="+typeSeqFormvalue.type;
	sendData(url_insert);
	refreshSeqTypeList();

};

function refreshSeqTypeList() {
	var typeSeqStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=runtype"
	});
	gridTypeSeq.setStore(typeSeqStore);
	gridTypeSeq.store.close();
	dijit.byId(gridTypeSeq)._refresh();
};

