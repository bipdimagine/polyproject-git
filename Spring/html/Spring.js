/**
 * @author plaza
 */


dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.layout.BorderContainer");

dojo.require("dijit.form.Button");
dojo.require("dijit.DropDownMenu");
dojo.require("dijit.PopupMenuItem");
dojo.require("dijit.MenuItem");
dojo.require("dijit.Menu");
dojo.require("dijit.form.FilteringSelect");

dojo.require("dijit.Dialog");
dojo.require("dijit.form.ValidationTextBox");
dojo.require("dojo.parser");
dojo.require("dojo.date.locale");
dojo.require("dijit.form.ComboBox");
dojo.require("dijit.form.CheckBox");
dojo.require("dijit.form.ToggleButton");
dojo.require("dijit.form.Form");
dojo.require("dijit.TitlePane");
dojo.require("dijit.form.TextBox");
dojo.require("dijit.form.Textarea");
dojo.require("dijit.Toolbar");
dojo.require("dojox.widget.Standby");
dojo.require("dijit.Tooltip");
dojo.require("dojo.cookie");


dojo.require("dojox.grid.DataGrid");
dojo.require("dojox.data.AndOrWriteStore");
dojo.require("dojox.grid.EnhancedGrid");
dojo.require("dojox.grid.enhanced.plugins.DnD");
dojo.require("dojox.grid.enhanced.plugins.Menu");
dojo.require("dojox.grid.enhanced.plugins.NestedSorting");
dojo.require("dojox.grid.enhanced.plugins.IndirectSelection");
dojo.require("dojox.grid.enhanced.plugins.Pagination");
dojo.require("dojox.grid.enhanced.plugins.Filter");
dojo.require("dojox.grid.enhanced.plugins.Selector");

var btlog;
var logged=1;
var initl=1;
var logname="";
var force_log;

var force;
var standby;
var projStore;
var projGrid;
var delprojGrid;
var v1;

dojo.addOnLoad(function() {
	relog(logname,dojo.byId("btlog_0"));
	relog(logname,dojo.byId("btlog_1"));
	relog(logname,dojo.byId("btlog_2"));
	checkPassword(okfunction);
});

function relog(logname,spid){
	var myHtml=spid.outerHTML;
	var exp=/(?:^|\s)id=\"(\w+)/;
	var pattern=myHtml.match(exp);
	var indice=pattern[1].split("_")[1];
	var btlog=dijit.byId("id_btlog"+"_"+indice);
	if (btlog) {
		spid.removeChild(btlog.domNode);
		btlog.destroyRecursive();
	}
	var btlog = new dijit.form.Button({
		showLabel: true,
		id:"id_btlog"+"_"+indice,
		iconClass:"loginIcon",
		onClick:function(){
			launch_connect();
		}			
 	},"id_btlog"+"_"+indice);
	dijit.byId("id_btlog"+"_"+indice).set("label", logname);
	spid.appendChild(btlog.domNode);
	return indice;
}

function launch_connect(items, request){
	dijit.byId('login').show();	
	force_log=1;	
}

function okfunction(items,request){
	// number of btlog_
	var nb_btlog=2;
	if (items[0].name.toString() == "BAD_LOGIN") {
		logged=0;
		// number of btlog_
		for(var i=0; i<nb_btlog+1; i++) {
			var a = dijit.byId("id_btlog"+"_"+i);
			if (a) {
				dijit.byId("id_btlog"+"_"+i).set("label", "Not Logged");
				dijit.byId("id_btlog"+"_"+i).set("iconClass","logoutIcon");
			}
		}
		hide_logout();
		return;
	}
	logged=1;
	logname=username;
	if (initl) {
		init();
		logged=1;
		logname=username;
	}
	for(var i=0; i<nb_btlog+1; i++) {
		var a = dijit.byId("id_btlog"+"_"+i);
		if (a) {
			dijit.byId("id_btlog"+"_"+i).set("label", logname);
			dijit.byId("id_btlog"+"_"+i).set("iconClass","loginIcon");
		}
	}
	initl=0;
	show_login();
}

function show_login() {
	dijit.byId("folderName").set("disabled",false);
	dijit.byId("btn_force").set("disabled",false);
	dijit.byId("bt_viewSpring").set("disabled",false);
	dijit.byId("bt_delProject").set("disabled",false);
	dijit.byId("bt_firstFile").set("disabled",false);
	dijit.byId("bt_secondFile").set("disabled",false);
	dijit.byId("bt_cellsFile").set("disabled",false);
	dijit.byId("bt_genesetsFile").set("disabled",false);
	dijit.byId("bt_customColorFile").set("disabled",false);
	dijit.byId("bt_upload").set("disabled",false);
	dijit.byId("bt_FolderSubmit").set("disabled",false);
	document.getElementById("TabProj").style.display = "block";
	document.getElementById("TabProjdel").style.display = "block";
}

function hide_logout() {
	dijit.byId("folderName").set("disabled",true);
	dijit.byId("btn_force").set("disabled",true);
	dijit.byId("bt_viewSpring").set("disabled",true);
	dijit.byId("bt_delProject").set("disabled",true);
	dijit.byId("bt_firstFile").set("disabled",true);
	dijit.byId("bt_secondFile").set("disabled",true);
	dijit.byId("bt_cellsFile").set("disabled",true);
	dijit.byId("bt_genesetsFile").set("disabled",true);
	dijit.byId("bt_customColorFile").set("disabled",true);
	dijit.byId("bt_upload").set("disabled",true);
	dijit.byId("bt_FolderSubmit").set("disabled",true);
	document.getElementById("TabProj").style.display = "none";
	document.getElementById("TabProjdel").style.display = "none";
}

function setPasswordlocal(){
	var passwd = document.getElementById('passwd').value;
	var username = document.getElementById('username').value;
	dojo.cookie("username", username, { expires: 1 });
	dojo.cookie("passwd", passwd, { expires: 1 });
	dijit.byId('login').hide();
	dijit.byId("loginForm").reset();				
	checkPassword(okfunction);
 }

var user;
function init(){
//################# Standby for loading : use sendData #############################
	standby = new dojox.widget.Standby({
	       	target: "winStandby"
	});
	document.body.appendChild(standby.domNode);
	standby.startup();
//####### user project ########################
	force_log=0;
	var user= dojo.cookie("username");
// CHANGEMENT DE SITE sur version en ligne: http://10.200.27.108:8001/Spring
// A faire ci-dessous et user= dojo.cookie("username","") 
//	if ((href.indexOf("102", 1) > -1) && (username == "plaza") ) {
	if ((href.indexOf("102", 1) > -1) && (username != "plaza") ) {
		textError.setContent("<b>Spring Utility</b> has moved.<br><b>Please Connect to:</b> http://10.200.27.108:8001/Spring");
		myError.show();
		logname="";
		username="";
		user= dojo.cookie("username","");
		checkPassword(okfunction);
		if(! logged) {
			return
		}
	} 
 	dijit.byId("btn_force").set('checked', false);
	force=0;
	var domBtFirst=dojo.byId("domBt_firstFile");
	var w_firstFile =dijit.byId("bt_firstFile");
	if (w_firstFile) {
		domBtFirst.removeChild(w_firstFile.domNode);
		w_firstFile.destroyRecursive();
	}
	var domBtSecond=dojo.byId("domBt_secondFile");
	var w_secondFile =dijit.byId("bt_secondFile");
	if (w_secondFile) {
		domBtSecond.removeChild(w_secondFile.domNode);
		w_secondFile.destroyRecursive();
	}

	var domBtCells=dojo.byId("domBt_cellsFile");
	var w_cellsFile =dijit.byId("bt_cellsFile");
	if (w_cellsFile) {
		domBtCells.removeChild(w_cellsFile.domNode);
		w_cellsFile.destroyRecursive();
	}

	var domBtGenesets=dojo.byId("domBt_genesetsFile");
	var w_genesetsFile =dijit.byId("bt_genesetsFile");
	if (w_genesetsFile) {
		domBtGenesets.removeChild(w_genesetsFile.domNode);
		w_genesetsFile.destroyRecursive();
	}

	var domBtcustomColor=dojo.byId("domBt_customColorFile");
	var w_customColorFile =dijit.byId("bt_customColorFile");
	if (w_customColorFile) {
		domBtcustomColor.removeChild(w_customColorFile.domNode);
		w_customColorFile.destroyRecursive();
	}

	w_firstFile = new dijit.form.Button({
		id:"bt_firstFile",
		label:"<span><img align='top' src='icons/document_small_upload.png'></span>",
		onClick:function() {
			uploadFile(which="firstFile",force,user);
		}
	},"bt_firstFile");
	domBtFirst.appendChild(w_firstFile.domNode);
	w_secondFile = new dijit.form.Button({
		id:"bt_secondFile",
		label:"<span><img align='top' src='icons/document_small_upload.png'></span>",
		onClick:function() {
			uploadFile(which="secondFile",force,user);
		}
	},"bt_secondFile");
	domBtSecond.appendChild(w_secondFile.domNode);

	w_cellsFile = new dijit.form.Button({
		id:"bt_cellsFile",
		label:"<span><img align='top' src='icons/document_small_upload.png'></span>",
		onClick:function() {
			uploadFile(which="cellsFile",force,user);
		}
	},"bt_cellsFile");
	domBtCells.appendChild(w_cellsFile.domNode);

	w_genesetsFile = new dijit.form.Button({
		id:"bt_genesetsFile",
		label:"<span><img align='top' src='icons/document_small_upload.png'></span>",
		onClick:function() {
			uploadFile(which="genesetsFile",force,user);
		}
	},"bt_genesetsFile");
	domBtGenesets.appendChild(w_genesetsFile.domNode);

	w_customColorFile = new dijit.form.Button({
		id:"bt_customColorFile",
		label:"<span><img align='top' src='icons/document_small_upload.png'></span>",
		onClick:function() {
			uploadFile(which="customColorFile",force,user);
		}
	},"bt_customColorFile");
	domBtcustomColor.appendChild(w_customColorFile.domNode);

	document.getElementById("InputFile").value = "";
//#####################################################################
// Attention upload_file2.pl dans includeSpringdev.js mais ne pas mettre en ligne
	projStore = new dojox.data.AndOrWriteStore({
			url: url_path + "/upload_file.pl?opt=listProject" + "&param_user=" + user

	});

	function clearOldProjList(size, request) {
                    var listProj = dojo.byId("projGridDiv");
                    if (listProj) {
                        while (listProj.firstChild) {
                           listProj.removeChild(listProj.firstChild);
                        }
                    }
	}
	function fetchFailedProj(error, request) {
		alert("lookup failed in fetchFailedProj.");
		alert(error);
	}
	projStore.fetch({
		onBegin: clearOldProjList,
		onError: fetchFailedProj,
		onComplete: function(items){
				projGrid = new dojox.grid.EnhancedGrid({
 					store: projStore,
 					structure: layoutProj,
					selectionMode:"single",
					rowSelector: "0.4em",
					canSort:function(colIndex, field){
						return field != 'out'  && field != 'cDate';
					},
					onClick:function(){
						viewSpring(projGrid,user,action="view");
					},
					plugins: {
 						nestedSorting: true,
						//dnd: true,
						indirectSelection: {
							name: "Sel",
							width: "30px",
							styles: "text-align: center;",
					},
					filter: {
						closeFilterbarButton: true,
						ruleCount: 5,
						itemsName: "name"
					},
				}
			}, document.createElement('div'));
			dojo.byId("projGridDiv").appendChild(projGrid.domNode);
			dojo.connect(projGrid, "onMouseOver", showTooltipField);
			dojo.connect(projGrid, "onMouseOut", hideTooltipField); 
			projGrid.startup();
			dojo.connect(dijit.byId("bt_viewSpring"), "onClick", function(e) {
				checkPassword(okfunction);
				if(! logged) {
					return;
				}
				var sp_btcloseproj=dojo.byId("bt_close_proj");
				var btcloseproj=dijit.byId("id_bt_closeproj");
				if (btcloseproj) {
					sp_btcloseproj.removeChild(btcloseproj.domNode);
					btcloseproj.destroyRecursive();
				}
				var buttonformclose_proj= new dijit.form.Button({
					id:"id_bt_closeproj",
					showLabel: false,
					type:"submit",
					iconClass:"closeIcon",
					style:"color:white",
					onclick:"projGrid.selection.clear();dijit.byId('projDialog').hide();"
				});
				buttonformclose_proj.startup();
				buttonformclose_proj.placeAt(sp_btcloseproj);
				var projDialogForm = dijit.byId("projDialog");
				checkGrid_user(projGrid.store,projDialogForm);
			});
		}
	});
/*       ###################################################################################### */
	function clearOldProjListDel(size, request) {
                    var listProjdel = dojo.byId("delprojGridDiv");
                    if (listProjdel) {
                        while (listProjdel.firstChild) {
                           listProjdel.removeChild(listProjdel.firstChild);
                        }
                    }
	}
	function fetchFailedProjDel(error, request) {
		alert("lookup failed in fetchFailedProj DEL.");
		alert(error);
	}

	projStore.fetch({
		onBegin: clearOldProjListDel,
		onError: fetchFailedProjDel,
		onComplete: function(items){
				delprojGrid = new dojox.grid.EnhancedGrid({
 					store: projStore,
 					structure: layoutProj,
					selectionMode:"single",
					rowSelector: "0.4em",
					canSort:function(colIndex, field){
						return field != 'out'  && field != 'cDate';
					},
					onClick:function(){
						viewSpring(delprojGrid,user,action="delete");
					},
					plugins: {
 						nestedSorting: true,
						//dnd: true,
						indirectSelection: {
							name: "Sel",
							width: "30px",
							styles: "text-align: center;",
					},
					filter: {
						closeFilterbarButton: true,
						ruleCount: 5,
						itemsName: "name"
					},
				}
			}, document.createElement('div'));
			dojo.byId("delprojGridDiv").appendChild(delprojGrid.domNode);
			delprojGrid.startup();
			dojo.connect(dijit.byId("bt_delProject"), "onClick", function(e) {
				checkPassword(okfunction);
				if(! logged) {
					return;
				}
				var sp_btcloseprojdel=dojo.byId("bt_close_projdel");
				var btcloseprojdel=dijit.byId("id_bt_closeprojdel");
				if (btcloseprojdel) {
					sp_btcloseprojdel.removeChild(btcloseprojdel.domNode);
					btcloseprojdel.destroyRecursive();
				}
				var buttonformclose_projdel= new dijit.form.Button({
					id:"id_bt_closeprojdel",
					showLabel: false,
					type:"submit",
					iconClass:"closeIcon",
					style:"color:white",
					onclick:"delprojGrid.selection.clear();dijit.byId('projDialogdel').hide"
				});
				buttonformclose_projdel.startup();
				buttonformclose_projdel.placeAt(sp_btcloseprojdel);
				var delprojDialogForm = dijit.byId("projDialogdel");
				checkGrid_user(delprojGrid.store,delprojDialogForm);
			});
		}
	});
}
dojo.addOnLoad(init);

function checkGrid_user(gridstore,dialog) {
	gridstore.fetch({onComplete:function(fitems){
			if (! fitems.filter(Boolean).length) {
				textError.setContent("Error User account. Please Reload or re-Connect...");
				myError.show();
				return;
			} else {
				dialog.show();
			}
		}
	});
}

function uploadFile(which,force,user) {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var wFile= document.getElementById(which).value;
	dojo.byId('opt').value ="insert";
	dojo.byId('param_user').value =user;
	dojo.byId('param_file').value =which;
	dojo.byId('param_force').value =force;
	var folderFormvalue = dijit.byId("folderForm").attr("value");
	if (! folderFormvalue.folderName) {
		textError.setContent("Enter a Project Name Folder please...");
		myError.show();
		return;
	}
	dojo.byId('param_dir').value =folderFormvalue.folderName;
	div_uploadFile.show();
}

function chgForce(a){
	if(this.checked) {
		force=1;
	} else {
		force=0;
	}
}

function resetField() {
	dijit.byId("folderForm").reset();				
	document.getElementById("InputFile").value = "";
	dijit.byId("springForm").reset();				
 	dijit.byId("btn_matrix").set('checked', false);
	dijit.byId("btn_gene").set('checked', false);
 	dijit.byId("btn_force").set('checked', false);	
}

function checkButton(type_file) {
	if (type_file == "firstFile") {dijit.byId("btn_matrix").set('checked', true);}
	if (type_file == "secondFile") {dijit.byId("btn_gene").set('checked', true);}
	if (type_file == "cellsFile") {dijit.byId("btn_cells").set('checked', true);}
	if (type_file == "genesetsFile") {dijit.byId("btn_genesets").set('checked', true);}
	if (type_file == "customColorFile") {dijit.byId("btn_customColor").set('checked', true);}

}

function submitFiles() {
	var user= dojo.cookie("username");	
	checkStart(user);
}

function checkStart(user) {
	var folderFormvalue = dijit.byId("folderForm").attr("value");
	var i_firstFile=dojo.byId('firstFile').value;
	var i_secondFile=dojo.byId('secondFile').value;
	var colgene=folderFormvalue.ColGene
	if (colgene<1 || colgene>15) {
		textError.setContent("Error: Wrong Gene Column number");
		myError.show();
		return;
	} else {
		colgene= colgene - 1;
	}

	var i_cellsFile=dojo.byId('cellsFile').value;
	var i_genesetsFile=dojo.byId('genesetsFile').value;
	var i_customColorFile=dojo.byId('customColorFile').value;

	var v1=dijit.byId('btn_matrix');
	var v2=dijit.byId('btn_gene');
	var v3=dijit.byId('btn_cells');
	var v4=dijit.byId('btn_genesets');
	var v5=dijit.byId('btn_customColor');

	if (v1.checked==true && v2.checked==true) {
		dojo.byId('outName').value =folderFormvalue.folderName;
		var url_insert = url_loadfile +"?opt=findFile" +
						"&param_user=" + user +
						"&param_dir=" + folderFormvalue.folderName +
						"&param_matrix=" + i_firstFile +
						"&param_genes=" + i_secondFile;
		if (v3.checked==true) {
			url_insert = url_insert + "&param_cells=" + i_cellsFile;
		}
		if (v4.checked==true) {
			url_insert = url_insert + "&param_genesets=" + i_genesetsFile;
		}
		if (v5.checked==true) {
			url_insert = url_insert + "&param_customcolor=" + i_customColorFile;
		}
		var res_both=sendData_nomessage(url_insert);
		res_both.addCallback(
		function(response) {
				if(response.status=="OK"){
					//OK:/poly-disk/poly-data/spring/inFILES/plaza:/poly-disk/poly-data/spring/outFILES/
					//OK:spring/inFILES/plaza:spring/outFILES/
					initResultSpring(response.message.split(":")[1],response.message.split(":")[2]);
				} 
			}
		);

	} else {
		textError.setContent("<b>Submit Error:</b> Matrix and Gene Files are required for pre-processing Spring Results ...<br>" +
		"Use Upload Button <img align='top' src='icons/document_small_upload.png'> for loading requiered input Files. <br>" +
		"<img align='top' src='icons/warning.png'> Loading a Matrix file can take several minutes.");
		myError.show();
		return;
	}
}

var lpython;
function initResultSpring(dirIn,dirOut) {
	var folderFormvalue = dijit.byId("folderForm").attr("value");
	var colgene=folderFormvalue.ColGene
	colgene= colgene - 1;
	var v1=dijit.byId('btn_matrix');
	var v2=dijit.byId('btn_gene');
	var v3=dijit.byId('btn_cells');
	var v4=dijit.byId('btn_genesets');
	var v5=dijit.byId('btn_customColor');
	if (v1.checked==true && v2.checked==true) {
		var o_out = dijit.byId("outName").attr("value");
		var o_matrix = dijit.byId("firstFile").attr("value");
		var o_genes = dijit.byId("secondFile").attr("value");
		var o_cells = dijit.byId("cellsFile").attr("value");
		var o_genesets = dijit.byId("genesetsFile").attr("value");
		var o_customcolor = dijit.byId("customColorFile").attr("value");
		if (href.indexOf("102", 1) > -1) {lpython=1} else {lpython=0};
		var url_runPython = url_path + "/run_pythonScript.pl"+"?lpython="+lpython+"&dirIn=" + dirIn + "&dirOut=" + dirOut + "&name=" + o_out + "&matrix=" + o_matrix + "&genes=" + o_genes + "&colgene=" + colgene;
		if (v3.checked==true) {
			url_runPython = url_runPython + "&cells=" + o_cells;
		}
		if (v4.checked==true) {
			url_runPython = url_runPython + "&genesets=" + o_genesets;
		}
		if (v5.checked==true) {
			url_runPython = url_runPython + "&customcolor=" + o_customcolor;
		}
		var res_Python=sendData(url_runPython,0,0);
		res_Python.addCallback(
			function(response) {
				if(response.status=="OK"){
					dijit.byId("btn_out").set('checked', true);
					refreshprojGrid();
				} 
			}
		);

	};
}

function viewSpring(grid,user,action) {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var selProj;
	var item = grid.selection.getSelected();
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "name" ) {
						selProj = Projvalue.toString();
					}
				});

			}
		}); 
	} else {
		textError.setContent("Select a Project");
		myError.show();
		return;
	}
	if (action=="view") {viewProject(selProj,user)};
	if (action=="delete") {deleteProject(selProj,user)};
}

function viewProject(name,user) {
	checkPassword(okfunction);
	if(! logged) {
		return;
	}
	var url_insert = url_loadfile +"?opt=findSpringFile" + "&param_user=" + user + "&name=" + name;
	// SendData without Standby
	var res_view=sendData(url_insert,1,1);
	res_view.addCallback(
		function(response) {
			if(response.status=="OK"){
				//var Spring_ref="http://10.200.27.108:8000/springViewer_1_6_dev.html?dataspring/" + user+"/"+name+"/"+name;
				//var Spring_ref="http://10.200.27.108:8000/springViewer_1_5_dev.html?dataspring/" + user+"/"+name+"/"+name;
				var Spring_ref;
				if (href.indexOf("102", 1) > -1) {
					Spring_ref="https://springviewer.polyweb.fr/springViewer_1_5_dev.html?dataspring_old/" + user+"/"+name+"/"+name;
				} else {
					Spring_ref="https://springviewer.polyweb.fr/springViewer_1_5_dev.html?dataspring/" + user+"/"+name+"/"+name;
				}
				window.open(Spring_ref,"_blank");
			}
		}
	);
}

function deleteProject(name,user) {
	checkPassword(okfunction);
	if(! logged) {
		return;
	}
	if(! name) {
		textError.setContent("Select a Project");
		myError.show();
		return;
	}

	var url_insert = url_loadfile +"?opt=delProject" + "&param_user=" + user + "&name=" + name;
	// SendData with message OK
	var res=sendData(url_insert,0,0);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				delprojGrid.selection.clear();
				refreshprojGrid();
			}
		}
	);
}

var layoutProj = [
		{ field: 'id', name: 'ID', width:'3em'},
		{ field: "name",name: "Project", width: '20'},
		{ field: "cDate", name: "Date" , datatype:"date", width: '7'},
		{ field: "out",name: "<img align='middle' src='icons/exclamation.png'>",width: '2', formatter:bullet},
		{ field: "cg",name: "Cells Group", width: '6',styles:"text-align:center;",formatter:inactiveRadioButtonView},
		{ field: "gs",name: "Gene Sets", width: '6',styles:"text-align:center;",formatter:inactiveRadioButtonView},
		{ field: "cc",name: "Cust.Color", width: '6',styles:"text-align:center;",formatter:inactiveRadioButtonView},
];

function bullet(value) {
	if(value == "1") {
		return "<img align='top' src='icons/bullet_green.png'>";
	} 
	else { 
		return "<img align='top' src='icons/bullet_red.png'>";
	}
}

function inactiveRadioButtonView(value,idx,cell) {
	var Cbutton;
	if (cell.field == "cg" || cell.field == "gs" || cell.field == "cc") {
		var Cbutton = new dijit.form.CheckBox({
			style:"border:0;margin: 0; padding: 0;text-align:center;",
			checked:false,
			value:0,
			disabled:true,
		});
		if (value==1) {
			cell.customStyles.push("background: grey;");	
			Cbutton.attr('checked', true);
		}		
	}
	return Cbutton;
}

function refreshprojGrid() {
	var user= dojo.cookie("username");	
	projStore = new dojox.data.AndOrWriteStore({
			url: url_path + "/upload_file.pl?opt=listProject"  + "&param_user=" + user
	});
	projGrid.setStore(projStore);
	projGrid._refresh();
	delprojGrid.setStore(projStore);
	delprojGrid._refresh();
}
