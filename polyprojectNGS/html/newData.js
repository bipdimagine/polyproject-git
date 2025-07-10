/**
 * @author plaza
 */

dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.layout.BorderContainer");
dojo.require("dojox.layout.ExpandoPane");
dojo.require("dijit.layout.AccordionContainer");
dojo.require("dijit.layout.TabContainer");

dojo.require("dijit.form.Button");
dojo.require("dijit.DropDownMenu");
dojo.require("dijit.PopupMenuItem");
dojo.require("dijit.MenuItem");
dojo.require("dijit.Menu");
dojo.require("dijit.form.FilteringSelect");

dojo.require("dijit.MenuBar");
dojo.require("dijit.PopupMenuBarItem");
dojo.require("dijit.form.DropDownButton");
dojo.require("dijit.popup");


dojo.require("dojox.grid.DataGrid");
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dojo.data.ItemFileWriteStore");
dojo.require("dojox.data.AndOrReadStore");
dojo.require("dojox.data.AndOrWriteStore");
dojo.require("dijit.Dialog");
dojo.require("dijit.form.ValidationTextBox");
dojo.require("dojo.parser");
dojo.require("dojo.date.locale");

dojo.require("dojox.grid.TreeGrid");
dojo.require("dijit.tree.ForestStoreModel");
dojo.require("dojox.grid.LazyTreeGridStoreModel");
dojo.require("dijit.Tree");


dojo.require("dijit.form.ComboBox");
dojo.require("dijit.form.CheckBox");
dojo.require("dijit.form.Form");
dojo.require("dijit.TitlePane");
dojo.require("dijit.form.TextBox");
dojo.require("dijit.form.Textarea");
dojo.require("dojox.grid.cells.dijit");
dojo.require("dojox.grid.EnhancedGrid");
dojo.require("dojox.grid.enhanced.plugins.DnD");
dojo.require("dojox.grid.enhanced.plugins.Menu");
dojo.require("dojox.grid.enhanced.plugins.NestedSorting");
dojo.require("dojox.grid.enhanced.plugins.IndirectSelection");
dojo.require("dojox.grid.enhanced.plugins.Pagination");
dojo.require("dojox.grid.enhanced.plugins.Filter");
dojo.require("dojox.grid.enhanced.plugins.Selector");

dojo.require("dijit.Tooltip");
dojo.require("dijit.MenuSeparator");
dojo.require("dojox.widget.PlaceholderMenuItem");

dojo.require("dojox.grid.enhanced.plugins.exporter.CSVWriter");
dojo.require("dojox.grid.enhanced.plugins.exporter.TableWriter");
dojo.require("dojox.grid.enhanced.plugins.Printer");
dojo.require("dijit.form.NumberTextBox");
dojo.require("dijit.registry");
dojo.require("dijit.Toolbar");
dojo.require("dijit.ToolbarSeparator");

dojo.require("dojox.widget.Standby");

dojo.require("dojo._base.declare");
dojo.require("dojo.aspect");
dojo.require("dojo._base.lang");
dojo.require("dojo.store.Memory");
dojo.require("dojo.store.Cache");


dojo.require("dijit.form.CurrencyTextBox");
dojo.require("dojox.grid.cells");
dojo.require("dojox.form.CheckedMultiSelect");
dojo.require("dojo.query");

dojo.require("dijit.form.HorizontalSlider");
dojo.require("dijit.form.HorizontalRule");
dojo.require("dijit.form.HorizontalRuleLabels");
dojo.require("dijit.form.ToggleButton");
dojo.require("dojox/mobile/Switch");
dojo.require("dojo.on");
dojo.require("dojo/dom-construct");

var BC;
/*########################################################################
##################### Exon Capture : New DATA
##########################################################################*/
dojo.addOnLoad(function() {
	dojo.connect(dijit.byId("searchCaptureForm"),"onKeyDown",function(e) {
    		if (e.keyCode == dojo.keys.ENTER) {
			wordsearchCap(gridCap);
		}
	}); 
});

var filterCapValue;
function wordsearchCap(grid) {
	filterCapValue=dijit.byId('FilterCapBox').get('value');
	filterCapValue = "'*" + filterCapValue + "*'";
        grid.queryOptions = {ignoreCase: true};
	grid.setQuery({complexQuery: "capName:"+filterCapValue + "OR capDes:" +filterCapValue + "OR capAnalyse:" +filterCapValue + "OR capValidation:" +filterCapValue+ "OR bunName:" +filterCapValue + "OR capType:" +filterCapValue});
	grid.store.fetch();
	grid.store.close();
	dijit.byId(grid)._refresh();
}

function resetSearchCap(grid) {
	var sliderFormvalue = dijit.byId("slider_cap").attr("value");
	dijit.byId('FilterCapBox').set('value',"");
//	QuerydependCapSlider();
	wordsearchCap(grid);
	grid.selection.clear();
}

function QuerydependCapSlider(){
	var sliderFormvalue = dijit.byId("slider_cap").attr("value");
	var url_captureStore="/manageCapture.pl?option=capture";

	if (sliderFormvalue==1) {
		url_captureStore+= "&numAnalyse=1";
	} else if (sliderFormvalue==2) {
		url_captureStore+= "&numAnalyse=2";
	} else if (sliderFormvalue==3) {
		url_captureStore+= "&numAnalyse=3";
	} else if (sliderFormvalue==4) {
		url_captureStore+= "&numAnalyse=4";
	} else if (sliderFormvalue==5) {
		url_captureStore+= "&numAnalyse=5";
	} else if (sliderFormvalue==6) {
		url_captureStore+= "&numAnalyse=6";
	} else if (sliderFormvalue==7) {
		url_captureStore+= "&numAnalyse=7";
	} else if (sliderFormvalue==8) {
		url_captureStore+= "&numAnalyse=8";
	}

	captureStore = new dojox.data.AndOrWriteStore({url: url_path + url_captureStore});
	gridCap.setStore(captureStore);
}


var gpCap;
function Manage_Analyse(e) {
	document.getElementById("TableGeneRelease_title").style.visibility="hidden";
	if(e.value=="exome"){
		var boxan = dijit.byId("capAnalyse");
		boxan.attr("value",e.value);
	} 
	if(e.value=="genome"){
		var boxan = dijit.byId("capAnalyse");
		boxan.attr("value",e.value);
	} 
	if(e.value=="rnaseq"){
		var boxan = dijit.byId("capAnalyse");
		boxan.attr("value",e.value);
	} 
	if(e.value=="singlecell"){
		var boxan = dijit.byId("capAnalyse");
		boxan.attr("value",e.value);
	} 
	if(e.value=="old") {
		document.getElementById("TableGeneRelease_title").style.visibility="visible";
		var boxan = dijit.byId("capAnalyse");
		boxan.attr("value","");
		boxan.attr("placeHolder","Select an Analyse");		
	}
	if(e.value=="new") {
		document.getElementById("TableGeneRelease_title").style.visibility="visible";
		var boxan = dijit.byId("capAnalyse");
		boxan.attr("value","");
		boxan.attr("placeHolder","Enter a New Analyse");
	}
	if(e.value=="amplicon"){
		var boxan = dijit.byId("capAnalyse");
		boxan.attr("value",e.value);
	} 
	if(e.value=="other"){
		var boxan = dijit.byId("capAnalyse");
		boxan.attr("value",e.value);
	} 
}

var widePos=0;
var filterExon=0;
var param_dir;

function editCapture(item) {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	dijit.byId('CPCapBun').set('title', "<b >Bundles of Exon Capture "+
	"<span style='background:#6D7741;border-radius: 5px 5px 5px 5px;margin:2;padding:2'>"+item.capName+" ID: "+ item.captureId+"</span>");
	var capspn=dojo.byId('SbundleCap');
	capspn.innerHTML=item.capName.toString();
	var capspid = dojo.byId("SbundleCapId");
	capspid.innerHTML= item.captureId.toString();
	var capspt=dojo.byId('SbundleCapType');
	capspt.innerHTML=item.capType.toString();

	var sp_btcloseexcap=dojo.byId("bt_close_excap");
	var btcloseexcap=dijit.byId("id_bt_closeexcap");
	if (btcloseexcap) {
		sp_btcloseexcap.removeChild(btcloseexcap.domNode);
		btcloseexcap.destroyRecursive();
	}

	var buttonformclose_excap= new dijit.form.Button({
		showLabel: true,
		id:"id_bt_closeexcap",
		iconClass:"closeIcon",
		style:"color:white",
		onClick:function() {
			closeEditBundle();
		}
	});
	buttonformclose_excap.startup();
	buttonformclose_excap.placeAt(sp_btcloseexcap);
	viewCaptureBundle();

//############################ Init Capture ###############################
	dojo.style("bt_saveCapture", {'visibility':'visible'});
	document.getElementById("TableCapFiles").style.visibility="visible";
	dojo.byId('captureId').value =item.captureId;

        dojo.byId('capture').value =item.capName;
	dojo.byId('capDes').value =item.capDes;
	dojo.byId('capVs').value =item.capVs;
	// dans polyprojectNGS.js
	typefilterSelect.set('store',typeCaptureStore);
	typefilterSelect.startup();
	dijit.byId("capType").attr("placeHolder","");
	dojo.byId('capType').value =item.capType;


	umifilterSelect.set('store',umiNameStore);
	umifilterSelect.startup();
	dijit.byId("capUMI").attr("placeHolder","");
	dojo.byId('capUMI').value =item.umi;

	// dans polyprojectNGS.js
	capmethodSelect.set('store',capmethStore);
	capmethodSelect.startup();
	dijit.byId("capMethod").attr("placeHolder","");
	dojo.byId('capMethod').value =item.capMeth.toString();
	// FilteringSelect Only Select
	capmethodSelect.set('value',item.capMeth.toString());
	// dans polyprojectNGS.js
	schemasfilterSelect.set('store',schemasStore);
	schemasfilterSelect.startup();
	dojo.byId('capAnalyse').value =item.capAnalyse.toString();
	dojo.byId('capValidation').value =item.capValidation;
	activateRadioAnalyse(0);

	relgenecapfilterSelect.set('store',relgeneNameStore);
	dijit.byId("capRelGene").attr("placeHolder","");
	relgenecapfilterSelect.startup();
	dojo.byId('capRelGene').value =item.capRelGene.toString();
	relgenecapfilterSelect.set('value',item.capRelGene.toString());

	dojo.byId('capFile').value =item.capFile;
	dojo.byId('capFilePrimer').value =item.capFilePrimers;
	if (! item.capFile.toString().length) {
		dojo.byId('capFile').value ="";
	}
	if (! item.capFilePrimers.toString().length) {
		dojo.byId('capFilePrimer').value ="";
	}
	if (item.capFile.toString().length) {
		document.getElementById("AccMain").style.display = "block";
		dijit.byId("AccMain").domNode.style.display = 'block';
		dijit.byId("AccMain").resize();
	} else {
		document.getElementById("AccMain").style.display = "none";
	}
	var domBt=dojo.byId("domBt_capFile");
	var w_capFile =dijit.byId("bt_capFile");
	if (w_capFile) {
		domBt.removeChild(w_capFile.domNode);
		w_capFile.destroyRecursive();
	}

	var domBtPrimer=dojo.byId("domBt_capFilePrimer");
	var w_capFilePrimer =dijit.byId("bt_capFilePrimer");
	if (w_capFilePrimer) {
		domBtPrimer.removeChild(w_capFilePrimer.domNode);
		w_capFilePrimer.destroyRecursive();
	}

	document.getElementById("TableErrorGenome").style.visibility="hidden";
//	initRadioRelCap(item.rel.toString());
	initRadioCaptureRelCap(item.rel.toString());

	var hrc = dojo.byId("enddirCap");
	hrc.innerHTML=item.rel+","+"capture/"+item.capType;
	param_dir= document.getElementById("enddirCap").innerHTML;

	var o_hrc = dojo.byId("out_enddirCap");
	var p_rel=item.rel.toString();
	if(p_rel.indexOf("HG19") !== -1) {p_rel="HG19"}
	if(p_rel.indexOf("HG38") !== -1) {p_rel="HG38"}
	o_hrc.innerHTML="capture/"+p_rel+"/"+item.capType;

	w_capFile = new dijit.form.Button({
//	w_capFile = new dojox.mobile.Button({
		id:"bt_capFile",
		label:"<span><img align='top' src='icons/document_small_upload.png'></span>",
		onClick:function() {
			dijit.byId('divCaptureFile').reset();
			var z= dojo.byId("FileNameCap");
			z.innerHTML= item.capFile;
			dojo.byId('FileNameCap').value =item.capFile;
			if (! item.capFile.toString().length) {
				dojo.byId('FileNameCap').value =item.capName+".bed";
			}
			dojo.byId('capId').value =item.captureId;
			dojo.byId("capId").innerHTML= item.captureId;
			dojo.byId('TypeCap').value =item.capType;
			dojo.byId('TypeCap').innerHTML=item.capType;
			
			dojo.byId('capRel').innerHTML=item.rel;
			
			var hrc = dojo.byId("enddirCap");
			hrc.innerHTML=item.rel+","+"capture/"+item.capType;
			param_dir= document.getElementById("enddirCap").innerHTML;

			var o_hrc = dojo.byId("out_enddirCap");
			o_hrc.innerHTML=item.rel+","+"capture/"+item.capType;
			var p_rel=item.rel.toString();
			if(p_rel.indexOf("HG19") !== -1) {p_rel="HG19"}
			if(p_rel.indexOf("HG38") !== -1) {p_rel="HG38"}
			o_hrc.innerHTML="capture/"+p_rel+"/"+item.capType;
			//param_dir= document.getElementById("out_enddirCap").innerHTML;

			var za= dojo.byId("FileName_Cap");
			za.innerHTML= "Capture File Name: ";
			var zb= dojo.byId("Column_legend");
			zb.innerHTML= "chr[1..22,X,Y]&nbsp;<b>*</b>&nbsp;&nbsp;Start&nbsp;&nbsp;End<br><b>*</b>&nbsp;First column: Chromosome column must be confirm to Genome Fasta index File (.fai) of the release";

			divCaptureFile.set('title', "Deposit Capture File");
			dijit.byId("loadFC").set("label", "Upload Capture Tab File");
			dojo.style(dijit.byId('loadFC').domNode,{'display':'block'});
			divCaptureFile.show();
		}
	},"bt_capFile");
	domBt.appendChild(w_capFile.domNode);

	w_capFilePrimer = new dijit.form.Button({
//	w_capFilePrimer = new dojox.mobile.Button({
		id:"bt_capFilePrimer",
		label:"<span><img align='top' src='icons/document_small_upload.png'></span>",
		onClick:function() {
			dijit.byId('divCaptureFile').reset();
			var z= dojo.byId("FileNameCap");
			z.innerHTML= item.capFile;
			dojo.byId('FileNameCap').value =item.capFilePrimers;
			if (! item.capFilePrimers.toString().length) {
				dojo.byId('FileNameCap').value =item.capName+".bed.primers";
			}
			dojo.byId('capId').value =item.captureId;
			dojo.byId("capId").innerHTML= item.captureId;
			dojo.byId('TypeCap').value =item.capType;
			dojo.byId('TypeCap').innerHTML=item.capType;
			dojo.byId('capRel').innerHTML=item.rel;
			
			var hrc = dojo.byId("enddirCap");
			hrc.innerHTML=item.rel+","+"capture/"+item.capType;
			param_dir= document.getElementById("enddirCap").innerHTML;

			var o_hrc = dojo.byId("out_enddirCap");
			var p_rel=item.rel.toString();
			if(p_rel.indexOf("HG19") !== -1) {p_rel="HG19"}
			if(p_rel.indexOf("HG38") !== -1) {p_rel="HG38"}
			o_hrc.innerHTML="capture/"+p_rel+"/"+item.capType;

			var za= dojo.byId("FileName_Cap");
			za.innerHTML= "Primer File Name: ";
			var zb= dojo.byId("Column_legend");
		zb.innerHTML= "<b>4 Columns:</b> chr[1..22,X,Y]&nbsp;<b>*</b>&nbsp;&nbsp;Start&nbsp;&nbsp;End&nbsp;&nbsp;Pool&nbsp;&nbsp;<b> Or </b><br><b>6 Columns:</b> chr[1..22,X,Y]&nbsp;<b>*</b>&nbsp;&nbsp;Start<sub>1</sub>&nbsp;&nbsp;End<sub>1</sub>&nbsp;&nbsp;Start<sub>2</sub>&nbsp;&nbsp;End<sub>2</sub>&nbsp;&nbsp;Pool<br><b>*</b>&nbsp;First column: Chromosome column must be confirm to Genome Fasta index File (.fai) of the release</b>";
			divCaptureFile.set('title', "Deposit Primer File");
			dijit.byId("loadFC").set("label", "Upload Primer Tab File");
			dojo.style(dijit.byId('loadFC').domNode,{'display':'block'});
			divCaptureFile.show();
		}
	},"bt_capFilePrimer");
	domBtPrimer.appendChild(w_capFilePrimer.domNode);

	var downdomBt=dojo.byId("domBt_downcapFile");
	var w_downcapFile =dijit.byId("bt_downcapFile");
	if (w_downcapFile) {
		downdomBt.removeChild(w_downcapFile.domNode);
		w_downcapFile.destroyRecursive();
	}

	w_downcapFile = new dijit.form.Button({
//	w_capFile = new dojox.mobile.Button({
		id:"bt_downcapFile",
		label:"<span><img align='top' src='icons/move_waiting_down_alternative.png'></span>",
		onClick:function() {
			downcapFileFolder();
		}
	},"bt_downcapFile");
	downdomBt.appendChild(w_downcapFile.domNode);

	standbyShow();
	bundleStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=bundleCap"+"&exclude=1"+"&CapSel="+item.captureId
	});
	capturebundleStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=bundleCap"+"&exclude=0"+"&CapSel="+item.captureId
	});
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}
	function clearOldBundleList(size, request) {
                    var listBun = dojo.byId("gridBundleDiv");
                    if (listBun) {
                        while (listBun.firstChild) {
                           listBun.removeChild(listBun.firstChild);
                        }
                    }
	}
	function clearOldBundleCaptureList(size, request) {
                    var listBunCap = dojo.byId("gridCaptureBundleDiv");
                    if (listBunCap) {
                        while (listBunCap.firstChild) {
                           listBunCap.removeChild(listBunCap.firstChild);
                        }
                    }
	}
	var menusObjectB = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};
	menusObjectB.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectB.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectB.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridBundle);"}));
	menusObjectB.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridBundle);"}));
	menusObjectB.cellMenu.startup();

	menusObjectB.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectB.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectB.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridBundle);"}));
	menusObjectB.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(gridBundle);"}));
	menusObjectB.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridBundle);"}));
	menusObjectB.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(gridBundle);"}));
	menusObjectB.selectedRegionMenu.startup();

	showProgressDlg("Loading Other Bundles... ",true,"gridBundleDiv","OB");
	bundleStore.fetch({
		onBegin: clearOldBundleList,
		onError: fetchFailed,
		onComplete: function(items){
			gridBundle = new dojox.grid.EnhancedGrid({
				store: bundleStore,
				structure: layoutBundle,
				rowSelector: "0.4em",
				loadingMessage:'Loading, please wait',
				rowsPerPage: 1000,  // IMPORTANT
				selectionMode: 'multiple',
				canSort:function(colIndex, field){
					return colIndex != 1 && field != 'flagTr' && field != 'flagCap' && field != 'flagGn' && field != 'nbTr' && field !='nbBun';
				},
				plugins: {
 					filter: {
						closeFilterbarButton: true,
						ruleCount: 5,
						itemsName: "name"
					},
          				pagination: {
              					pageSizes: ["25","All"],
              					description: true,
              					sizeSwitch: true,
              					pageStepper: true,
              					gotoButton: true,
              					maxPageStep: 4,
						defaultPageSize: 25,
              					position: "bottom"
          				},
					indirectSelection: {
						name: "Sel",
						width: "1.5em",
						styles: "text-align: center;",
					},
					nestedSorting: true,
					dnd: true,
					exporter: true,
					printer:true,
					selector:true,
					menus:menusObjectBC
				}
			},document.createElement('div'));
			dojo.byId("gridBundleDiv").appendChild(gridBundle.domNode);
			sortDateGrid(bundleStore, date="cDate");
			gridBundle.startup();
			showProgressDlg("Loading Other Bundles... ",false,"gridBundleDiv","OB");
			gridBundle.store.fetch({onComplete:standbyHide});
			dojo.connect(gridBundle, "onMouseOver", showTooltip);
			dojo.connect(gridBundle, "onMouseOut", hideTooltip); 
		}
	});

	layoutCaptureBundle = [
		{ field: "Row", name: "Row",get: getRow, width: '2.5'},
		{ field: "flagTr",name: "Tr",width: '2', formatter:bullet},
		{ field: "bundleId",name: "ID",width: '3'},
		{ field: "bunName",name: "Bundle Name",width: '22'},
		{ field: "relGene",name: "relG",width: '2.5', formatter:backgroundCell},
		{ field: "bunVs",name: "Vs",width: '2', editable:true},
		{ field: "bunDes", name: "Bundle Description", width: '22'},
		{ field: "meshid", name: "Mesh", width: '4.5'},
		{ field: "nbTr", name: "#Tr", width: '4'},
		{ field: "flagGn",name: "Gn",width: '2', formatter:bullet},
		{ field: "cDate", name: "Date", datatype:"date", width: '7'},
	];

	var menusObjectBC = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};
	menusObjectBC.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectBC.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectBC.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridCaptureBundle);"}));
	menusObjectBC.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridCaptureBundle);"}));
	menusObjectBC.cellMenu.startup();

	menusObjectBC.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectBC.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectBC.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridCaptureBundle);"}));
	menusObjectBC.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(gridCaptureBundle);"}));
	menusObjectBC.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridCaptureBundle);"}));
	menusObjectBC.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(gridCaptureBundle);"}));
	menusObjectBC.selectedRegionMenu.startup();

	showProgressDlg("Loading Bundles... ",true,"gridCaptureBundleDiv","BU");
	capturebundleStore.fetch({
		onBegin: clearOldBundleCaptureList,
		onError: fetchFailed,
		onComplete: function(items){
			gridCaptureBundle = new dojox.grid.EnhancedGrid({
				store: capturebundleStore,
				structure: layoutCaptureBundle,
				rowSelector: "0.4em",
				loadingMessage:'Loading, please wait',
				rowsPerPage: 1000,  // IMPORTANT
				selectionMode: 'multiple',
				canSort:function(colIndex, field){
					return colIndex != 1 && field != 'flagTr' && field != 'flagCap' && field != 'flagGn' && field != 'nbTr' && field !='nbBun';
				},
				plugins: {
 					filter: {
						closeFilterbarButton: true,
						ruleCount: 5,
						itemsName: "name"
					},
          				pagination: {
              					pageSizes: ["30","All"],
              					description: true,
              					sizeSwitch: true,
              					pageStepper: true,
              					gotoButton: true,
              					maxPageStep: 4,
						defaultPageSize: 30,
              					position: "bottom"
          				},
					indirectSelection: {
						headerSelector:true, 
						//name: "Sel",
						width: "1.5em",
						styles: "text-align: center;",
					},
					nestedSorting: true,
					dnd: true,
					exporter: true,
					printer:true,
					selector:true,
					menus:menusObjectBC
				}
			},document.createElement('div'));
			dojo.byId("gridCaptureBundleDiv").appendChild(gridCaptureBundle.domNode);
			sortDateGrid(capturebundleStore, date="cDate");
			gridCaptureBundle.startup();
			showProgressDlg("Loading Bundles... ",false,"gridCaptureBundleDiv","BU");
			dojo.connect(gridCaptureBundle, "onMouseOver", showTooltip);
			dojo.connect(gridCaptureBundle, "onMouseOut", hideTooltip);
			dojo.connect(gridCaptureBundle, "onMouseOver", showTooltipField);
			dojo.connect(gridCaptureBundle, "onMouseOut", hideTooltipField);
			dojo.connect(gridCaptureBundle, 'onRowDblClick', gridCaptureBundle, function(e) {
				dijit.byId("trs_file").set('checked', true);
				dijit.byId("trs_col").set('checked', false);
				chgTrsFile();
				var itemC= gridCaptureBundle.getItem(e.rowIndex);
				initNewBun=0;
				editBundle(itemC);
				}		
			);
		}		
	});
//########################### Init Transcript #############################
	if (item.rel.toString()) {
		var i_hre = dojo.byId("relExon");
		i_hre.innerHTML=item.rel.toString();
	}
	widePos=0;
	filterExon=1;
	dijit.byId("swExon").set("value", "off");
	dijit.byId("sliderCap").attr('value',widePos);
	initFilterExon(widePos,filterExon,standbyEx=0,exonFile=0);
//###################### Init Undesigned Transcript #######################
	initUndesignTr(widePos,standbyEx=0);
//#########################################################################
	divCapBunForm = dijit.byId("divCapBun");
	divCapBunForm.show();
}

function downcapFileFolder() {
	dojo.style("bt_capbed", {'visibility':'hidden'});
	var sp_btclosecapbed=dojo.byId("bt_close_capbed");
	var btclosecapbed=dijit.byId("id_bt_closecapbed");
	if (btclosecapbed) {
		sp_btclosecapbed.removeChild(btclosecapbed.domNode);
		btclosecapbed.destroyRecursive();
	}
	var buttonformclose_capbed= new dijit.form.Button({
		id:"id_bt_closecapbed",
		showLabel: false,
		type:"submit",
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('downcapFileFolderDialog').hide()"
	});
	buttonformclose_capbed.startup();
	buttonformclose_capbed.placeAt(sp_btclosecapbed);

	downcapFileFolderDialog = dijit.byId("downcapFileFolderDialog");
	downcapFileFolderDialog.show();
	var captureFormvalue = dijit.byId("capForm").getValues();
	var s_capFile =document.getElementById("capFile").value;
	var folder_dir= document.getElementById("out_enddirCap").innerHTML;
	capbedStore = new dojo.data.ItemFileWriteStore({
	       url: url_path + "/upload_file.pl?opt=getloadFile" + 
			"&file_name=" + s_capFile +
			"&folder_dir=" + folder_dir			
	});
	var layoutCapbed = [
		{field: "chr",name: "chr", width: '3'},
		{field: "start",name: "start", width: '10'},
		{field: "end",name: "end", width: '10'},
	];
	function clearOldBedList(size, request) {
                    var listBed = dojo.byId("bedGrid");
                    if (listBed) {
                        while (listBed.firstChild) {
                           listBed.removeChild(listBed.firstChild);
                        }
                    }
	}
	function fetchBedFailed(error, request) {
		alert("lookup bed capture file failed.");
		alert(error);
	}
	capbedStore.fetch({
		onBegin: clearOldBedList,
		onError: fetchBedFailed,
		onComplete: function(items){
			capbedGrid =  new dojox.grid.EnhancedGrid({
				store: capbedStore,
				rowSelector: "0.4em",
				structure: layoutCapbed,
				plugins: {
					exporter: true,
				}
			},document.createElement('div'));
			dojo.byId("capbedGrid").appendChild(capbedGrid.domNode);
			capbedGrid.startup();
			capbedGrid.setStore(capbedStore);
			dojo.style("bt_capbed", {'visibility':'visible'});
		}
	});
}

function exportFileAll(grid){
	dijit.byId(grid).exportGrid("csv",{writerArgs: {separator: ";"}}, function(str){
	var reg1=new RegExp(/chr;start;end/,"g");
	var reg2=new RegExp(/^\s*[\r\n]/,"g");

	str=str.replace(reg1,'');
	str=str.replace(reg2,'');
	var regSep=new RegExp(',',"g");
	str=str.replace(regSep,';');
	var form = document.createElement('form');
	dojo.attr(form, 'method', 'POST');
	var f_input=document.createElement('input');
	f_input.type="hidden";
	f_input.name="my_input";
	f_input.value=str;
	form.appendChild(f_input);
	document.body.appendChild(form);
	dojo.io.iframe._currentDfd = null;
	if (this._deferred) {
    		this._deferred.cancel();
	}
	this._deferred=dojo.io.iframe.send({
		url: url_path + "/XLSexport.pl",
 		form: form,
 		method: "POST",
		handleAs: "text",
		content: {exp: str},
	});
	document.body.removeChild(form);
    });
};

function activateRadioAnalyse(n_analyse,analyse) {
	var boxanal = dijit.byId("capAnalyse");
	boxanal.attr("placeHolder","");
	document.getElementById("TableGeneRelease_title").style.visibility="hidden";
	if (! analyse) {
		sliderFormvalue = dijit.byId("slider_cap").attr("value");
	}
	if (sliderFormvalue==1) {
	//All
		dijit.byId("analEx").set('checked', false);
		dijit.byId("analEx").set('disabled', false);
		dijit.byId("analGe").set('checked', false);
		dijit.byId("analGe").set('disabled', false);
		dijit.byId("analRNA").set('checked', false);
		dijit.byId("analRNA").set('disabled', false);
		dijit.byId("analSi").set('checked', false);
		dijit.byId("analSi").set('disabled', false);
		dijit.byId("analOldVal").set('checked', false);
		dijit.byId("analOldVal").set('disabled', false);	
		dijit.byId("analNewVal").set('checked', false);
		dijit.byId("analNewVal").set('disabled', false);
		dijit.byId("analAm").set('checked', false);
		dijit.byId("analAm").set('disabled', false);
		dijit.byId("analOt").set('checked', false);
		dijit.byId("analOt").set('disabled', false);

		var captureFormvalue = dijit.byId("capForm").getValues();
		var s_capAnalyse = captureFormvalue.capAnalyse;
		initButtonAnalyse(s_capAnalyse);
	} else if (sliderFormvalue==2) {
	//Exome
		dijit.byId("analEx").set('checked', true); //Exome
		dijit.byId("analEx").set('disabled', true);
		dijit.byId("analGe").set('checked', false);
		dijit.byId("analGe").set('disabled', true);
		dijit.byId("analRNA").set('checked', false);
		dijit.byId("analRNA").set('disabled', true);
		dijit.byId("analSi").set('checked', false);
		dijit.byId("analSi").set('disabled', true);
		dijit.byId("analOldVal").set('checked', false);
		dijit.byId("analOldVal").set('disabled', true);	
		dijit.byId("analNewVal").set('checked', false);
		dijit.byId("analNewVal").set('disabled', true);	
		dijit.byId("analAm").set('checked', false);
		dijit.byId("analAm").set('disabled', true);
		dijit.byId("analOt").set('checked', false);
		dijit.byId("analOt").set('disabled', true);
		boxanal.attr("value","exome");
	} else if (sliderFormvalue==3) {
	//Genome
		dijit.byId("analEx").set('checked', false);
		dijit.byId("analEx").set('disabled', true);
		dijit.byId("analGe").set('checked', true);//Genome
		dijit.byId("analGe").set('disabled', true);
		dijit.byId("analRNA").set('checked', false);
		dijit.byId("analRNA").set('disabled', true);
		dijit.byId("analSi").set('checked', false);
		dijit.byId("analSi").set('disabled', true);
		dijit.byId("analOldVal").set('checked', false);
		dijit.byId("analOldVal").set('disabled', true);	
		dijit.byId("analNewVal").set('checked', false);
		dijit.byId("analNewVal").set('disabled', true);	
		dijit.byId("analAm").set('checked', false);
		dijit.byId("analAm").set('disabled', true);
		dijit.byId("analOt").set('checked', false);
		dijit.byId("analOt").set('disabled', true);
		boxanal.attr("value","genome");
	} else if (sliderFormvalue==4) {
		document.getElementById("TableGeneRelease_title").style.visibility="visible";
	//Target Validation
		dijit.byId("analEx").set('checked', false);
		dijit.byId("analEx").set('disabled', true);
		dijit.byId("analGe").set('checked', false);
		dijit.byId("analGe").set('disabled', true);
		dijit.byId("analRNA").set('checked', false);
		dijit.byId("analRNA").set('disabled', true);
		dijit.byId("analSi").set('checked', false);
		dijit.byId("analSi").set('disabled', true);
		dijit.byId("analOldVal").set('checked', true);// Activate Target
		dijit.byId("analOldVal").set('disabled', false);	
		dijit.byId("analNewVal").set('checked', false);
		dijit.byId("analNewVal").set('disabled', false);	
		if (n_analyse) {
			dijit.byId("analOldVal").set('checked', false);
			dijit.byId("analOldVal").set('disabled', false);
			dijit.byId("analNewVal").set('checked', true);
			dijit.byId("analNewVal").set('disabled', false);	
			boxanal.attr("value","");
			boxanal.attr("placeHolder","Enter a New Analyse");
		}
		dijit.byId("analAm").set('checked', false);
		dijit.byId("analAm").set('disabled', true);
		dijit.byId("analOt").set('checked', false);
		dijit.byId("analOt").set('disabled', true);

	} else if (sliderFormvalue==5) {
	//RNAseq
		dijit.byId("analEx").set('checked', false);
		dijit.byId("analEx").set('disabled', true);
		dijit.byId("analGe").set('checked', false);
		dijit.byId("analGe").set('disabled', true);
		dijit.byId("analRNA").set('checked', true);// Activate RNA
		dijit.byId("analRNA").set('disabled', true);
		dijit.byId("analSi").set('checked', false);
		dijit.byId("analSi").set('disabled', true);
		dijit.byId("analOldVal").set('checked', false);
		dijit.byId("analOldVal").set('disabled', true);	
		dijit.byId("analNewVal").set('checked', false);
		dijit.byId("analNewVal").set('disabled', true);	
		dijit.byId("analAm").set('checked', false);
		dijit.byId("analAm").set('disabled', true);
		dijit.byId("analOt").set('checked', false);
		dijit.byId("analOt").set('disabled', true);
		boxanal.attr("value","rnaseq");
	} else if (sliderFormvalue==6) {
	//SingleCell
		dijit.byId("analEx").set('checked', false);
		dijit.byId("analEx").set('disabled', true);
		dijit.byId("analGe").set('checked', false);
		dijit.byId("analGe").set('disabled', true);
		dijit.byId("analRNA").set('checked', false);
		dijit.byId("analRNA").set('disabled', true);
		dijit.byId("analSi").set('checked', true);// activate SingleCell
		dijit.byId("analSi").set('disabled', true);
		dijit.byId("analOldVal").set('checked', false);
		dijit.byId("analOldVal").set('disabled', true);	
		dijit.byId("analNewVal").set('checked', false);
		dijit.byId("analNewVal").set('disabled', true);	
		dijit.byId("analAm").set('checked', false);
		dijit.byId("analAm").set('disabled', true);
		dijit.byId("analOt").set('checked', false);
		dijit.byId("analOt").set('disabled', true);
		boxanal.attr("value","singlecell");
	} else if (sliderFormvalue==7) {
	//Amplicon
		dijit.byId("analEx").set('checked', false);
		dijit.byId("analEx").set('disabled', true);
		dijit.byId("analGe").set('checked', false);
		dijit.byId("analGe").set('disabled', true);
		dijit.byId("analRNA").set('checked', false);
		dijit.byId("analRNA").set('disabled', true);
		dijit.byId("analSi").set('checked', false);
		dijit.byId("analSi").set('disabled', true);
		dijit.byId("analOldVal").set('checked', false);
		dijit.byId("analOldVal").set('disabled', true);	
		dijit.byId("analNewVal").set('checked', false);
		dijit.byId("analNewVal").set('disabled', true);	
		dijit.byId("analAm").set('checked', true);// activate Amplicon
		dijit.byId("analAm").set('disabled', true);
		dijit.byId("analOt").set('checked', false);
		dijit.byId("analOt").set('disabled', true);
		boxanal.attr("value","amplicon");
	} else if (sliderFormvalue==8) {
	//Other
		dijit.byId("analEx").set('checked', false);
		dijit.byId("analEx").set('disabled', true);
		dijit.byId("analGe").set('checked', false);
		dijit.byId("analGe").set('disabled', true);
		dijit.byId("analRNA").set('checked', false);
		dijit.byId("analRNA").set('disabled', true);
		dijit.byId("analSi").set('checked', false);
		dijit.byId("analSi").set('disabled', true);
		dijit.byId("analOldVal").set('checked', false);
		dijit.byId("analOldVal").set('disabled', true);	
		dijit.byId("analNewVal").set('checked', false);
		dijit.byId("analNewVal").set('disabled', true);	
		dijit.byId("analAm").set('checked', false);
		dijit.byId("analAm").set('disabled', true);
		dijit.byId("analOt").set('checked', true);// activate Other
		dijit.byId("analOt").set('disabled', true);
		boxanal.attr("value","other");
	}
}

function initButtonAnalyse(analyse) {
	document.getElementById("TableGeneRelease_title").style.visibility="hidden";
	if (analyse == "exome") {
		dijit.byId("analEx").set('checked', true); //Exome
		//dijit.byId("analEx").set('disabled', true);
	} else if (analyse == "genome") {
		dijit.byId("analGe").set('checked', true);//Genome
		//dijit.byId("analGe").set('disabled', true);
	} else if (analyse == "rnaseq") {
		dijit.byId("analRNA").set('checked', true);// Activate RNA
		//dijit.byId("analRNA").set('disabled', true);
	} else if (analyse == "singlecell") {
		dijit.byId("analSi").set('checked', true);// activate SingleCell
		//dijit.byId("analSi").set('disabled', true);
	} else if (analyse == "amplicon") {
		dijit.byId("analAm").set('checked', true);// Activate Amplicon
		//dijit.byId("analRNA").set('disabled', true);
	} else if (analyse == "other") {
		dijit.byId("analOt").set('checked', true);// Activate Other
		//dijit.byId("analRNA").set('disabled', true);
	} else {
		document.getElementById("TableGeneRelease_title").style.visibility="visible";
		dijit.byId("analOldVal").set('checked', true);// Activate Target
		//dijit.byId("analOldVal").set('disabled', true);
	}
}

dojo.addOnLoad(function() {
	dojo.connect(dijit.byId("FilterExonForm"),"onKeyDown",function(e) {
    		if (e.keyCode == dojo.keys.ENTER) {
			wordsearchExon(captureTrGrid);
		}
	}); 
});

function wordsearchExon(grid) {
	filterExonValue=dijit.byId('FilterExonBox').get('value');
	filterExonValue = "'*" + filterExonValue + "*'";
        grid.queryOptions = {ignoreCase: true};
	grid.setQuery({complexQuery: "trId:"+filterExonValue + "OR gene:" +filterExonValue});
	grid.store.fetch();
	grid.store.close();
	dijit.byId(grid)._refresh();
}

function resetSearchExon(grid) {
		FilterExonForm.reset();        
		grid.queryOptions = {ignoreCase: true};
		grid.setQuery({});
		wordsearchExon(grid);
}

dojo.addOnLoad(function() {
	dojo.connect(dijit.byId("swExon"),"onStateChanged",function(e) {
		if(e=="on") {
			filterExon=0;
			initFilterExon(widePos,filterExon,standbyEx=0,exonFile=0);
		} else {
			filterExon=1;
			initFilterExon(widePos,filterExon,standbyEx=0,exonFile=0);
		}
	}); 
});

var processDialog;
dojo.addOnLoad(function() {
	processDialogEx = new dijit.Dialog({
       		title:"processDialog",
        	style:"margin:2;padding:2;border:none",
	});
	processDialogUn = new dijit.Dialog({
       		title:"processDialog",
        	style:"margin:2;padding:2;border:none",
	});
	processDialogBu = new dijit.Dialog({
       		title:"processDialog",
        	style:"margin:2;padding:2;border:none",
	});
	processDialogOb = new dijit.Dialog({
       		title:"processDialog",
        	style:"margin:2;padding:2;border:none",
	});
	processDialogBt = new dijit.Dialog({
       		title:"processDialog",
        	style:"margin:2;padding:2;border:none",
	});
	processDialogLi = new dijit.Dialog({
       		title:"processDialog",
        	style:"margin:2;padding:2;border:none",
	});
	processDialogNa = new dijit.Dialog({
       		title:"processDialog",
        	style:"margin:2;padding:2;border:none",
	});
//ProcessDialog Monitoring
	processDialogMo = new dijit.Dialog({
       		title:"processDialog",
        	style:"margin:2;padding:2;border:none",
	});
});


function activateLoading(){
	dijit.byId("exDeposit").set('disabled', false);	
	dijit.byId("exRetrieve").set('disabled', false);	

}

function unactivateLoading(){
	dijit.byId("exDeposit").set('disabled', true);	
	dijit.byId("exRetrieve").set('disabled', true);	

}

var xhrArgsEx;
var deferredEx;
var exonFile=0;
function initFilterExon(){
	if (standbyEx) {standbyShow();};
	var layoutCaptureTr = [
		{ field: "Row", name: "Row",get: getRow, width: '2.5'},
		{field: 'trId',name: 'Transcript',width: '12em'},
		{field: 'gene',name: 'Gene',width: '10em'},
		{field: 'nbExon',name: '#Ex',formatter:warnNBTr,width: '2em'},
		{field: 'nbSub',name: "<img align='middle' src='icons/exclamation.png'>",styles:"white-space:nowrap;margin:0;padding:0;",formatter:warnNBTr,width: '2em'},
	];
	var CapSel=document.getElementById("captureId").value;
	var RelSel= document.getElementById("relExon").innerHTML;
	var captureFormvalue = dijit.byId("capForm").getValues();
	var s_capAnalyse = captureFormvalue.capAnalyse;
	var menusObjectEx = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};
	menusObjectEx.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectEx.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectEx.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(captureTrGrid);"}));
	menusObjectEx.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAllExon(captureTrGrid);"}));
	menusObjectEx.cellMenu.startup();

	menusObjectEx.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectEx.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectEx.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(captureTrGrid);"}));
	menusObjectEx.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(captureTrGrid);"}));
	menusObjectEx.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAllExon(captureTrGrid);"}));
	menusObjectEx.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelectedExon(captureTrGrid);"}));
	menusObjectEx.selectedRegionMenu.startup();
 	var timeoutExData ={
		identifier: "trId",
		items: [{trId:"Error Time Out",gene:"",nbExon:"",nbSub:""}]
	}
 	var notloadedExData ={
		identifier: "trId",
		items: [{trId:"No Data loaded",gene:"",nbExon:"",nbSub:""}]
	}
	var Matched=0;
	if (! filterExon) {
		Matched=1;
	}
	if (exonFile || (s_capAnalyse!="exome" && s_capAnalyse!="genome" && s_capAnalyse!="rnaseq" && s_capAnalyse!="singlecell" && s_capAnalyse!="amplicon" && s_capAnalyse!="other")) {
 		unactivateLoading();
		var url_exonTr;
		if (exonFile ) {
			activateLoading();
			url_exonTr="/run_exon.pl?option=retrieveExons" + 				
				"&CapSel=" + CapSel +
				"&RelSel=" + RelSel
		} else {
			url_exonTr="/manageCapture.pl?option=transcriptsCapture" +
			"&CapSel=" + CapSel +
			"&RelSel=" + RelSel +
			"&widePos=" + widePos +
			"&matched=" + Matched
		}
		showProgressDlg("Loading EXON... ",true,"captureTrGridDiv","EX");

  		xhrArgsEx={
			url: url_path +	url_exonTr,
			handleAs: "json",
			handle: function(response,args) {
				showProgressDlg("Loading EXON... ",false,"captureTrGridDiv","EX");
				},
              		timeout: 0, // infinite no time out
			load: function (res) {
				captureTrStore = new dojox.data.AndOrWriteStore({data: res});

				function fetchFailedTr(error, request) {
					alert("lookup failed TR.");
					alert(error);
				}
				function clearOldCaptureTrList(size, request) {
					var listCapTr = dojo.byId("captureTrGridDiv");
 					if (listCapTr) {
						while (listCapTr.firstChild) {
							listCapTr.removeChild(listCapTr.firstChild);
						}
					}
				}
				var gotCapTrItems = function(items,request){
					var maxNB=0;
					dojo.forEach(items, function(i,index){
						maxNB=Math.max(maxNB,captureTrStore.getValue(i,"nbExon"));
					});
					if (maxNB>0) {
						var fcols="";
						for(var i = 1; i <= maxNB; i++){
							layoutCaptureTr.push({
								field:"col_"+i,
								name:i,
								styles:"margin: 0; padding: 0;text-align: center;",
								width:"2em",
								formatter:colorTrCov
							});
							fcols += "col_"+ i + ":U:*" + " OR ";
						}
						fcols=fcols.substring(0,fcols.length-3);
					}
					var noMessage="";
					if (Matched) {noMessage="No Transcript Found"}
					else {noMessage="No Transcript Found <b>when toggling to Exon Out</b>"};
					captureTrGrid = new dojox.grid.EnhancedGrid({
						store: captureTrStore,
						structure: layoutCaptureTr,
						rowSelector: "0.4em",
						selectionMode: 'multiple',
						rowsPerPage: 1000,  // IMPORTANT
						noDataMessage: noMessage,
						loadingMessage:"Loading Transcripts Exon1...",
						canSort:function(colIndex, field){
							var cols="";
							for (i = 4; i <= maxNB+4; i++) {
								cols += "colIndex !=" + i + "&&";
							}
							cols=cols.substring(0,cols.length-2);
							return eval(cols)
						},
						plugins: {
							nestedSorting: true,
							exporter: true,
							printer:true,
							menus:menusObjectEx
						},
					},document.createElement('div'));
					dojo.byId("captureTrGridDiv").appendChild(captureTrGrid.domNode);
					captureTrGrid.startup();				
					if (standbyEx) {captureTrGrid.store.fetch({onComplete:standbyHide});}
					if (!standbyEx){captureTrGrid.store.fetch()};
					captureTrGrid.store.close();
					dijit.byId(captureTrGrid)._refresh();
					dojo.connect(captureTrGrid, "onMouseOver", showRowTrTooltip);			
					dojo.connect(captureTrGrid, "onMouseOut", hideRowTrTooltip); 
				}

				captureTrStore.fetch({
					onBegin: clearOldCaptureTrList,
					onError: fetchFailedTr,
					onComplete:gotCapTrItems
				});
			},
			error: function(error,ioargs) {
				standbyHide();
				showProgressDlg("Loading EXON... ",false,"captureTrGridDiv","EX");
				var CapNameError=document.getElementById("capture").value;
				if (ioargs.xhr.status=="504" || ioargs.xhr.status=="502") {
					captureTrStore = new dojox.data.AndOrWriteStore({data: timeoutExData});

					captureTrGrid = new dojox.grid.EnhancedGrid({
						store: captureTrStore,
						structure: layoutCaptureTr,
						rowSelector: "0.4em",
						rowsPerPage: 1000,  // IMPORTANT
						loadingMessage:"<span class='dojoxGridLoading'>Loading Undesigned Transcripts...</span>",
						selectionMode: 'multiple',
					},document.createElement('div'));
					dojo.byId("captureTrGridDiv").appendChild(captureTrGrid.domNode);
					captureTrGrid.startup();
					captureTrGrid.store.close();
				} 
				return;
			}
        	};
		deferredEx = dojo.xhrGet(xhrArgsEx);
	} else {
		if (standbyEx) {standbyHide();};
		activateLoading();
		captureTrStore = new dojox.data.AndOrWriteStore({data: notloadedExData});
		function fetchFailedLoadTr(error, request) {
			alert("lookup failed Load TR.");
				alert(error);
		}
		function clearOldCaptureTrLoadList(size, request) {
			var listCapLoadTr = dojo.byId("captureTrGridDiv");
 			if (listCapLoadTr) {
				while (listCapLoadTr.firstChild) {
					listCapLoadTr.removeChild(listCapLoadTr.firstChild);
				}
			}
		}
		var gotCapTrLoadItems = function(items,request){
			captureTrGrid = new dojox.grid.EnhancedGrid({
				store: captureTrStore,
				structure: layoutCaptureTr,
				rowsPerPage: 1000,  // IMPORTANT
				rowSelector: "0.4em",
				selectionMode: 'multiple',
			},document.createElement('div'));
			dojo.byId("captureTrGridDiv").appendChild(captureTrGrid.domNode);
			captureTrGrid.startup();
			captureTrGrid.store.fetch();
			captureTrGrid.store.close();
			dijit.byId(captureTrGrid)._refresh();
		}
		captureTrStore.fetch({
			onBegin: clearOldCaptureTrLoadList,
			onError: fetchFailedLoadTr,
			onComplete:gotCapTrLoadItems
		});
	}
}

function exonDeposit() {
	var CapSel=document.getElementById("captureId").value;
	var RelSel= document.getElementById("relExon").innerHTML;
	var Matched=0;
	if (! filterExon) {
		Matched=1;
	}
	var url_insert = url_path + "/run_exon.pl?option=deposeExons" +
		"&CapSel=" + CapSel +
		"&RelSel=" + RelSel +
		"&widePos=" + widePos +
		"&matched=" + Matched;
	sendData_v2(url_insert);
}

function exonRetrieve() {
	var CapSel=document.getElementById("captureId").value;
	var RelSel= document.getElementById("relExon").innerHTML;

	var url_insert = url_path + "/run_exon.pl?option=retrieveExonsParam" + 				
				"&CapSel=" + CapSel +
				"&RelSel=" + RelSel;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
//			"Widened Capture Position:".$widePos.", Exon Covered or Not (0,1):".$matched
			if(response.status=="Error"){
				return;
			}

			var sp_message=response.message.split(",");
			var sp_w=sp_message[0].split(":");
			var widePos=sp_w[1];
			var sp_m=sp_message[2].split(":");
			var Matched=sp_m[1];
			if(response.status=="OK"){
				if (widePos) {
					dijit.byId("sliderCap").attr('value',widePos);
				}

				if (Matched==1) {
					filterExon=0;
					dijit.byId("swExon").set("value", "on");
				} else {
					filterExon=1;
					dijit.byId("swExon").set("value", "off");
				}
				initFilterExon(widePos,filterExon,standbyEx=0,exonFile=1);
			}
		}
	);
}

function closeEditBundle() {
	dijit.byId('divBundleDB').reset();
	dijit.byId('divBundleDB').hide();
	exonFile=0;
	unactivateLoading();
	if (deferredEx) {
		if(!deferredEx.isResolved()) {
			deferredEx.cancel();
		}
		if(!deferredUnTr.isResolved()) {
			deferredUnTr.cancel();
		}
	}
}

dojo.addOnLoad(function() {
	dojo.connect(dijit.byId("FilterUnTrForm"),"onKeyDown",function(e) {
    		if (e.keyCode == dojo.keys.ENTER) {
			wordsearchUnTr(captureUnTrGrid);
			wordsearchUnTr(captureUnGeneGrid);
		}
	}); 
});

function wordsearchUnTr(grid) {
	filterUnTrValue=dijit.byId('FilterUnTrBox').get('value');
	filterUnTrValue = "'*" + filterUnTrValue + "*'";
        grid.queryOptions = {ignoreCase: true,deep:true};
	grid.setQuery({complexQuery: "geneId:"+filterUnTrValue + "OR gene:" +filterUnTrValue
			+ "OR chr:" +filterUnTrValue});
	grid.store.fetch();
	grid.store.close();
	dijit.byId(grid)._refresh();
}

function resetSearchUnTr(grid) {
		FilterUnTrForm.reset();        
		grid.queryOptions = {ignoreCase: true};
		grid.setQuery({});
		wordsearchUnTr(grid);
		collapseUnTr();
}

var xhrArgsUnTr;
var deferredUnTr;

var xhrArgsUnGene;
var deferredUnGene;
var thresholdStore;
var thresholdUnSelect;
var thresholdData ={
        identifier: "name",
	items: [
		{name: "0"},
		{name: "10"},
		{name: "20"},
		{name: "30"},
		{name: "40"},
		{name: "50"},
		{name: "60"},
		{name: "70"},
	]
}

dojo.addOnLoad(function() {

        thresholdStore = new dojo.data.ItemFileReadStore({
                data: thresholdData
        });

	thresholdUnSelect = new dijit.form.FilteringSelect({
		id: "thresholdUn",
		name: "thresholdUn",
		value:"40",
		style:"width:3em",
		store: thresholdStore,
		searchAttr: "name",
		onChange: function() {
			initUndesignTr(widePos,standbyEx=1);						
		}
	},"thresholdUn");
});


function initUndesignTr(){
	if (standbyEx) {standbyShow();};
	var CapSel=document.getElementById("captureId").value;
	var RelSel= document.getElementById("relExon").innerHTML;
	var captureFormvalue = dijit.byId("capForm").getValues();
	var s_capAnalyse = captureFormvalue.capAnalyse;

	var layoutUnTr = [
//		{ field: "Row", name: "Row",get: getRow, width: '2.5'},
		{ field: 'geneId',name: 'Gene Id/Transcript',width: '15em'},
		{ field: 'gene',name: 'Gene',width: '10em'},
		{ field: 'un',name: 'Un',width: '2em', formatter:bulletGene},
		{ field: 'chr',name: 'Chr',width: '3em'},
		{ field: 'loc',name: 'Location',width: '12em'},
		{ field: 'nbseen',name: '#occ',width: '2em'},
		
	];
	var timeoutUnData ={
		identifier: "geneId",
		label: "geneId",
		items: [{geneId: "<b>Error Time Out</b>",gene:"",chr:"",loc:"",nbseen:""}]
	}

	var layoutUnGene = [
		{ field: "Row", name: "Row",get: getRow, width: '2.5'},
		{ field: 'gene',name: 'Gene',width: '10em'},
		{ field: 'un',name: 'Un',width: '2em', formatter:bulletGene},
		{ field: 'nbseen',name: '#occ',width: '2em'},
		{ field: 'geneId',name: 'Gene Id/Transcript',width: '15em'},
		
	];

	function myStyleRowUnTr(row){
		var itemR=captureUnTrGrid.getItem(row.index);
		if (itemR) {
			if (itemR.gene.toString() != "") {
				//column idx=5 ==> #occ="" when Gene
 				var nd5 = dojo.query('td[idx="5"]', row.node)[0];
				nd5.innerHTML="";
			}
		}
	}
	thresholdUnSelect.set('store',thresholdStore);
	thresholdUnSelect.startup();
	var s_thresholdUn = document.getElementById("thresholdUn").value;
	var menusObjectUnGene = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};
	menusObjectUnGene.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectUnGene.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectUnGene.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(captureUnGeneGrid);"}));
	menusObjectUnGene.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(captureUnGeneGrid);"}));
	menusObjectUnGene.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAllExon(captureUnGeneGrid);"}));
	menusObjectUnGene.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelectedExon(captureUnGeneGrid);"}));
	menusObjectUnGene.cellMenu.startup();

	if (s_capAnalyse != "exome" && s_capAnalyse != "genome" && s_capAnalyse!="rnaseq" && s_capAnalyse!="singlecell" && s_capAnalyse!="amplicon" && s_capAnalyse!="other") {
		showProgressDlg("Loading Undesigned Transcripts... ",true,"captureUnTrGridDiv","UN");
   		xhrArgsUnTr={
 			url: url_path + "/manageCapture.pl?option=captureTranscripts" +
			"&CapSel=" + CapSel +
			"&RelSel=" + RelSel +
			"&widePos=" + widePos +
			"&threshold=" + s_thresholdUn,
			handleAs: "json",
			handle: function(response,args) {
				showProgressDlg("Loading Undesigned Transcripts... ",false,"captureUnTrGridDiv","UN");
				},
              		timeout: 0, // infinite no time out
			load: function (res) {
 				captureUnTrStore = new dojox.data.AndOrWriteStore({data: res});

				var ModelUnTr = new dijit.tree.ForestStoreModel({
					store: captureUnTrStore,deferItemLoadingUntilExpand: true,
					childrenAttrs: ['children']
				});

				function fetchFailedUnTr(error, request) {
					alert("lookup failed UnTR.");
					alert(error);
				}

				function clearOldCaptureUnTrList(size, request) {
					var listCapUnTr = dojo.byId("captureUnTrGridDiv");
 					if (listCapUnTr) {
						while (listCapUnTr.firstChild) {
							listCapUnTr.removeChild(listCapUnTr.firstChild);
						}
					}
				}

				var gotCapUnTrItems = function(items,request){
					captureUnTrGrid = new dojox.grid.TreeGrid({
	        				treeModel: ModelUnTr,
	        				structure: layoutUnTr,
						selectable: true,
						defaultOpen: true,
						onStyleRow: myStyleRowUnTr,
						selectionMode: 'multiple'
					}, document.createElement('div'));
					dojo.byId("captureUnTrGridDiv").appendChild(captureUnTrGrid.domNode);
					captureUnTrGrid.startup();
					if (standbyEx) {captureUnTrGrid.store.fetch({onComplete:standbyHide});}
					if (!standbyEx){captureUnTrGrid.store.fetch()};
					captureUnTrGrid.store.close();
					dijit.byId(captureUnTrGrid)._refresh();
					dojo.connect(captureUnTrGrid, "onMouseOver", showTooltip);			
					dojo.connect(captureUnTrGrid, "onMouseOut", hideTooltip); 
				}
	
				captureUnTrStore.fetch({
					onBegin: clearOldCaptureUnTrList,
					onError: fetchFailedUnTr,
					onComplete:gotCapUnTrItems
				});
			},
			error: function(error,ioargs) {
				standbyHide();
				showProgressDlg("Loading Undesigned Transcripts... ",false,"captureUnTrGridDiv","UN");
				var CapNameError=document.getElementById("capture").value;

				if (ioargs.xhr.status=="504" || ioargs.xhr.status=="502") {
					captureUnTrStore = new dojox.data.AndOrWriteStore({data: timeoutUnData});

					var ModelUnTr = new dijit.tree.ForestStoreModel({
						store: captureUnTrStore,deferItemLoadingUntilExpand: true,
						childrenAttrs: ['children']
					});
					captureUnTrGrid = new dojox.grid.TreeGrid({
	        				treeModel: ModelUnTr,
	        				structure: layoutUnTr,
						selectable: true,
						defaultOpen: true,
						selectionMode: 'multiple',
					}, document.createElement('div'));
					dojo.byId("captureUnTrGridDiv").appendChild(captureUnTrGrid.domNode);
					captureUnTrGrid.startup();
					captureUnTrGrid.store.close();
					dojo.connect(captureUnTrGrid, "onMouseOver", showTooltip);			
					dojo.connect(captureUnTrGrid, "onMouseOut", hideTooltip); 
				} 
				return;
			}
		};
		deferredUnTr = dojo.xhrGet(xhrArgsUnTr);
// UnGene
   		xhrArgsUnGene={
 			url: url_path + "/manageCapture.pl?option=captureTranscripts" +
			"&CapSel=" + CapSel +
			"&RelSel=" + RelSel +
			"&widePos=" + widePos +
			"&threshold=" + s_thresholdUn,
			handleAs: "json",
			/*handle: function(response,args) {
				showProgressDlg("Loading Undesigned Transcripts... ",false,"captureUnTrGridDiv","UN");
				},*/
              		timeout: 0, // infinite no time out
			load: function (res) {
 				captureUnGeneStore = new dojox.data.AndOrWriteStore({data: res});
				function fetchFailedUnGene(error, request) {
					alert("lookup failed Undesigned Gene.");
					alert(error);
				}
				function clearOldCaptureUnGeneList(size, request) {
					var listCapUnGene = dojo.byId("captureUnGeneGridDiv");
 					if (listCapUnGene) {
						while (listCapUnGene.firstChild) {
							listCapUnGene.removeChild(listCapUnGene.firstChild);
						}
					}
				}
				var gotCapUnGeneItems = function(items,request){
					captureUnGeneGrid = new dojox.grid.EnhancedGrid({
						store: captureUnGeneStore,
						structure: layoutUnGene,
						rowSelector: "0.4em",
						selectionMode: 'multiple',
						rowsPerPage: 1000,  // IMPORTANT
//						noDataMessage: noMessage,
//						loadingMessage:"Loading Transcripts Exon1...",
						plugins: {
							nestedSorting: true,
							exporter: true,
							printer:true,
							menus:menusObjectUnGene
						},
					},document.createElement('div'));
					dojo.byId("captureUnGeneGridDiv").appendChild(captureUnGeneGrid.domNode);
					captureUnGeneGrid.startup();				
				}

				captureUnGeneStore.fetch({
					onBegin: clearOldCaptureUnGeneList,
					onError: fetchFailedUnGene,
					onComplete:gotCapUnGeneItems
				});
			},

        	};
		deferredUnGene = dojo.xhrGet(xhrArgsUnGene);
	}
}

function showProgressDlg(processMessage, isShow,isWhere,isType) {
	var pDialog="processDialog";
	switch (isType){
		case "BU":
			pDialog=eval(pDialog+"Bu");
 			break;		
		case "OB":
			pDialog=eval(pDialog+"Ob");
 			break;		
		case "EX":
			pDialog=eval(pDialog+"Ex");
 			break;
		case "UN":
			pDialog=eval(pDialog+"Un");
 			break;
		case "BT":
			pDialog=eval(pDialog+"Bt");
 			break;
		case "LI":
			pDialog=eval(pDialog+"Li");
 			break;
		case "NA":
			pDialog=eval(pDialog+"Na");
 			break;
		case "MO":
			pDialog=eval(pDialog+"Mo");
 			break;		
	}
	if (isShow == true) {
      		pDialog.attr("content", "<object data='icons/loading-facebook.svg' type='image/svg+xml'></object>"+ processMessage);
 		dojo.byId(isWhere).appendChild(pDialog.domNode);
        	pDialog.titleBar.style.display = 'none';
		dojo.style(pDialog.domNode,'position','fixed');
 	       	pDialog.startup();
        	pDialog.show();
    	} else {
		if (pDialog) {
			pDialog.hide();
		}
    	}
}

function expandUnTr() {
	foldingAll(true, 1);
}

function collapseUnTr() {
	foldingAll(false, 1);
}

function foldingAll(state, levels) {
        // state: boolean, expand all rows if true, collapse all rows if false
        // level: integer, how many levels will be affected
        for (var i = 0; i < levels; i++) {
                var v = captureUnTrGrid.views.views[captureUnTrGrid.views.views.length - 1];
                for (var e in v._expandos) {
                        for (var a in v._expandos[e]) {
                                var expando = (v._expandos[e])[a];
                                if (expando.open != state) {
                                        expando.setOpen(state);
                                }
                        }
                }
        }
}

function wideCapture(value) {
	widePos=value;
	initFilterExon(widePos,filterExon,standbyEx=0,exonFile=0);
}

function wideCaptureUn(value) {
	widePos=value;
	initUndesignTr(widePos,standbyEx=1);
}

function colorTrCov(value,idx,cell,row) {
	if (value == undefined) {
		value=":"
	}
	var MU=value.toString().split(":");
	if (MU[0]=="M") {
		cell.customStyles.push("background: green");	
		return "<img align='middle' src='icons/bullet_green.png'>";
	} else if (MU[0]=="U") {
		cell.customStyles.push("background: red");	
		return "<img align='middle' src='icons/bullet_red.png'>";
	} else {
		return " ";
	}
}

function warnNBTr(value,idx,cell,row) {
	if (value >= 100) {
		cell.customStyles.push("background: orange");	
	}
	return value;
}

function viewNewCapture_Cap(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	divCapBunForm = dijit.byId("divCapBun");
	divCapBunForm.reset();
	dojo.style("bt_saveCapture", {'visibility':'hidden'});
	dijit.byId("capType").attr("placeHolder","Select or Enter Type");
	dijit.byId("capMethod").attr("placeHolder","Select a Method");
	document.getElementById("TableCapFiles").style.visibility="hidden";
	document.getElementById("AccMain").style.display = "none";

	capmethodSelect.set('store',capmethStore);
	capmethodSelect.startup();
	schemasfilterSelect.set('store',schemasStore);
	schemasfilterSelect.startup();
	typefilterSelect.set('store',typeCaptureStore);
	typefilterSelect.startup();
	umifilterSelect.set('store',umiNameStore);
	umifilterSelect.startup();
	relgenecapfilterSelect.set('store',relgeneNameStore);
	dijit.byId("capRelGene").attr("placeHolder","");
	relgenecapfilterSelect.startup();

	dijit.byId('CPCapBun').set('title', "Bundles of Exon Capture: No Bundle");
	if (gridCaptureBundle) {
		var emptyCells = { items: "" };
		capturebundleStore = new dojo.data.ItemFileWriteStore({data: emptyCells});
		dojo.byId("gridCaptureBundleDiv").appendChild(gridCaptureBundle.domNode);
		gridCaptureBundle.setStore(capturebundleStore);
		gridCaptureBundle.store.close();

		bundleStore = new dojo.data.ItemFileWriteStore({data: emptyCells});
		dojo.byId("gridBundleDiv").appendChild(gridBundle.domNode);
		gridBundle.setStore(bundleStore);
		gridBundle.store.close();
	}
	viewCaptureBundle();
	activateRadioAnalyse(1);
	divCapBunForm.show();

	var domBtcapFiles=dojo.byId("domBt_capFilesNext");
	var w_toolcapFile =dijit.byId("bt_capSubmit");
	if (w_toolcapFile) {
		domBtcapFiles.removeChild(toolbar_capFiles.domNode);
		w_toolcapFile.destroyRecursive();
	}
	toolbar_capFiles = new dijit.Toolbar({style:"line-height: 2.5em;"}, document.createElement('div'));
	toolbar_capFiles.addChild(new dijit.form.Button({
			showLabel: true,
			iconClass:"nextIcon",
 			label : "Next",
			id:"bt_capSubmit",
			onclick:"save_NewCap(newCap=1);",
	}));
	domBtcapFiles.appendChild(toolbar_capFiles.domNode);
	document.getElementById("TableErrorGenome").style.visibility="hidden";
	initRadioCaptureRelCap("HG19");
}

function save_NewCap(newCap){
	var captureFormvalue = dijit.byId("capForm").getValues();
//capMethod is FilteringSelect
	var s_capMeth = document.getElementById("capMethod").value;

	var s_analRadio = captureFormvalue.analRadio;
	var s_capAnalyse = captureFormvalue.capAnalyse;
	var s_capValidation = document.getElementById("capValidation").value;

	var s_capFile = captureFormvalue.capFile;

	var s_capFilePrimer = captureFormvalue.capFilePrimer;
// Release Genome
	var r = dojo.byId("releaseCapForm");
	var rrc = "";
	for (var i = 0; i < r.elements.length; i++) {
		var elem = r.elements[i];
		if (elem.name == "button") {
			continue;
		}
		if (elem.type == "radio" && !elem.checked) {
			continue;
		}
		rrc += elem.title;
	}
	if (!rrc.length) {
		textError.setContent("Select a Genome Release Please");
		myError.show();
		return;
	}
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var regexp2 = /^[a-zA-Z0-9-._]+$/;
	var regexp3 = /^[0-9]+$/;
	var regexp4 = /^[a-zA-Z0-9]+$/;
	var check_name = captureFormvalue.capture;
	var check_capVs = captureFormvalue.capVs;
	var check_capType = captureFormvalue.capType;
	var check_capMeth = document.getElementById("capMethod").value;
	var check_capAnalyse = captureFormvalue.capAnalyse;
	var ccap = captureFormvalue.capAnalyse;
	var check_capValidation = document.getElementById("capValidation").value;
	if ((check_name.search(regexp) == -1) || (check_capVs.search(regexp) == -1) ||
		(check_capType.search(regexp) == -1)){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
    	}
	if (check_capAnalyse.search(regexp4) == -1){		
		textError.setContent("Only Alpha-Numeric");
		myError.show();
		return;
    	}
	if (check_capVs.search(regexp3) == -1){		
		textError.setContent("Version: Only numeric permitted");
		myError.show();
		return;
    	}
	if (captureFormvalue.capRelGene.length ==0 && (ccap !="genome" && ccap !="exome" && ccap !="rnaseq" && ccap != "singlecell" && ccap != "amplicon" && ccap != "other")){		
			textError.setContent("Enter a Release Gene");
			myError.show();
			return 1;
	}
	if (captureFormvalue.capture.length ==0){		
			textError.setContent("Enter a capture name");
			myError.show();
			return;
	}
	if (captureFormvalue.capVs.length ==0){		
		textError.setContent("Enter a capture version number");
		myError.show();
		return;
	}
	if (captureFormvalue.capDes.length ==0){		
		textError.setContent("Enter a capture description");
		myError.show();
		return;
	}

	if (check_capMeth.length ==0){		
			textError.setContent("Select a Method");
			myError.show();
			return;
	}
	if (typeof(check_capValidation)=="undefined"){
		check_capValidation="";
	}

	var url_insert;
	if(newCap) {
		url_insert = url_path + "/manageCapture.pl?option=Newcapture"+
		"&capture="+captureFormvalue.capture +
		"&capVs="+captureFormvalue.capVs +
		"&capDes="+captureFormvalue.capDes +
		"&capType="+captureFormvalue.capType +
		"&capUMI="+captureFormvalue.capUMI +
		"&capMeth="+check_capMeth +
		"&golden_path="+ rrc +
		"&capRelGene="+ captureFormvalue.capRelGene +
		"&capAnalyse="+captureFormvalue.capAnalyse +
		"&capValidation="+check_capValidation +
		"&capTypeVal="+captureFormvalue.analRadio+
		"&capFile=" +
		"&capFilePrimers=";
	}
	else {
		captureFormvalue.capFile=document.getElementById("capFile").value;
		captureFormvalue.capFilePrimer=document.getElementById("capFilePrimer").value;
		url_insert = url_path + "/manageCapture.pl?option=upCapture" +
						"&capId=" + document.getElementById("captureId").value +
						"&capture=" + captureFormvalue.capture +
						"&capVs=" + captureFormvalue.capVs +
						"&capDes=" + captureFormvalue.capDes +
						"&capType=" + captureFormvalue.capType +
						"&capUMI=" + captureFormvalue.capUMI +
						"&capMeth=" + check_capMeth +
						"&golden_path="+ rrc +
						"&capRelGene="+ captureFormvalue.capRelGene +
						"&capAnalyse=" + captureFormvalue.capAnalyse +
						"&capValidation=" + check_capValidation +
						"&capTypeVal="+captureFormvalue.analRadio+
						"&capFile=" + captureFormvalue.capFile +
						"&capFilePrimers=" + captureFormvalue.capFilePrimer;
	}
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				if(newCap) {
					document.getElementById("AccMain").style.display = "none";
					dijit.byId("myMessageSubmit").set("disabled",true);
					url_lastCaptureId = url_path+"/manageData.pl?option=lastCapture";
					var lastCaptureIdStore = new dojo.data.ItemFileReadStore({url: url_lastCaptureId});
					refreshCaptureList(); 
					var gotList = function(items, request){
						var lastCaptureIdnext;
						dojo.forEach(items, function(i){
						lastCaptureIdnext=lastCaptureIdStore.getValue( i, 'capture_id' );
						});
						gridCap.store.fetch({onComplete: function (items){
						dojo.forEach(items, function(item, index){
							if (item.captureId.toString()==lastCaptureIdnext.toString()){
								gridCap.selection.clear();
								gridCap.selection.addToSelection(index);
								editCapture(item);
								gridCap.selection.clear();
								var domBtcapFiles=dojo.byId("domBt_capFilesNext");
								var w_toolcapFile =dijit.byId("bt_capSubmit");
								if (w_toolcapFile) {
								domBtcapFiles.removeChild(toolbar_capFiles.domNode);
									w_toolcapFile.destroyRecursive();
								}
							}
						});
						}
						});
						dijit.byId("myMessageSubmit").set("disabled",false);
					} 
					var gotError = function(error, request){
  						alert("The request to the store failed. " +  error);
					}
					lastCaptureIdStore.fetch({
  						onComplete: gotList,
  						onError: gotError
					});
				} else {
					refreshCaptureList();
					dojo.byId('capUMI').value =captureFormvalue.capUMI;
					document.getElementById("TableErrorGenome").style.visibility="hidden";
					dijit.byId("AccMain").domNode.style.display = 'block';
					dijit.byId("AccMain").resize();
				}
			}
		}
	);
}

function viewCaptureBundle() {
	var mainTab=dijit.byId("AccMain");
	var subTab=dijit.byId("CPCapBun");
	mainTab.selectChild(subTab);
}

function viewAddBundle() {
	var mainTab=dijit.byId("AccMain");
	var subTab=dijit.byId("CPnewBun");
	mainTab.selectChild(subTab);
}

function paramBtNewBundle() {
	dojo.style(dijit.byId("bt_bunSubmit").domNode,{'visibility':'visible'});	
	dojo.style(dijit.byId("bt_upBun").domNode,{'visibility':'hidden'});	
	dojo.style(dijit.byId("bt_upTrans").domNode,{'visibility':'hidden'});	
	dojo.style(dijit.byId("bt_delTrans").domNode,{'visibility':'hidden'});	
}

function paramBtUpdateBundle() {
	dojo.style(dijit.byId("bt_bunSubmit").domNode,{'visibility':'hidden'});	
	dojo.style(dijit.byId("bt_upBun").domNode,{'visibility':'visible'});	
	dojo.style(dijit.byId("bt_upTrans").domNode,{'visibility':'visible'});	
	dojo.style(dijit.byId("bt_delTrans").domNode,{'visibility':'visible'});	
}

var initNewBun=0;
function viewNewBundle() {
//	checkPassword(okfunction);
//	if(! logged) {
//		return
//	}
	dojo.style('trsColForm', 'display', 'none');
	initNewBun=1;
	paramBtNewBundle();

	var blab = dojo.byId("labBundle");
	blab.innerHTML= "NEW BUNDLE";
	var sbid = dojo.byId("bundleId");
	sbid.innerHTML= "";
	var BunSel=document.getElementById("bundleId").innerHTML;

	relgenefilterSelect.set('store',relgeneNameStore);
	dijit.byId("bunRelGene").attr("placeHolder","");
	relgenefilterSelect.startup();

	viewNewTranscript();
	divBundleDB.set('title',"<b>New Bundle & New Transcript</b>");
	divBundleDB.show();
}

function editBundle(item) {
//	checkPassword(okfunction);
//	if(! logged) {
//		return
//	}
	dojo.style('trsColForm', 'display', 'none');
	paramBtUpdateBundle();
	var blab = dojo.byId("labBundle");
	blab.innerHTML= "BUNDLE";
	var sbid = dojo.byId("bundleId");
	sbid.innerHTML= item.bundleId;
        dojo.byId('bundle').value =item.bunName;
	dojo.byId('bunDes').value =item.bunDes;
	dojo.byId('bunVs').value =item.bunVs;
	dojo.byId('meshid').value =item.meshid;
 	relgenefilterSelect.set('store',relgeneNameStore);
	dijit.byId("bunRelGene").attr("placeHolder","");
	relgenefilterSelect.startup();
	dojo.byId('bunRelGene').value =item.relGene.toString();
	relgenefilterSelect.set('value',item.relGene.toString());
	viewNewTranscript();
	var libBun = dojo.byId("LibBundleDB");
	libBun.innerHTML= "<b style='font-size:125%;'>Bundle & New Transcript</b>";
	divBundleDB.show();
}

function editBundleTranscript() {
	var item = gridCaptureBundle.selection.getSelected();
	if(item.length == 1) {
		dojo.forEach(item, function(selectedItem) {
			item=selectedItem;
		});
	} else {
		textError.setContent("Select One bundle only Please...");
		myError.show();
		divBundleDB.reset();
		divBundleDB.hide();
		gridCaptureBundle.selection.clear();
		return;
	}
	initNewBun=0;
	editBundle(item);
}

function ctrlBundleForm(bunFormvalue) {
	//test no blank
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var regexp2 = /^[a-zA-Z0-9]+$/;
	var regexp3 = /^[0-9\.]+$/;
	var alphanum=/^[a-zA-Z0-9-_ \.\>]+$/;
	var check_name = bunFormvalue.bundle;
	var check_bunVs = bunFormvalue.bunVs;
	var check_meshid = bunFormvalue.meshid;
	var check_bunDes = bunFormvalue.bunDes;
	var check_bunRel = bunFormvalue.bunRelGene;

	if (bunFormvalue.bundle.length ==0){		
			textError.setContent("Enter a bundle name");
			myError.show();
			return 1;
	}
	if (bunFormvalue.bunRelGene.length ==0){		
			textError.setContent("Enter a Release Gene");
			myError.show();
			return 1;
	}

	if (bunFormvalue.bunVs.length ==0){		
		textError.setContent("Enter a bundle version number");
		myError.show();
		return 1;
	}
	if (bunFormvalue.bunDes.length ==0){		
		textError.setContent("Enter a bundle description");
		myError.show();
		return 1;
	}
	if (check_bunDes.search(alphanum) == -1) {
		textError.setContent("no accent permitted");
		myError.show();
		return 1;
	}
	if ((check_bunVs.search(regexp3) == -1) || (check_bunRel.search(regexp3) == -1)){		
			onError=1;
		textError.setContent("Version: Only numeric permitted");
		myError.show();
		return 1;
    	}
	if ((check_name.search(regexp) == -1) || (check_bunVs.search(regexp) == -1)) {		
			onError=1;
		textError.setContent("No spaces permitted");
		myError.show();
		return 1;
    	}
	if (bunFormvalue.meshid.length >0){
		if (check_meshid.search(regexp2) == -1){
			textError.setContent("Meshid:No spaces permitted");
			myError.show();
			return 1;
		}
	}
}

function newBundleAndCapture(upload,initNewBun) {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var s_capId= document.getElementById("SbundleCapId").innerHTML;
	if(! s_capId) {
		textError.setContent("Error : For Uploading Large Transcript File, an Exon Capture must be attributed to the Bundle");
		myError.show();
		return;
	}
	var bunFormvalue = dijit.byId("bunForm").getValues();
	var onError=ctrlBundleForm(bunFormvalue);
	if (onError) {
		return;
	}
	var getLabBundle= document.getElementById("labBundle").innerHTML;
	initNewBun=1;
	if (getLabBundle == "BUNDLE") {initNewBun=0;}

	switch (initNewBun){
	case 0:
		loadParamTrans();
		div_uploadFile.show();
		break;
	case 1:
		var url_insert = url_path + "/manageData.pl?option=Newbundle2Capture" + 
			"&bundle="+bunFormvalue.bundle +
			"&bunVs="+bunFormvalue.bunVs +
			"&bunDes="+bunFormvalue.bunDes +
			"&meshid="+bunFormvalue.meshid.toUpperCase() +
			"&capid=" + s_capId +
			"&bunRG=" + bunFormvalue.bunRelGene;
		var res=sendData_v2(url_insert);
		res.addCallback(function(response) {
			if(response.status=="OK"){
				refreshBundleList();
				url_lastBundleId = url_path+"/manageData.pl?option=lastBundle";
				var lastBundleIdStore = new dojo.data.ItemFileReadStore({url: url_lastBundleId});
				var gotListCapBun = function(items, request){
					gridCaptureBundle.selection.clear();
					var lastBundleIdnext;
					dojo.forEach(items, function(i){
						lastBundleIdnext=lastBundleIdStore.getValue( i, 'bundle_id' );
					});
					gridCaptureBundle.store.fetch({onComplete: function (items){
						dojo.forEach(items, function(item, index){
							var sItem = gridCaptureBundle.getItem(index);
							if (sItem.bundleId.toString()==lastBundleIdnext.toString()){
								gridCaptureBundle.selection.clear();
								var s_capbun=dojo.byId('bundleId');
								s_capbun.innerHTML=sItem.bundleId.toString();
								gridCaptureBundle.selection.addToSelection(index);
								if(upload) {loadParamTrans();}
								var trsColFormvalue = dijit.byId("trsColForm").getValues();
								if (trsColFormvalue.Rtrans != "") {
									addTranscript();
								}
							}
							});
						}
					});
				}
				var gotError = function(error, request){
  					alert("The request to the store failed. " +  error);
				}
				lastBundleIdStore.fetch({
  					onComplete: gotListCapBun,
  					onError: gotError
				});
				if(upload) {div_uploadFile.show();}
				var blab = dojo.byId("labBundle");
				blab.innerHTML= "BUNDLE";
				paramBtUpdateBundle();
				refreshCaptureBundleTransList(save=1);
			}
		}
		);
	break;
	}
}

function loadParamTrans() {
	dojo.byId('param_dir').value =param_dir;
	dojo.byId('param_dir').innerHTML =param_dir;

	var fid= document.getElementById("bundleId").innerHTML;
	dojo.byId('param_capid').value =fid;
	dojo.byId('param_capid').innerHTML =fid;

	dojo.byId('opt').value ="insertTranscript";
	
	dojo.byId('param_type').value ="trs_file";
	param_type= "trs_file";

	var transFormvalue = dijit.byId("transForm").getValues();
	var checkModeTrans=transFormvalue.dbox1;
	var checkModeBTrans=transFormvalue.dbox2;
	var Tmod=0;
	var BTmod=0;
	if (checkModeTrans=="on") {Tmod=1};
	if (checkModeBTrans=="on") {BTmod=1};
	if (! Tmod && ! BTmod) {
		Tmod=1;
		BTmod=0;
	}
	dojo.byId('param_trans').value =Tmod+","+BTmod;
}

function upBundle() {
	var bunFormvalue = dijit.byId("bunForm").getValues();
	var onError=ctrlBundleForm(bunFormvalue);
	if (onError) {
		return;
	}
	selBun = document.getElementById("bundleId").innerHTML;

	var url_insert = url_path + "/manageData.pl?option=upBundle" + 
		"&BunSel=" + selBun +
		"&bundle=" + bunFormvalue.bundle +
		"&bunVs=" + bunFormvalue.bunVs +
		"&bunDes=" + bunFormvalue.bunDes +
		"&meshid=" + bunFormvalue.meshid.toUpperCase() +
		"&bunRG=" + bunFormvalue.bunRelGene;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshBundleList();
			}
		}
	);
}

function removeCaptureBundle() {
	var CapSel=document.getElementById("captureId").value;
	var item = gridCaptureBundle.selection.getSelected();
	BunGroups = new Array();
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridCaptureBundle.store.getAttributes(selectedItem), function(attribute) {
					var Bunvalue = gridCaptureBundle.store.getValues(selectedItem, attribute);
					if (attribute == "bundleId" ) {
						BunGroups.push(Bunvalue.toString());
					} 
				});
			} 
		});
	} else {
		textError.setContent("Please Select one Bundle");
		myError.show();
		return;
	}

	var url_insert = url_path + "/manageData.pl?option=RemCapturebundle" +
						"&BunSel=" + BunGroups +
						"&CapSel=" + CapSel;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshBundleList();
			}
		}
	);
}

//javascript test string begins with
String.prototype.startsWith = function (string) {
    return(this.indexOf(string) === 0);
};

var crCap;
function initRadioCaptureRelCap(rel) {
	var p_rel=rel;
	if(p_rel.indexOf("HG19") !== -1) {p_rel="HG19"}
	if(p_rel.indexOf("HG38") !== -1) {p_rel="HG38"}
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearOldCapList(size, request) {
		var listRel = dojo.byId("releaseRadioCap");
		if (listRel) {
			while (listRel.firstChild) {
				listRel.removeChild(listRel.firstChild);
			}
		}
	}
	function gotReleaseCap(items, request) {
		var listRel = dojo.byId("releaseRadioCap");
		if (listRel) {
			var i;
			var defSpanCap = dojo.doc.createElement('div');
			var cpt=1;
			for (i = 0; i < items.length; i++) {
				if(cpt==0) {cpt=1};
				var p_name=items[i].relName.toString();
				if (p_name.startsWith('HG19') && p_name != "HG19") {continue};
				if (p_name.startsWith('HG38') && p_name != "HG38") {continue};
				var item = items[i];
				var iname = 'crDB';
				var cbname = items[i].relName;
				var id = iname + i;
				var title =cbname;
				var crCap=dijit.byId(id);
				if(typeof(crCap)!=="undefined") {
					crCap.destroy();
				}
//				crCap = new dijit.form.RadioButton({
				crCap = new dojox.mobile.RadioButton({
					id: id,
					name: iname,
					title:cbname,
				});

				if (p_rel!="" && item.relName==p_rel){
					crCap.set('checked', true);
					var hre = dojo.byId("relExon");
					hre.innerHTML=item.relName;
				} 
				var defLabel = dojo.doc.createElement('label');
				// write next line when multiple 3
				if((cpt%3 == 0) && (cpt >0)) {
					cbname=cbname + "<br>";
				}
				cpt++;
				defLabel.innerHTML = cbname ;
				defSpanCap.appendChild(defLabel);
				dojo.place(crCap.domNode, dojo.byId("releaseRadioCap"), "last");
				dojo.place(defLabel, dojo.byId("releaseRadioCap"), "last");
			}
			if (p_rel==""){
				document.getElementById("AccMain").style.display = "none";
				document.getElementById("TableErrorGenome").style.visibility="visible";
			}
		}
	}
	relStore.fetch({
//	relRefStore.fetch({
		onBegin: clearOldCapList,
		onComplete: gotReleaseCap,
		onError: fetchFailed,
		queryOptions: {
			deep: true
		}
	});
}

var param_type;
function cap_uploadFile() {
	var FileA= document.getElementById("FileName_Cap").innerHTML;
	var type_load=FileA.toLowerCase().split(" ")[0];
	dojo.byId('param_dir').value =param_dir;
	dojo.byId('param_dir').innerHTML =param_dir;
	var fid= document.getElementById("capId").innerHTML;
	dojo.byId('param_capid').value =fid;
	dojo.byId('param_capid').innerHTML =fid;

	dojo.byId('opt').value ="insert";
	dojo.byId('param_type').value =type_load;
	param_type= type_load;

	div_uploadFile.show();
}

function cap_pasteFile() {
	var Filename = dijit.byId("FileNameCap").get("value");
	var lcol = dijit.byId("Rcapcol");
	param_dir= document.getElementById("enddirCap").innerHTML;
	var fid= document.getElementById("capId").innerHTML;
	
	var Filename_type= document.getElementById("FileName_Cap").innerHTML;
	var type_file=Filename_type.toLowerCase().split(" ")[0];

	if(Rcapcol.value.length>0) {
		Rcapcol.value=Rcapcol.value + "\n";
		var LinesCap=Rcapcol.value.replace(/^$/g,"").split("\n");
		LinesCap=Rcapcol.value.replace(/^#.*/g,"").split("\n");

		for(var i=0; i<LinesCap.length-1; i++) {
			LinesCap[i]=LinesCap[i].replace(/\s+/gm,"<tab>");
			LinesCap[i]=LinesCap[i].replace(/\+/gm,"<plus>");
		}

		LinesCap=LinesCap.filter(function(val) {return val !== ''});
		var prog_url=url_path + "/upload_file.pl?";
		var options="opt=insertPaste" +
			"&type=" + type_file +
			"&capId=" + fid +
			"&file_name=" + Filename +
			"&Param_dir=" + param_dir +
			"&Lines=" + LinesCap;
		var res=sendDataPost(prog_url,options);
		res.addCallback(
			function(response) {
				if(response.status=="OK"){
					refreshCaptureList();
					if (type_file == "capture") {
						dojo.byId('capFile').value =Filename;
						dojo.byId('capFile').innerHTML =Filename;
						document.getElementById("AccMain").style.display = "block";
						dijit.byId("AccMain").domNode.style.display = 'block';
						dijit.byId("AccMain").resize();
						divCaptureFile.hide();
						viewAddBundle();
					}
					if (type_file == "primer") {
						dojo.byId('capFilePrimer').value =Filename;
						dojo.byId('capFilePrimer').innerHTML =Filename;
						divCaptureFile.hide();
						viewAddBundle();
					}
				}
			}
		);
	}
}

function refreshCaptureList(stand) {
 	if (stand) {standbyShow();};
   	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=captureName",
            handleAs: "json",
            load: function (res) {
 		capStore = new dojo.store.Memory({data: res});
           }
        });

   	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=captureMethName",
            handleAs: "json",
            load: function (res) {
 		capmethNameStore = new dojo.store.Memory({data: res});
           }
        });
	QuerydependCapSlider();
	gridCap=dijit.byId("grid_Cap");
	gridCap.setStore(captureStore);
	gridCap.store.close();
	//gridCap.startup();
	if (stand) {gridCap.store.fetch({onComplete:standbyHide});};
	if (typeof(stand) == "undefined" ) {gridCap.store.fetch();};
	dijit.byId(gridCap)._refresh();

	captureGrid.setStore(captureStore);
	captureGrid.store.close();
	dijit.byId(captureGrid)._refresh();
};

/*########################################################################
##################### Bundle Transcript : New DATA New Version
##########################################################################*/
	layoutBundle = [
		{ field: "Row", name: "Row",get: getRow, width: '2.5'},
		{ field: "flagCap",name: "Cap",width: '2', formatter:bullet},
		{ field: "flagTr",name: "Tr",width: '2', formatter:bullet},
		{ field: "bundleId",name: "ID",width: '3'},
		{ field: "bunName",name: "Bundle Name",width: '15'},
		{ field: "bunVs",name: "Vs",width: '2'},
		{ field: "bunDes", name: "Bundle Description", width: '18'},
		{ field: "meshid", name: "Mesh", width: '8'},
		{ field: "capName", name: "Capture", width: '16'},
		{ field: "capMeth", name: "Method", width: '6'},
		{ field: "capValidation", name: "Validation", width: '10'},
		{ field: "nbTr", name: "#Tr", width: '4'},
		{ field: "flagGn",name: "Gn",width: '2', formatter:bullet},
		{ field: "cDate", name: "Date", datatype:"date", width: '7'},
	];

function addBundle2capture() {
	var CapSel=document.getElementById("captureId").value;
	var item = gridBundle.selection.getSelected();
	BunGroups = new Array();
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridBundle.store.getAttributes(selectedItem), function(attribute) {
					var Bunvalue = gridBundle.store.getValues(selectedItem, attribute);
					if (attribute == "bundleId" ) {
						BunGroups.push(Bunvalue.toString());
					}
				});
			} 
		});
	} else {
		textError.setContent("Please Select at least one Bundle");
		myError.show();
		return;
	}
	var url_insert = url_path + "/manageData.pl?option=AddCapturebundle" +
				"&BunSel="  + BunGroups +
				"&captureid=" + CapSel ;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshBundleList();
				viewCaptureBundle();
			}
		}
	);
}

function refreshBundleList() {
	var CapSel=document.getElementById("captureId").value;
	bundleStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=bundleCap"+"&exclude=1"+"&CapSel="+CapSel
	});
	gridBundle.setStore(bundleStore);
	gridBundle.store.close();

	capturebundleStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=bundleCap"+"&exclude=0"+"&CapSel="+CapSel
	});
	gridCaptureBundle.setStore(capturebundleStore);
	gridCaptureBundle.store.close();

	QuerydependCapSlider();
	gridCap.store.close();
};

/*########################################################################
##################### Bundle Transcript : New DATA
##########################################################################*/

function viewNewTranscript() {
	var BunSel=document.getElementById("bundleId").innerHTML;
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}
	function clearOldTranscriptList(size, request) {
                    var listTra = dojo.byId("gridBundleTransDiv");
                    if (listTra) {
                        while (listTra.firstChild) {
                           listTra.removeChild(listTra.firstChild);
                        }
                    }
	}

	var bundleTransStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=bundleTranscripts"+"&BunSel="+BunSel,
		clearOnClose: true,
	});
	
	transmissionStore = new dojo.data.ItemFileReadStore({
		data: { identifier: 'value', label: 'name',
		items: [{value: "AD",name: "Autosomal Dominant"},
		{value: "AR",name: "Autosomal Recessive"},
		{value: "XL",name: "X-Linked"},
		{value: "",name: ""}
			]
		}
	});

	var layoutBundleTrans = [
		{ field: "Row", name: "Row",get: getRow, width: '2'},
		{ field: "transcriptId",name: "ID",width: '4'},
		{ field: "flagGn",name: "Gn",width: '2', formatter:bullet},
		{ field: "ensemblId",name: "Ensembl Id",width: '12'},
		{ field: "gene",name: "Gene",width: '12'},
		{ field: "transmission", name: "Trans", width: '4', editable: true,
			styles: 'text-align: center;', type:'dojox.grid.cells._Widget',
			widgetClass:'dijit.form.FilteringSelect',
			widgetProps:{store:transmissionStore,required:false}
		},
		{ field: "buntransmission", name: "B-Trans", width: '4', editable: true,
			styles: 'text-align: center;', type:'dojox.grid.cells._Widget',
			widgetClass:'dijit.form.FilteringSelect',
			widgetProps:{store:transmissionStore,required:false}
		},
	];
	var menusObjectT = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};
	menusObjectT.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectT.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectT.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridBundleTrans);"}));
	menusObjectT.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridBundleTrans);"}));
	menusObjectT.cellMenu.startup();


	menusObjectT.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectT.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectT.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridBundleTrans);"}));
	menusObjectT.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(gridBundleTrans);"}));
	menusObjectT.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridBundleTrans);"}));
	menusObjectT.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(gridBundleTrans);"}));
	menusObjectT.selectedRegionMenu.startup();

	showProgressDlg("Loading Bundle Transcripts... ",true,"gridBundleTransDiv","BT");
	bundleTransStore.fetch({
		onBegin: clearOldTranscriptList,
		onError: fetchFailed,
		onComplete: function(items,request){
			gridBundleTrans = new dojox.grid.EnhancedGrid({
				store: bundleTransStore,
				structure: layoutBundleTrans,
				selectionMode:"Multiple",
				rowsPerPage: 1000,  // IMPORTANT
				rowSelector: "0.4em",
				plugins: {
					filter: {
						closeFilterbarButton: true,
						ruleCount: 5,
						itemsName: "name"
					},
					indirectSelection: {
						headerSelector:true, 
						width: "20px",
						styles: "text-align: center;",
					},
					nestedSorting: true,
					dnd: true,
					exporter: true,
					printer:true,
					selector:true,
					menus:menusObjectT
				}
			},document.createElement('div'));
			var NBflagGn = 0;
			dojo.forEach(items, function(i){
				NBflagGn += bundleTransStore.getValue(i,"flagGn");
			});
			var light = dojo.byId("lightGene");
			if (NBflagGn) {
				light.innerHTML=
		"<img styles='white-space:nowrap;margin:0;padding:0;' align='top' src='icons/ledred.png'>";
			} else {
				light.innerHTML=
		"<img styles='white-space:nowrap;margin:0;padding:0;' align='top' src='icons/ledgreen.png'>";
			}

			dojo.byId("gridBundleTransDiv").appendChild(gridBundleTrans.domNode);
			gridBundleTrans.setStore(bundleTransStore);
			gridBundleTrans.startup();
//			gridBundleTrans.store.fetch({onComplete:standbyHide});
			gridBundleTrans.store.fetch({});
			showProgressDlg("Loading Bundle Transcripts... ",false,"gridBundleTransDiv","BT");
			dojo.connect(gridBundleTrans, "onMouseOver", showTooltip);
			dojo.connect(gridBundleTrans, "onMouseOut", hideTooltip); 
		}
	});
}

/*###################### Add/del Transcript to Bundle  ##################*/

function trs_uploadFile() {
	newBundleAndCapture(upload=1,initNewBun);
}

function addTranscript(){
/*	checkPassword(okfunction);
	if(! logged) {
		return
	}*/
	var bunFormvalue = dijit.byId("bunForm").getValues();
	selBun = document.getElementById("bundleId").innerHTML;
	var transFormvalue = dijit.byId("transForm").getValues();

	var checkModeTrans=transFormvalue.dbox1;
	var checkModeBTrans=transFormvalue.dbox2;

	var Tmod=0;
	var BTmod=0;
	if (checkModeTrans=="on") {Tmod=1};
	if (checkModeBTrans=="on") {BTmod=1};
	if (! Tmod && ! BTmod) {
		Tmod=1;
		BTmod=0;
	}
	var trsColFormvalue = dijit.byId("trsColForm").getValues();
	var LinesTranscript=trsColFormvalue.Rtrans.split("\n");
	var TranscriptGroups=[];
	var TransmissionGroups=[];
	if (trsColFormvalue.Rtrans == "") {
		textError.setContent("Transcripts List is empty !");
		myError.show();
		return;
	}
	LinesTranscript=LinesTranscript.filter(element=>element);// ajouter
	var chainalphanum= /^[a-zA-Z0-9-_]*$/;
	for(var i=0; i<LinesTranscript.length; i++) {
		var fieldTranscript=LinesTranscript[i].split(new RegExp("\\s+"));
		if (fieldTranscript.toString() == ""){
			console.log("no good");
			break;
		}
		for(var j=0; j<fieldTranscript.length; j++) {
			switch (j){
				case 0:
					fieldTranscript[j]=fieldTranscript[j].replace(/ /g,"");
					if (fieldTranscript[j].search(chainalphanum) == -1){		
		textError.setContent("<b>Error</b>: Transcript Id must be alplanumeric. " + fieldTranscript[j] + ":<b>Not Ok</b>, Transcripts not Added");
						myError.show();
						return;
    					}
					TranscriptGroups.push(fieldTranscript[j].replace(/ /g,""));
					if (fieldTranscript.length==1) {TransmissionGroups.push("")};
					break;
				case 1:TransmissionGroups.push(fieldTranscript[j].replace(/ /g,""));break;
			}
		}
	}

	var prog_url=url_path + "/manageData.pl?";
	var options="option=addTranscripts" +
				"&relgene="+ bunFormvalue.bunRelGene +
				"&Tmod="+ Tmod +
				"&BTmod="+ BTmod +
				"&BunSel="  + selBun +
				"&transcript=" + TranscriptGroups +
				"&transmission=" + TransmissionGroups;

	var res=sendDataPost(prog_url,options);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				trsColForm.reset();        
				refreshBundleTransList(save=1);
				refreshBundleList();
				chgTrsCol();
			}
		}
	);
}

/*###################### del Bundle Transcript #########################*/

function delTranscript(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	selBun = document.getElementById("bundleId").innerHTML;
	var transFormvalue = dijit.byId("transForm").getValues();
	var itemBT= gridBundleTrans.selection.getSelected();
	var TranscriptIdGroups = new Array(); 
	if (itemBT.length) {
		dojo.forEach(itemBT, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridBundleTrans.store.getAttributes(selectedItem), function(attribute) {
					var BTvalue = gridBundleTrans.store.getValues(selectedItem, attribute);
					if (attribute == "transcriptId" ) {
						TranscriptIdGroups.push(BTvalue);
					} 
				});
			} 
		});
	} else {
		textError.setContent("Please select one or more Transcripts !");
		myError.show();
		return;
	}

	var url_insert = url_path + "/manageData.pl?option=delTranscripts" +
						"&BunSel=" + selBun +
						"&transcriptId=" + TranscriptIdGroups;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				gridBundleTrans.selection.clear();
				refreshBundleTransList();
			}
		}
	);
}

/*###################### up Bundle Transcript #########################*/

function upTranscript(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	selBun = document.getElementById("bundleId").innerHTML;
	var itemBT= gridBundleTrans.selection.getSelected();
	var TranscriptIdGroups = new Array(); 
	var TransmissionGroups = new Array(); 
	var bTransmissionGroups = new Array(); 
	if (itemBT.length) {
		dojo.forEach(itemBT, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridBundleTrans.store.getAttributes(selectedItem), function(attribute) {
					var BTvalue = gridBundleTrans.store.getValues(selectedItem, attribute);
					if (attribute == "transcriptId" ) {
						TranscriptIdGroups.push(BTvalue);
					} else if (attribute == "transmission" ) {
						TransmissionGroups.push(BTvalue);
					} else if (attribute == "buntransmission" ) {
						bTransmissionGroups.push(BTvalue);
					} 
				});
			} 
		});
	} else {
		textError.setContent("Please select one or more Transcripts !");
		myError.show();
		return;
	} 
	var url_insert = url_path + "/manageData.pl?option=upTranscripts" +
						"&BunSel=" + selBun +
						"&transcriptId=" + TranscriptIdGroups +
						"&transmission=" + TransmissionGroups +
						"&btransmission="+ bTransmissionGroups;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshBundleTransList(save=1);
			}
		}
	);
}

function refreshBundleTransList(save) {
	var CapSel=document.getElementById("captureId").value;
	var BunSel=document.getElementById("bundleId").innerHTML;

	bundleTransStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=bundleTranscripts"+"&BunSel="+ BunSel,
	});

	if (typeof(save) != "undefined" ) {gridBundleTrans.store.save();}
	gridBundleTrans.setStore(bundleTransStore);
	gridBundleTrans.store.close();
	dijit.byId(gridBundleTrans)._refresh();
};


function refreshCaptureBundleTransList(save) {
	var CapSel=document.getElementById("captureId").value;
	var BunSel=document.getElementById("bundleId").innerHTML;

	bundleTransStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=bundleTranscripts"+"&BunSel="+ BunSel,
	});

	if (typeof(save) != "undefined" ) {gridBundleTrans.store.save();}
	gridBundleTrans.setStore(bundleTransStore);
	gridBundleTrans.store.close();
	dijit.byId(gridBundleTrans)._refresh();

	capturebundleStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=bundleCap"+"&exclude=0"+"&CapSel="+CapSel
	});
	gridCaptureBundle.setStore(capturebundleStore);
	gridCaptureBundle.store.close();
	dijit.byId(gridCaptureBundle)._refresh();
	QuerydependCapSlider();
	gridCap.store.close();
	dijit.byId(gridCap)._refresh();
};

/*########################################################################
##################### Init : New DATA
##########################################################################*/
var LineAll="cpMacT||cpProfT||cpPrepT||cpTechT||cpPersT||cpPipeT||cpUmiT||cpPltT|| cpMSeqT||cpMAlnT||cpMCallT||cpRelT||cpCapT";
const initBlock = `
cpMacT="";
cpProfT="";
cpPrepT="";
cpTechT="";
cpPersT="";
cpPipeT="";
cpUmiT="";
cpPltT="";
cpMSeqT=""
cpMAlnT="";
cpMCallT="";
cpRelT="";
cpCapT="";
`;

function removeItemFromLine(line, itemToRemove) {
  return line
    .split('||')
    .map(s => s.trim())
    .filter(item => item !== itemToRemove)
    .join('||');
}

function removeVariableInitializations(codeBlock, varsToRemove) {
  const varsSet = Array.isArray(varsToRemove) ? new Set(varsToRemove) : new Set([varsToRemove]);
  return codeBlock
    .split('\n')                                   // Sépare les lignes
    .filter(line => {
      const match = line.trim().match(/^([a-zA-Z_][\w]*)\s*=/);  // Match variable name
      return !match || !varsSet.has(match[1]);     // Garde la ligne si la variable n?est pas à retirer
    })
    .join('\n');
}

/*########################################################################
##################### Plateform : New DATA
##########################################################################*/
var plateformDGrid;
var cpPltT;
var cpPltC;

function viewNewPlateform(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpPltT");
	if(eval(cpPltT)) {
		clearSub(cpPltT,cpPltC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpPltT");
	eval(cleanedBlock);
	cpPltT=buildLayoutTop("Plt","Plateform",cpPltT,"default");
	cpPltC=buildLayoutCenter("Plt",cpPltC,plateformDGrid,plateformStore,layoutPlateform,"multiple");
}

function viewNewPlateform_Plt(){
	divPlateformDB.show();
}

function extractDef_Plt(){
	yearSelect_Plt.set('store',yearStore);
	yearSelect_Plt.startup();
	var checkedPlt=0;
	dijit.byId("btn_Plt").set('checked', false);
	dijit.byId('yearSelect_Plt').set('value',"");
	divExtractPlateformDB.show();
}

function upExtractDefPlt(Sub) {
	var sl_year=dijit.byId("yearSelect_Plt").get('value');	
	var bt_ext=dijit.byId("btn_Plt");
	if(bt_ext.checked==false) {checkedPlt=0} else {checkedPlt=1};
	if (sl_year.length ==0){		
			textError.setContent("Enter a Year");
			myError.show();
			return;
	}

	var url_insert = url_path + "/manageData.pl?option=upExtractDef" + 				
				"&year=" + sl_year +
				"&table=" + Sub +
				"&def_value=" + checkedPlt;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshPlateformList();
				divExtractPlateformDB.hide();
			}
		}
	);
};

function newPlateform() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var pltFormvalue = dijit.byId("pltForm").getValues();
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
	var res=sendData_v2(url_insert);
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
	plateformStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=plateform"
	});
	plateformDGrid=dijit.byId("grid_Plt");
	
	plateformDGrid.setStore(plateformStore);
	plateformDGrid.store.close();
	plateformDGrid._refresh();

	plateformGrid.setStore(plateformStore);
	groups_FTable.setStore(plateformStore);
};

/*########################################################################
##################### Machine : New DATA
##########################################################################*/
var machineDGrid;
var cpMacT;
var cpMacC;
function viewNewMachine(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpMacT");
	if(eval(cpMacT)) {
		clearSub(cpMacT,cpMacC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpMacT");
	eval(cleanedBlock);
	cpMacT=buildLayoutTop("Mac","Machine",cpMacT,"default");
	cpMacC=buildLayoutCenter("Mac",cpMacC,machineDGrid,macStore,layoutMachine,"multiple");
}

function viewNewMachine_Mac(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	divMachineDB.show();
}

function extractDef_Mac(){
	yearSelect_Mac.set('store',yearStore);
	yearSelect_Mac.startup();
	var checkedMac=0;
	dijit.byId("btn_Mac").set('checked', false);
	dijit.byId('yearSelect_Mac').set('value',"");
	divExtractMachineDB.show();
}

function upExtractDefMac(Sub) {
	var sl_year=dijit.byId("yearSelect_Mac").get('value');	
	var bt_ext=dijit.byId("btn_Mac");
	if(bt_ext.checked==false) {checkedMac=0} else {checkedMac=1};
	if (sl_year.length ==0){		
			textError.setContent("Enter a Year");
			myError.show();
			return;
	}

	var url_insert = url_path + "/manageData.pl?option=upExtractDef" + 				
				"&year=" + sl_year +
				"&table=" + Sub +
				"&def_value=" + checkedMac;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshMachineList();
				divExtractMachineDB.hide();
			}
		}
	);
};

function newMachine() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var macFormvalue = dijit.byId("macForm").getValues();
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
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divMachineDB').reset();
				dijit.byId('divMachineDB').hide();
				refreshMachineList();
			}
		}
	);
};

function refreshMachineList() {
	macStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=machine"
	});
	machineDGrid=dijit.byId("grid_Mac");
	machineDGrid.setStore(macStore);
	machineDGrid.store.close();
	machineDGrid._refresh();
	
	machineGrid.setStore(macStore);

   	dojo.xhrGet({
		url: url_path + "/manageData.pl?option=machineName",
		handleAs: "json",
		load: function (res) {
 		machineStore = new dojo.store.Memory({data: res});
		}
        });
};

/*########################################################################
##################### Sequencing Method : New DATA
##########################################################################*/
var MethSeqDGrid;
var cpMSeqT;
var cpMSeqC;
function viewNewMethSeq(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpMSeqT");
	if(eval(cpMSeqT)) {
		clearSub(cpMSeqT,cpMSeqC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpMSeqT");
	eval(cleanedBlock);
	cpMSeqT=buildLayoutTop("MSeq","Sequencing Method",cpMSeqT,"default");
	cpMSeqC=buildLayoutCenter("MSeq",cpMSeqC,MethSeqDGrid,methSeqStore,layoutMethSeq,"multiple");
}

function viewNewSequencing_Method_MSeq(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	divMethodSeqDB.show();
}

function extractDef_MSeq(){
	yearSelect_MSeq.set('store',yearStore);
	yearSelect_MSeq.startup();
	var checkedMSeq=0;
	dijit.byId("btn_MSeq").set('checked', false);
	dijit.byId('yearSelect_MSeq').set('value',"");
	divExtractMethSeqDB.show();
}

function upExtractDefMSeq(Sub) {
	var sl_year=dijit.byId("yearSelect_MSeq").get('value');	
	var bt_ext=dijit.byId("btn_MSeq");
	if(bt_ext.checked==false) {checkedMSeq=0} else {checkedMSeq=1};
	if (sl_year.length ==0){		
			textError.setContent("Enter a Year");
			myError.show();
			return;
	}

	var url_insert = url_path + "/manageData.pl?option=upExtractDef" + 				
				"&year=" + sl_year +
				"&table=" + Sub +
				"&def_value=" + checkedMSeq;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshSeqMethodList();
				divExtractMethSeqDB.hide();
			}
		}
	);
};

function newSeqMethod() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var methSeqFormvalue = dijit.byId("methSeqForm").getValues();
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
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divMethodSeqDB').reset();
				dijit.byId('divMethodSeqDB').hide();
				refreshSeqMethodList();
			}
		}
	);
};

function refreshSeqMethodList() {
	methSeqStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=methodSeq"
	});
	MethSeqDGrid=dijit.byId("grid_MSeq");
	MethSeqDGrid.setStore(methSeqStore);
	MethSeqDGrid.store.close();
	MethSeqDGrid._refresh();

	mseqGrid.setStore(methSeqStore);

    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=methSeqName",
            handleAs: "json",
            load: function (res) {
 		methSeqNameStore = new dojo.store.Memory({data: res});
           }
        });
};

/*########################################################################
##################### Alignment Method : New DATA
##########################################################################*/
var AlnDGrid;
var cpMAlnT;
var cpMAlnC;

function viewNewMethAlign(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpMAlnT");
	if(eval(cpMAlnT)) {
		clearSub(cpMAlnT,cpMAlnC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpMAlnT");
	eval(cleanedBlock);
	cpMAlnT=buildLayoutTop("MAln","Alignment Method",cpMAlnT,"default","extractDef");
	cpMAlnC=buildLayoutCenter("MAln",cpMAlnC,AlnDGrid,AlnStore,layoutMeth,"multiple");
}

function viewNewAlignment_Method_MAln(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	divMethodAlnDB.show();
}

function extractDef_MAln(){
	yearSelect_MAln.set('store',yearStore);
	yearSelect_MAln.startup();
	var checkedMAln=0;
	dijit.byId("btn_MAln").set('checked', false);
	dijit.byId('yearSelect_MAln').set('value',"");
	divExtractMethodsAlnDB.show();
}

function upExtractDefMAln(Sub) {
	var sl_year=dijit.byId("yearSelect_MAln").get('value');	
	var bt_ext=dijit.byId("btn_MAln");
	if(bt_ext.checked==false) {checkedMAln=0} else {checkedMAln=1};
	if (sl_year.length ==0){		
			textError.setContent("Enter a Year");
			myError.show();
			return;
	}

	var url_insert = url_path + "/manageData.pl?option=upExtractDef" + 				
				"&year=" + sl_year +
				"&table=" + Sub +
				"&def_value=" + checkedMAln;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshAlnMethodList();
				divExtractMethodsAlnDB.hide();
			}
		}
	);
};

function newAlignMethod() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var methFormvalue = dijit.byId("methAlnForm").getValues();
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var check = methFormvalue.methodAln;
	if ((check.search(regexp) == -1)){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
	}

	if (methFormvalue.methodAln.length ==0){		
			textError.setContent("Enter a method name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=Newalignment"+"&method="+methFormvalue.methodAln;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divMethodAlnDB').reset();
				dijit.byId('divMethodAlnDB').hide();
				refreshAlnMethodList();
			}
		}
	);
};

function refreshAlnMethodList() {
	AlnStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=methodAln"
	});
	AlnDGrid=dijit.byId("grid_MAln");
	AlnDGrid.setStore(AlnStore);
	AlnDGrid.store.close();
	AlnDGrid._refresh();

	alnRGrid.setStore(AlnStore);
	groups_ATable.setStore(AlnStore);
};

/*########################################################################
##################### Calling Method : New DATA
##########################################################################*/
var CallDGrid;
var cpMCallT;
var cpMCallC;
var toolbar_MethCallTop;
var toolbar_MCall;

function viewNewMethCall(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpMCallT");
	if(eval(cpMCallT)) {
		clearSub(cpMCallT,cpMCallC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpMCallT");
	eval(cleanedBlock);
	cpMCallT=buildLayoutTop("MCall","Calling Method",cpMCallT,"default","extractDef");
	cpMCallC=buildLayoutCenter("MCall",cpMCallC,CallDGrid,CallStore,layoutMeth,"multiple");
}

function viewNewCalling_Method_MCall(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	divMethodCallDB.show();
}

function extractDef_MCall(){
	yearSelect_MCall.set('store',yearStore);
	yearSelect_MCall.startup();
	var checkedMCall=0;
	dijit.byId("btn_MCall").set('checked', false);
	dijit.byId('yearSelect_MCall').set('value',"");
	divExtractMethodsCallDB.show();
}

function upExtractDefMCall(Sub) {
	var sl_year=dijit.byId("yearSelect_MCall").get('value');	
	var bt_ext=dijit.byId("btn_MCall");
	if(bt_ext.checked==false) {checkedMCall=0} else {checkedMCall=1};
	if (sl_year.length ==0){		
			textError.setContent("Enter a Year");
			myError.show();
			return;
	}

	var url_insert = url_path + "/manageData.pl?option=upExtractDef" + 				
				"&year=" + sl_year +
				"&table=" + Sub +
				"&def_value=" + checkedMCall;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshCallMethodList();
				divExtractMethodsCallDB.hide();
			}
		}
	);
};

function newCallMethod() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var methFormvalue = dijit.byId("methCallForm").getValues();
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var check = methFormvalue.methodCall;
	if ((check.search(regexp) == -1)){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
	}

	if (methFormvalue.methodCall.length ==0){		
			textError.setContent("Enter a method name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=Newcalling"+"&method="+methFormvalue.methodCall;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divMethodCallDB').reset();
				dijit.byId('divMethodCallDB').hide();
				refreshCallMethodList();
			}
		}
	);
};

function refreshCallMethodList() {
	CallStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=methodCall"
	});
	CallDGrid=dijit.byId("grid_MCall");
	CallDGrid.setStore(CallStore);
	CallDGrid.store.close();
	CallDGrid._refresh();

	callRGrid.setStore(CallStore);
	groups_MTable.setStore(CallStore);
};

/*########################################################################
##################### UMI : New DATA
##########################################################################*/
var cpUmiT;
var cpUmiC;
var umiDGrid;
function viewNewUMI(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpUmiT");
	if(eval(cpUmiT)) {
		clearSub(cpUmiT,cpUmiC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpUmiT");
	eval(cleanedBlock);
	cpUmiT=buildLayoutTop("Umi","UMI",cpUmiT);
	cpUmiC=buildLayoutCenter("Umi",cpUmiC,umiDGrid,umiStore,layoutUMI,"single");
}

function viewNewUMI_Umi(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	divUmiDB.show();
}

function newUmi() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var umiFormvalue = dijit.byId("umiForm").getValues();
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var regexp2 = /^[A-Z0-9-_;\*]+$/;
	var check_umi = umiFormvalue.umi;
	var check_umimask = umiFormvalue.umimask;
	if ((check_umi.search(regexp) == -1)|| (check_umimask.search(regexp2) == -1)){		
		textError.setContent("No space or Lower case permitted ");
		myError.show();
		return;
	}

	if (umiFormvalue.umi.length ==0){		
			textError.setContent("Enter a Umi name");
			myError.show();
			return;
	}
	if (umiFormvalue.umimask.length ==0){		
		textError.setContent("Enter a Umi mask");
		myError.show();
		return;
	}
// problem with ; to be replaced because of perl-cgi
	var reg =new RegExp(";","g");
	umiFormvalue.umimask =umiFormvalue.umimask.replace(reg,'!');
	var url_insert = url_path + "/manageData.pl?option=newUmi"+"&umi="+umiFormvalue.umi+"&mask="+umiFormvalue.umimask.toString();
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divUmiDB').reset();
				dijit.byId('divUmiDB').hide();
				refreshUMIList();
			}
		}
	);
};

function refreshUMIList() {
	umiStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=umi"
	});
	umiDGrid=dijit.byId("grid_Umi");
	umiDGrid.setStore(umiStore);
	umiDGrid.store.close();
	umiDGrid._refresh();
   	dojo.xhrGet({
		url: url_path + "/manageData.pl?option=umiName",
		handleAs: "json",
		load: function (res) {
 		umiNameStore = new dojo.store.Memory({data: res});
		}
        });
};


/*########################################################################
##################### Pipeline Profile : New DATA
##########################################################################*/
var cpPipeT;
var cpPipeC;
var pipelineDGrid;
function viewNewPIPE(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpPipeT");
	if(eval(cpPipeT)) {
		clearSub(cpPipeT,cpPipeC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpPipeT");
	eval(cleanedBlock);
	cpPipeT=buildLayoutTop("Pipe","Pipeline Methods",cpPipeT);
//	cpPipeC=buildLayoutCenter("Pipeline",cpPipeC,pipelineDGrid,pipelineStore,layoutPIPE,"none");## Fait Planter??
	cpPipeC=buildLayoutCenter("Pipeline",cpPipeC,pipelineDGrid,pipelineStore,layoutPIPE,"single");
}

function hidePipe(){
	pipelineDGrid.selection.clear();
	methodGrid.selection.clear();
}

var pipeMethGrid;
function viewNewPipeline_Methods_Pipe() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	pipelineDGrid=dijit.byId("grid_Pipeline");
	pipelineDGrid.setStore(pipelineStore);

	var itemPipe = pipelineDGrid.selection.getSelected();
	var selPipeId;
	var selPipeName;
	var selPipeContent;
	var boxname = dijit.byId("pipe");
	var boxcontent = dijit.byId("pcontent");
	dojo.style("NewPipe", {'visibility':'visible'});
	dojo.style("SavePipe", {'visibility':'hidden'});
	boxname.attr("value","");
	boxcontent.attr("value","");
	var id_grid=dijit.byId("idgrid_pipe");
 	if (id_grid) {
		id_grid.destroyRecursive();
	}
	if (itemPipe.length) {
	//Grid of Method's Pipeline
		dojo.style("NewPipe", {'visibility':'hidden'});
		dojo.style("SavePipe", {'visibility':'visible'});
		dojo.forEach(itemPipe, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(pipelineDGrid.store.getAttributes(selectedItem), function(attribute) {
					var Pipevalue = pipelineDGrid.store.getValues(selectedItem, attribute);
					if (attribute == "pipelineId" ) {
						selPipeId = Pipevalue;
					}
					if (attribute == "Name" ) {
						selPipeName = Pipevalue;
					}
					if (attribute == "content" ) {
						selPipeContent = Pipevalue;
					}
				});
			} 			
		});
		boxname.attr("value",selPipeName);
		boxcontent.attr("value",selPipeContent);
		valcontent=selPipeContent+" ";
		var selpipe=selPipeContent.toString().split(" ");
		for(var i=0; i<selpipe.length;i++ ) { 
			addToMethSelection(selpipe[i]);
		}
	}
	divPipeDB.show();	
}

function addToMethSelection(methname) {
	methodGrid.store.fetch({onComplete: function (items){
			dojo.forEach(methodGrid._by_idx, function(item, index){
				var sItem = methodGrid.getItem(index);
				if (sItem.methName.toString() == methname.toString()) {
					methodGrid.selection.addToSelection(index);
				}
			});
		}
	});
}

function savePipeline() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var itemPipe = pipelineDGrid.selection.getSelected();
	var selPipeId;
	if (itemPipe.length) {
		dojo.forEach(itemPipe, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(pipelineDGrid.store.getAttributes(selectedItem), function(attribute) {
					var Pipevalue = pipelineDGrid.store.getValues(selectedItem, attribute);
					if (attribute == "pipelineId" ) {
						selPipeId = Pipevalue;;
					}
				});
			} 
		});
	}
	var pipeFormvalue = dijit.byId("pipeForm").getValues();
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var check_pipe = pipeFormvalue.pipe;
	if (check_pipe.search(regexp) == -1){		
		textError.setContent("Pipeline Name: No space or Lower case permitted ");
		myError.show();
		return;
	}

	if (pipeFormvalue.pipe.length ==0){		
			textError.setContent("Enter a Pipeline name");
			myError.show();
			return;
	}

	var item = methodGrid.selection.getSelected();
	var MethIdGroups = new Array();
	var MethNameGroups = new Array();
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(methodGrid.store.getAttributes(selectedItem), function(attribute) {
					var Methvalue = methodGrid.store.getValues(selectedItem, attribute);
					if (attribute == "methodId" ) {
						MethIdGroups.push(Methvalue);
					} else if (attribute == "methName") {
						MethNameGroups.push(Methvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Select Multiple Methods Please...");
		myError.show();
		return;
	}
	var content="";
	var boxcontent = dijit.byId("pcontent"); 
	for(var i=0; i<MethNameGroups.length; i++) {
		content+=MethNameGroups[i]+ " ";
	}
	var url_insert = url_path + "/manageData.pl?option=upPipeline" + 
							"&pipeline=" + pipeFormvalue.pipe +
							"&content=" + content.trim() +
							"&pipeId=" + selPipeId;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divPipeDB').reset();
				dijit.byId('divPipeDB').hide();
				refreshPipelineList();
			}
		}
	);
}

function newPipeline() {
	checkPassword(okfunction);
	var item = methodGrid.selection.getSelected();
	if(! logged) {
		return
	}
	var pipeFormvalue = dijit.byId("pipeForm").getValues();
	var regexp = /^[a-zA-Z0-9-_]+$/;
	var check_pipe = pipeFormvalue.pipe;
	if (check_pipe.search(regexp) == -1){		
		textError.setContent("Pipeline Name: No space or Lower case permitted ");
		myError.show();
		return;
	}

	if (pipeFormvalue.pipe.length ==0){		
			textError.setContent("Enter a Pipeline name");
			myError.show();
			return;
	}

	var item = methodGrid.selection.getSelected();
	var MethIdGroups = new Array();
	var MethNameGroups = new Array();
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(methodGrid.store.getAttributes(selectedItem), function(attribute) {
					var Methvalue = methodGrid.store.getValues(selectedItem, attribute);
					if (attribute == "methodId" ) {
						MethIdGroups.push(Methvalue);
					} else if (attribute == "methName") {
						MethNameGroups.push(Methvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Select Multiple Methods Please...");
		myError.show();
		return;
	}
	var content="";
	var boxcontent = dijit.byId("pcontent"); 
	for(var i=0; i<MethNameGroups.length; i++) {
		content+=MethNameGroups[i]+ " ";
	}
	var url_insert = url_path + "/manageData.pl?option=newPipeline"+"&pipeline="+pipeFormvalue.pipe+"&content="+content.trim();
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divPipeDB').reset();
				dijit.byId('divPipeDB').hide();
				refreshPipelineList();
			}
		}
	);
};

function refreshPipelineList() {
	pipelineStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=pipelineName"
	});
	pipelineDGrid=dijit.byId("grid_Pipeline");
	pipelineDGrid.setStore(pipelineStore);
	pipelineDGrid.store.close();
	pipelineDGrid._refresh();
   	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=pipelineName",
            handleAs: "json",
            load: function (res) {
 		pipelineNameStore = new dojo.store.Memory({data: res});
           }
        });
};

/*########################################################################
##################### PERSPECTIVE : New DATA
##########################################################################*/
var cpPersT;
var cpPersC;
function viewNewPERS(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpPersT");
	if(eval(cpPersT)) {
		clearSub(cpPersT,cpPersC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpPersT");
	eval(cleanedBlock);
	cpPersT=buildLayoutTop("Pers","Perspective",cpPersT);
	cpPersC=buildLayoutCenter("Pers",cpPersC,perspectiveGrid,perspectiveStore,layoutPERS,"single");
}

function viewNewPerspective_Pers(){
	divPerspectiveDB.show();
}

function newPerspective() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var persFormvalue = dijit.byId("persForm").getValues();
	var regexp = /^[a-zA-Z0-9-_+]+$/;
	var check = persFormvalue.perspective;
	if (check.search(regexp) == -1){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
	}

	if (persFormvalue.perspective.length ==0){		
			textError.setContent("Enter a Perspective name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=Newperspective"+"&perspective="+persFormvalue.perspective;
	console.log(url_insert);
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divPerspectiveDB').reset();
				dijit.byId('divPerspectiveDB').hide();
				refreshPerspectiveList();
			}
		}
	);
};

function refreshPerspectiveList() {
	perspectiveStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=perspective"
	});
	perspectiveGrid=dijit.byId("grid_Pers");
	perspectiveGrid.setStore(perspectiveStore);
	persGrid.setStore(perspectiveStore);
};


/*########################################################################
##################### TECHNOLOGY : New DATA
##########################################################################*/
var cpTechT;
var cpTechC;
function viewNewTECH(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpTechT");
	if(eval(cpTechT)) {
		clearSub(cpTechT,cpTechC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpTechT");
	eval(cleanedBlock);
	cpTechT=buildLayoutTop("Tech","Technology",cpTechT);
	cpTechC=buildLayoutCenter("Tech",cpTechC,technologyGrid,technologyStore,layoutTECH,"single");
}

function viewNewTechnology_Tech(){
	divTechnologyDB.show();
}

function newTechnology() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var techFormvalue = dijit.byId("techForm").getValues();
	var regexp = /^[a-zA-Z0-9-_+]+$/;
	var check = techFormvalue.technology;
	if (check.search(regexp) == -1){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
	}

	if (techFormvalue.technology.length ==0){		
			textError.setContent("Enter a Technology name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=Newtechnology"+"&technology="+techFormvalue.technology;
	console.log(url_insert);
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divTechnologyDB').reset();
				dijit.byId('divTechnologyDB').hide();
				refreshTechnologyList();
			}
		}
	);
};

function refreshTechnologyList() {
	technologyStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=technology"
	});
	technologyGrid=dijit.byId("grid_Tech");
	technologyGrid.setStore(technologyStore);
	techGrid.setStore(technologyStore);
};

/*########################################################################
##################### PREPARATION : New DATA
##########################################################################*/
var cpPrepT;
var cpPrepC;
function viewNewPREP(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpPrepT");
	if(eval(cpPrepT)) {
		clearSub(cpPrepT,cpPrepC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpPrepT");
	eval(cleanedBlock);
	cpPrepT=buildLayoutTop("Prep","Preparation",cpPrepT);
	cpPrepC=buildLayoutCenter("Prep",cpPrepC,preparationGrid,preparationStore,layoutPREP,"single");
}

function viewNewPreparation_Prep(){
	divPreparationDB.show();
}

function newPreparation() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var prepFormvalue = dijit.byId("prepForm").getValues();
	var regexp = /^[a-zA-Z0-9-_+]+$/;
	var check = prepFormvalue.preparation;
	if (check.search(regexp) == -1){		
		textError.setContent("No spaces permitted");
		myError.show();
		return;
	}

	if (prepFormvalue.preparation.length ==0){		
			textError.setContent("Enter a Preparation name");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=Newpreparation"+"&preparation="+prepFormvalue.preparation;
	console.log(url_insert);
//./manageData.pl option=Newperspective perspective=ezeze-tetete
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divPreparationDB').reset();
				dijit.byId('divPreparationDB').hide();
				refreshPreparationList();
			}
		}
	);
};

function refreshPreparationList() {
	preparationStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=preparation"
	});
	preparationGrid=dijit.byId("grid_Prep");
	preparationGrid.setStore(preparationStore);
	prepGrid.setStore(preparationStore);
};

/*########################################################################
##################### PROFILE : New DATA
##########################################################################*/

dojo.addOnLoad(function() {
/*	var sp_btsubmit_addprof=dojo.byId("bt_submit_addprof");
	var buttonformsubmit_addprof= new dijit.form.Button({
		showLabel: true,
		id:"bt_submitProf",
		type:"submit",
		label:"Submit",
		value:"Submit",
		iconClass:"validIcon",
		style:"color:white",
		onClick:function(){
			newProfile();
		}			
	});
	buttonformsubmit_addprof.startup();
	buttonformsubmit_addprof.placeAt(sp_btsubmit_addprof);
 */
	perspectiveStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=perspective"
	});
	technologyStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=technology"
	});
	preparationStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=preparation"
	});

	function fetchFailedPers(error, request) {
		alert("lookup failed persGridDiv");
		alert(error);
	}

	function clearOldPersList(size, request) {
                    var listPers = dojo.byId("persGridDiv");
                    if (listPers) {
                        while (listPers.firstChild) {
                           listPers.removeChild(listPers.firstChild);
                        }
                    }
	}
	perspectiveStore.fetch({
		onBegin: clearOldPersList,
		onError: fetchFailedPers,
		onComplete: function(items){
			persGrid = new dojox.grid.EnhancedGrid({
 				store: perspectiveStore,
  				structure: layoutPERS,
				selectionMode:"single",
				selectable: true,
				rowSelector: "0.4em",
				plugins: {
 					indirectSelection: {
						name: "Sel",
						width: "30px",
						styles: "text-align: center;",
					},
					nestedSorting: true,
					dnd: true,
					selector:true,
				}
			}, document.createElement('div'));
			dojo.byId("persGridDiv").appendChild(persGrid.domNode);
//			persGrid.startup();
		}
	});

	function fetchFailedTech(error, request) {
		alert("lookup failed techGridDiv");
		alert(error);
	}

	function clearOldTechList(size, request) {
                    var listTech = dojo.byId("techGridDiv");
                    if (listTech) {
                        while (listTech.firstChild) {
                           listTech.removeChild(listTech.firstChild);
                        }
                    }
	}

	technologyStore.fetch({
		onBegin: clearOldTechList,
		onError: fetchFailedTech,
		onComplete: function(items){
			techGrid = new dojox.grid.EnhancedGrid({
 				store: technologyStore,
  				structure: layoutTECH,
				selectionMode:"single",
				selectable: true,
				rowSelector: "0.4em",
				plugins: {
 					indirectSelection: {
						name: "Sel",
						width: "30px",
						styles: "text-align: center;",
					},
					nestedSorting: true,
					dnd: true,
					selector:true,
				}
			}, document.createElement('div'));
			dojo.byId("techGridDiv").appendChild(techGrid.domNode);
			//techGrid.startup();
		}
	});

	function fetchFailedPrep(error, request) {
		alert("lookup failed prepGridDiv");
		alert(error);
	}

	function clearOldPrepList(size, request) {
                    var listPrep = dojo.byId("prepGridDiv");
                    if (listPrep) {
                        while (listPrep.firstChild) {
                           listPrep.removeChild(listPrep.firstChild);
                        }
                    }
	}
	preparationStore.fetch({
		onBegin: clearOldPrepList,
		onError: fetchFailedPrep,
		onComplete: function(items){
			prepGrid = new dojox.grid.EnhancedGrid({
 				store: preparationStore,
  				structure: layoutPREP,
				selectionMode:"single",
				selectable: true,
				rowSelector: "0.4em",
				plugins: {
 					indirectSelection: {
						name: "Sel",
						width: "30px",
						styles: "text-align: center;",
					},
					nestedSorting: true,
					dnd: true,
					selector:true,
				}
			}, document.createElement('div'));
			dojo.byId("prepGridDiv").appendChild(prepGrid.domNode);
			//prepGrid.startup();
		}
	});
});

var cpProfT;
var cpProfC;
//var profiledataGrid;
function viewNewPROF(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpProfT");
	if(eval(cpProfT)) {
		clearSub(cpProfT,cpProfC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpProfT");
	eval(cleanedBlock);
	cpProfT=buildLayoutTop("Prof","Profile",cpProfT);
	cpProfC=buildLayoutCenter("Prof",cpProfC,profiledataGrid,profiledataStore,layoutPROF,"single");
}

function viewNewProfile_Prof(){
	dojo.style("bt_submitProf", {'visibility':'visible'});
	dojo.style("bt_saveProf", {'visibility':'hidden'});
	dijit.byId("bt_submitProf").set("disabled",true);

	profiledataGrid=dijit.byId("grid_Prof");
	profiledataGrid.setStore(profiledataStore);
	var valPers="";
	var valTech="";
	var valPrep="";
	var val3prof="";
	var h_3prf = dojo.byId("sp_3prof");
	var itemProf = profiledataGrid.selection.getSelected();
	var SelProfId=0;
	var SelProfName="";
	if (itemProf.length) {
		console.log("if item");
		console.log(itemProf.profId);
		console.log(itemProf.profName);
		dojo.style("bt_submitProf", {'visibility':'hidden'});
		dojo.style("bt_saveProf", {'visibility':'visible'});
		dojo.forEach(itemProf, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(profiledataGrid.store.getAttributes(selectedItem), function(attribute) {
					var Profvalue = profiledataGrid.store.getValues(selectedItem, attribute);
					if (attribute == "profId" ) {
						selProfId = Profvalue;
					}
					if (attribute == "profName" ) {
						SelProfName = Profvalue;
					}
				});
			} 			
		});
		val3prof=SelProfName.toString();
		var t_val=val3prof.split(" ");
		valPers=t_val[0];
		valTech=t_val[1];
		valPrep=t_val[2];		
		h_3prf.innerHTML= val3prof;

	} else {
		h_3prf.innerHTML= val3prof;
	}

	persGrid.setStore(perspectiveStore);
	persGrid.startup();
	techGrid.setStore(technologyStore);
	techGrid.startup();
	prepGrid.setStore(preparationStore);
	prepGrid.startup();
	persGrid.selection.clear();
	techGrid.selection.clear();
	prepGrid.selection.clear();

	dojo.connect(persGrid, 'onRowClick', function(e) {
		var rowIndex = e.rowIndex;
		var itemP= persGrid.getItem(rowIndex);
		valPers=itemP.persName.toString();
		val3prof=valPers+" "+valTech+" "+valPrep;
		var h_3prf = dojo.byId("sp_3prof");
		h_3prf.innerHTML= val3prof;
		activate_btsumit(val3prof);

	});
	dojo.connect(techGrid, 'onRowClick', function(e) {
		var rowIndex = e.rowIndex;
		var itemP= techGrid.getItem(rowIndex);
		valTech=itemP.techName.toString();
		val3prof=valPers+" "+valTech+" "+valPrep;
		var h_3prf = dojo.byId("sp_3prof");
		h_3prf.innerHTML= val3prof;
		activate_btsumit(val3prof);

	});
	dojo.connect(prepGrid, 'onRowClick', function(e) {
		var rowIndex = e.rowIndex;
		var itemP= prepGrid.getItem(rowIndex);
		valPrep=itemP.prepName.toString();
		val3prof=valPers+" "+valTech+" "+valPrep;
		var h_3prf = dojo.byId("sp_3prof");
		h_3prf.innerHTML= val3prof;
		activate_btsumit(val3prof);
	});
	divProfileDB.show();
}


function activate_btsumit(val) {
	dijit.byId("bt_submitProf").set("disabled",true);
	var t_val=val.split(" ");
	t_val=t_val.filter(element=>element);// ajouter
	if (t_val.length==3) {dijit.byId("bt_submitProf").set("disabled",false);}
};

function saveProfile() {
	var itemProf = profiledataGrid.selection.getSelected();
	var SelProfId=0;
	if (itemProf.length) {
		console.log("if item");
		console.log(itemProf.profId);
		console.log(itemProf.profName);
		dojo.style("bt_submitProf", {'visibility':'hidden'});
		dojo.style("bt_saveProf", {'visibility':'visible'});
		dojo.forEach(itemProf, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(profiledataGrid.store.getAttributes(selectedItem), function(attribute) {
					var Profvalue = profiledataGrid.store.getValues(selectedItem, attribute);
					if (attribute == "profId" ) {
						SelProfId = Profvalue;
					}

				});
			} 			
		});
	}
	var profileName= document.getElementById("sp_3prof").innerHTML;
	if (SelProfId) {
		var url_insert = url_path + "/manageData.pl?option=NewUpdateprofile"+"&SelprofId="+SelProfId+"&profileName="+profileName;
		console.log(url_insert);
		var res=sendData_v2(url_insert);
		res.addCallback(
			function(response) {
				if(response.status=="OK"){
					dijit.byId('divProfileDB').reset();
					dijit.byId('divProfileDB').hide();
					refreshProfiledataList();
				}
			}
		);
	}
};

function newProfile() {
	//checkPassword(okfunction);
	//if(! logged) {
	//	return
	//}
	var itemPers = persGrid.selection.getSelected();
	var itemTech = techGrid.selection.getSelected();
	var itemPrep = prepGrid.selection.getSelected();
	var profileName= document.getElementById("sp_3prof").innerHTML;
	if (itemPers.length && itemTech.length && itemPrep.length) {
		var url_insert = url_path + "/manageData.pl?option=NewUpdateprofile"+"&profileName="+profileName;
		console.log(url_insert);
		var res=sendData_v2(url_insert);
		res.addCallback(
			function(response) {
				if(response.status=="OK"){
					dijit.byId('divProfileDB').reset();
					dijit.byId('divProfileDB').hide();
					refreshProfiledataList();
				}
			}
		);
		
	} else {
		textError.setContent("Please Select Perspective, Technology and Preparation...");
		myError.show();
		return;
	}
};

function refreshProfiledataList() {
	profiledataStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=profile"
	});

	profiledataGrid=dijit.byId("grid_Prof");
	profiledataGrid.setStore(profiledataStore);

// profileMenuStore && profileStore
     	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=profileName",
            handleAs: "json",
            load: function (res) {
 		profileStore = new dojo.store.Memory({data: res});
           }
        });

	profilefilterSelect.set('store',profileStore);

	profileMenuStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=profileName",
		clearOnClose: true,
	});
	var sp_btDropDownProfile_Run=dojo.byId("dropDownRunProfile_bt");
	var sp_btDropDownProfile_Project=dojo.byId("dropDownProjectProfile_bt");

	var bt_buttonDDM=dijit.byId("id_buttonDDM");
	if (bt_buttonDDM) {
		sp_btDropDownProfile_Run.removeChild(bt_buttonDDM.domNode);
		bt_buttonDDM.destroyRecursive();
	}

	var bt_buttonDDM2=dijit.byId("id_buttonDDM2");
	if (bt_buttonDDM2) {
		sp_btDropDownProfile_Project.removeChild(bt_buttonDDM2.domNode);
		bt_buttonDDM2.destroyRecursive();
	}

        var menuDDM = new dijit.DropDownMenu({ style: "display: none;"});
        var buttonDDM = new dijit.form.DropDownButton({
		label: "Profile",
		name: "Profile",
		id:"id_buttonDDM",
		dropDown: menuDDM,
		iconClass:"profileIcon",
        });

        var buttonDDM2 = new dijit.form.DropDownButton({
		label: "Profile",
		name: "Profile",
		id:"id_buttonDDM2",
		dropDown: menuDDM,
		iconClass:"profileIcon",
        });

	var gotProfileList = function(items, request){
		dojo.forEach(items, function(i){
			var nameP= profileMenuStore.getValue(i,"name");
			menuDDM.addChild(new dijit.MenuItem({
					label: nameP,
					onClick: function(){ 
							updateProfile(nameP);
					}
        			})
			);
		});
	}
	var gotProfileError = function(error, request){
  		alert("Failed Profile Menu Store " +  error);
	}
	profileMenuStore.fetch({
  		onComplete: gotProfileList,
  		onError: gotProfileError
	});

	sp_btDropDownProfile_Run.appendChild(buttonDDM.domNode);
	buttonDDM.startup();
	buttonDDM.placeAt(sp_btDropDownProfile_Run);

	sp_btDropDownProfile_Project.appendChild(buttonDDM2.domNode);
	buttonDDM2.startup();
	buttonDDM2.placeAt(sp_btDropDownProfile_Project);
};

/*########################################################################
##################### Release : New DATA
##########################################################################*/
var releaseDGrid;
var cpRelT;
var cpRelC;

function viewUpdateRelease(){	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpRelT");
	if(eval(cpRelT)) {
		clearSub(cpRelT,cpRelC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpRelT");
	eval(cleanedBlock);
	cpRelT=buildLayoutTop("Rel","Release",cpRelT,"default");
	cpRelC=buildLayoutCenter("Rel",cpRelC,releaseDGrid,relStore,layoutRelease,"multiple");
}

function extractDef_Rel(){
	yearSelect_Rel.set('store',yearStore);
	yearSelect_Rel.startup();
	var checkedRel=0;
	dijit.byId("btn_Rel").set('checked', false);
	dijit.byId('yearSelect_Rel').set('value',"");
	divExtractReleaseDB.show();
}

function upExtractDefRel(Sub) {
	var sl_year=dijit.byId("yearSelect_Rel").get('value');	
	var bt_ext=dijit.byId("btn_Rel");
	if(bt_ext.checked==false) {checkedRel=0} else {checkedRel=1};
	if (sl_year.length ==0){		
			textError.setContent("Enter a Year");
			myError.show();
			return;
	}

	var url_insert = url_path + "/manageData.pl?option=upExtractDef" + 				
				"&year=" + sl_year +
				"&table=" + Sub +
				"&def_value=" + checkedRel;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshReleaseList();
				divExtractReleaseDB.hide();
			}
		}
	);
};

function refreshReleaseList() {
	relStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=release"
	});
	releaseDGrid=dijit.byId("grid_Rel");
	releaseDGrid.setStore(relStore);
	releaseDGrid.store.close();
	releaseDGrid._refresh();
};

/*########################################################################
##################### Capture : New DATA
##########################################################################*/
var capDataDGrid;
var cpCapT;
var cpCapC;

function viewUpdateCapture(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var LineAll_mod = removeItemFromLine(LineAll, "cpCapT");
	if(eval(cpCapT)) {
		clearSub(cpCapT,cpCapC);
	} else if (eval(LineAll_mod)) {
		var l_line=LineAll_mod.split("||");
		for(var i=0; i<l_line.length; i++) {
			if (eval(l_line[i])) {
				clearSub(eval(l_line[i]),eval(l_line[i].slice(0, -1)+"C"));
			}
		}
	} else {
		BC =  new dijit.layout.BorderContainer({
		}, "appSub");
	}
	const cleanedBlock = removeVariableInitializations(initBlock, "cpCapT");
	eval(cleanedBlock);
	cpCapT=buildLayoutTop("Capd","Capture",cpCapT,"default","extractDef");
	cpCapC=buildLayoutCenter("Capd",cpCapC,capDataDGrid,captureStore,layoutCapData,"multiple");
}

function hideCap(){
	yearStore.query({}).forEach(function(e,index){
		if (e.year=="All") {yearStore.remove(e.year)};
	});
}

var filterCapGrid;
function extractDef_Capd(){
	yearStore.put({value:"All", year:"All"});
	yearSelect_Capd.set('store',yearStore);
	yearSelect_Capd.startup();
	analyseSelect.set('store',analyseDataStore);
	analyseSelect.startup();
	var checkedCap=0;
	dijit.byId("btn_Capd").set('checked', false);
	dijit.byId('yearSelect_Capd').set('value',"");
	dijit.byId('analyseSelect').set('value',"");
	var id_gridf=dijit.byId("grid_filterCap");
 	if (id_gridf) {
		var emptyCells = { items: "" };
		filterCapStore = new dojox.data.AndOrWriteStore({data: emptyCells});
		filterCapGrid.setStore(filterCapStore);
		filterCapGrid.store.close();
		filterCapGrid._refresh();
		id_gridf.destroyRecursive();
	}

	filterCapGrid = new dojox.grid.EnhancedGrid({
		id: "grid_filterCap",
		store: filterCapStore,
		rowSelector: "0.4em",
		structure: layoutCapData,
		selectionMode:"multiple",
		rowsPerPage: 1000,  // IMPORTANT
    		keepRows: 1000,
    		delayScroll: true,
		selectable: true,
		autoHeight : true,
		sortFields: [{attribute: 'captureId', descending: true}],
		plugins: {
			indirectSelection: {
				headerSelector:"true",
				width: "30px",
				styles: "text-align: center;",
			},
 			filter: {
				closeFilterbarButton: true,
				ruleCount: 5,
			},
			nestedSorting: true,
			dnd: true,
			selector:true,
		}
	},document.createElement('div'));
	dojo.byId("filterCapGridDiv").appendChild(filterCapGrid.domNode);
	filterCapGrid.startup();
	filterCapGrid.layout.setColumnVisibility(2,false);
	filterCapGrid.layout.setColumnVisibility(7,false);
	divExtractCaptureDB.show();
}

function showFilteringTable(Sub) {
	var sl_year=dijit.byId("yearSelect_Capd").get('value');	
	var sl_analyse=dijit.byId("analyseSelect").get('value');
	if (sl_year.length ==0){		
			textError.setContent("Enter a Year");
			myError.show();
			return;
	}

	if (sl_analyse.length ==0){		
			textError.setContent("Enter an Analyse type");
			myError.show();
			return;
	}
	var url_capProj="/manageData.pl?option=captureProject" + "&analyse=" + sl_analyse;
	if (sl_year !="All") {url_capProj += "&year=" + sl_year;}
	filterCapStore = new dojox.data.AndOrWriteStore({
		url: url_path + url_capProj
	});
	filterCapGrid.setStore(filterCapStore);
	filterCapGrid.store.close();
	filterCapGrid._refresh();
};

function upExtractDefCap(Sub) {
	var sl_analyse=dijit.byId("analyseSelect").get('value');
	var sl_year=dijit.byId("yearSelect_Capd").get('value');
	var bt_ext=dijit.byId("btn_Capd");
	var item = filterCapGrid.selection.getSelected();
	var Idselected = new Array();
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(filterCapGrid.store.getAttributes(selectedItem), function(attribute) {
					var Idvalue = filterCapGrid.store.getValues(selectedItem, attribute);
					if (attribute == "captureId" ) {
						Idselected.push(Idvalue);
						return Idselected;
					}
				});
			}
		});
	} else {
		textError.setContent("Please Select One or more Exonic Captures");
		myError.show();
		return;
	}
	var url_insert = url_path + "/manageData.pl?option=upExtractDef" + 				
				"&table=" + Sub +
				"&analyse=" + sl_analyse +
				"&idSel="+Idselected;
	if (Sub=="Capd" && sl_year !="All") {url_insert  += "&year=" + sl_year;}
	if (Sub=="Capd") {url_insert += "&def_value=" + bt_ext.checked;}
/*
voir aussi method Post
*/
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				hideCap();
				refreshCapDataList();
				divExtractCaptureDB.hide();
			}
		}
	);
};

function refreshCapDataList() {
	captureStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageCapture.pl?option=capture"
	});
	capDataDGrid=dijit.byId("grid_Capd");
	capDataDGrid.setStore(captureStore);
	capDataDGrid.store.close();
	capDataDGrid._refresh();
};


/*########################################################################
#####################  New DATA
##########################################################################*/

var toolbar_Top;
var toolbar_Bottom;

function buildLayoutTop(sub,title,cpT,use_default,use_extractDef){
	var bt_title=title.split(",");
	cpT = new dijit.layout.ContentPane({
		region: "top",
		style:"color:white;margin: 0; padding: 0;border:0",
		id:"cp"+sub+"T"
	});
	toolbar_Top = new dijit.Toolbar({style:"line-height: 2.5em;"},
		document.createElement('div')
	);
	var spanP = document.createElement("span");
	spanP.innerHTML = "&nbsp;&nbsp;<b style='font-size:125%;'>"+bt_title[0]+
			  "</b>&nbsp;&nbsp;<img src='icons/table_save.png' id='TDataPrint' class='tooltip'>";
	toolbar_Top.domNode.appendChild(spanP);

	var spanBt = document.createElement("span");
	spanBt.style.cssText = "display: inline-block;width: 37em;line-height: 2.5em;";
	toolbar_Top.domNode.appendChild(spanBt);

	var bt_title_fn=bt_title[0].replace(/ /g,"_");

	toolbar_Top.addChild(new dijit.form.Button({
		showLabel: true,
		iconClass:"plusIcon",
		id:"btognew_"+sub,
 		label : "New "+bt_title[0],
		onclick:"viewNew"+bt_title_fn+"_"+sub+"();",
	}));

	if (sub.match(/^(Pipe)$/)) {
		dijit.byId("btognew_"+sub).set("label","New/Update "+bt_title[0]+"<img id='Tpi' src='icons/information.png'>");
	}
	if (sub.match(/^(Prof)$/)) {
		dijit.byId("btognew_"+sub).set("label","New/Update "+bt_title[0]+"<img id='Tpi' src='icons/information.png'>");
	}
	if (sub.match(/^(Capd|Rel)$/)) {
		dojo.style(dijit.byId("btognew_"+sub).domNode, {'visibility':'hidden'});
	} else {
		dojo.style(dijit.byId("btognew_"+sub).domNode, {'visibility':'visible'});
	}
	if (use_default) {
		toolbar_Top.addChild(new dijit.form.ToggleButton({
			style:"height:16;width:auto;margin:0;padding:0;float: top; border-radius: 8px;background:#9ABF5E; border: 1px solid #696B43; color: white",
			id:"btog_"+sub,
			iconClass:"dijitCheckBoxIcon",
 			label : "Default",
		}));
		toolbar_Top.addChild(new dijit.form.Button({
			showLabel: true,
			iconClass:"validIcon",
			style:"float:center;border-radius:10px;background:linear-gradient(brown,#510303);border:0;color:white;margin:0;padding:0;width:1.5em;",
			onclick:"changeDefault('"+sub+"');",
		}));
		dijit.byId("btog_"+sub).set('checked', false);
		if (use_extractDef) {
			toolbar_Top.addChild(new dijit.form.Button({
				showLabel: true,
				iconClass:"settingIcon",
				style:"",
 				label : "Default Grouping",
				onclick:"extractDef_"+sub+"();",
			}));
		}
	}
	cpT.set('content',toolbar_Top);
	BC.addChild(cpT);

	var tipA = new dijit.Tooltip({
		connectId:["TDataPrint"],
		position:["below"],
		label: 	"<div class='tooltip'><b>Preview/Save All :</b> right click on the Grid<br>"+
			"<b>Preview/Save Selected :</b>Select rows then right click on one Grid row selected"+
			"</div>"
	});
	var tipB = new dijit.Tooltip({
		connectId: ["Tpi"],
		position:["below"],
		label:"<div class='tooltip'><b>New Pipeline Method</b> when <b>no</b> PipeLine Name is selected<br>"+
					"<b>Update PipeLine Method</b> when a PipeLine Name is selected</div>",
	});


	return cpT;
}

function changeDefault(valsub){
	var bt_checked;
	var Idselected = new Array();
	if (valsub=="Plt") {
		bt_checked=btog_Plt.checked;
		plateformDGrid=dijit.byId("grid_"+valsub);
		plateformDGrid.setStore(plateformStore);
		var item = plateformDGrid.selection.getSelected();
		if (item.length) {
			dojo.forEach(item, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(plateformDGrid.store.getAttributes(selectedItem), function(attribute) {
						var Idvalue = plateformDGrid.store.getValues(selectedItem, attribute);
						if (attribute == "plateformId" ) {
							Idselected.push(Idvalue);
							return Idselected;
						}
					});
				}
			});
		} else {
			textError.setContent("Select a Plateform Name");
			myError.show();
			return;
		}
	}
	if (valsub=="Mac") {
		bt_checked=btog_Mac.checked;
		machineDGrid=dijit.byId("grid_"+valsub);
		machineDGrid.setStore(macStore);
		var item = machineDGrid.selection.getSelected();
		if (item.length) {
			dojo.forEach(item, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(machineDGrid.store.getAttributes(selectedItem), function(attribute) {
						var Idvalue = machineDGrid.store.getValues(selectedItem, attribute);
						if (attribute == "machineId" ) {
							Idselected.push(Idvalue);
							return Idselected;
						}
					});
				}
			});
		} else {
			textError.setContent("Select a Machine Name");
			myError.show();
			return;
		}
	}
	if (valsub=="MSeq") {
		bt_checked=btog_MSeq.checked;
		MethSeqDGrid=dijit.byId("grid_"+valsub);
		MethSeqDGrid.setStore(methSeqStore);
		var item = MethSeqDGrid.selection.getSelected();
		if (item.length) {
			dojo.forEach(item, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(MethSeqDGrid.store.getAttributes(selectedItem), function(attribute) {
						var Idvalue = MethSeqDGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methodSeqId" ) {
							Idselected.push(Idvalue);
							return Idselected;
						}
					});
				}
			});
		} else {
			textError.setContent("Select a Method Seq Name");
			myError.show();
			return;
		}
	
	}
	if (valsub=="MAln") {
		bt_checked=btog_MAln.checked;
		AlnDGrid=dijit.byId("grid_"+valsub);
		AlnDGrid.setStore(AlnStore);
		var item = AlnDGrid.selection.getSelected();
		if (item.length) {
			dojo.forEach(item, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(AlnDGrid.store.getAttributes(selectedItem), function(attribute) {
						var Idvalue = AlnDGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methodId" ) {
							Idselected.push(Idvalue);
							return Idselected;
						}
					});
				}
			});
		} else {
			textError.setContent("Select a Alignment Method Name");
			myError.show();
			return;
		}
	
	}
	if (valsub=="MCall") {
		bt_checked=btog_MCall.checked;
		CallDGrid=dijit.byId("grid_"+valsub);
		CallDGrid.setStore(CallStore);
		var item = CallDGrid.selection.getSelected();
		if (item.length) {
			dojo.forEach(item, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(CallDGrid.store.getAttributes(selectedItem), function(attribute) {
						var Idvalue = CallDGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methodId" ) {
							Idselected.push(Idvalue);
							return Idselected;
						}
					});
				}
			});
		} else {
			textError.setContent("Select a Calling Method Name");
			myError.show();
			return;
		}
	
	}
	if (valsub=="Rel") {
		bt_checked=btog_Rel.checked;
		releaseDGrid=dijit.byId("grid_"+valsub);
		releaseDGrid.setStore(relStore);
		var item = releaseDGrid.selection.getSelected();
		if (item.length) {
			dojo.forEach(item, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(releaseDGrid.store.getAttributes(selectedItem), function(attribute) {
						var Idvalue = releaseDGrid.store.getValues(selectedItem, attribute);
						if (attribute == "releaseId" ) {
							Idselected.push(Idvalue);
							return Idselected;
						}
					});
				}
			});
		} else {
			textError.setContent("Select a Release Genome Name");
			myError.show();
			return;
		}
	
	}
	if (valsub=="Capd") {
		bt_checked=btog_Capd.checked;
		capDataDGrid=dijit.byId("grid_"+valsub);
		capDataDGrid.setStore(captureStore);
		var item = capDataDGrid.selection.getSelected();
		if (item.length) {
			dojo.forEach(item, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(capDataDGrid.store.getAttributes(selectedItem), function(attribute) {
						var Idvalue = capDataDGrid.store.getValues(selectedItem, attribute);
						if (attribute == "captureId" ) {
							Idselected.push(Idvalue);
							return Idselected;
						}
					});
				}
			});
		} else {
			textError.setContent("Select a Exon Capture Name");
			myError.show();
			return;
		}	
	}
	var param_def="";
	var url_insert = url_path + "/manageData.pl?option=upDataDefault"+
				"&table="+ valsub +
				"&idSel="+Idselected;
	var param_def="";
	if (valsub=="Plt") {url_insert += "&def_value="+btog_Plt.checked;}
	if (valsub=="Mac") {url_insert += "&def_value="+btog_Mac.checked;}
	if (valsub=="MSeq") {url_insert += "&def_value="+btog_MSeq.checked;}
	if (valsub=="MAln") {url_insert += "&def_value="+btog_MAln.checked;}
	if (valsub=="MCall") {url_insert += "&def_value="+btog_MCall.checked;}
	if (valsub=="Rel") {url_insert += "&def_value="+btog_Rel.checked;}
	if (valsub=="Capd") {url_insert += "&def_value="+btog_Capd.checked;}
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				if (valsub=="Plt") {refreshPlateformList();}
				if (valsub=="Mac") {refreshMachineList();}
				if (valsub=="MSeq") {refreshSeqMethodList();}
				if (valsub=="MAln") {refreshAlnMethodList();}
				if (valsub=="MCall") {refreshCallMethodList();}
				if (valsub=="Rel") {refreshReleaseList();}
				if (valsub=="Capd") {refreshCapDataList();}
			}
		}
	);
}

function buildLayoutCenter(sub,cpC,grid,store,layout,typeselector){
	var id_grid=dijit.byId("grid_"+sub);
 	if (id_grid) {
		id_grid.destroyRecursive();
	}

	cpC = new dijit.layout.ContentPane({
		region: "center",
		style:"margin: 0; padding: 0;",
		id:"cp"+sub+"C"
	});
	BC.addChild(cpC);
	var div= document.createElement("div");
	div.id="grid"+sub+"Div";
	div.style="width: 100%; height: 93%;margin: 0; margin: 0;";
	cpC.set('content',div);


	var menusObjectData = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};
	menusObjectData.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectData.cellMenu.addChild(new dijit.MenuSeparator());
	menusObjectData.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll('grid_"+sub+"');"}));
	menusObjectData.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll('grid_"+sub+"');"}));
	menusObjectData.cellMenu.startup();
	grid = new dojox.grid.EnhancedGrid({
		id: "grid_"+sub,
		store: store,
		rowSelector: "0.4em",
		structure: layout,
		selectionMode:typeselector,
		rowsPerPage: 1000,  // IMPORTANT
    		keepRows: 1000,
    		delayScroll: true,
		selectable: true,
		autoHeight : true,
		plugins: {
			indirectSelection: {
				name: "Sel",
				width: "30px",
				styles: "text-align: center;",
			},
 			filter: {
				closeFilterbarButton: true,
				ruleCount: 5,
			},
			nestedSorting: true,
			dnd: true,
			exporter: true,
			printer:true,
			selector:true,
			menus:menusObjectData
		}
	},document.createElement('div'));
	grid.setStore(store);
	div.appendChild(grid.domNode);
	grid.startup();
	dojo.connect(grid, "onMouseOver", showTooltip);
	dojo.connect(grid, "onMouseOut", hideTooltip); 
	if (sub=="Capd") {grid.layout.setColumnVisibility(7,false);}
	return cpC;
}

function buildLayoutBottom(sub,title,cpB){
	var bt_title=title.split(",");
	cpB = new dijit.layout.ContentPane({
		region: "bottom",
		align:"center",
		style:"color:white;margin: 0; padding: 0;",
		id:"cp"+sub+"B"
	});
	BC.addChild(cpB);
	toolbar_bottom = new dijit.Toolbar({
	}, "toolbar_"+sub);
	var bt_title_fn=bt_title[0].replace(/ /g,"_");
	toolbar_bottom.addChild(new dijit.form.Button({
		showLabel: true,
		iconClass:"plusIcon",
 		label : "New "+bt_title[0],
		onclick:"viewNew"+bt_title_fn+"_"+sub+"();",
	}));
	if(bt_title.length>1) {
		bt_title[1]=bt_title[1].replace(/ /g,"_");
		toolbar_bottom.addChild(new dijit.form.Button({
			showLabel: true,
			iconClass:"renameIcon",
 			label : bt_title[1],
			onclick:"view"+bt_title[1]+"_"+sub+"();",
		}));
		if(bt_title.length>1) {
		}
		bt_title[2]=bt_title[2].replace(/ /g,"_");
		toolbar_bottom.addChild(new dijit.form.Button({
			showLabel: true,
			iconClass:"plusIcon",
 			label : bt_title[2],
			onclick:"viewNew"+bt_title[2]+"_"+sub+"();",
		}));
	}
	cpB.set('content',toolbar_bottom);
	return cpB;	
}

function clearSub(cpSubT,cpSubC){
	if (cpSubT) {
		BC.removeChild(cpSubT);
		cpSubT.destroyRecursive();

		BC.removeChild(cpSubC);
		cpSubC.destroyRecursive();
	}
}






