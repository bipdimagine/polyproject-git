/**
 * @author plaza
 */

require([
"dojox/charting/Chart2D","dojox/charting/widget/Chart2D","dojox/charting/themes/PlotKit/blue",
"dojox/charting/widget/Legend","dojox/charting/widget/SelectableLegend",
"dojox/charting/plot2d/StackedAreas","dojox/charting/Chart","dojox/charting/axis2d/Default",
"dojox/charting/themes/Wetland","dojox/charting/plot2d/Lines","dojox/charting/action2d/Tooltip",
"dojox/charting/widget/Legend","dojox/gfx/utils",
"dojox/charting/plot2d/Columns","dojox/gfx/filters","dojox/gfx/svgext",
"dojox/charting/plot2d/Grid","dojox/charting/themes/MiamiNice",
"dojo/NodeList-traverse","dojo/ready",
"dojox/form/RangeSlider","dijit/form/HorizontalSlider","dijit/form/HorizontalRule",
"dojox/charting/widget/SelectableLegend",
"dijit/form/HorizontalRuleLabels"

]);

var stat_1Store;
var stat_1Grid;
var stat_1Dial;
var stat_12Store;
var stat_12Grid;
var stat_12Dial;

var stat_2Store;
var stat_2Grid;
var stat_2Dial;
var stat_22Store;
var stat_22Grid;
var stat_22Dial;

var stat_3Store;
var stat_3Grid;
var stat_3Dial;
var stat_32Store;
var stat_32Grid;
var stat_32Dial;

var stat_4Store;
var stat_4Grid;
var stat_4Dial;
var stat_42Store;
var stat_42Grid;
var stat_42Dial;

var stat_5Store;
var stat_5Grid;
var stat_5Dial;
var stat_52Store;
var stat_52Grid;
var stat_52Dial;


var stat_6Store;
var stat_6Grid;
var stat_6Dial;
var stat_62Store;
var stat_62Grid;
var stat_562Dial;



var valAnalyse;
var valPlt;
var valUnit;
var valUnitEYU;

var MyCheckedMultiSelect;
var qanalyseMultiSelect;
var s_plateformSelect;
var qdirectorMultiSelect;

var layoutGrid = [
	{ field: "Row", name: "Row", width: '3'},
	{ field: "nbPat",name: "NB",width: '4'},
	{ field: "year",name: "Year",width: '5'},
];

var layoutGridPlt = [
	{ field: "Row", name: "Row", width: '3'},
	{ field: "name",name: "Platform",width: '10'},
	{ field: "nbPat",name: "NB",width: '4'},
	{ field: "year",name: "Year",width: '5'},
];

var layoutGridUnit = [
	{ field: "Row", name: "Row", width: '3'},
	{ field: "name",name: "TeamId",width: '4'},
	{ field: "nbPat",name: "NB",width: '4'},
	{ field: "year",name: "Year",width: '5'},
	{ field: "teamLeader",name: "Team Leader",width: '20'},
	{ field: "teamName",name: "Team Name",width: '30'},
];

function isUpperCase(str) {
    return str === str.toUpperCase();
}

require([
"dojo/_base/declare","dojo/_base/lang","dojo/_base/array",
"dojox/form/CheckedMultiSelect"
], function( declare,lang,array,CheckedMultiSelect) 
{
	 MyCheckedMultiSelect = declare(CheckedMultiSelect, {
		startup: function() {
			this.inherited(arguments);  
			setTimeout(lang.hitch(this, function() {
				this.dropDownButton.set("label", this.label);            
			}));
		},
		_updateSelection: function() {
			this.inherited(arguments);                
			if(this.dropDown && this.dropDownButton){
				var label = "";
				array.forEach(this.options, function(option){
					if(option.selected){
						var okmatch=option.label.match(/[|]/);
						if(okmatch) {
							var sp_label=option.label.split(" | ");
							var str_label=sp_label[0].split(" ").filter(function(e){return e});
							var final_label="";
							for(var i = 0; i < str_label.length; i++){
								if(isUpperCase(str_label[i])) {
									final_label+=str_label[i].toString();
								}
							}
							label += (label.length ? ", " : "") + final_label;
						} else {
							label += (label.length ? ", " : "") + option.label;
						}
					}
				});
				this.dropDownButton.set("label", label.length ? label : this.label);
			}
		}
	});
});

var unitNameStore;

dojo.addOnLoad(function() {
    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=unitName",
            handleAs: "json",
            load: function (res) {
		unitNameStore = new dojo.store.Memory({data: res});
           }
        });
});

var filter_year = [];
var sl_year = [];
var sl_value = [];
var arr_userid=[];
var prog_param;

function initStat(serial) {
	dijit.byId('Graph_1').set('title', "<span style='width:90%'><B>Samples/Year&nbsp;&nbsp;&nbsp;&nbsp;<span class='cl_filter'>Filter:Analyse</span></B></span><span id='btlog_9' style='width:10%' class='cl_log_span2'></span>");
	relog(logname,dojo.byId("btlog_9"));
	checkPassword(okfunction);

	if(! logged) {
		return
	}
// Number of Samples/Year Filter:Analyse
	if(serial==1) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		colorfill=["#80B0FF"];
		var ind="1";
		var prog_name="patAna";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		colorfill=["#809DCC"];
		ind="12";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
	}
// Number of Samples/Year and Plateform Filter:Analyse
	if(serial==4) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		colorfill=["#80B0FF"];
		var ind="4";
		var prog_name="EYpatDetail";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		colorfill=["#809DCC"];
		ind="42";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
	}
// Number of Samples/Year Filter:Analyse & Plateform
	if(serial==2) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		colorfill=["#9ACEC8"];
		var ind="2";
		var prog_name="patAnaPlt";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_valmonoselect(plateformNameStore, divMono="splateformSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
		colorfill=["#6B8E8A"];
		ind="22";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_valmonoselect(plateformNameStore,divMono="splateformSelect_"+ind, ind, prog_name, dbana,  colorfill, filter_year);
	}
// Number of Samples/Year&nbsp;&nbsp;&nbsp;&nbsp;Filter:Analyse & Unit
	if(serial==3) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		colorfill=["#85B599"];
		var ind="3";
		var prog_name="patAnaUnit";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_dirmultiselect(directorStore, divMulti="qdirectorSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
		colorfill=["#437C5B"];
		ind="32";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_dirmultiselect(directorStore, divMulti="qdirectorSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
	}
// Number of Samples/Year&nbsp;&nbsp;&nbsp;&nbsp;Filter:Analyse & User
	if(serial==5) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		arr_userid=[];
		var prog_name="patAnaUser";
		colorfill=["#A6AF82"];
		var ind="5";
		var dbana=0;
		launch_gridmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		colorfill=["#707A43"];
		var ind="52";
		var dbana=1;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		
	}
// Number of Samples/Year and Team Filter:Analyse & Unit
	if(serial==6) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		arr_userid=[];
		colorfill=["#85B599"];
		var ind="6";
		var prog_name="EYUpatDetail";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_valmonoselectUnit(unitNameStore, divMono="sunitSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
		colorfill=["#809DCC"];
		ind="62";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_valmonoselectUnit(unitNameStore, divMono="sunitSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
	}	
}

var layoutFilterUser = [
	{field: 'Name',name: 'Last Name',width: '12em'},
	{field: 'Firstname',name: 'First Name',width: '8em'},
	{field: 'Group',name: 'Group',width: '8em',styles:"text-align:left;white-space:nowrap;"},
	{field: 'Code',name: 'Lab Code',width: '10em'},
//	{field: 'Site',name: "Site <span id='bt_clearUser'></span>",width: 'auto'},
	{field: 'Site',name: "Site",width: '10em'},
];

function launch_gridmultiselect(Store,divMulti,ind,prog_name,prog_param,dbana,colorfill,filter_year){

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearOldUserList(size, request) {
                    var listUser = dojo.byId("UserDiv");
                    if (listUser) {
                        while (listUser.firstChild) {
                           listUser.removeChild(listUser.firstChild);
                        }

                    }
	}
	userStore.fetch({
		onBegin: clearOldUserList,
		onError: fetchFailed,
		onComplete: function(items){
			userstat = new dojox.grid.EnhancedGrid({
				query: {UserId: '*'},
				store: userStore,
				rowSelector: "0.4em",
				structure: layoutFilterUser,
				selectionMode:"Multiple",
				plugins: {
					filter: {
						closeFilterbarButton: true,
						ruleCount: 5,
						itemsName: "name"
					},
					indirectSelection: {
						headerSelector:false, 
						width: "2em",
						styles: "text-align: center;",
					},
					nestedSorting: true,
					dnd: true,
					selector:true,
				}
			},document.createElement('div'));
			dojo.byId("UserDiv").appendChild(userstat.domNode);
			userstat.startup();
			dojo.connect(userstat, "onCellMouseOver", showRowTooltip);
			dojo.connect(userstat, "onCellMouseOut", hideRowTooltip); 

			var sp_btclear=dojo.byId("bt_clearUser");
			var id_btclear=dijit.byId("id_btclearUser");
			if (id_btclear) {
				sp_btclear.removeChild(id_btclear.domNode);
				id_btclear.destroyRecursive();
			}
			var buttonform_clear= new dijit.form.Button({
				id:"id_btclearUser",
				title:"Clear Selection",
				showLabel: false,
				iconClass:"clearIcon",
				style:"color:white",
				onClick:ClearSelection,
			});
			buttonform_clear.startup();
			buttonform_clear.placeAt(sp_btclear,"last");
			function ClearSelection() {
				userstat.selection.clear();
				arr_userid=[];
				dbana=0;
				colorfill=["#A6AF82"];
				launch_stat(libchart="stat_"+ind, colorfill, eval("stat_"+ind+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				dbana=1;
				colorfill=["#707A43"];
				launch_stat(libchart="stat_"+ind+"2", colorfill, eval("stat_"+ind+"2"+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
			}
			dojo.connect(userstat, "onCellClick", userstat, function(){
				var items = userstat.selection.getSelected();
 				arr_userid=[];
				dojo.forEach(items, function(item){
					arr_userid.push(userstat.store.getValue(item, "UserId"));
				}, userstat);

				dbana=0;
				colorfill=["#A6AF82"];
				launch_stat(libchart="stat_"+ind, colorfill, eval("stat_"+ind+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);

				dbana=1;
				colorfill=["#707A43"];
				launch_stat(libchart="stat_"+ind+"2", colorfill, eval("stat_"+ind+"2"+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
			});
		}
	});	
}

function create_divSlider(ind){
	var tab_appSlider=dojo.byId("appSlider_"+ind);
	var div0= document.createElement("div");
	div0.id="ySlider_" + ind;
	var div1 = document.createElement("div");
	div1.id="yRuleLabels_" + ind;
	div0.appendChild(div1);
	tab_appSlider.appendChild(div0);
}

var def_unit="IMAGINE NECKER";
function launch_valmonoselectUnit(Store,divMono,ind,prog_name,dbana,colorfill,filter_year){
	var s_unitSelect=dijit.byId("unitSelect_"+ind);
	if(!s_unitSelect ){
		s_unitSelect = new dijit.form.FilteringSelect({
			store: Store,
			searchAttr: "name",
			value:def_unit, // id=2-> 84
			style: {width: '20em'},
			//value:"IMAGINE",
			id:"unitSelect_"+ind,
			onChange: function(item) {
				valUnitEYU=s_unitSelect.item.value.toString();
				if (valUnitEYU) {
					prog_param="&analyse="+valAnalyse;
					if(dbana) {
						prog_param=prog_param +"&not="+"1";
					}
					launch_Cluster(libchart="stat_"+ind, colorfill, eval("stat_"+ind+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value);
				}
			}
		},divMono);
		s_unitSelect.startup();
	} else {
		s_unitSelect.reset();
	}
}

function launch_valmonoselect(Store,divMono,ind,prog_name,dbana,colorfill,filter_year){
	var s_plateformSelect=dijit.byId("plateformSelect_"+ind);

	if(!s_plateformSelect ){
		s_plateformSelect = new dijit.form.FilteringSelect({
			store: Store,
			searchAttr: "name",
			value:"IMAGINE",
			id:"plateformSelect_"+ind,
			onChange: function(item) {
				valPlt=item.toString();
				if (valPlt) {
					prog_param="&analyse="+valAnalyse+"&platform="+valPlt;
					if(dbana) {
						prog_param=prog_param +"&not="+"1";
					}
					
					launch_stat(libchart="stat_"+ind, colorfill, eval("stat_"+ind+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				}
			}
		},divMono);
		s_plateformSelect.startup();
	} else {
		s_plateformSelect.reset();
	}
}

function launch_dirmultiselect(Store,divMulti,ind,prog_name,dbana,colorfill,filter_year){
	require([
    		"dojo/_base/declare","dojo/_base/lang","dojo/_base/array","dojo/on","dojo/dom",
		"dojo/dom-class","dijit/registry",
		"dojo/store/Memory","dojo/store/Observable","dojo/data/ObjectStore",
		"dojox/form/CheckedMultiSelect","dijit/form/Button"
	], function( 				declare,lang,array,on,dom,domClass,registry,Memory,Observable,DataStore,CheckedMultiSelect,Button) 
		{
			var dataStore = new DataStore({
				objectStore:Store,
				labelProperty:"label"
			});
			var qdirectorMultiSelect=registry.byId("idDirMultiSelect_"+ind);
			if(!qdirectorMultiSelect ){
				qdirectorMultiSelect = new MyCheckedMultiSelect({
					dropDown: true,
					id:"idDirMultiSelect_"+ind,
					store: dataStore,
					multiple: true,
					value:"",
					labelAttr: "label",
					searchAttr:"label",
					sortByLabel: false,
					label: "Select",
					onChange: function(item) {
						valUnit=item.toString();
						if (valUnit) {
							prog_param="&analyse="+valAnalyse;
							if(dbana && prog_name!="patAnaUser") {
								prog_param=prog_param +"&not="+"1";
							}
							if(prog_name=="patAnaUnit") {
								prog_param=prog_param+"&unit=" +valUnit;
							}
							launch_stat(libchart="stat_"+ind, colorfill, eval("stat_"+ind+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
						}
					}
				},divMulti);
   				qdirectorMultiSelect.startup();
				var sp_btclear=dom.byId("bt_clearUser_"+ind);
				var id_btclear=registry.byId("id_btclearUser_"+ind);
				if (id_btclear) {
					sp_btclear.removeChild(id_btclear.domNode);
					id_btclear.destroyRecursive();
				}
				var buttonform_clear= new Button({
					id:"id_btclearUser_"+ind,
					title:"Clear Selection",
					showLabel: false,
					iconClass:"clearIcon",
					style:"color:white",
					onClick:ClearSelection,
				});
				buttonform_clear.startup();
				buttonform_clear.placeAt(sp_btclear,"last");

				function ClearSelection() {
					qdirectorMultiSelect.reset();
					qdirectorMultiSelect._updateSelection();
					arr_userid=[];
					valUnit=0;
					prog_param="&analyse="+valAnalyse;
					if(dbana && prog_name!="patAnaUser") {
							prog_param=prog_param +"&not="+"1";
					}
					if(prog_name=="patAnaUnit") {
						prog_param=prog_param+"&unit=" +valUnit;
					}
					launch_stat(libchart="stat_"+ind, colorfill, eval("stat_"+ind+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				}
			} else {
				qdirectorMultiSelect.reset();
				qdirectorMultiSelect._updateSelection();
			}
		}
	)
}
var pvalana0;
var pvalana1;
function launch_valmultiselect(Store,divMulti,ind,prog_name,prog_param,dbana,colorfill,filter_year){
	require([
    		"dojo/_base/declare","dojo/_base/lang","dojo/_base/array","dojo/on","dojo/dom",
		"dojo/dom-class","dijit/registry",
		"dojo/store/Memory","dojo/store/Observable","dojo/data/ObjectStore",
		"dojox/form/CheckedMultiSelect"
	], function( 				declare,lang,array,on,dom,domClass,registry,Memory,Observable,DataStore,CheckedMultiSelect) 
		{
			var dataStore = new DataStore({
				objectStore:Store,
				labelProperty:"label"
			});
			var qanalyseMultiSelect=registry.byId("idanaMultiSelect_"+ind);
			if(!qanalyseMultiSelect ){
				qanalyseMultiSelect = new MyCheckedMultiSelect({
					dropDown: true,
					id:"idanaMultiSelect_"+ind,
					store: dataStore,
					multiple: true,
					value:"exome",
					labelAttr: "label",
					searchAttr:"label",
					sortByLabel: false,
					label: "<a style='background:#66CC00'>exome</a>",
					onChange: function(item) {
						valAnalyse=item.toString();
						if (valAnalyse) {
							if(prog_name!="patAnaUser") {
								prog_param="&analyse="+valAnalyse;
								if(dbana) {
									prog_param=prog_param +"&not="+"1";
								}
							}
							if(prog_name=="patAnaUser") {
								if(dbana) {
									pvalana1=valAnalyse;
								} else {
									pvalana0=valAnalyse;
								}
							}
							if(prog_name=="patAnaPlt") {
								prog_param=prog_param+"&platform="+valPlt;
							}							
							if(prog_name=="patAnaUnit") {
								prog_param=prog_param+"&unit=" +valUnit;
							}
							if(prog_name=="EYpatDetail"|| prog_name=="EYUpatDetail") {
								launch_Cluster(libchart="stat_"+ind, colorfill, eval("stat_"+ind+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value);
							} else {
								launch_stat(libchart="stat_"+ind, colorfill, eval("stat_"+ind+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
							}
						}
					}
				},divMulti);
   				qanalyseMultiSelect.startup();
			} else {
				qanalyseMultiSelect.reset();
			}
			valAnalyse="exome";
			valPlt="IMAGINE";
			valUnit="";
			if(prog_name!="patAnaUser") {
				prog_param="&analyse="+valAnalyse;
				if(dbana) {
					prog_param=prog_param +"&not="+"1";
				}
			}

			if(prog_name=="patAnaUser") {
				if(dbana) {
					pvalana1=valAnalyse;
				} else {
					pvalana0=valAnalyse;
				}
			}

			if(prog_name=="patAnaPlt") {
				prog_param=prog_param+"&platform="+valPlt;
			}
			if(prog_name=="patAnaUnit") {
				prog_param=prog_param+"&unit=" +valUnit;
			}
			if(prog_name=="EYUpatDetail") {
				valUnitEYU=84; //IMAGINE NECKER
			}
			if(prog_name=="EYpatDetail" || prog_name=="EYUpatDetail") {
				launch_Cluster(libchart="stat_"+ind, colorfill, eval("stat_"+ind+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value);
			} else {
				launch_stat(libchart="stat_"+ind, colorfill, eval("stat_"+ind+"Store"), prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
			}
		}
	)
}

function launch_stat(libchart,colorfill,Store,prog_name,prog_param,dbana,filter_year,sl_year,sl_value,arr_userid){
	var ind=libchart.split("_");
	var button_grid="button_" + ind[1];
	if (prog_name=="patAnaUser") {
		if (dbana) {
			prog_param="&analyse="+pvalana1;
		} else {
			prog_param="&analyse="+pvalana0;
		}
	}

	if (dbana && prog_name=="patAnaUser") {
		prog_param=prog_param +"&not="+"1";
	}
	if (arr_userid.length>=1 && prog_name=="patAnaUser") {
		prog_param=prog_param+"&user="+ arr_userid;
	}	
	var url_stat;
	if (filter_year.length>=1) {
		url_stat="/stat.pl?opt="+prog_name + prog_param +"&year="+ filter_year.toString();
	} else {
		url_stat="/stat.pl?opt="+prog_name + prog_param ;
	}
	showProgressDlg("Loading Graph... ",true,libchart,"LI");
	var xhrArgsEx={
		url: url_path + url_stat,
		handleAs: "json",
		handle: function(response,args) {
			showProgressDlg("Loading Graph... ",false,libchart,"LI");
			},
              	timeout: 0, // infinite no time out
		load: function (res) {
			Store = new dojo.data.ItemFileWriteStore({data: res});
			function clearOldChartList(size, request) {
				var listChart = dojo.byId(libchart);
				while (listChart.hasChildNodes()) {
					listChart.removeChild(listChart.lastChild);
  				}
			}

			function fetchChartFailed(error, request) {
				alert("lookupChart failed.");
			}

			var viewChart2D = function(items, request){
//############################# GRAPHICS        ######################################################
				var chart=dijit.byId(libchart);
				if (chart != undefined) {
					chart.destroy();
				}
				var chart = new dojox.charting.Chart2D(libchart);
 				var myTheme=dojox.charting.themes.MiamiNice;
				myTheme.axis.majorTick.color = "green";
				chart.setTheme(myTheme);
				chart.addPlot("default", {
					type: "Columns",
					markers: true,
					precision: 2,
					gap: 5
				});
				chart.addPlot("grid", {
					type: "Grid",
					fontColor: "blue",
    					hMajorLines: true,
    					vMajorLines: false,
 				});

				var xlabelArray=new Array();
				var ylab=new Array();
				for (var i = 0; i <= items.length; i++){
					if (i== items.length ) {
						var xlabel= {"value":i+1,"text":""};
					} else {
						var xlabel= {"value":i+1,"text":items[i].year};
						ylab.push(+items[i].year);
					}
					xlabelArray[i]=xlabel;
				}
				var ln = xlabelArray.length;
				if (filter_year.length==0) {
					sl_year=ylab;
				}
				sl_yearselect(ind[1], libchart, colorfill, Store, prog_name, prog_param, dbana, sl_year, sl_value);

				var myLabelFuncX = function(text, value, precision){
					if(text==0){return " ";}
				};
				chart.addAxis('x',{
					titleFont: "normal normal bold 8pt Arial",
					natural:true,
					majorTicks:true,
					minorTicks:true,
					microTicks: true,
					majorTick: {length: 0},
					minorTick: {length: 0},	
					microTick: {length: 0},	
					majorLabels:true,minorLabels:true,microLabels:true,rotation:-90,min:0, max:ln,
					labelFunc: myLabelFuncX,
					labels:xlabelArray}
				);
				var str_find="not=1";
				var okmatch=url_stat.match(str_find);
				var lib_valAnalyse;
				if(okmatch) {
					lib_valAnalyse = "Not " + valAnalyse;
				} else {
					lib_valAnalyse = valAnalyse;
				}

				chart.addAxis("y", { vertical: true, fixLower: "major", fixUpper: "major",
					titleFont: "normal normal bold 8pt Arial",
					title:"Number of '" + lib_valAnalyse + "'"});

				var arrayNBpat=[];
				for(var i = 0; i < items.length; i++){
					arrayNBpat.push(+items[i].nbPat);
				}
				var total=0;
				for(var n = 0; n < arrayNBpat.length; n++){
					total+=arrayNBpat[n];
				}
				var serie_legend;
				if(prog_name=="patAnaUser") {
					serie_legend="Number of Patients '" + lib_valAnalyse + "' per year" +" <small>(<b title='Cumulative Total'>"+total+"</b>) #Users (<b>" + arr_userid.length + "</b>)</small>";
				} else {
					serie_legend="Number of Patients '" + lib_valAnalyse + "' per year" +" <small>(<b title='Cumulative Total'>"+total+"</b>)</small>";
				}
				chart.addSeries(serie_legend,arrayNBpat,{stroke: {color: colorfill[0],width:4},fill: colorfill[0]});
				var anim4b = new dojox.charting.action2d.Tooltip(chart, 'default',{
					text:function(o) {
						return("nb: " + dojo.number.format((o.y),{places:0})
						);
					}
				});
				//chart.resize();
				//if (ln <= 4) {
				//	chart.resize(300, 300);
				//}
				chart.render();
				var liblegend="legend_"+ind[1];
				var legend = dijit.byId(liblegend);
				if (legend != undefined) {
					legend.destroyRecursive(true); 
				}
				var legend = new dojox.charting.widget.Legend({chart: chart, horizontal: true}, liblegend);
//############################# Button and Grid ######################################################
				launch_ButtonGrid(button_grid,Store,prog_name,lib_valAnalyse,total);
//############################# END ######################################################

			}
			Store.fetch({query:{Row:"*",nbPat:"*"},
				onBegin: clearOldChartList,
				onComplete: viewChart2D,
				onError: fetchChartFailed
			});
		}
	}
	var defferedEx = dojo.xhrGet(xhrArgsEx);
}

function launch_Cluster(libchart,colorfill,Store,prog_name,prog_param,dbana,filter_year,sl_year,sl_value){
	var ind=libchart.split("_");
	var button_grid="button_" + ind[1];
	var url_stat;
	url_stat="/stat.pl?opt="+prog_name;
	if(prog_name=="EYUpatDetail") {
		url_stat=url_stat + "&unit=" + valUnitEYU;
	}
	if (filter_year.length>=1) {
		url_stat=url_stat + prog_param +"&year="+ filter_year.toString();
	} else {
		url_stat=url_stat + prog_param ;
	}
	showProgressDlg("Loading Graph... ",true,libchart,"LI");
	var xhrArgsEx={
		url: url_path + url_stat,
		handleAs: "json",
		handle: function(response,args) {
			showProgressDlg("Loading Graph... ",false,libchart,"LI");
			},
              	timeout: 0, // infinite no time out
		load: function (res) {
			Store = new dojo.data.ItemFileWriteStore({data: res});
			function clearOldChartList(size, request) {
				var listChart = dojo.byId(libchart);
				while (listChart.hasChildNodes()) {
					listChart.removeChild(listChart.lastChild);
  				}
			}

			function fetchChartFailed(error, request) {
				alert("lookupChart failed.");
			}

			var viewChart2DC = function(items, request){
//############################# GRAPHICS        ######################################################
				var chart=dijit.byId(libchart);
				if (chart != undefined) {
					chart.destroy();
				}
				var chart = new dojox.charting.Chart2D(libchart);
 				var myTheme=dojox.charting.themes.MiamiNice;
				myTheme.axis.majorTick.color = "green";
				chart.setTheme(myTheme);
				chart.addPlot("default", {
					type: "ClusteredColumns",
//					type: "StackedColumns",
					markers: true,
					precision: 2,
					gap: 5
				});
				chart.addPlot("grid", {
					type: "Grid",
					fontColor: "blue",
    					hMajorLines: true,
    					vMajorLines: false,
 				});

				var myLabelFuncX = function(text, value, precision){
					if(text==0){return " ";}
				};
				
				var yearLabel= new Array();
				for(var i = 0; i < items.length; i++){
					if (! ~yearLabel.toString().indexOf(items[i].year) ) {
						yearLabel.push(+items[i].year);
					}
				}
				var yearLabel= [];
				var yearLabelobj= [];
				var y=1;

				for(var i = 0; i < items.length; i++){
					if (! ~yearLabel.toString().indexOf(items[i].year) ) {
						yearLabel.push(+items[i].year);
						var xlabel ={"value":y,"text":items[i].year};
						yearLabelobj.push(xlabel);
						y++;
					}
				}
				var ln = yearLabelobj.length;

				if (filter_year.length==0) {
					sl_year=yearLabel;
				}
				sl_yearselect(ind[1], libchart, colorfill, Store, prog_name, prog_param, dbana, sl_year, sl_value);
				chart.addAxis('x',{
					titleFont: "normal normal bold 8pt Arial",
					natural:true,
					majorTicks:true,
					minorTicks:true,
					microTicks: true,
					majorTick: {length: 0},
					minorTick: {length: 0},	
					microTick: {length: 0},	
					majorLabels: true,minorLabels: true,microLabels: true,rotation:-90,min:0, max:ln+0.5,
					labelFunc: myLabelFuncX,
					labels:yearLabelobj
					}
				);

				var str_find="not=1";
				var okmatch=url_stat.match(str_find);
				var lib_valAnalyse;
				if(okmatch) {
					lib_valAnalyse = "Not " + valAnalyse;
				} else {
					lib_valAnalyse = valAnalyse;
				}

				chart.addAxis("y", { vertical: true, fixLower: "major", fixUpper: "major",
					titleFont: "normal normal bold 8pt Arial",
					title:"Number of '" + lib_valAnalyse + "'",
					min:0
				});
				maxIColor=0;
				for(var i = 0; i < items.length; i++){
					maxIColor=Math.max(maxIColor,items[i].col);
				}
				var SerieName=new Array();
				var SerieTeam=new Array();
				var Serie=new Array();
				var ToTSerie=new Array();



				for(var i = 0; i < maxIColor; i++){
					Serie[i]=new Array();
					ToTSerie[i]=new Array();
					for(var j = 0; j < items.length; j++){
						if (items[j].col==i+1) {
							if (! ~SerieName.toString().indexOf(items[j].name)) {
								SerieName.push(items[j].name);
								if(prog_name=="EYUpatDetail") {
									SerieTeam.push(items[j].teamName.toString());
								}
							}
							if(prog_name=="EYUpatDetail") {
								Serie[i].push({y:items[j].nbPat,
									tooltip:"Team: " + items[j].name.toString()+" "+
									items[j].teamName.toString()+
									"<br> "+items[j].teamLeader.toString()+
									"<br>Year: "+items[j].year+
									"<br>nb: "+dojo.number.format((items[j].nbPat),{places:0})
								});
							} else {
								Serie[i].push({y:items[j].nbPat,
									tooltip:items[j].name.toString()+
									"<br>Year: "+items[j].year+
									"<br>nb: "+dojo.number.format((items[j].nbPat),{places:0})
								});
							}
							ToTSerie[i].push(+items[j].nbPat);
							continue;
						}
					}
				}
				//+" "+SerieTeam[i]
				var totalFusion=0;
				for(var i = 0; i < maxIColor; i++){
					var cfill=getRandomColor();
					var total=0;
					for(var n = 0; n < ToTSerie[i].length; n++){
						total+=ToTSerie[i][n];
					}
					totalFusion+=total;
					chart.addSeries(SerieName[i]+"<small>(<b title='Cumulative Total toto'>"+total+"</b>)</small>",Serie[i],{stroke: {color: colorfill[0]},fill: cfill});
				}

				var anim4b = new dojox.charting.action2d.Tooltip(chart, 'default');
				//chart.resize();
				//if (ln <= 4) {
				//	chart.resize(300, 300);
				//}
				chart.render();
				var liblegend="legend_"+ind[1];
				var legend = dijit.byId(liblegend);
				if (legend != undefined) {
					legend.destroyRecursive(true); 
				}
				//var legend = new dojox.charting.widget.Legend({chart: chart, horizontal: true, style:'font-size:70%;'}, liblegend);
				var legend = new dojox.charting.widget.SelectableLegend({chart: chart, horizontal: true, style:'font-size:70%;'}, liblegend);
				if (totalFusion) {
					var spFtotal = dojo.byId("total_"+ ind[1]);
					spFtotal.innerHTML= "<small>Total ("+ totalFusion +")</small>";
				}

//############################# Button and Grid ######################################################
				launch_ButtonGrid(button_grid,Store,prog_name,lib_valAnalyse,total,totalFusion);
//############################# END ######################################################
			}
			Store.fetch({query:{Row:"*",nbPat:"*"},
				onBegin: clearOldChartList,
				onComplete: viewChart2DC,
				onError: fetchChartFailed
			});
		}
	}
	var defferedEx = dojo.xhrGet(xhrArgsEx);
}

function getRandomColor() {
    var letters = '0123456789ABCDEF';
    var color = '#';
    for (var i = 0; i < 6; i++ ) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

function sl_yearselect(ind,libchart,colorfill,Store,prog_name,prog_param,dbana,sl_year,sl_value){
	if (sl_value.length==0) {
		sl_value =[1,sl_year.length];
	}
	var div_rangeSlider=dojo.byId("ySlider_"+ind);
	var id_rangeSlider=dijit.byId("ySlider_"+ind);
	if (id_rangeSlider) {
		div_rangeSlider.removeChild(id_rangeSlider.domNode);
		id_rangeSlider.destroyRecursive();
	}
	var rangeSlider = new dojox.form.HorizontalRangeSlider({
		id: "ySlider_"+ind,
		name: "ySlider_"+ind,
		value: sl_value,
		minimum: 1,
		maximum: sl_year.length,
		discreteValues:sl_year.length,
		intermediateChanges: false,
		showButtons:false,
		style: "width:40em;",
		onChange: function (value) {
			var ind_ymin=value[0];
			var ind_ymax=value[1];
			filter_year = [];
			for (var i = 0; i < sl_year.length; i++) {
				if ((i>=ind_ymin-1) && (i<=ind_ymax-1)) {
					filter_year.push(+sl_year[i]);
				}
			}
			sl_value=value;
			if(prog_name=="EYpatDetail"||prog_name=="EYUpatDetail" ) {
				launch_Cluster(libchart, colorfill, Store, prog_name, prog_param, dbana, filter_year, sl_year, sl_value);
			} else {
				launch_stat(libchart, colorfill, Store, prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);				
			}
		}
	});
	rangeSlider.placeAt(div_rangeSlider,"first");
	rangeSlider.startup();
	var div_sliderRuleLabels=dojo.byId("yRuleLabels_"+ind);
	var id_sliderRuleLabels=dijit.byId("yRuleLabels_"+ind);
	if (id_sliderRuleLabels) {
		div_sliderRuleLabels.removeChild(id_sliderRuleLabels.domNode);
		id_sliderRuleLabels.destroyRecursive();
	}

	var sliderRuleLabels = new dijit.form.HorizontalRuleLabels({
		container: 'topDecoration',
		id:"yRuleLabels_"+ind,
		minimum:1,
		maximum:sl_year.length,
		labels:sl_year,
		labelStyle:"font-size:8px;text-align:right;color: grey",
		style:"width:40em;height:1em;"
	});
	sliderRuleLabels.placeAt(div_sliderRuleLabels,"first");
	sliderRuleLabels.startup();
}

//function launch_ButtonGrid(button_grid,Store,prog_name,lib_valAnalyse,total){
function launch_ButtonGrid(button_grid,Store,prog_name,lib_valAnalyse,total,ctotal){
	dijit.byId("bip"+button_grid) && dijit.byId("bip"+button_grid).destroyRecursive();
	dojo.place(
		new dijit.form.Button({
			id:"bip"+button_grid,
			showLabel: false,
			iconClass:"viewProject",
			onClick:viewGrid
	}).domNode, button_grid, "first");

	function viewGrid() {
		var id_cp=dijit.byId("cp"+button_grid);
 		if (id_cp) {
			id_cp.destroyRecursive();
		}
		var cp = new dijit.layout.ContentPane({
			id:"cp"+button_grid,
			style:"width:100%;height:92%;"
		},cp);
		var id_grid=dijit.byId('Grid'+button_grid);
 		if (id_grid) {
			id_grid.destroyRecursive();
		}
		var val_layoutGrid="layoutGrid";
		if(prog_name=="EYpatDetail") {val_layoutGrid="layoutGridPlt"}
		if(prog_name=="EYUpatDetail") {val_layoutGrid="layoutGridUnit"}
		var menusObjectS = {
			cellMenu: new dijit.Menu(),
		};
		menusObjectS.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
		menusObjectS.cellMenu.addChild(new dijit.MenuSeparator());
		menusObjectS.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll('Grid"+button_grid+"');"}));
		menusObjectS.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll('Grid"+button_grid+"');"}));
		Grid = new dojox.grid.EnhancedGrid({
			id:'Grid'+button_grid,
			store: Store,
			structure: val_layoutGrid,
			style:'width:100%;hight:100%;',
			canSort:function(colIndex, field){
				return colIndex != 1 && field != 'Row' && field != 'nbPat' && field != 'year';
			},
			plugins: {
				exporter: true,
				printer:true,
				selector:true,
				menus:menusObjectS
			}
		},cp);
		var spPrint="&nbsp;<span id="+"Print" + button_grid +"><img src='icons/table_save.png'></span>";
		var serie_legend="Number of Patients '" + lib_valAnalyse + "' per year";
		if (ctotal) {total=ctotal;}
		serie_legend="Number of Patients '" + lib_valAnalyse + "' per year"+" <small>(<b title='Cumulative Total'>"+total+"</b>)</small>";
		Dial = new dijit.Dialog({
       			title:serie_legend+spPrint,
			style:"width:25em;height:40em",
			content:cp.domNode
		});
		dojo.place(Grid.domNode,Dial.containerNode,'first');
 		var tipT = new dijit.Tooltip({
			connectId:["Print"+button_grid],
			position:["below"],
			label: 	"<div class='tooltip'><b>Preview/Save All :</b> right click on the Grid<br>"+
				"<b>Preview/Save Selected :</b>Select rows then right click on one Grid row selected"+
				"</div>"
		});
		Grid.startup();
		Dial.show();
	}
}





