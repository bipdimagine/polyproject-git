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
	//################# Init Capture
	var captureStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=capture"
	});
	// set the layout structure:
	gridCap.setStore(captureStore);
	dijit.byId(gridCap)._refresh();
});

dojo.addOnLoad(function() {
	formCapDBDlg = dijit.byId("divCaptureDB");
	dojo.connect(dijit.byId("buttonAddCaptureDB"), "onClick", formCapDBDlg, "show");
});

//################# Return Main window
function goMain(){
//	this.location.href ="polyprojectNGS.html";
	this.location.href ="index.html";
}

function newCapture() {
	var capFormvalue = dijit.byId("capForm").getValues();
	//test no blank
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var regexp2 = /^[a-zA-Z0-9-._]+$/;
	var check_name = capFormvalue.capture;
	var check_capVs = capFormvalue.capVs;
	var check_capFile = capFormvalue.capFile;
	var check_capType = capFormvalue.capType;
	
	if ((check_name.search(regexp) == -1) || (check_capVs.search(regexp) == -1) ||
		(check_capFile.search(regexp2) == -1) || (check_capType.search(regexp) == -1)	){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
    }

	if (capFormvalue.capture.length ==0){		
			textError.setContent("Enter a capture name");
			myError.show();
			return;
	}
	if (capFormvalue.capVs.length ==0){		
		textError.setContent("Enter a capture version");
		myError.show();
		return;
	}
	if (capFormvalue.capDes.length ==0){		
		textError.setContent("Enter a capture description");
		myError.show();
		return;
	}
	if (capFormvalue.capFile.length ==0){		
		textError.setContent("Enter a capture file name");
		myError.show();
		return;
	}
	if (capFormvalue.capType.length ==0){		
		textError.setContent("Enter a capture type name");
		myError.show();
		return;
	}
	
	var url_insert = url_path + "/manageData.pl?option=Newcapture"+"&capture="+capFormvalue.capture+
	"&capVs="+capFormvalue.capVs+"&capVs="+capFormvalue.capVs+"&capDes="+capFormvalue.capDes+
	"&capFile="+capFormvalue.capFile+"&capType="+capFormvalue.capType;
	sendData(url_insert);
	refreshCaptureList();
};

function refreshCaptureList() {
	var captureStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=capture"
	});
	gridCap.setStore(captureStore);
	gridCap.store.close();
	dijit.byId(gridCap)._refresh();
};








