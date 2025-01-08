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

//var projectName = param("type");
//console.log(projectName);

dojo.addOnLoad(function() {
	//################# Init MethSeq
	var methSeqStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=methodSeq"
	});
	gridMethSeq.setStore(methSeqStore);
	gridMethSeq._refresh();

});

dojo.addOnLoad(function() {
	formMethSeqDBDlg = dijit.byId("divMethodSeqDB");
	dojo.connect(dijit.byId("buttonAddMethodSeqDB"), "onClick", formMethSeqDBDlg, "show");
});

//################# Return Main window
function goMain(){
//	this.location.href ="polyprojectNGS.html";
	this.location.href ="index.html";
}

function newSeqMethod() {
	var methSeqFormvalue = dijit.byId("methSeqForm").getValues();
	//test no blank
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var check = methSeqFormvalue.methseq;
	if ((check.search(regexp) == -1)){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
    }

	if (methSeqFormvalue.methseq.length ==0){		
			textError.setContent("Enter a sequencing method name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=NewMethSeq"+"&methseq="+methSeqFormvalue.methseq;
	sendData(url_insert);
	refreshSeqMethodList();

};

function refreshSeqMethodList() {
	var methSeqStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=methodSeq"
	});
	gridMethSeq.setStore(methSeqStore);
	gridMethSeq.store.close();
//	dijit.byId(gridMethSeq)._refresh();
	gridMethSeq._refresh();
};



