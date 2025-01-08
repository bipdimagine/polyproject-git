/**
 * @author plaza
 * viewDiseasePro.js
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

dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dojo.data.ItemFileWriteStore");

/*
function init1() {
	var projectName = param("project");
	console.log(projectName);
//	var projectName = parent.haut.document.getElementById('project_name').value;
//	document.getElementById("titre").textContent = "Project Name : "+projectName;
}
dojo.addOnLoad(init1);
*/
var projectName = param("project");
//document.getElementById("titre").textContent = "Project Name : "+projectName;
//var projectName = document.getElementById('project_name').value;
console.log(projectName);
	var url_path = "/cgi-bin/plaza/polyprojectNGS";
	var projDiseaseStore = new dojo.data.ItemFileReadStore({
	        url: url_path + "/manageData.pl?option=projDisease"+"&ProjSel="+ projectName
	});
	gridP.setStore(projDiseaseStore);
	dijit.byId(gridP)._refresh();
	


//document.location.href ="viewDiseaseProj.html";
//var Url=location.href;
//console.log(Url);
//var Url1 = Url.replace(/([^\?])\?.*/,"$1");
//console.log(Url1);
//this.location.href =Url1;
/*
Variables = Url.split ("&");
for (i = 0; i < Variables.length; i++) {
Separ = Variables[i].split("=");
eval ('var '+Separ[0]+'="'+Separ[1]+'"');
}
*/
//var projectName = parent.haut.document.getElementById('project_name').value;
//document.getElementById("titre").textContent = projectName;
//var projectName = param("project" 
