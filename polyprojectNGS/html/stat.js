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
"dojox/form/CheckedMultiSelect",
"dojox/form/RangeSlider","dijit/form/HorizontalSlider","dijit/form/HorizontalRule",
"dojox/charting/widget/SelectableLegend",
"dijit/form/HorizontalRuleLabels"

]);


const data = {};
for (let i = 1; i <= 8; i++) {
  data[`stat_${i}Store`] = "Store" + i;
  data[`stat_${i}Grid`] = "Grid" + i;
  data[`stat_${i}Dial`] = "Dial" + i;
  data[`stat_${i}2Store`] = "Store" + i + "2";
  data[`stat_${i}2Grid`] = "Grid" + i + "2";
  data[`stat_${i}2Dial`] = "Dial" + i + "2";

  data[`query_${i}Store`] = "QStore" + i;
  data[`query_${i}Grid`] = "QGrid" + i;
  data[`query_${i}DialGrid`] = "QDialGrid" + i;
  data[`query_${i}2Store`] = "QStore" + i + "2";
  data[`query_${i}2Grid`] = "QGrid" + i + "2";
  data[`query_${i}2DialGrid`] = "QDialGrid" + i + "2";
}

var valAnalyse;
var valPlt;
var valUnit;
var valUnitEYU;
var valPhe;
var valMac;

var MyCheckedMultiSelect;
var qanalyseMultiSelect;
var s_plateformSelect;
var qMultiSelect;

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

var layoutProjPheGrid = [
	{ field: "Row", name: "Row",get: getRow, width: '2.5'},
	{ field: "project", name: "Project", width: '8'},
	{ field: "analyse",name: "Analyse",width: '5'},
	{ field: "phenotype",name: "Phenotype",width: '15'},
	{ field: "year",name: "Year",width: '5'},
];

var layoutProjMacGrid = [
	{ field: "Row", name: "Row",get: getRow, width: '2.5'},
	{ field: "project", name: "Project", width: '8'},
	{ field: "analyse",name: "Analyse",width: '5'},
	{ field: "machine",name: "Machine",width: '15'},
	{ field: "type",name: "Type",width: '15'},
	{ field: "year",name: "Year",width: '5'},
];

var layoutProjPltGrid = [
	{ field: "Row", name: "Row",get: getRow, width: '2.5'},
	{ field: "project", name: "Project", width: '8'},
	{ field: "analyse",name: "Analyse",width: '5'},
	{ field: "plateform",name: "Plateform",width: '15'},
	{ field: "year",name: "Year",width: '5'},
];

var layoutProjUnitGrid = [
	{ field: "Row", name: "Row",get: getRow, width: '2.5'},
	{ field: "project", name: "Project", width: '8'},
	{ field: "analyse",name: "Analyse",width: '5'},
	{ field: "unit",name: "Unit",width: '15'},
	{ field: "year",name: "Year",width: '5'},
];

var layoutProjTeamUnitGrid = [
	{ field: "Row", name: "Row",get: getRow, width: '2.5'},
	{ field: "project", name: "Project", width: '8'},
	{ field: "analyse",name: "Analyse",width: '5'},
	{ field: "team",name: "Team",width: '20'},
	{ field: "unit",name: "Unit",width: '10'},
	{ field: "year",name: "Year",width: '5'},
];

var layoutProjUserGrid = [
	{ field: "Row", name: "Row",get: getRow, width: '2.5'},
	{ field: "project", name: "Project", width: '8'},
	{ field: "analyse",name: "Analyse",width: '5'},
	{ field: "user",name: "User",width: '15'},
	{ field: "year",name: "Year",width: '5'},
];

var layoutProjGroupGrid = [
	{ field: "Row", name: "Row",get: getRow, width: '2.5'},
	{ field: "project", name: "Project", width: '8'},
	{ field: "analyse",name: "Analyse",width: '5'},
	{ field: "group",name: "Group",width: '15'},
	{ field: "year",name: "Year",width: '5'},
];


var layoutFilterUser = [
	{field: 'Name',name: 'Last Name',width: '12em'},
	{field: 'Firstname',name: 'First Name',width: '8em'},
	{field: 'Group',name: 'Group',width: '8em',styles:"text-align:left;white-space:nowrap;"},
	{field: 'Code',name: 'Lab Code',width: '10em'},
//	{field: 'Site',name: "Site <span id='bt_clear'></span>",width: 'auto'},
	{field: 'Site',name: "Site",width: '10em'},
];

var layoutGroup = [
	{field: 'group',name: "Group",width: '12em'},
//	{field: 'bt',name: "BTU",width: '4em',formatter:ButtonUserGroup},
	{field: 'bt',name: "<b>&nbsp;&nbsp;</b>",width: '2.5em',formatter:ButtonStatUserGroup},
//	{field: 'bt',name: "<b>&nbsp;&nbsp;</b>",width: '2.5em'},
];

var layoutDetailedGroup = [
	{field: 'Name',name: "Last Name",width: '12em'},
	{field: 'Firstname',name: "First Name",width: '10em'},
	{field: 'Site',name: 'Site',width: '10em'},
	{field: 'Code',name: 'Lab Code',width: '10em'},
	{field: 'Team',name: 'Team',width: '26em',styles:"text-align:left;white-space:nowrap;"}
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

	ugroupStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=ugroup"
	});
});

var filter_year = [];
var sl_year = [];
var sl_value = [];
var arr_userid=[];
var arr_groupid=[];
var prog_param;

function initStat(serial) {
	dijit.byId('Graph_1').set('title', "<span style='width:90%'><B>Samples/Year&nbsp;&nbsp;&nbsp;&nbsp;<span class='cl_filter'>Filter:Analyse & Machine</span></B></span>&nbsp;&nbsp;&nbsp;&nbsp;<span class='cl_project'>Project List</span></B><span id='btlog_9' style='width:10%' class='cl_log_span2'></span>");
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
		valMac="";
		colorfill=["#80B0FF"];
		var ind="1";
		var prog_name="patAnaMac";
		var prog_name_P="proAnaMac";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_dirmultiselect_data(machineStore, divMulti="qmachineSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
		colorfill=["#809DCC"];
		ind="12";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_dirmultiselect_data(machineStore, divMulti="qmachineSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
	}
// Number of Samples/Year and Plateform Filter:Analyse
	if(serial==4) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		colorfill=["#80B0FF"];
		var ind="4";
		var prog_name="EYpatDetail";
		var prog_name_P="EYproDetail";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		colorfill=["#809DCC"];
		ind="42";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
	}
// Number of Samples/Year Filter:Analyse & Plateform
	if(serial==2) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		colorfill=["#9ACEC8"];
		var ind="2";
		var prog_name="patAnaPlt";
		var prog_name_P="proAnaPlt";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_valmonoselect_data(plateformNameStore, divMono="splateformSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
		colorfill=["#6B8E8A"];
		ind="22";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_valmonoselect_data(plateformNameStore,divMono="splateformSelect_"+ind, ind, prog_name, dbana,  colorfill, filter_year);
	}
// Number of Samples/Year&nbsp;&nbsp;&nbsp;&nbsp;Filter:Analyse & Unit
	if(serial==3) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		colorfill=["#85B599"];
		var ind="3";
		var prog_name="patAnaUnit";
		var prog_name_P="proAnaUnit";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_dirmultiselect_data(directorStore, divMulti="qdirectorSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
		colorfill=["#437C5B"];
		ind="32";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_dirmultiselect_data(directorStore, divMulti="qdirectorSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);

	}
// Number of Samples/Year&nbsp;&nbsp;&nbsp;&nbsp;Filter:Analyse & User
	if(serial==5) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		arr_userid=[];
		var prog_name="patAnaUser";
		var prog_name_P="proAnaUser";
		colorfill=["#A6AF82"];
		var ind="5";
		launch_gridmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, colorfill, filter_year);
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		colorfill=["#707A43"];
		var ind="52";
		var dbana=1;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		
	}
// Number of Samples/Year and Team Filter:Analyse & Unit
	if(serial==6) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		arr_userid=[];
		colorfill=["#85B599"];
		valUnitEYU=84;//IMAGINE NECKER
		var ind="6";
		var prog_name="EYUpatDetail";
		var prog_name_P="EYUproDetail";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_valmonoselectUnit_data(unitNameStore, divMono="sunitSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
		colorfill=["#809DCC"];
		ind="62";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_valmonoselectUnit_data(unitNameStore, divMono="sunitSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
	}
// Number of Samples/Year&nbsp;&nbsp;&nbsp;&nbsp;Filter:Analyse & Phenotype
	if(serial==7) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		arr_userid=[];
		valPhe="";

		colorfill=["#FDCD6D"];
		var ind="7";
		var prog_name="patAnaPhe";
		var prog_name_P="proAnaPhe";
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_dirmultiselect_data(phenotypeStore, divMulti="qphenotypeSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
		colorfill=["#FBA90A"];
		ind="72";
		dbana=1;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		launch_dirmultiselect_data(phenotypeStore, divMulti="qphenotypeSelect_"+ind, ind, prog_name, dbana, colorfill, filter_year);
	}	
// Number of Samples/Year&nbsp;&nbsp;&nbsp;&nbsp;Filter:Analyse & Group User
	if(serial==8) {
		filter_year = [];
		sl_year = [];
		sl_value = [];
		arr_userid=[];
		var prog_name="patAnaGroup";
		var prog_name_P="proAnaGroup";
		//colorfill=["#A6AF82"];
		colorfill=["#D8BFD8"];
		var ind="8";
		launch_gridmultiselect_gridGroup_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, colorfill, filter_year);
		var dbana=0;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
		//colorfill=["#707A43"];
		colorfill=["#DA70D6"];
		var ind="82";
		var dbana=1;
		create_divSlider(ind);
		launch_valmultiselect_data(valanalyseStore, divMulti="qanalyseSelect_"+ind, ind, prog_name, prog_param, dbana, colorfill, filter_year);
	}
}

var pvalana0;
var pvalana1;

// for valAnalyse Store + User Store
var userstatGrip;
function launch_gridmultiselect_data(Store,divMulti,ind,prog_name,prog_param,colorfill,filter_year){
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
			userstatGrip = new dojox.grid.EnhancedGrid({
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
			dojo.byId("UserDiv").appendChild(userstatGrip.domNode);
			userstatGrip.startup();
			dojo.connect(userstatGrip, "onCellMouseOver", showRowTooltip);
			dojo.connect(userstatGrip, "onCellMouseOut", hideRowTooltip); 

			var sp_btclear=dojo.byId("bt_clear_"+ind);
			var id_btclear=dijit.byId("id_btclear_"+ind);
			if (id_btclear) {
				sp_btclear.removeChild(id_btclear.domNode);
				id_btclear.destroyRecursive();
			}
			var buttonform_clear= new dijit.form.Button({
				id:"id_btclear_"+ind,
				title:"Clear Selection",
				showLabel: false,
				iconClass:"clearIcon",
				style:"color:white",
				onClick:ClearSelectionInGridMulti,
			});
			buttonform_clear.startup();
			buttonform_clear.placeAt(sp_btclear,"last");
			function ClearSelectionInGridMulti() {
				var s_phe0=dijit.byId("idanaMultiSelect_"+ind).value;
				var s_phe1=dijit.byId("idanaMultiSelect_"+ind+"2").value;
				userstatGrip.selection.clear();
				arr_userid=[];

				dbana=0;
				pvalana0=s_phe0.toString();
				prog_param="&analyse="+pvalana0;
				
				colorfill=["#A6AF82"];
				launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				launch_query_data(libquery="query_" + ind, data["query_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);

				dbana=1;
				pvalana1=s_phe1.toString();
				prog_param="&analyse="+pvalana1;
				prog_param=prog_param +"&not="+"1";
				colorfill=["#707A43"];
				launch_stat_data(libchart="stat_"+ind+"2", colorfill, data["stat_"+ind+"2"+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				launch_query_data(libquery="query_" + ind+"2", data["query_"+ind+"2"+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
			}
			dojo.connect(userstatGrip, "onCellClick", userstatGrip, function(){
				var s_phe0=dijit.byId("idanaMultiSelect_"+ind).value;
				var s_phe1=dijit.byId("idanaMultiSelect_"+ind+"2").value;
				var items = userstatGrip.selection.getSelected();
 				arr_userid=[];
				dojo.forEach(items, function(item){
					arr_userid.push(userstatGrip.store.getValue(item, "UserId"));
				}, userstatGrip);
				prog_param="&analyse="+valAnalyse;

				dbana=0;
				colorfill=["#A6AF82"];
				pvalana0=s_phe0.toString();
				prog_param="&analyse="+pvalana0;
				launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				launch_query_data(libquery="query_" + ind, data["query_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);

				dbana=1;
				pvalana1=s_phe1.toString();
				prog_param="&analyse="+pvalana1;
				prog_param=prog_param +"&not="+"1";
				colorfill=["#707A43"];
				launch_stat_data(libchart="stat_"+ind+"2", colorfill, data["stat_"+ind+"2"+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				launch_query_data(libquery="query_" + ind+"2", data["query_"+ind+"2"+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
			});
		}
	});	
}




// for valAnalyse Store + GroupUser Store toto layoutDetailedGroup
var groupuserstatGrip;
function launch_gridmultiselect_gridGroup_data(Store,divMulti,ind,prog_name,prog_param,colorfill,filter_year){
	var detailedGroupStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=userGroup"+"&GrpSel="+ userid
	});

	function fetchFailedDetailedUgroup(error, request) {
		alert("lookup failed Detailed Ugroup.");
		alert(error);
	}

	function clearOldDetailedGroupList(size, request) {
                    var listGUser = dojo.byId("detailedGroupGridDiv");
                    if (listGUser) {
                        while (listGUser.firstChild) {
                           listGUser.removeChild(listGUser.firstChild);
                        }
                    }
	}
	detailedGroupStore.fetch({
		onBegin: clearOldDetailedGroupList,
		onError: fetchFailedDetailedUgroup,
		onComplete: function(items){
			detailedGroupGrid = new dojox.grid.EnhancedGrid({
				query: {Name: '*'},
				store: detailedGroupStore,
				structure: layoutDetailedGroup,
			},document.createElement('div'));
			dojo.byId("detailedGroupGridDiv").appendChild(detailedGroupGrid.domNode);
			detailedGroupGrid.startup();		
		}
	});

	function fetchFailedUserGroup(error, request) {
		alert("lookup UGroup failed.");
		alert(error);
	}

	function clearOldUserGroupList(size, request) {
                    var listUserGroup = dojo.byId("GroupUserDiv");
                    if (listUserGroup) {
                        while (listUserGroup.firstChild) {
                           listUserGroup.removeChild(listUserGroup.firstChild);
                        }

                    }
	}
	ugroupStore.fetch({
		onBegin: clearOldUserGroupList,
		onError: fetchFailedUserGroup,
		onComplete: function(items){
			groupuserstatGrip = new dojox.grid.EnhancedGrid({
				query: {groupId: '*'},
				store: ugroupStore,
				rowSelector: "0.4em",
				structure: layoutGroup,
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
			dojo.byId("GroupUserDiv").appendChild(groupuserstatGrip.domNode);
			groupuserstatGrip.startup();
			dojo.connect(groupuserstatGrip, "onCellMouseOver", showRowTooltip);
			dojo.connect(groupuserstatGrip, "onCellMouseOut", hideRowTooltip); 

			var sp_btclear=dojo.byId("bt_clear_"+ind);
			var id_btclear=dijit.byId("id_btclear_"+ind);
			if (id_btclear) {
				sp_btclear.removeChild(id_btclear.domNode);
				id_btclear.destroyRecursive();
			}
			var buttonform_clear= new dijit.form.Button({
				id:"id_btclear_"+ind,
				title:"Clear Selection",
				showLabel: false,
				iconClass:"clearIcon",
				style:"color:white",
				onClick:ClearSelectionInGridMulti,
			});
			buttonform_clear.startup();
			buttonform_clear.placeAt(sp_btclear,"last");
			function ClearSelectionInGridMulti() {
				var s_phe0=dijit.byId("idanaMultiSelect_"+ind).value;
				var s_phe1=dijit.byId("idanaMultiSelect_"+ind+"2").value;
				groupuserstatGrip.selection.clear();
				detailedGroupStore = new dojo.data.ItemFileWriteStore({
					url: url_path + "/manageData.pl?option=userGroup"+"&GrpSel="
				});
				detailedGroupGrid.setStore(detailedGroupStore);
				detailedGroupGrid.store.close();
				dojo.style(dojo.byId('dgroup'), "padding", "0 0 0 0");
				var j_ug = dojo.byId("dgroup");
				j_ug.innerHTML= "";
				arr_userid=[];

				dbana=0;
				pvalana0=s_phe0.toString();
				prog_param="&analyse="+pvalana0;				
				colorfill=["#A6AF82"];
				launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				launch_query_data(libquery="query_" + ind, data["query_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);

				dbana=1;
				pvalana1=s_phe1.toString();
				prog_param="&analyse="+pvalana1;
				prog_param=prog_param +"&not="+"1";
				colorfill=["#707A43"];
				launch_stat_data(libchart="stat_"+ind+"2", colorfill, data["stat_"+ind+"2"+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				launch_query_data(libquery="query_" + ind+"2", data["query_"+ind+"2"+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
			}

			dojo.connect(groupuserstatGrip, "onCellClick", groupuserstatGrip, function(){
				var s_phe0=dijit.byId("idanaMultiSelect_"+ind).value;
				var s_phe1=dijit.byId("idanaMultiSelect_"+ind+"2").value;
				var items = groupuserstatGrip.selection.getSelected();
 				arr_userid=[];
				dojo.forEach(items, function(item){
					arr_userid.push(groupuserstatGrip.store.getValue(item, "groupId"));
				}, groupuserstatGrip);
				prog_param="&analyse="+valAnalyse;

				dbana=0;
				colorfill=["#D8BFD8"];
				pvalana0=s_phe0.toString();
				prog_param="&analyse="+pvalana0;
				launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				launch_query_data(libquery="query_" + ind, data["query_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);

				dbana=1;
				pvalana1=s_phe1.toString();
				prog_param="&analyse="+pvalana1;
				prog_param=prog_param +"&not="+"1";
				colorfill=["#DA70D6"];
				launch_stat_data(libchart="stat_"+ind+"2", colorfill, data["stat_"+ind+"2"+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				launch_query_data(libquery="query_" + ind+"2", data["query_"+ind+"2"+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);

			});
		}
	});	
}

//formatter
function ButtonStatUserGroup(value,idx,cell) {
	var sp_val=value.toString().split("#");
	var Cbutton;
	if (cell.field == "bt") {
		Cbutton = new dijit.form.Button({
			style:"background:transparent;",
			label:"<span class='userButton'><img src='icons/user.png'></span>",
			baseClass:"userButton2",
			onClick: function(e){
				detailedGroupStore = new dojo.data.ItemFileWriteStore({
					url: url_path + "/manageData.pl?option=userGroup"+"&GrpSel="+ sp_val[0].toString()
				});
				detailedGroupGrid.setStore(detailedGroupStore);
				detailedGroupGrid.store.close();
				dojo.style(dojo.byId('dgroup'), "padding", "0 1px 0 1px");
				var j_ug = dojo.byId("dgroup");
				j_ug.innerHTML= sp_val[1].toString();
			} 
		});		
	}
	return Cbutton;
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

// for Team Unit Store
var def_unit="IMAGINE NECKER";// id=2-> 84
function launch_valmonoselectUnit_data(Store,divMono,ind,prog_name,dbana,colorfill,filter_year){
	var s_unitSelect=dijit.byId("unitSelect_"+ind);
	if(!s_unitSelect ){
		s_unitSelect = new dijit.form.FilteringSelect({
			store: Store,
			searchAttr: "name",
			value:def_unit,
			style: {width: '20em'},
			id:"unitSelect_"+ind,
			onChange: function(item) {
				valUnitEYU=s_unitSelect.item.value.toString();
				if (valUnitEYU) {
					valAnalyse=dijit.byId("idanaMultiSelect_"+ind).value;
					prog_param="&analyse="+valAnalyse;
					prog_param=prog_param+"&unit=" +valUnitEYU;
					if(dbana) {
						prog_param=prog_param +"&not="+"1";
					}
					launch_Cluster_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value);
					if(prog_name_p=="EYUproDetail") {
						launch_query_data(libquery="query_" + ind, data["query_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
					}
				}
			}
		},divMono);
		s_unitSelect.startup();
	} else {
		s_unitSelect.reset();
	}
}

// for platform Store
function launch_valmonoselect_data(Store,divMono,ind,prog_name,dbana,colorfill,filter_year){
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
					valAnalyse=dijit.byId("idanaMultiSelect_"+ind).value;
					prog_param="&analyse="+valAnalyse+"&platform="+valPlt;
					if(dbana) {
						prog_param=prog_param +"&not="+"1";
					}
					launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
					if(prog_name_p=="proAnaPlt") {
						launch_query_data(libquery="query_" + ind, data["stat_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
					}
				}
			}
		},divMono);
		s_plateformSelect.startup();
	} else {
		s_plateformSelect.reset();
	}
}

// phenotype director (unit) machine store
function launch_dirmultiselect_data(Store,divMulti,ind,prog_name,dbana,colorfill,filter_year){
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

			var qMultiSelect=registry.byId("idDirMultiSelect_"+ind);
			if(!qMultiSelect ){
				qMultiSelect = new MyCheckedMultiSelect({
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
						if (divMulti.includes(["qdirectorSelect"])) {
							valUnit=item.toString();
							if (valUnit) {
								valAnalyse=dijit.byId("idanaMultiSelect_"+ind).value;
								prog_param="&analyse="+valAnalyse;
								if(dbana) {
									prog_param=prog_param +"&not="+"1";
								}
								if(prog_name=="patAnaUnit" || prog_name_p=="proAnaUnit") {
									prog_param=prog_param+"&unit=" +valUnit;
								}
								launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
								launch_query_data(libquery="query_" + ind, data["stat_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);

							}
						}
						if (divMulti.includes(["qphenotypeSelect"])) {
							valPhe=item.toString();
							if (valPhe) {
								valAnalyse=dijit.byId("idanaMultiSelect_"+ind).value;
								prog_param="&analyse="+valAnalyse;
								if(dbana) {
									prog_param=prog_param +"&not="+"1";
								}
								if(prog_name=="patAnaPhe" || prog_name_p=="proAnaPhe") {
									prog_param=prog_param+"&phe=" +valPhe;
								}
								launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
								launch_query_data(libquery="query_" + ind, data["stat_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
							}
						}
						if (divMulti.includes(["qmachineSelect"])) {
							valMac=item.toString();
							if (valMac) {
								valAnalyse=dijit.byId("idanaMultiSelect_"+ind).value;
								prog_param="&analyse="+valAnalyse;
								if(dbana) {
									prog_param=prog_param +"&not="+"1";
								}
								if(prog_name=="patAnaMac" || prog_name_p=="proAnaMac") {
									prog_param=prog_param+"&machine=" +valMac;
								}
								launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
								launch_query_data(libquery="query_" + ind, data["stat_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
							}
						}
					}
				},divMulti);
   				qMultiSelect.startup();
				var sp_btclear=dom.byId("bt_clear_"+ind);
				var id_btclear=registry.byId("id_btclear_"+ind);
				if (id_btclear) {
					sp_btclear.removeChild(id_btclear.domNode);
					id_btclear.destroyRecursive();
				}
				var buttonform_clear= new Button({
					id:"id_btclear_"+ind,
					title:"Clear Selection",
					showLabel: false,
					iconClass:"clearIcon",
					style:"color:white",
					onClick:ClearSelectionInDirMulti,
				});
				buttonform_clear.startup();
				buttonform_clear.placeAt(sp_btclear,"last");

				function ClearSelectionInDirMulti() {
					qMultiSelect.reset();
					qMultiSelect._updateSelection();
					arr_userid=[];
					valAnalyse=dijit.byId("idanaMultiSelect_"+ind).value;					
					prog_param="&analyse="+valAnalyse;
					if(dbana && prog_name!="patAnaUser") {
						valUnit=0;
						prog_param=prog_param +"&not="+"1";
					}
					if(prog_name=="patAnaUnit") {
						valUnit=0;
						prog_param=prog_param+"&unit=" +valUnit;
					}
					if(dbana && prog_name!="patAnaPhe") {
						valPhe=0;
						prog_param=prog_param +"&not="+"1";
					}
					if(prog_name=="patAnaPhe") {
						valPhe=0;
						prog_param=prog_param+"&phe=" +valPhe;
					}
					if(dbana && prog_name!="patAnaMac") {
						valMac="";
						prog_param=prog_param +"&not="+"1";
					}
					if(prog_name=="patAnaMac") {
						valMac="";
						prog_param=prog_param+"&machine=" +valMac;
					}
					launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
					launch_query_data(libquery="query_" + ind, data["query_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				}
			} else {
				qMultiSelect.reset();
				qMultiSelect._updateSelection();
			}
		}
	)
}

// for valAnalyseStore
function launch_valmultiselect_data(Store,divMulti,ind,prog_name,prog_param,dbana,colorfill,filter_year){
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
							prog_param="&analyse="+valAnalyse;
							if(dbana) {
								prog_param=prog_param +"&not="+"1";
							}
							if(prog_name=="patAnaUser" || prog_name=="patAnaGroup") {
								if(dbana) {
									pvalana1=valAnalyse;
								} else {
									pvalana0=valAnalyse;
								}
							}
							if(prog_name=="patAnaPlt") {
								valPlt=dijit.byId("plateformSelect_"+ind).get("value");
								prog_param=prog_param+"&platform="+valPlt;
							}							
							if(prog_name=="patAnaUnit") {
								valUnit=dijit.byId("idDirMultiSelect_"+ind).get("value");
								prog_param=prog_param+"&unit=" +valUnit;
							}
							if(prog_name=="patAnaPhe") {
								valPhe=dijit.byId("idDirMultiSelect_"+ind).get("value");
								prog_param=prog_param+"&phe=" +valPhe;
							}
							if(prog_name=="patAnaMac") {
								valMac=dijit.byId("idDirMultiSelect_"+ind).get("value");
								prog_param=prog_param+"&machine=" +valMac;
							}

							if(prog_name=="EYpatDetail"|| prog_name=="EYUpatDetail" || prog_name_p=="EYproDetail" || prog_name_p=="EYUproDetail") {
								launch_Cluster_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value);
								if(prog_name_p=="EYUproDetail") {
									prog_param=prog_param + "&unit=" + valUnitEYU;
								}
								launch_query_data(libquery="query_" + ind, data["query_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
							} else {
								launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
								launch_query_data(libquery="query_" + ind, data["query_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
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
//			valPhe="";
			valUnitEYU=84; //IMAGINE NECKER
			prog_name_p="";
			prog_param="&analyse="+valAnalyse;
			if(prog_name=="patAnaUser") {
				if(dbana) {
					pvalana1=valAnalyse;
				} else {
					pvalana0=valAnalyse;
				}
				prog_name_p="proAnaUser";
			}
			if(prog_name=="patAnaGroup") {
				if(dbana) {
					pvalana1=valAnalyse;
				} else {
					pvalana0=valAnalyse;
				}
				prog_name_p="proAnaGroup";
			}

			if(prog_name=="patAnaPlt") {
				prog_param=prog_param+"&platform="+valPlt;
				prog_name_p="proAnaPlt";
			}
			if(prog_name=="patAnaUnit") {
				prog_param=prog_param+"&unit=" +valUnit;
				prog_name_p="proAnaUnit";
			}
			if(prog_name=="patAnaPhe") {
				prog_param=prog_param+"&phe=" +valPhe;
				prog_name_p="proAnaPhe";
				
			}
			if(prog_name=="patAnaMac") {
				prog_param=prog_param+"&machine=" +valMac;
				prog_name_p="proAnaMac";				
			}
			if(dbana) {
				prog_param=prog_param +"&not="+"1";
			}

			if(prog_name=="EYUpatDetail") {
				valUnitEYU=84; //IMAGINE NECKER
				prog_name_p="EYUproDetail";
			}
			if(prog_name=="EYpatDetail") {
				prog_name_p="EYproDetail";
			}
			if(prog_name=="EYpatDetail" || prog_name=="EYUpatDetail" || prog_name_p=="EYproDetail" || prog_name_p=="EYUproDetail") {
				launch_Cluster_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value);
				if(prog_name_p=="EYUproDetail") {
					prog_param=prog_param + "&unit=" + valUnitEYU;
				}
				launch_query_data(libquery="query_" + ind, data["stat_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
			} else {
				launch_stat_data(libchart="stat_"+ind, colorfill, data["stat_"+ind+"Store"], prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
				launch_query_data(libquery="query_" + ind, data["stat_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
			}
		}
	)
}

function launch_stat_data(libchart,colorfill,Store,prog_name,prog_param,dbana,filter_year,sl_year,sl_value,arr_userid){
	var ind=libchart.split("_");
	var button_grid="button_" + ind[1];	
	if (prog_name=="patAnaUser" || prog_name=="patAnaGroup") {
		if (dbana) {
			prog_param="&analyse="+pvalana1;
		} else {
			prog_param="&analyse="+pvalana0;
		}
	}
	if (dbana && prog_name=="patAnaUser") {
		prog_param=prog_param +"&not="+"1";
	}
	if (dbana && prog_name=="patAnaGroup") {
		prog_param=prog_param +"&not="+"1";
	}
	if (arr_userid.length>=1 && prog_name=="patAnaUser") {
		prog_param=prog_param+"&user="+ arr_userid;
	}
	if (arr_userid.length>=1 && prog_name=="patAnaGroup") {
		prog_param=prog_param+"&group="+ arr_userid;
	}
	var url_stat;
	if (filter_year.length>=1) {
		url_stat="/stat.pl?opt="+prog_name + prog_param +"&year="+ filter_year.toString();
	} else {
		url_stat="/stat.pl?opt="+prog_name + prog_param ;
	}
//	console.log(url_stat);
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
				if (prog_name=="patAnaUser" || prog_name=="patAnaGroup") {
					if (dbana) {
						valAnalyse=pvalana1;
					} else {
						valAnalyse=pvalana0;
					}
				}
				if(okmatch) {
					lib_valAnalyse = "Not " + valAnalyse;
				} else {
					lib_valAnalyse = valAnalyse;
				}
				var arrayNBpat=[];
				for(var i = 0; i < items.length; i++){
					arrayNBpat.push(+items[i].nbPat);
				}
				if (items.length === 1) {
					chart.addAxis("y", { vertical: true, fixLower: "major", fixUpper: "major",min: 0,max: arrayNBpat[0] * 1.2,
						titleFont: "normal normal bold 8pt Arial",
						title:"Number of '" + lib_valAnalyse + "'"});

				} else {
					chart.addAxis("y", { vertical: true, fixLower: "major", fixUpper: "major",
						titleFont: "normal normal bold 8pt Arial",
						title:"Number of '" + lib_valAnalyse + "'"});
				}
				var total=0;
				for(var n = 0; n < arrayNBpat.length; n++){
					total+=arrayNBpat[n];
				}
				var serie_legend;
				if(prog_name=="patAnaUser" || prog_name=="patAnaGroup") {
					serie_legend="Number of Patients '" + lib_valAnalyse + "' per year" +" <small>(<b title='Cumulative Total'>"+total+"</b>) #Users (<b>" + arr_userid.length + "</b>)</small>";
					if(prog_name=="patAnaGroup") {
						serie_legend="Number of Patients '" + lib_valAnalyse + "' per year" +" <small>(<b title='Cumulative Total'>"+total+"</b>) #Groups (<b>" + arr_userid.length + "</b>)</small>";
					}
				} else {
					serie_legend="Number of Patients '" + lib_valAnalyse + "' per year" +" <small>(<b title='Cumulative Total'>"+total+"</b>)</small>";
				}
//				chart.addSeries(serie_legend,arrayNBpat,{stroke: {color: colorfill[0],width:4},fill: colorfill[0]});
				var data = arrayNBpat.map((v,i)=>({x:i+1, y:v}));
				chart.addSeries(serie_legend, data, {stroke:{color:colorfill[0],width:4}, fill:colorfill[0]});


				var anim4b = new dojox.charting.action2d.Tooltip(chart, 'default',{
					text:function(o) {
						return("nb: " + dojo.number.format((o.y),{places:0})
						);
					}
				});
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

function launch_query_data(libquery,Store,prog_name,prog_param,dbana,filter_year,sl_year, sl_value,arr_userid){
	var ind=libquery.split("_");
	var button_grid_P="button_" + ind[1] + "_P";
	var doForquery=dojo.byId(button_grid_P);	
	if (doForquery) {
		if (arr_userid.length>=1 && prog_name=="proAnaUser") {
			prog_param=prog_param+"&user="+ arr_userid;
		}	
		if (arr_userid.length>=1 && prog_name=="proAnaGroup") {
			prog_param=prog_param+"&group="+ arr_userid;
		}	
		var url_stat;
		if (filter_year.length>=1) {
			url_stat="/stat.pl?opt="+prog_name + prog_param +"&year="+ filter_year.toString();
		} else {
			url_stat="/stat.pl?opt="+prog_name + prog_param ;
		}
//		console.log(url_stat);
		var xhrArgsP={
			url: url_path + url_stat,
			handleAs: "json",
             		timeout: 0, // infinite no time out
			load: function (res) {
				Store = new dojox.data.AndOrWriteStore({data: res});
				var str_find="not=1";
				var okmatch=url_stat.match(str_find);
				var lib_valAnalyse;
				if(okmatch) {
					lib_valAnalyse = "Not " + valAnalyse;
					if(prog_name=="proAnaUser"||prog_name=="proAnaGroup") {lib_valAnalyse = "Not " + pvalana1;}
				} else {
					lib_valAnalyse = valAnalyse;
					if(prog_name=="proAnaUser"||prog_name=="proAnaGroup") {lib_valAnalyse = pvalana0;}
				}
				if (["proAnaPhe","proAnaUser","proAnaGroup","proAnaPlt","proAnaUnit","proAnaMac","EYproDetail","EYUproDetail"].includes(prog_name)) {
					var gotList = function(items, request){
						var NBPROJ = 0;
						dojo.forEach(items, function(i){
							if (Store.getValue(i,"project")) {NBPROJ++}
						});
						var spU = dojo.byId("nbrproj_"+ind[1] + "_P");
						spU.innerHTML= "("+NBPROJ+")";
					}
					Store.fetch({
  						onComplete: gotList,
 					});
				}
				launch_ButtonGrid_P(button_grid_P,Store,prog_name,lib_valAnalyse,ind[1]);
			}
		}
		var defferedP = dojo.xhrGet(xhrArgsP);
	};
}

function launch_Cluster_data(libchart,colorfill,Store,prog_name,prog_param,dbana,filter_year,sl_year,sl_value){
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
//	console.log(url_stat);
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
				var totalFusion=0;
				for(var i = 0; i < maxIColor; i++){
					var cfill=getRandomColor();
					var total=0;
					for(var n = 0; n < ToTSerie[i].length; n++){
						total+=ToTSerie[i][n];
					}
					totalFusion+=total;
					chart.addSeries(SerieName[i]+"<small>(<b title='Cumulative Total'>"+total+"</b>)</small>",Serie[i],{stroke: {color: colorfill[0]},fill: cfill});
				}

				var anim4b = new dojox.charting.action2d.Tooltip(chart, 'default');
				chart.render();
				var liblegend="legend_"+ind[1];
				var legend = dijit.byId(liblegend);
				if (legend != undefined) {
					legend.destroyRecursive(true); 
				}
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
			if(prog_name=="EYpatDetail"||prog_name=="EYUpatDetail" || prog_name_p=="EYproDetail" || prog_name_p=="EYUproDetail") {
				launch_Cluster_data(libchart, colorfill, Store, prog_name, prog_param, dbana, filter_year, sl_year, sl_value);
				if(prog_name_p=="EYUproDetail") {
					prog_param=prog_param + "&unit=" + valUnitEYU;
				}
				launch_query_data(libquery="query_" + ind, data["query_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
			} else {
				launch_stat_data(libchart, colorfill, Store, prog_name, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);				
				launch_query_data(libquery="query_" + ind, data["query_"+ind+"Store"], prog_name_p, prog_param, dbana, filter_year, sl_year, sl_value, arr_userid);
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

function launch_ButtonGrid_P(button_grid,Store,prog_name,lib_valAnalyse,ind){
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
		var menusObjectS = {
			cellMenu: new dijit.Menu(),
		};

		var val_layoutGrid;
		if(prog_name=="proAnaPhe") {val_layoutGrid="layoutProjPheGrid"}
		if(prog_name=="proAnaMac") {val_layoutGrid="layoutProjMacGrid"}
		if(prog_name=="proAnaPlt") {val_layoutGrid="layoutProjPltGrid"}
		if(prog_name=="EYproDetail") {val_layoutGrid="layoutProjPltGrid"}
		if(prog_name=="EYUproDetail") {val_layoutGrid="layoutProjTeamUnitGrid"}
		if(prog_name=="proAnaUnit") {val_layoutGrid="layoutProjUnitGrid"}
		if(prog_name=="proAnaUser") {val_layoutGrid="layoutProjUserGrid"}
		if(prog_name=="proAnaGroup") {val_layoutGrid="layoutProjGroupGrid"}
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
				return colIndex != 1 && field != 'Row' && field != 'year';
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
		if (button_grid.includes(["_P"])) { serie_legend="NGS Project List '" + lib_valAnalyse + "' per year";}

		if (["proAnaPhe","proAnaUser","proAnaGroup","proAnaPlt","proAnaUnit","proAnaMac","EYproDetail","EYUproDetail"].includes(prog_name)) {
			var gotList = function(items, request){
				var NBPROJ = 0;
				dojo.forEach(items, function(i){
					if (Store.getValue(i,"project")) {NBPROJ++}
				});
				if (button_grid.includes(["_P"])) {serie_legend+=" ("+NBPROJ+")"};
			}
			Store.fetch({
  				onComplete: gotList,
 			});
		}
		var style_grid="width:35em;height:48em";
		var title_dialog=serie_legend+spPrint;
		if (["proAnaMac"].includes(prog_name)) {
			var val_DirMulti=dijit.byId("idDirMultiSelect_"+ind).get("value");
			if (val_DirMulti.length>0) {
				title_dialog+="<br>Other Filter: "+val_DirMulti.toString();
			}
		}
		if (["proAnaPhe"].includes(prog_name)) {
			var val_DirMulti;
			getVal_Multiselect(ind, function(values){
  				val_DirMulti=values;
			});
			if (val_DirMulti.length>0) {
				title_dialog+="<br>Other Filter: "+val_DirMulti.toString();
			}
		}
		if (["proAnaUnit"].includes(prog_name)) {
			var val_DirMulti;
			getVal_Multiselect(ind, function(values){
  				val_DirMulti=values;
			});
			var sp_val=val_DirMulti.toString().split(",");
			var cum_val="";
			for(var i = 0; i < sp_val.length; i++){
				var sp_label=sp_val[i].split(" | ");
				cum_val+=sp_label[0]+",";
			}
			cum_val=cum_val.slice(0,-1);
			title_dialog+="<br>Other Filter: "+cum_val;
		}
		if (["proAnaPlt"].includes(prog_name)) {
			var Plt=dijit.byId("plateformSelect_"+ind).get("value");
			title_dialog+="<br>Other Filter: "+Plt;
		}
		if (["proAnaUser"].includes(prog_name)) {
			var items = userstatGrip.selection.getSelected();
 			var arr_user=[];
			dojo.forEach(items, function(item){
				arr_user.push(userstatGrip.store.getValue(item, "Name"));
			}, userstatGrip);
			title_dialog+="<br>Other Filter: "+arr_user.toString();
		}
		if (["proAnaGroup"].includes(prog_name)) {
			var items = groupuserstatGrip.selection.getSelected();
 			var arr_user=[];
			dojo.forEach(items, function(item){
				arr_user.push(groupuserstatGrip.store.getValue(item, "Name"));
			}, groupuserstatGrip);
			title_dialog+="<br>Other Filter: "+arr_user.toString();
		}

		if(prog_name=="proAnaMac") {style_grid="width:48em;height:48em"}
		if(prog_name=="EYUproDetail") {style_grid="width:50em;height:48em"}
		Dial = new dijit.Dialog({
       			title:title_dialog,
			//style:"width:35em;height:48em",
			style:style_grid,
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
		Grid.resize();
	}
}

function getVal_Multiselect(ind, callback) {
    require(["dojox/form/CheckedMultiSelect"], function() {
	var widget = dijit.byId("idDirMultiSelect_" + ind);
	function getDisplayedLabelsFromOptions(widget){
		var selected = widget.get ? widget.get('value') : widget.value;
 		if(selected == null) return [];
		if(!Array.isArray(selected)) selected = [selected];
		var opts = Object.keys(widget.options || {}).map(function(k){ return widget.options[k]; });
		var labels = selected.map(function(v){
			var found = opts.find(function(o){ return String(o.value) === String(v); });
 			return found ? found.label : null;
 		}).filter(Boolean);
 		return labels;
 	}
        var labels = getDisplayedLabelsFromOptions(widget);
        callback(labels);
    });
}




