/**
 * @author plaza
 */

require(["dijit/Dialog","dojo/data/ItemFileReadStore","dojo/data/ItemFileWriteStore","dojo/parser", "dijit/layout/BorderContainer", "dijit/layout/ContentPane","dijit/DropDownMenu","dijit/Menu","dijit/MenuItem", "dijit/MenuSeparator", "dijit/PopupMenuItem","dijit/form/ComboBox","dijit/form/CheckBox","dijit/form/Form",
"dijit/TitlePane","dijit/form/TextBox","dijit/form/Textarea","dojox/grid/cells/dijit","dojox/grid/cells",
"dijit/form/Button","dijit/form/FilteringSelect","dijit/form/ValidationTextBox",
"dojox/grid/enhanced/plugins/Pagination","dojox/grid/enhanced/plugins/Filter","dojox/grid/EnhancedGrid",
"dojox/grid/enhanced/plugins/DnD",
"dojox/grid/enhanced/plugins/Menu","dojox/grid/enhanced/plugins/NestedSorting",
"dojox/grid/enhanced/plugins/IndirectSelection","dojox/grid/enhanced/plugins/exporter/CSVWriter",
"dojox/grid/enhanced/plugins/exporter/TableWriter","dojox/grid/enhanced/plugins/Printer",
"dojo/ready","dojo/store/Memory", "dijit/registry", "dojo/on",
"dijit/Toolbar","dijit/ToolbarSeparator",
"dojox/data/AndOrReadStore","dojox/data/AndOrWriteStore",
"dojo/_base/declare","dojo/aspect","dojo/_base/lang",
"dijit/form/CurrencyTextBox","dojox/widget/Standby","dojo/date/locale",
"dojo/store/Observable"
]);

var layoutUsers;
var layoutUnit;
var layoutTeam;
var layoutTeamUnit;

//store
var jsonStore;
var teamUnitNameStore;
var unitStore;
var teamStore;
var gsiteStore;
var ginstituteStore;
var siteStore;
var siteNameStore;
var instituteNameStore;
var unitNameStore;
var groupNameStore;

//Grid
var gridT;
var gridTU;
var unitGrid;
var gridUser;

var lastId;
var lastIdnext;
	
var boxlog;
var boxpw;

var cssFiles = ["print_style1.css"];

var filterValue;
var sitefilterSelect;
var institutefilterSelect;
var groupfilterSelect;
var standby;

var spid_btlog;
var btlog;
var logged=1;
var initl=1;
var logname="";

dojo.addOnLoad(function() {
	spid_btlog = dojo.byId("btlog_0");
	indice=relog(logname,spid_btlog);
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

function hide_tab() {
	document.getElementById("TabMain").style.display = "none";
//	document.getElementById("TabMainBottom").style.display = "none";
	document.getElementById("TabAddUser").style.display = "none";
	document.getElementById("TabEditUser").style.display = "none";
//	dojo.style("refreshUserDB", {'visibility':'hidden'});
	dijit.byId("refreshUserDB").set("disabled",true);
	dijit.byId("buttonAddUserDB").set("disabled",true);
	dijit.byId("saveUserDB").set("disabled",true);
	dijit.byId("editUserDB").set("disabled",true);
	dijit.byId("buttonGroupDB").set("disabled",true);
}

function show_tab() {
	document.getElementById("TabMain").style.display = "block";
//	document.getElementById("TabMainBottom").style.display = "block";
	document.getElementById("TabAddUser").style.display = "block";
	document.getElementById("TabEditUser").style.display = "block";
//	dojo.style("refreshUserDB", {'visibility':'visible'});
	dijit.byId("refreshUserDB").set("disabled",false);
	dijit.byId("buttonAddUserDB").set("disabled",false);
	dijit.byId("saveUserDB").set("disabled",false);
	dijit.byId("editUserDB").set("disabled",false);
	dijit.byId("buttonGroupDB").set("disabled",false);
}

function launch_connect(items, request){
		dijit.byId('ulogin').show();
}

function okfunction(items,request){
	if (items[0].name.toString() == "BAD_LOGIN") {
		logged=0;
		for(var i=0; i<4; i++) {
			var a = dijit.byId("id_btlog"+"_"+i);
			if (a) {
				dijit.byId("id_btlog"+"_"+i).set("label", "Not Logged");
				dijit.byId("id_btlog"+"_"+i).set("iconClass","logoutIcon");
			}
		}
		hide_tab();
		return
	}
	logged=1;
	logname=username;

	if (initl) {
		init();
		logged=1;
		logname=username;
	}
	for(var i=0; i<4; i++) {
		var a = dijit.byId("id_btlog"+"_"+i);
		if (a) {
			dijit.byId("id_btlog"+"_"+i).set("label", logname);
			dijit.byId("id_btlog"+"_"+i).set("iconClass","loginIcon");
		}
	}
	initl=0;
	show_tab()
}

function setPasswordlocal(){
	var passwd = document.getElementById('passwd').value;
	var username = document.getElementById('username').value;
	dojo.cookie("username", username, { expires: 1 });
	dojo.cookie("passwd", passwd, { expires: 1 });
	dijit.byId('ulogin').hide();
	dijit.byId("loginForm").reset();				
	checkPassword(okfunction);  				
}

function sortDateGrid(Store, Date) {
	Store.comparatorMap = {};
	Store.comparatorMap[Date] = function (a,b) {
		var af = dojo.date.locale.parse(a, {datePattern:"dd/MM/yyyy", selector:"date",
			locale:"fr-fr",formatLength: "short"});
		var bf = dojo.date.locale.parse(b, {datePattern:"dd/MM/yyyy", selector:"date",
			locale:"fr-fr",formatLength: "short"});
    		var c = dojo.date.compare(af, bf);
    		return c;
	};
}

function reloadMemStore(sc) {
 	var xhrArgsEx={
		url: url_path + "/polyusers_up.pl?option=teamUnitName",
		handleAs: "json",
		sync:sc,
		load: function (res) {
 			teamUnitNameStore = new dojo.store.Memory({data: res, idProperty: "value"});
			teamUnitNameStore.query().forEach(function(e){
				var e_unit=e.unit;
				var e_value=e.value;
				var e_name=e.name;
				teamUnitNameStore.remove(e);
				teamUnitNameStore.put({unit:e_unit, value:e_value, name:e_name});
			});
		}
	}
	var defferedEx = dojo.xhrGet(xhrArgsEx);
}

function reloadMemGroupStore(sc) {
 	var xhrArgsEx={
		url: url_path + "/polyusers_up.pl?option=groupName",
		handleAs: "json",
		sync:sc,
		load: function (res) {
 			groupNameStore = new dojo.store.Memory({data: res, idProperty: "value"});
			groupNameStore.query().forEach(function(e){
				var e_value=e.value;
				var e_name=e.name;
				groupNameStore.remove(e);
				groupNameStore.put({value:e_value, name:e_name});
			});
		}
	}
	var defferedEx = dojo.xhrGet(xhrArgsEx);
}

var selhgmd;
function activeRadioButtonView(value,idx,cell) {
	var Cbutton;	
	if (cell.field == "hgmd") {
		Cbutton = new dijit.form.CheckBox({
			style:"border:0;margin: 0; padding: 0;text-align:center;",
			onChange: function(e){
				var id = gridUser.getItem(idx).id;
				if(e){selhgmd="1:"+id;cell.customStyles.push("background: grey;");Cbutton.attr('checked', true);value=1;} else {
				selhgmd="0:"+id;Cbutton.attr('checked', false);value=0;};
			} 
		});
		
		if (value==1) {
			cell.customStyles.push("background: grey;");	
			Cbutton.attr('checked', true);
			Cbutton.set('checked', true);
			selhgmd="1";
		} else {selhgmd="0";Cbutton.attr('checked', false);Cbutton.set('checked', false);}
	}
	return Cbutton;
}


//reloadMemStore(sc="true");
function init(){
	reloadMemStore(sc="true");
	reloadMemGroupStore(sc="false");
//################# Standby for loading : #############################
	standby = new dojox.widget.Standby({
	       	target: "winStandby"
	});
	document.body.appendChild(standby.domNode);
	standby.startup();
//################# 
	standbyShow();
	var layoutUsers = [
	{name: "Row",get: getRow,width: 3,styles: 'text-align:center;'},
	{field: "firstname",name: "First Name",width: '8',styles: 'text-align:center;', editable: true},
	{field: "name",name: "Last Name",width: '10',styles: 'text-align:center;', editable: true},
	{field: "group",name: "Group",width: '12',styles: 'text-align:center;', editable: true,
		type:'dojox.grid.cells._Widget', widgetClass:'dijit.form.ComboBox',
		widgetProps:{store:groupNameStore,searchAttr: 'name',required:false},formatter:userColorGroup
	},
	{field: "email",name: "Email",width: '18',styles: 'text-align:center;', editable: true},
	{ field: "hgmd",name: "HGMD",width: '3',styles:"text-align:center;",
		type: 'dojox.grid.cells.CheckBox',
		formatter:activeRadioButtonView,
		editable: true},
	{field: "team",name: "Team",width: '40',styles: 'text-align:center;',formatter:comma, editable: true,
		type:'dojox.grid.cells._Widget', widgetClass:'dijit.form.FilteringSelect',
		widgetProps:{store:teamUnitNameStore,required:false}},
	{field: "unit",name: "Lab Code",width: '10',styles: 'text-align:center;'},
	{field: "site",name: "Site",width: '8',styles: 'text-align:center;'},
	{field: "organisme",name: "Institute",width: '8',styles: 'text-align:center;'},
	{field: "responsable",name: "Team Leader",width: '25',styles: 'text-align:center;',formatter:comma},
	{field: "director",name: "Director",width: '14',styles: 'text-align:center;'},
	{field: "cDate", name: "Date", datatype:"date", width: '7',styles: 'text-align:center;'},
	];
	var url_user = url_path+"/polyusers_view.pl";
	jsonStore = new dojox.data.AndOrWriteStore({ url: url_user });

	function clearOldUserList(size, request) {
		var listUser = dojo.byId("gridUserDiv");
		if (listUser) {
 			while (listUser.firstChild) {
				listUser.removeChild(listUser.firstChild);
			}
		}
	}
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}
	var menusObjectS = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};
	menusObjectS.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectS.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectS.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridUser);"}));
	menusObjectS.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridUser);"}));
	menusObjectS.cellMenu.startup();

	menusObjectS.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectS.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectS.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridUser);"}));
	menusObjectS.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(gridUser);"}));
	menusObjectS.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridUser);"}));
	menusObjectS.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(gridUser);"}));
	menusObjectS.selectedRegionMenu.startup();

//	if(!gridUser) {
	jsonStore.fetch({
		onBegin: clearOldUserList,
		onError: fetchFailed,
		onComplete: function(items){
			gridUser = new dojox.grid.EnhancedGrid({
        			id: "gridUser",
				store: jsonStore,
        			structure: layoutUsers,
    				query: {id: '*'},
				loadingMessage:'Loading, please wait',
				canSort:function(colIndex, field){
					return colIndex != 1 && field != 'hgmd';
				},
				selectionMode:"multiple",
				plugins: {
 					filter: {
						closeFilterbarButton: true,
						ruleCount: 5,
						itemsName: "name"
					},
					indirectSelection: {
						width: "1.5em",
						styles: "text-align: center;",
					},
          				pagination: {
              					pageSizes: ["25","50", "100", "All"],
              					description: true,
              					sizeSwitch: true,
              					pageStepper: true,
              					gotoButton: true,
              					maxPageStep: 5,
						defaultPageSize: 25,
              					position: "bottom"
          				},
					nestedSorting: true,
					exporter: true,
					printer:true,
					menus:menusObjectS
				}
			}, document.createElement('div'));
			dojo.byId("gridUserDiv").appendChild(gridUser.domNode);
			sortDateGrid(jsonStore, date="cDate");
			gridUser.startup();
			gridUser.setStore(jsonStore);
			gridUser.store.fetch({onComplete:standbyHide});
//			gridUser.store.fetch({});
			dojo.connect(gridUser, "onMouseOver", showTooltipField);
			dojo.connect(gridUser, "onMouseOut", hideTooltipField); 
		}
	});

	var unitStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/polyusers_up.pl?option=unit"
	});

	dojo.connect(dijit.byId("searchUserForm"),"onKeyDown",function(e) {  
    		if (e.keyCode == dojo.keys.ENTER) {
			wordsearchUser();
		}
	}); 

   	dojo.xhrGet({
            url: url_path + "/polyusers_up.pl?option=institute",
            handleAs: "json",
            load: function (res) {
 		ginstituteStore = new dojo.store.Memory({data: res});
           }
        });

   	dojo.xhrGet({
            url: url_path + "/polyusers_up.pl?option=instituteName",
            handleAs: "json",
            load: function (res) {
 		instituteNameStore = new dojo.store.Memory({data: res});
           }
        });

   	dojo.xhrGet({
            url: url_path + "/polyusers_up.pl?option=site",
            handleAs: "json",
            load: function (res) {
 		gsiteStore = new dojo.store.Memory({data: res});
           }
        });

   	dojo.xhrGet({
            url: url_path + "/polyusers_up.pl?option=siteName",
            handleAs: "json",
            load: function (res) {
 		siteNameStore = new dojo.store.Memory({data: res});
           }
        });

   	dojo.xhrGet({
            url: url_path + "/polyusers_up.pl?option=unitName",
            handleAs: "json",
            load: function (res) {
 		unitNameStore = new dojo.store.Memory({data: res});
           }
        });

	// Combo Institute	
	institutefilterSelect = new dijit.form.ComboBox({
		id: "instituteSelect",
		name: "institute",
		value: "",
		autoComplete: true,
		placeHolder: "Enter or Select an Institute",
		regExp:"[a-zA-Z0-9-_/ ]+",
		uppercase:"true",
		invalidMessage:"no accent, no apostrophe",
		required:"true",
		store: ginstituteStore,
		searchAttr: "organisme"
	},"instituteSelect");

	// Combo Site
	sitefilterSelect = new dijit.form.ComboBox({
		id: "site",
		name: "site",
		required:"true",
		maxlength:20,
		placeHolder: "Enter or Select a Site",
		regExp:"[a-zA-Z0-9-_/ ]+",
		uppercase:"true",
		invalidMessage:"no accent, no apostrophe",
		autoComplete: true,
		store: gsiteStore,
		searchAttr: 'site',
		labelattr:"site",
	},"site");

	// FilteringSelect Group
	groupfilterSelect = new dijit.form.FilteringSelect({
		id: "groupSelect",
		name: "group",
		value: "",
		style: "width: 10em;",
		placeHolder: "Enter a Group",
		required:"false",
		store: groupNameStore,
		searchAttr: "name"
	},"groupSelect");

// New User
	formUnitDBDlg = dijit.byId("divUnitDB");
	dojo.connect(dijit.byId("buttonAddUnitDB"), "onClick", function(e) {
		checkPassword(okfunction);
		if(! logged) {
			return
		}
		institutefilterSelect.set('store',ginstituteStore);
		institutefilterSelect.startup();
		sitefilterSelect.set('store',gsiteStore);
		sitefilterSelect.startup();
		groupfilterSelect.set('store',groupNameStore);
		groupfilterSelect.startup();
		formUnitDBDlg.show();
	});
	formTeamDlg = dijit.byId("teamDialog");
	dojo.connect(dijit.byId("viewTeam"), "onClick", function(e) {

		var layoutTeam = [
		{name: "Row",get: getRow,width: 3,styles: 'text-align:center;'},
		{field: "teamId",name: "ID",width: 3,styles: 'text-align:center;'},
		{field: "name",name: "Name",width: '44',styles: 'text-align:center;', editable: true},
		{field: "Leaders",name: "Leaders",width: '15',styles: 'text-align:center;', editable: true},
		{field: "Unit",name: "Lab Code",width: '10',styles: 'text-align:center;'},
		{field: "Institute",name: "Institute",width: '8',styles: 'text-align:center;'},
		{field: "Site",name: "Site",width: '10',styles: 'text-align:center;'},
		];

		var menusObjectT = {
			cellMenu: new dijit.Menu(),
			selectedRegionMenu: new dijit.Menu()
		};

		menusObjectT.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
		menusObjectT.cellMenu.addChild(new dijit.MenuSeparator());	
		menusObjectT.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridT);"}));
		menusObjectT.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridT);"}));
		menusObjectT.cellMenu.startup();

		menusObjectT.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
		menusObjectT.selectedRegionMenu.addChild(new dijit.MenuSeparator());
		menusObjectT.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridT);"}));
		menusObjectT.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(gridT);"}));
		menusObjectT.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridT);"}));
		menusObjectT.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(gridT);"}));
		menusObjectT.selectedRegionMenu.startup();

		var url_team = url_path+"/polyusers_up.pl?option=team";
		var teamStore = new dojo.data.ItemFileWriteStore({ url: url_team });
		if(!gridT) {
			teamStore.fetch({
			onBegin: clearOldGridTList,
			onError: fetchFailed,
			onComplete: function(items){
				gridT = new dojox.grid.EnhancedGrid({
					id:'gridT',
					store: teamStore,
					structure: layoutTeam,
					rowSelector: "0.4em",
					selectionMode: 'multiple',
					plugins: {
 						filter: {
							closeFilterbarButton: true,
							ruleCount: 5,
							itemsName: "name"
						},
          					pagination: {
              						pageSizes: ["25", "50", "All"],
              						description: true,
              						sizeSwitch: true,
              						pageStepper: true,
              						gotoButton: true,
              						maxPageStep: 4,
							defaultPageSize: 22,
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
						menus:menusObjectT
					}
				},document.createElement('div'));
				dojo.byId("gridTDiv").appendChild(gridT.domNode);
				gridT.startup();
			}
		});
		} else {
			gridT.store.close();
			gridT.setStore(teamStore);
			dijit.byId(gridT)._refresh();
		}

		function clearOldGridTList(size, request) {
			var listGridT = dojo.byId("gridTDiv");
			if (listGridT) {
 				while (listGridT.firstChild) {
					listGridT.removeChild(listGridT.firstChild);
				}
			}
		}
		function fetchFailed(error, request) {
			alert("lookup failed.");
			alert(error);
		}
		checkPassword(okfunction);
		if(! logged) {
			return
		}
		formTeamDlg.show();
	});
	formUserDBDlg = dijit.byId("divUserDB");
	dojo.connect(dijit.byId("buttonAddUserDB"), "onClick", function(e) {
		spid_btlog = dojo.byId("btlog_1");
		relog(logname,spid_btlog);
		checkPassword(okfunction);
		if(! logged) {
			return
		}

		var sp_btcloseadduser=dojo.byId("bt_close_adduser");
		var btcloseadduser=dijit.byId("id_bt_closeadduser");
		if (btcloseadduser) {
			sp_btcloseadduser.removeChild(btcloseadduser.domNode);
			btcloseadduser.destroyRecursive();
		}
		var buttonformclose_adduser= new dijit.form.Button({
			id:"id_bt_closeadduser",
			showLabel: false,
			type:"submit",
			iconClass:"closeIcon",
			style:"color:white",
			onclick:"dijit.byId('divUserDB').reset();dijit.byId('divUserDB').hide();"
		});
		buttonformclose_adduser.startup();
		buttonformclose_adduser.placeAt(sp_btcloseadduser);

		var mainTab=dijit.byId("AccTeam");
		var subTab=dijit.byId("CPTeamSel");
		mainTab.selectChild(subTab);
		formUserDBDlg.show();
		standbyShow();
//------------------ Team  update formatter
		var layoutTeamUnit = [
			{name: "Row",get: getRow,width: 2,styles: 'text-align:center;'},
			{field: "name",name: "Name",width: '29',styles: 'text-align:center;',
			formatter:comma, editable: true},
			{field: "Unit",name: "Lab Code",width: '8',styles: 'text-align:center;', editable: true,
			type:'dojox.grid.cells._Widget', widgetClass:'dijit.form.FilteringSelect',
			widgetProps:{store:unitNameStore,required:false}
			},
			{field: "Institute",name: "Institute",width: '7',styles: 'text-align:center;'},
			{field: "Site",name: "Site",width: '10',styles: 'text-align:center;'},
			{field: "Leaders",name: "Leaders",width: '15',styles: 'text-align:center;',
			formatter:comma, editable: true},
			{field: "Director",name: "Director",width: '15',styles: 'text-align:center;'},
		];
		var url_teamUnit = url_path+"/polyusers_up.pl?option=teamUnit";
		var teamUnitStore = new dojo.data.ItemFileWriteStore({ url: url_teamUnit });

		var menusObjectTU = {
			cellMenu: new dijit.Menu(),
			selectedRegionMenu: new dijit.Menu()
		};

		menusObjectTU.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
		menusObjectTU.cellMenu.addChild(new dijit.MenuSeparator());	
		menusObjectTU.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridTU);"}));
		menusObjectTU.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridTU);"}));
		menusObjectTU.cellMenu.startup();

		menusObjectTU.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
		menusObjectTU.selectedRegionMenu.addChild(new dijit.MenuSeparator());
		menusObjectTU.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridTU);"}));
		menusObjectTU.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(gridTU);"}));
		menusObjectTU.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridTU);"}));
		menusObjectTU.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(gridTU);"}));
		menusObjectTU.selectedRegionMenu.startup();

		function clearOldGridTUList(size, request) {
			var listGridTU = dojo.byId("gridTUDiv");
			if (listGridTU) {
 				while (listGridTU.firstChild) {
				listGridTU.removeChild(listGridTU.firstChild);
				}
			}
		}
		if(!gridTU) {
		teamUnitStore.fetch({
			onBegin: clearOldGridTUList,
			onError: fetchFailed,
			onComplete: function(items){
				gridTU = new dojox.grid.EnhancedGrid({
					id:'gridTU',
					store: teamUnitStore,
					structure: layoutTeamUnit,
					rowSelector: "0.4em",
					loadingMessage:'Loading, please wait',
					selectionMode: 'single',
					onClick:function(){
						var itemTU = gridTU.selection.getSelected();
						var selTSite;
						dojo.forEach(itemTU, function(selectedItem) {
							if (selectedItem !== null) {
								dojo.forEach(gridTU.store.getAttributes(selectedItem), function(attribute) {
									var Tvalue = gridTU.store.getValues(selectedItem, attribute);
									if (attribute == "Site" ) {
										selTSite=Tvalue;
										dijit.byId("TNhgmd").set('checked', true);
										if (selTSite != "NECKER" && selTSite != "IMAGINE") {
											dijit.byId("TNhgmd").set('checked', false);
										} 
									} 
								});
							} 
						});
					},
					plugins: {
 						filter: {
							closeFilterbarButton: true,
							ruleCount: 5,
							itemsName: "name"
						},
          					pagination: {
              						pageSizes: ["20","All"],
              						description: true,
              						sizeSwitch: true,
              						pageStepper: true,
              						gotoButton: true,
              						maxPageStep: 4,
							defaultPageSize: 20,
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
						menus:menusObjectTU
					}
				},document.createElement('div'));
				dojo.byId("gridTUDiv").appendChild(gridTU.domNode);
				gridTU.startup();
				gridTU.store.fetch({onComplete:standbyHide});
			}
		});
		} else {
			gridTU.store.close();
			gridTU.setStore(teamUnitStore);
			dijit.byId(gridTU)._refresh();
			gridTU.store.fetch({onComplete:standbyHide});
		}
//------------------ Unit update
		var layoutLab = [
		{field: "unit",name: "Lab Code",width: '17',styles: 'text-align:center;', editable: true},
		{field: "site",name: "Site",width: '10',styles: 'text-align:center;', editable: true,
			type:'dojox.grid.cells._Widget', widgetClass:'dijit.form.ComboBox',
			widgetProps:{store:siteNameStore,required:false}
		},
		{field: "organisme",name: "Institute",width: '10',styles: 'text-align:center;', editable: true,
			type:'dojox.grid.cells._Widget', widgetClass:'dijit.form.ComboBox',
			widgetProps:{store:instituteNameStore,required:false}
		},
		{field: "director",name: "Director",width: '15',styles: 'text-align:center;', editable: true},
		];

		var menusObjectU = {
			cellMenu: new dijit.Menu(),
			selectedRegionMenu: new dijit.Menu()
		};
		menusObjectU.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
		menusObjectU.cellMenu.addChild(new dijit.MenuSeparator());	
		menusObjectU.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(unitGrid);"}));
		menusObjectU.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(unitGrid);"}));
		menusObjectU.cellMenu.startup();

		menusObjectU.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
		menusObjectU.selectedRegionMenu.addChild(new dijit.MenuSeparator());
		menusObjectU.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(unitGrid);"}));
		menusObjectU.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(unitGrid);"}));
		menusObjectU.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(unitGrid);"}));
		menusObjectU.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(unitGrid);"}));
		menusObjectU.selectedRegionMenu.startup();

		function fetchFailed(error, request) {
			alert("lookup failed.");
			alert(error);
		}

		function clearOldunitGridList(size, request) {
			var listunitGrid = dojo.byId("unitGridDiv");
			if (listunitGrid) {
 				while (listunitGrid.firstChild) {
					listunitGrid.removeChild(listunitGrid.firstChild);
				}
			}
		}
		if(!unitGrid) {

		unitStore.fetch({
			onBegin: clearOldunitGridList,
			onError: fetchFailed,
			onComplete: function(items){
				unitGrid = new dojox.grid.EnhancedGrid({
					id:'unitGrid',
					store: unitStore,
					structure: layoutLab,
					rowSelector: "0.4em",
					selectionMode: 'multiple',
					plugins: {
 						filter: {
							closeFilterbarButton: true,
							ruleCount: 5,
							itemsName: "name"
						},
          					pagination: {
              						pageSizes: ["20","All"],
              						description: true,
              						sizeSwitch: true,
              						pageStepper: true,
              						gotoButton: true,
              						maxPageStep: 4,
							defaultPageSize: 20,
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
						menus:menusObjectU
					}
				},document.createElement('div'));
				dojo.byId("unitGridDiv").appendChild(unitGrid.domNode);
				unitGrid.startup();
			}
		});
		} else {
			unitGrid.store.close();
			unitGrid.setStore(unitStore);
			dijit.byId(unitGrid)._refresh();
		}
	});

//login pw
	var boxfn = dijit.byId("firstname"); 
	var boxln = dijit.byId("lastname"); 
	boxlog = dijit.byId("login");
	boxpw = dijit.byId("password");
	var url_lastUserId = url_path+"/polyusers_up.pl?option=lastUser";
	var lastUserIdStore = new dojo.data.ItemFileReadStore({ url: url_lastUserId });
//get the last userId+1 for pw
	lastUserIdStore.fetch({ 
		query: {userId:'*'},
		onItem:function(item)  {
			dojo.connect(boxln, "onChange", function() {
				lastId=lastUserIdStore.getValue( item, 'userId' );
				if (lastIdnext){
					boxpw.attr("value", (lastIdnext + 1) + boxpw.attr("value"));
				} else {
					boxpw.attr("value", (lastId + 1) + boxpw.attr("value"));
				}
			});			
               }

	});
	dojo.connect(boxfn, "onChange", function() {
		boxlog.attr("value", boxfn.attr("value").substring(0,1).toLowerCase());
	});

	dojo.connect(boxln, "onKeyUp", function() {
		boxlog.attr("value", boxfn.attr("value").substring(0,1).toLowerCase()+
				boxln.attr("value").toLowerCase().replace(/[-_ ]/g,""));
	});
	dojo.connect(boxln, "onChange", function() {
		boxpw.attr("value", boxln.attr("value").toLowerCase().replace(/[-_ ]/g,"").substring(0,3));
	});

	formUnitDBDlg = dijit.byId("divUnitDB");
	dojo.connect(dijit.byId("button_newUnit"), "onClick", function(e) {
		checkPassword(okfunction);
		if(! logged) {
			return
		}
		var sp_btcloseaddunit=dojo.byId("bt_close_addunit");
		var btcloseaddunit=dijit.byId("id_bt_closeaddunit");
		if (btcloseaddunit) {
			sp_btcloseaddunit.removeChild(btcloseaddunit.domNode);
			btcloseaddunit.destroyRecursive();
		}
		var buttonformclose_addunit= new dijit.form.Button({
			id:"id_bt_closeaddunit",
			showLabel: false,
			type:"submit",
			iconClass:"closeIcon",
			style:"color:white",
			onclick:"dijit.byId('divUnitDB').reset();dijit.byId('divUnitDB').hide();"
		});
		buttonformclose_addunit.startup();
		buttonformclose_addunit.placeAt(sp_btcloseaddunit);

		institutefilterSelect.set('store',ginstituteStore);
		institutefilterSelect.startup();
		sitefilterSelect.set('store',gsiteStore);
		sitefilterSelect.startup();
		formUnitDBDlg.show();
	});
}
//dojo.addOnLoad(init);

function AddRemUserGroup() {
	spid_btlog = dojo.byId("btlog_3");
	relog(logname,spid_btlog);

	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var itemUser = gridUser.selection.getSelected();
	var UserIdGroups = new Array();
	var FUserGroups = new Array();
	var LUserGroups = new Array();
	var GroupGroups = new Array();

	if (itemUser.length) {
		dojo.forEach(itemUser, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridUser.store.getAttributes(selectedItem), function(attribute) {
					var Uservalue = gridUser.store.getValues(selectedItem, attribute);
					if (attribute == "id" ) {
						UserIdGroups.push(Uservalue.toString());
					} else if (attribute == "firstname" ) {
						FUserGroups.push(Uservalue.toString());
					} else if (attribute == "name" ) {
						LUserGroups.push(Uservalue.toString());
					} else if (attribute == "group" ) {
						GroupGroups.push(Uservalue.toString());
					}
				});
			} 			
		});
	} else {
		textError.setContent("Please select one or more User(s) !");
		myError.show();
		return;
	} 
	showUserGroup(UserIdGroups,FUserGroups,LUserGroups,GroupGroups);
}

function showUserGroup(id,fname,lname,group) {
	var su = dojo.byId("guserid");
	su.innerHTML= id;
	var ju = dojo.byId("gusername");
	ju.innerHTML= lname;
	var sp_btclosegroup=dojo.byId("bt_close_group");
	var btclosegroup=dijit.byId("id_bt_closegroup");
	if (btclosegroup) {
		sp_btclosegroup.removeChild(btclosegroup.domNode);
		btclosegroup.destroyRecursive();
	}
	var buttonformclose_group= new dijit.form.Button({
			id:"id_bt_closegroup",
			showLabel: false,
			type:"submit",
			iconClass:"closeIcon",
			style:"color:white",
			onclick:"dijit.byId('userDialog').reset();dijit.byId('userDialog').hide();"
	});
	buttonformclose_group.startup();
	buttonformclose_group.placeAt(sp_btclosegroup);
	userDialog.show();
	//Grid of User's Group
	var userGroupStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/polyusers_up.pl?option=userGroup"+"&UserSel="+ id
	});
	var layoutUserGroup = [{field: 'Name',name: "Last Name",width: '12em'},
	                     {field: 'Firstname',name: "First Name",width: '10em'},
	                     {field: 'Group',name: "Group",width: '12em'}
	];
	function fetchFailedUgroup(error, request) {
		alert("lookup failed Ugroup.");
		alert(error);
	}

	function clearOldUserGroupList(size, request) {
                    var listGUser = dojo.byId("userGroupGridDiv");
                    if (listGUser) {
                        while (listGUser.firstChild) {
                           listGUser.removeChild(listGUser.firstChild);
                        }
                    }
	}
	userGroupStore.fetch({
		onBegin: clearOldUserGroupList,
		onError: fetchFailedUgroup,
		onComplete: function(items){
			usergroupGrid = new dojox.grid.EnhancedGrid({
				query: {Name: '*'},
				store: userGroupStore,
				rowSelector: "0.4em",
				selectionMode: 'multiple',
				structure: layoutUserGroup,
				plugins: {
					nestedSorting: true,
					dnd: true,
					indirectSelection: {
						name: "Del",
						width: "30px",
						styles: "text-align: center;",
					}
				}
			},document.createElement('div'));
			dojo.byId("userGroupGridDiv").appendChild(usergroupGrid.domNode);
			usergroupGrid.startup();		
		}
	});
	//Grid of Group
	var groupStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/polyusers_up.pl?option=group"
	});
	var layoutGroup = [{field: 'group',name: "Group",width: '12em'}
	];

	function fetchFailedGroup(error, request) {
		alert("lookup failed Group.");
		alert(error);
	}

	function clearOldGroupList(size, request) {
                    var listGroup = dojo.byId("gridGroupDiv");
                    if (listGroup) {
                        while (listGroup.firstChild) {
                           listGroup.removeChild(listGroup.firstChild);
                        }
                    }
	}
	groupStore.fetch({
		onBegin: clearOldGroupList,
		onError: fetchFailedGroup,
		onComplete: function(items){
			groupGrid = new dojox.grid.EnhancedGrid({
				query: {group: '*'},
				store: groupStore,
				rowSelector: "0.4em",
				selectionMode: 'single',
				structure: layoutGroup,
				plugins: {
					nestedSorting: true,
					dnd: true,
					indirectSelection: {
						//name: "Del",
						width: "30px",
						styles: "text-align: center;",
					}
				}
			},document.createElement('div'));
			dojo.byId("gridGroupDiv").appendChild(groupGrid.domNode);
			groupGrid.startup();		
		}
	});
}

function addUserGroup() {
	var UserSelected = document.getElementById("gusername").innerHTML;
	var UserId = document.getElementById("guserid").innerHTML;
	var itemGroup = groupGrid.selection.getSelected();
	var groupGroups = new Array();
	if (itemGroup.length) {
		dojo.forEach(itemGroup, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(groupGrid.store.getAttributes(selectedItem), function(attribute) {
					var Groupvalue = groupGrid.store.getValues(selectedItem, attribute);
					if (attribute == "groupId" ) {
						groupGroups.push(Groupvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select one or more Group from List of Groups !");
		myError.show();
		return;
	} 
	if (! UserId) {
		textError.setContent("Please select one or more User !");
		myError.show();
		return;
	} 

	var url_insert = url_path + "/polyusers_up.pl?option=addGroup"+"&UserSel="+UserId+"&Group="+groupGroups;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				var userGroupStore = new dojo.data.ItemFileWriteStore({
					url: url_path + "/polyusers_up.pl?option=userGroup"+"&UserSel="+ UserId
				});
				usergroupGrid.setStore(userGroupStore);
				usergroupGrid.store.close();
				dijit.byId(usergroupGrid)._refresh();
				refreshUserList();
				gridUser.selection.clear();
				groupGrid.selection.clear();
			}
		}
	);
}

function removeUserGroup() {
	var UserSelected = document.getElementById("gusername").innerHTML;
	var UserId = document.getElementById("guserid").innerHTML;
	var itemUGroup = usergroupGrid.selection.getSelected();
	var UserGroups = new Array(); 
	var GroupGroups = new Array(); 
	var UsernameGroups = new Array(); 
	if (itemUGroup.length) {
		dojo.forEach(itemUGroup, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(usergroupGrid.store.getAttributes(selectedItem), function(attribute) {
					var Uservalue = usergroupGrid.store.getValues(selectedItem, attribute);
					if (attribute == "UserId" ) {
						UserGroups.push(Uservalue);
					} else if (attribute == "Name" ) {
						UsernameGroups.push(Uservalue);
					} else if (attribute == "GroupId" ) {
						GroupGroups.push(Uservalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select one or more Users from User's Group !");
		myError.show();
		return;
	} 
	var beg_name=UserSelected.split(',');
	var beg_id=UserId.split(',');
	var end_name=UsernameGroups.toString().split(',');
	var end_id=UserGroups.toString().split(',');
	var url_insert = url_path + "/polyusers_up.pl?option=remGroup"+"&UserSel="+UserGroups+"&GroupSel="+GroupGroups;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				var userGroupStore = new dojo.data.ItemFileWriteStore({
					url: url_path + "/polyusers_up.pl?option=userGroup"+"&UserSel="+ UserId
				});
				usergroupGrid.setStore(userGroupStore);
				usergroupGrid.store.close();
				dijit.byId(usergroupGrid)._refresh();
				refreshUserList();
				gridUser.selection.clear();
				groupGrid.selection.clear();
				var inter_name = difference(beg_name,end_name);
				var inter_id = difference(beg_id,end_id);
				var su = dojo.byId("guserid");
				su.innerHTML= inter_id.toString();
				var ju = dojo.byId("gusername");
				ju.innerHTML= inter_name.toString();
			}
		}
	);
}

/*###################### Create New Group ##################*/
function viewNewGroup(){
	dojo.style('NewGroupTab', 'visibility', 'visible');
}

function createNewGroup(){
	var alphanum=/^[a-zA-Z0-9-_\.\>]+$/;
	var newgroupFormvalue = dijit.byId("newGroupForm").getValues();
	var check_grp = newgroupFormvalue.groupName;
	if (check_grp.search(alphanum) == -1) {
		textError.setContent("Enter a Group Name with no accent, no space");
		myError.show();
		return;
	}
	if (newgroupFormvalue.groupName.length ==0){
		textError.setContent("Enter a Group Name");
		myError.show();
		return;
	}
	var url_insert = url_path + "/polyusers_up.pl?option=newGroup" +
					"&group="+ newgroupFormvalue.groupName.toUpperCase();
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				reloadMemGroupStore(sc="false");
//				reloadMemGroupStore(sc="true");
				refreshGroupList();
				groupfilterSelect.set('store',groupNameStore);
				groupfilterSelect.startup();
				var url_lastGroupId = url_path+"/polyusers_up.pl?option=lastGroup";
				var lastGroupIdStore = new dojo.data.ItemFileReadStore({ url: url_lastGroupId });
				var gotGroupList = function(items, request){
					var lastIdGnext;
					dojo.forEach(items, function(i){
						lastIdGnext=lastGroupIdStore.getValue( i, 'ugroup_id' );
					});

					groupGrid.store.fetch({onComplete: function (items){
							dojo.forEach(groupGrid._by_idx, function(item, index){
								var sItem = groupGrid.getItem(index);
								if (sItem.groupId.toString() == lastIdGnext.toString()) {
									groupGrid.selection.addToSelection(index);
									addUserGroup();
									myMessage.hide();
								}
							});
						}
					});
				}

				var gotGroupError = function(error, request){
  					alert("The request to the Group store failed. " +  error);
				}

				lastGroupIdStore.fetch({
  					onComplete: gotGroupList,
  					onError: gotGroupError
				});
				dojo.style('NewGroupTab', 'visibility', 'hidden');
			}
		}
	);
}

function refreshGroupList() {
	var url_group = url_path+"/polyusers_up.pl?option=group";
	var groupStore = new dojo.data.ItemFileWriteStore({ url: url_group });
	groupGrid.setStore(groupStore);
	groupGrid.store.close();
}; 

function difference(a1, a2) {
  var result = [];
  for (var i = 0; i < a1.length; i++) {
    if (a2.indexOf(a1[i]) === -1) {
      result.push(a1[i]);
    }
  }
  return result;
}

function comma(value) {
	return value.replace(/,/g," ");
}

function viewNewTeam() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var mainTab=dijit.byId("AccTeam");
	var subTab=dijit.byId("CPNewTeam");
	mainTab.selectChild(subTab);
	dijit.byId("button_adduser").set("disabled",true);
}

function onClickNewTeam(){
	dijit.byId("button_adduser").set("disabled",true);
}

function onClickSelTeam(){
	dijit.byId("button_adduser").set("disabled",false);
}

function resetSearch() {
	gridUser.selection.clear();
	searchUserForm.reset();
	wordsearchUser();
}

function findUser() {
	var filterField = dijit.byId("filterSelect").get('value');
	var filterCSelect = dijit.byId("cSelect").get('displayedValue');
	var reg =new RegExp(" ","g");
	filterCSelect =filterCSelect.replace(reg,'*');
	filterCSelect = "*" + filterCSelect + "*";
	jsonStore = new dojox.data.AndOrReadStore({ 
		url: url_path + "/polyusers_view.pl",
	});
	dijit.byId(gridUser).setQuery({complexQuery: filterField +":"+filterCSelect}, {ignoreCase:true});
	gridUser.store.fetch();
	gridUser.store.close();
	dijit.byId(gridUser)._refresh();
}

function wordsearchUser() {
	dojox.grid.DataGrid.prototype.setQueryAfterLoading = function(query,queryOptions) {
		if (this._isLoading === true) {
			if (this._queryAfterLoadingHandle !== undefined) {
				dojo.disconnect(this, '_onFetchComplete',this._queryAfterLoadingHandle);
        		}
        		this._queryAfterLoadingHandle = dojo.connect(this,'_onFetchComplete', function() {
            			if (this._queryAfterLoadingHandle !== undefined) {
                			dojo.disconnect(this._queryAfterLoadingHandle);
                			delete this._queryAfterLoadingHandle;
            			}
            			this.setQuery(query,queryOptions);
        		});
    		}
		else {
			this.setQuery(query,queryOptions);
		}
	}
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}
	filterValue=dijit.byId('FilterUserBox').get('value');
	filterValue = "'*" + filterValue + "*'";

	gridUser.setQueryAfterLoading({complexQuery: "name:"+filterValue+"OR unit:"+filterValue+"OR firstname:"+filterValue+"OR site:"+filterValue+"OR organisme:"+filterValue+"OR group:"+filterValue}, {ignoreCase:true});

	gridUser.store.fetch();
	gridUser.store.close();
	dijit.byId(gridUser)._refresh();
}

function refreshUserList() {
	reloadMemGroupStore(sc="false");
	var url_user = url_path+"/polyusers_view.pl";
	var jsonStore = new dojox.data.AndOrWriteStore({ url: url_user });
			gridUser.startup();
	gridUser.setStore(jsonStore);
	gridUser.store.close();
	gridUser.startup();
}; 

function refreshUnitList() {
	var url_unit = url_path+"/polyusers_up.pl?option=unit";
	var unitStore = new dojo.data.ItemFileWriteStore({ url: url_unit });
	unitGrid.setStore(unitStore);
	unitGrid.store.close();
}; 

function refreshTeamList() {
	var url_team = url_path+"/polyusers_up.pl?option=team";
	var teamStore = new dojo.data.ItemFileWriteStore({ url: url_team });
	gridT.setStore(teamStore);
	gridT.store.close();
}; 

function refreshTeamUnitList() {
	var url_teamUnit = url_path+"/polyusers_up.pl?option=teamUnit";
	var teamUnitStore = new dojo.data.ItemFileWriteStore({ url: url_teamUnit });
	gridTU.setStore(teamUnitStore);
	gridTU.store.close();
}; 

function newUnit() {
	var unitFormvalue = dijit.byId("unitForm").getValues();
	if (unitFormvalue.code.length ==0){		
			textError.setContent("Enter a Lab code");
			myError.show();
			return;
	}
	if (unitFormvalue.institute.length ==0){		
		textError.setContent("Enter an institute name");
		myError.show();
		return;
	}
	if (unitFormvalue.institute.length ==0){		
		textError.setContent("Enter an institute name");
		myError.show();
		return;
	}
	if (unitFormvalue.site.length ==0){		
		textError.setContent("Enter a site name");
		myError.show();
		return;
	}
	if (unitFormvalue.fndirector.length ==0){		
		textError.setContent("Enter the Director First Name");
		myError.show();
		return;
	}
	if (unitFormvalue.lndirector.length ==0){		
		textError.setContent("Enter the Director Last Name");
		myError.show();
		return;
	}
	
	var url_insert = url_path + "/polyusers_up.pl?option=Newunit"+"&code="+unitFormvalue.code+
	"&organisme="+unitFormvalue.institute+"&site="+unitFormvalue.site+"&director="+unitFormvalue.fndirector+" "+unitFormvalue.lndirector.toUpperCase();
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				reloadMemStore(sc="false");
				dijit.byId('divUnitDB').reset();
				dijit.byId('divUnitDB').hide();
				refreshUnitList();
				refreshUserList();
			}
		}
	);
};

function upUnit() {
	var itemU = unitGrid.selection.getSelected();
	var selUId;
	var selUnit;
	var selSite;
	var selOrg;
	var selDir;
	var alphanum=/^[a-zA-Z0-9-_ \.\>]*$/;
	if (itemU.length==1) {
		dojo.forEach(itemU, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(unitGrid.store.getAttributes(selectedItem), function(attribute) {
					var Uvalue = unitGrid.store.getValues(selectedItem, attribute);
					if (attribute == "unitId" ) {
						selUId=Uvalue;
					} else if (attribute == "unit" ) {
						selUnit=Uvalue;
					} else if (attribute == "site" ) {
						selSite=Uvalue;
					} else if (attribute == "organisme" ) {
						selOrg=Uvalue;
					} else if (attribute == "director" ) {
						selDir=Uvalue;
					}
				});
			} 
		});
	} else {
		textError.setContent("Please Select one Unit");
		myError.show();
		return;
	}

	if (selUnit.toString().search(alphanum) == -1 || selSite.toString().search(alphanum) == -1 ||
		selOrg.toString().search(alphanum) == -1 || selDir.toString().search(alphanum) == -1) {
		textError.setContent("No accent please");
		myError.show();
		return;
	}

	var url_insert = url_path + "/polyusers_up.pl?option=upUnit" +
						"&selUid=" + selUId +
						"&code=" + selUnit +
						"&site=" + selSite +
						"&organisme=" + selOrg +
						"&director=" + selDir;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				reloadMemStore(sc="false");
				refreshUnitList();
				refreshTeamUnitList();
				refreshUserList();
			}
		}
	);
}

function newTeam() {
	// Team Leaders
	var teamFormvalue = dijit.byId("teamForm").getValues();
	var leaderFormvalue = dijit.byId("leaderForm").getValues();
	var alphanum=/^[a-zA-Z0-9-_ \.\>]*$/;
	var Leaders=leaderFormvalue.fleaders1+" "+leaderFormvalue.lleaders1.toUpperCase()+","+
	leaderFormvalue.fleaders2+" "+leaderFormvalue.lleaders2.toUpperCase();
	var check_desf1 = leaderFormvalue.fleaders1;
	var check_desl1 = leaderFormvalue.lleaders1;
	var check_desf2 = leaderFormvalue.fleaders2;
	var check_desl2 = leaderFormvalue.lleaders2;

	if (check_desf1.search(alphanum) == -1 || check_desl1.search(alphanum) == -1 || 
	check_desf2.search(alphanum) == -1 || check_desl2.search(alphanum) == -1) {
		textError.setContent("No accent please");
		myError.show();
		return;
	}
	if (teamFormvalue.name.length ==0){		
		textError.setContent("Enter a Team Name");
		myError.show();
		return;
	}
	if (Leaders.replace(/[, ]/g,"").length ==0){
		textError.setContent("Enter at least one Leader's name");
		myError.show();
		return;
	}	
	if (leaderFormvalue.fleaders2.replace(/ /g,"").length ==0 && leaderFormvalue.lleaders2.replace(/ /g,"").length ==0){
		Leaders=Leaders.replace(/,/g,"");
	}

	//Unit code Lab Id
	var itemUnit = unitGrid.selection.getSelected();
	var UnitGroups = new Array(); 
	if (itemUnit.length) {
		dojo.forEach(itemUnit, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(unitGrid.store.getAttributes(selectedItem), function(attribute) {
					var Unitvalue = unitGrid.store.getValues(selectedItem, attribute);
					if (attribute == "unitId" ) {
						UnitGroups.push(Unitvalue);
					}
				});
			}
		});
	} else {
		textError.setContent("Please select a Unit Code Lab");
		myError.show();
		return;
	} 
	var url_insert = url_path + "/polyusers_up.pl?option=Newteam"+"&name="+teamFormvalue.name
	+"&leaders="+Leaders + "&unit=" + UnitGroups;

	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				reloadMemStore(sc="false");
				gridTU.selection.clear();
				refreshTeamUnitList();
				refreshUserList();
				var mainTab=dijit.byId("AccTeam");
				var subTab=dijit.byId("CPTeamSel");
				mainTab.selectChild(subTab);
			}
		}
	);
};

function upTeam() {
	var itemT = gridTU.selection.getSelected();
	var selTId;
	var selTeam;
	var selLead;
	var selUnitCode;
	var alphanum=/^[a-zA-Z0-9-_ \.\>,]*$/;
	if (itemT.length==1) {
		dojo.forEach(itemT, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridTU.store.getAttributes(selectedItem), function(attribute) {
					var Tvalue = gridTU.store.getValues(selectedItem, attribute);
					if (attribute == "teamId" ) {
						selTId=Tvalue;
					} else if (attribute == "name" ) {
						selTeam=Tvalue;
					} else if (attribute == "Leaders" ) {
						selLead=Tvalue;
					} else if (attribute == "Unit" ) {
						selUnitCode=Tvalue;
					}
				});
			} 
		});
	} else {
		textError.setContent("Please Select One Team");
		myError.show();
		return;
	}

	if (selTeam.toString().search(alphanum) == -1 || selLead.toString().search(alphanum) == -1) {
		textError.setContent("No accent please");
		myError.show();
		return;
	}

	var url_insert = url_path + "/polyusers_up.pl?option=upTeam" +
						"&selTid=" + selTId +
						"&name=" + selTeam +
						"&leaders=" + selLead +
						"&ucode=" + selUnitCode;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				reloadMemStore(sc="false");
				gridTU.selection.clear();
				refreshTeamUnitList();
				refreshUserList();
			}
		}
	);
}

function newUser() {
//User Team field
	var userFormvalue = dijit.byId("adduserForm").getValues();
	var itemT = gridTU.selection.getSelected();
	var selTId;
	if (itemT.length==1) {
		dojo.forEach(itemT, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridTU.store.getAttributes(selectedItem), function(attribute) {
					var Tvalue = gridTU.store.getValues(selectedItem, attribute);
					if (attribute == "teamId" ) {
						selTId=Tvalue;
					}
				});
			} 
		});
	} else {
		textError.setContent("Please Select One Team");
		myError.show();
		return;
	}
	var alphanum=/^[a-zA-Z0-9-_ \.\>]+$/;
	var nospace=/^[a-zA-Z0-9-_\.\>]+$/;
	var mformat=new RegExp("[a-zA-Z0-9._%-]+@[a-z0-9.-]+\\.[a-z]{2,4}");

	var check_firstname=userFormvalue.firstname;
	var check_lastname=userFormvalue.lastname;
	if (check_firstname.search(alphanum) == -1) {
		textError.setContent("No accent on First Name please");
		myError.show();
		return;
	}
	if (check_lastname.search(alphanum) == -1) {
		textError.setContent("No accent on Last Name please");
		myError.show();
		return;
	}
	if (userFormvalue.lastname == 0){		
		textError.setContent("Enter a Last Name");
		myError.show();
		return;
	}
	if (userFormvalue.firstname == 0){		
		textError.setContent("Enter a First Name");
		myError.show();
		return;
	}
	var check_mail=userFormvalue.email;
	if (check_mail.search(mformat) == -1) {
		textError.setContent("Enter a real mail");
		myError.show();
		return;
	}	
	if (userFormvalue.email == 0){		
		textError.setContent("Enter a E-Mail");
		myError.show();
		return;
	}
	var check_login=userFormvalue.login;
	if (check_login.search(nospace) == -1) {
		textError.setContent("No space for Login please");
		myError.show();
		return;
	}
	if (userFormvalue.login == 0){		
		textError.setContent("Enter a Login");
		myError.show();
		return;
	}
	var check_pw=userFormvalue.password;
	if (check_pw.search(nospace) == -1) {
		textError.setContent("No space for Password please");
		myError.show();
		return;
	}
	if (userFormvalue.password == 0){		
		textError.setContent("Enter a Password");
		myError.show();
		return;
	}
	var tg=dijit.byId("TNhgmd");
	var tgvalue;
	if(tg.checked==false) {tgvalue=0} else {tgvalue=1};

	var url_insert = url_path + "/polyusers_up.pl?option=Newuser" + "&firstname=" + userFormvalue.firstname +
	"&lastname="+userFormvalue.lastname +
 	"&group="+userFormvalue.group +
	"&email="+userFormvalue.email + 
	"&login="+userFormvalue.login +
	"&pw="+userFormvalue.password +
	"&hgmd="+tgvalue +
	"&teamid="+selTId;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divUserDB').reset();
				dijit.byId('divUserDB').hide();
				url_lastUserId = url_path+"/polyusers_up.pl?option=lastUser";
				lastUserIdStore = new dojo.data.ItemFileReadStore({ url: url_lastUserId });
				var gotList = function(items, request){
					dojo.forEach(items, function(i){
						lastIdnext=lastUserIdStore.getValue( i, 'userId' );
						dijit.byId('adduserForm').reset();
				});
					
				}
				var gotError = function(error, request){
  					alert("The request to the store failed. " +  error);
				}

				lastUserIdStore.fetch({
  					onComplete: gotList,
  					onError: gotError
				});
				refreshUserList();
			}
		}
	);
};

function upUser() {
	var itemU = gridUser.selection.getSelected();
	var selUId;
	var selLname;
	var selFname;
	var selMail;
	var selTeam;
	var selHgmd;
	var guserGroups = new Array(); 
	var alphanum=/^[a-zA-Z0-9-_ \.\>]+$/;
	var mformat=new RegExp("[a-zA-Z0-9._%-]+@[a-z0-9.-]+\\.[a-z]{2,4}");
	if (itemU.length==1) {
		dojo.forEach(itemU, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridUser.store.getAttributes(selectedItem), function(attribute) {
					var Uvalue = gridUser.store.getValues(selectedItem, attribute);
					if (attribute == "id" ) {
						selUId=Uvalue;
					} else if (attribute == "name" ) {
						selLname=Uvalue;
					} else if (attribute == "firstname" ) {
						selFname=Uvalue;
					} else if (attribute == "group" ) {
						guserGroups.push(Uvalue);
					} else if (attribute == "email" ) {
						selMail=Uvalue;
					} else if (attribute == "team" ) {
						selTeam=Uvalue;
					} else if (attribute == "hgmd" ) {
						selHgmd=Uvalue;
					}
				});
			} 
		});
	} else {
		textError.setContent("Please Select One User");
		myError.show();
		return;
	}
	if (selLname.toString().search(alphanum) == -1 || selFname.toString().search(alphanum) == -1) {
		textError.setContent("No accent please");
		myError.show();
		return;
	}
	if (selMail.toString().search(mformat) == -1) {
		textError.setContent("Enter a real mail");
		myError.show();
		return;
	}	
	if (selTeam.toString().length == 0) {
		textError.setContent("Select a Team");
		myError.show();
		return;
	}
	var spHgmd=selhgmd.split(":");
	var SelHgmd;
	if (spHgmd[1] == selUId) {
		SelHgmd	= spHgmd[0];
	} else {
		SelHgmd	= selHgmd;
	}
	var url_insert = url_path + "/polyusers_up.pl?option=upUser" +
						"&selUid=" + selUId +
						"&lastname=" + selLname +
						"&firstname=" + selFname +
						"&group=" + guserGroups + 
						"&email=" + selMail + 
						"&team=" + selTeam +
						"&hgmd=" + SelHgmd;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				gridUser.selection.clear();
				refreshUserList();
			}
		}
	);
}

var selUserId;
var selUserFName;
var selUserLName;
function editUser() {
	spid_btlog = dojo.byId("btlog_2");
	relog(logname,spid_btlog);

	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var itemUser = gridUser.selection.getSelected();
	if (itemUser.length==1) {
		dojo.forEach(itemUser, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridUser.store.getAttributes(selectedItem), function(attribute) {
					var Uservalue = gridUser.store.getValues(selectedItem, attribute);
					if (attribute == "id" ) {
						selUserId = Uservalue;
					} else if (attribute == "firstname" ) {
						selUserFName = Uservalue;
					} else if (attribute == "name" ) {
						selUserLName = Uservalue;
					}

				});
			} 			
		});
	} else {
		textError.setContent("Please select one User !");
		myError.show();
		return;
	} 
	showUser(selUserId,selUserFName,selUserLName);
}

function showUser(id,fname,lname){
	var fnameU = dojo.byId("fnameUid");
	fnameU.innerHTML= fname;
	var lnameU = dojo.byId("lnameUid");
	lnameU.innerHTML= lname;
	divEditUserDB.show();
	var sp_btcloseedituser=dojo.byId("bt_close_edituser");
	var btcloseedituser=dijit.byId("id_bt_closeedituser");
	if (btcloseedituser) {
		sp_btcloseedituser.removeChild(btcloseedituser.domNode);
		btcloseedituser.destroyRecursive();
	}
	var buttonformclose_edituser= new dijit.form.Button({
			id:"id_bt_closeedituser",
			showLabel: false,
			type:"submit",
			iconClass:"closeIcon",
			style:"color:white",
			onclick:"dijit.byId('divEditUserDB').reset();dijit.byId('divEditUserDB').hide();"
	});
	buttonformclose_edituser.startup();
	buttonformclose_edituser.placeAt(sp_btcloseedituser);
	standbyShow();

//---------------------------- Fetch Data Grid User -----------------------------------

	var userStore = new dojo.data.ItemFileReadStore({
		 url: url_path+"/polyusers_view.pl?"+"&UserId="+ id
	});

	function gotUser(items, request) {
		var list1 = dojo.byId("UserInfo");
		if (list1) {
			var d1width=200;
			var d2width=700;
			var gGroups = new Array();
			dojo.byId('lgroup').innerHTML ="";
			var gSites = new Array();
			dojo.byId('lsite').innerHTML ="";
			for (var i = 0; i < items.length; i++) {
				var item = items[i];
				var table = document.createElement("table");
				table.border = 0;
				table.cellPadding = 5;
				table.cellSpacing = 10;
				if (userStore.getValue(item, "id")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Id'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "id")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}
				if (userStore.getValue(item, "email")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Email'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "email")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}								
				if (userStore.getValue(item, "cDate")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Creation Date'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "cDate")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}
				if (userStore.getValue(item, "group")=="") {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Group'));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}
				if (userStore.getValue(item, "group")) {
					var val_g=userStore.getValue(item, "group");
					var value_sp=val_g.split(" ");
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Group'));
					if (value_sp.length>= 1) {
						for (var i=0; i<value_sp.length; i++) {
							var span = document.createElement("span");
							span.setAttribute('style','border:1px solid #00BFFF;background-color:#B0E0E6;color:#000fb3;');
							span.appendChild(document.createTextNode(value_sp[i]));
							var span2 = document.createElement("span");
							span2.appendChild(document.createTextNode(" "));
							td2.appendChild(span);
							td2.appendChild(span2);
						}
					} 
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
					gGroups.push(userStore.getValue(item, "group").toString());// DIAG
				}
				if (userStore.getValue(item, "unit")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Unit'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "unit")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
					gSites.push(userStore.getValue(item, "unit").toString());// DIAG-Site:CEDI
					//gGroups.push(userStore.getValue(item, "unit").toString());// DEFIDIAG pas encore
				}								
				if (userStore.getValue(item, "site")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Site'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "site")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}								
				if (userStore.getValue(item, "organisme")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Institute'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "organisme")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}								
				if (userStore.getValue(item, "team")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Team'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "team")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}								
				if (userStore.getValue(item, "responsable")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Team Leaders'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "responsable")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}								
				if (userStore.getValue(item, "director")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Director'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "director")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}								
				if (userStore.getValue(item, "login")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Login'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "login")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}								
				if (userStore.getValue(item, "pw")) {
					var tr = document.createElement("tr");
					var td1 = document.createElement('td');
					var td2 = document.createElement('td');
					td1.width = d1width;
					td1.setAttribute('style','font-weight: bold');
					td2.width = d2width;
					td1.appendChild(document.createTextNode('Password'));
					td2.appendChild(document.createTextNode(userStore.getValue(item, "pw")));
					tr.appendChild(td1);
					tr.appendChild(td2);					
 					table.appendChild(tr);
					list1.appendChild(table);
				}								
			}
			if (gGroups.toString().search("DIAG")>=0 || gGroups.toString().search("BONEOME")>=0) {
				dojo.byId('lgroup').innerHTML =gGroups.toString();
				if (gSites.toString().search("CEDI")>=0) {
					dojo.byId('lsite').innerHTML =gSites.toString();
				}
			}
			standbyHide();
		}
	}

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearOldUList(size, request) {
                    var list1 = dojo.byId("UserInfo");
                    if (list1) {
                        while (list1.firstChild) {
                            list1.removeChild(list1.firstChild);
                        }
                    }
	}

	userStore.fetch({
		onBegin: clearOldUList,
		onComplete: gotUser,
		onError: fetchFailed,
	});
}

function chgLog(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}

	var g_group = document.getElementById("lgroup").innerHTML;
	var g_site = document.getElementById("lsite").innerHTML;
	if (g_group) {
		var sp_btcloseinitcode=dojo.byId("bt_close_initcode");
		var btcloseinitcode=dijit.byId("id_bt_closeinitcode");
		if (btcloseinitcode) {
			sp_btcloseinitcode.removeChild(btcloseinitcode.domNode);
			btcloseinitcode.destroyRecursive();
		}
		var buttonformclose_initcode= new dijit.form.Button({
			id:"id_bt_closeinitcode",
			showLabel: false,
			type:"submit",
			iconClass:"closeIcon",
			style:"color:white",
			onclick:"dijit.byId('divInitLog').reset();dijit.byId('divInitLog').hide();"
		});
		buttonformclose_initcode.startup();
		buttonformclose_initcode.placeAt(sp_btcloseinitcode);
		var suglog=selUserFName.toString().substring(0,1).toLowerCase()+selUserLName.toString().toLowerCase().replace(/[-_ ]/g,"");
		var sugpass=selUserId.toString()+selUserLName.toString().toLowerCase().replace(/[-_ ]/g,"").substring(0,3);

		divInitLog.show();
		var newlog = dijit.byId("initlogin");
		var newpass = dijit.byId("initpassword");
		newlog.attr("value",suglog);
		newpass.attr("value",sugpass);



		//newlog.attr("value",suglog);
	} else {
		var sp_btclosenewcode=dojo.byId("bt_close_newcode");
		var btclosenewcode=dijit.byId("id_bt_closenewcode");
		if (btclosenewcode) {
			sp_btclosenewcode.removeChild(btclosenewcode.domNode);
			btclosenewcode.destroyRecursive();
		}
		var buttonformclose_newcode= new dijit.form.Button({
			id:"id_bt_closenewcode",
			showLabel: false,
			type:"submit",
			iconClass:"closeIcon",
			style:"color:white",
			onclick:"dijit.byId('divChgLog').reset();dijit.byId('divChgLog').hide();"
		});
		buttonformclose_newcode.startup();
		buttonformclose_newcode.placeAt(sp_btclosenewcode);

		var suglog=selUserFName.toString().substring(0,1).toLowerCase()+selUserLName.toString().toLowerCase().replace(/[-_ ]/g,"");
		var sugpass=selUserId.toString()+selUserLName.toString().toLowerCase().replace(/[-_ ]/g,"").substring(0,3);
		divChgLog.show();
		var newlog = dijit.byId("chglogin");
		var newpass = dijit.byId("chgpassword");
		newlog.attr("value",suglog);
		newpass.attr("value",sugpass);
	}
}

function chgAccess(){
	var codeFormvalue = dijit.byId("chgLogForm").getValues();
	var nospace=/^[a-zA-Z0-9-_\.\>]+$/;
	var check_login=codeFormvalue.chglogin;
	if (check_login.search(nospace) == -1) {
		textError.setContent("No space for Login please");
		myError.show();
		return;
	}
	if (codeFormvalue.chglogin == 0){		
		textError.setContent("Enter a Login");
		myError.show();
		return;
	}
	var check_pw=codeFormvalue.chgpassword;
	if (check_pw.search(nospace) == -1) {
		textError.setContent("No space for Password please");
		myError.show();
		return;
	}
	if (codeFormvalue.chgpassword == 0){		
		textError.setContent("Enter a Password");
		myError.show();
		return;
	}
	var url_insert = url_path + "/polyusers_up.pl?option=chgLog"+"&userid="+ selUserId +
					"&login="+ codeFormvalue.chglogin +
					"&pw="+ codeFormvalue.chgpassword;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divChgLog').reset();
				dijit.byId('divChgLog').hide();
				refreshUserList();
				gridUser.selection.clear();
				divEditUserDB.hide();
			}
		}
	);
}

function initAccess(){
	var codeFormvalue = dijit.byId("initLogForm").getValues();
	var nospace=/^[a-zA-Z0-9-_\.\>]+$/;
	var check_login=codeFormvalue.initlogin;
	if (check_login.search(nospace) == -1) {
		textError.setContent("No space for Login please");
		myError.show();
		return;
	}
	if (codeFormvalue.initlogin == 0){		
		textError.setContent("Enter a Login");
		myError.show();
		return;
	}
	var url_insert = url_path + "/polyusers_up.pl?option=initLog"+"&userid="+ selUserId +
					"&login="+ codeFormvalue.initlogin +
					"&pw="+ codeFormvalue.initpassword;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divInitLog').reset();
				dijit.byId('divInitLog').hide();
				refreshUserList();
				gridUser.selection.clear();
				divEditUserDB.hide();
			}
		}
	);
}

function inactivateUser(){
	var sp_btclosehideuser=dojo.byId("bt_close_hideuser");
	var btclosehideuser=dijit.byId("id_bt_closehideuser");
	if (btclosehideuser) {
		sp_btclosehideuser.removeChild(btclosehideuser.domNode);
		btclosehideuser.destroyRecursive();
	}
	var buttonformclose_hideuser= new dijit.form.Button({
			id:"id_bt_closehideuser",
			showLabel: false,
			type:"submit",
			iconClass:"closeIcon",
			style:"color:white",
			onclick:"dijit.byId('divHideUser').reset();dijit.byId('divHideUser').hide();"
	});
	buttonformclose_hideuser.startup();
	buttonformclose_hideuser.placeAt(sp_btclosehideuser);
	var suglog=selUserFName.toString().substring(0,1).toLowerCase()+selUserLName.toString().toLowerCase().replace(/[-_ ]/g,"");
	var newlog = dijit.byId("inactivelogin");
	newlog.attr("value",suglog);
	divHideUser.show();
}

function hideUser(){
	var newlog = dijit.byId("inactivelogin");
	newlog.set("disabled",false);
	var codeFormvalue = dijit.byId("inactiveForm").getValues();
	var url_insert = url_path + "/polyusers_up.pl?option=hideUser"+"&userid="+ selUserId +
					"&login="+ codeFormvalue.inactivelogin;
	newlog.set("disabled",true);
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('divHideUser').reset();
				dijit.byId('divHideUser').hide();
				refreshUserList();
				gridUser.selection.clear();
				divEditUserDB.hide();
			}
		}
	);
}

function getRow(inRowIndex){
	return ' ' + (inRowIndex+1);
}

function previewAll(grid){
	var gPat=dijit.byId(grid);
	gPat.exportToHTML({
		title: "Grid View - All",
		cssFiles: cssFiles
	}, function(str){
			var win = window.open();
			win.document.open();
			win.document.write(str);
			gPat.normalizePrintedGrid(win.document);
			win.document.close();
	});
}

function previewSelected(grid){
	var gPat=dijit.byId(grid);
	gPat.exportSelectedToHTML({
		title: "Grid View - Selected",
		cssFiles: cssFiles
	}, function(str){
			var win = window.open();
			win.document.open();
			win.document.write(str);
			gPat.normalizePrintedGrid(win.document);
			win.document.close();
	});
}

function exportAll(grid){
	dijit.byId(grid).exportGrid("csv",{writerArgs: {separator: ";"}}, function(str){
		var reg=new RegExp('"',"g");
		var reg1=new RegExp("'","g");
		var reg2=new RegExp("<br>","g");
		var reg3=new RegExp("NaN","g");
		var reg4=new RegExp("<img .*.png>","g");
		var reg5=new RegExp("<center></center>","g");
		var reg6=new RegExp(",","g");
		str=str.replace(reg,'');
		str=str.replace(reg1,'');
		str=str.replace(reg2,'');
		str=str.replace(reg3,'');
		str=str.replace(reg4,'');
		str=str.replace(reg5,'');
		str=str.replace(reg6,'');
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
}

function exportSelected(grid){
	dijit.byId(grid).exportSelected("csv",{writerArgs: {separator: ";"}}, function(str){
		var reg=new RegExp('"',"g");
		var reg1=new RegExp("'","g");
		var reg2=new RegExp("<br>","g");
		var reg3=new RegExp("NaN","g");
		var reg4=new RegExp("<img .*.png>","g");
		var reg5=new RegExp("<center></center>","g");
		var reg6=new RegExp(",","g");
		str=str.replace(reg,'');
		str=str.replace(reg1,'');
		str=str.replace(reg2,'');
		str=str.replace(reg3,'');
		str=str.replace(reg4,'');
		str=str.replace(reg5,'');
		str=str.replace(reg6,';');
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
}

function standbyShow() {
	myStandby.show(); 
 	standby.show(); 
}

function standbyHide() {
	standby.hide();
	myStandby.hide();
};

