/**
 * @author plaza
 */

dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.layout.BorderContainer");
dojo.require("dojox.layout.ExpandoPane");
dojo.require("dijit.layout.AccordionContainer");
dojo.require("dijit.layout.AccordionPane");
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


dojo.require("dojox.grid.DataGrid");
dojo.require("dojo.data.ItemFileReadStore");
dojo.require("dojo.data.ItemFileWriteStore");
dojo.require("dojox.data.AndOrReadStore");
dojo.require("dojox.data.AndOrWriteStore");
dojo.require("dijit.Dialog");
dojo.require("dijit.form.ValidationTextBox");
dojo.require("dojo.parser");
dojo.require("dojo.date.locale");

dojo.require("dojox.grid.LazyTreeGrid");
dojo.require("dijit.tree.ForestStoreModel");
dojo.require("dojox.grid.LazyTreeGridStoreModel");

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
dojo.require("dojo.cookie");
dojo.require("dojo.NodeList-traverse");

dojo.require("dojo.date.stamp");

function viewNewUser(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var href = window.location.href;
	var hrefU=href.replace("polyprojectNGS","polyusers");
	window.open(hrefU,'_blank');
}

var phenotypeStore;
var phenotypeNameStore;

var layoutSchemas = [
	{ field: "Row", name: "Row",get: getRow, width: '2.5'},
	{ field: "Name",name: "Validation DB Name",width: '10'},
];

var layoutOneBundle= [
	{ field: "bundleId",name: "ID",width: '4'},
	{ field: "bunName",name: "Name",width: '20', editable: true},
	{ field: "bunVs",name: "Version",width: '4', editable: true},
	{ field: "bunDes", name: "Description", width: '24', editable: true},
	{ field: "meshid", name: "Mesh", width: '10', editable: true},
];

var layoutSmallProject = [
	{ field: "FreeProj",name: "Free",width: '2.5', formatter:bullet},
	{ field: "name",name: "Name",width: '8'},
	{ field: "id",name: "ID",width: '4'},
	{ field: "description", name: "Description", width: '12'},
	{ field: "dejaVu",name: "Vu",width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
	{ field: "somatic",name: "So",width: '1.5',
		styles:"text-align:center;",formatter:activeRadioButtonView},
	{ field: "users", name: "Users", width: '15'},
	{ field: "RunId", name: "Run", width: '8'},
	{ field: "phenotype", name: "Phenotype", width: '15'},
];

var layoutOneProject;
var layoutProject = [
	{ field: "Row", name: "Row",get: getRow, width: '3'},
	{ field: "luser",name: "<img align='top' src='icons/user-icon.png'>",
	styles:"white-space:nowrap;margin:0;padding:0;text-align:center;",
	width: '2',filterable: false, formatter:ledbullet},
	{ field: "statut",name: "<img align='top' src='icons/exclamation.png'>",
	styles:"white-space:nowrap;margin:0;padding:0;text-align:center;",
	width: '1.5',filterable: false, formatter:bullet},
	{ field: "id",name: "ID",width: '3',formatter:colorField},
	{ field: "name",name: "Name",width: '9',formatter:colorField,styles:'font-weight:bold;'},
	{ field: "capAnalyse", name: "Ana", width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldAnalyse},
	{ field: "sp",name: "SP", width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldSpecies},
	{ field: "dejaVu",name: "Vu",width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
	{ field: "somatic",name: "So",width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
	{ field: "description", name: "Description", width: '20',styles:"text-align:left;white-space:nowrap;"},
	{ field: "Rel", name: "Rel", width: '5',styles:"text-align:left;white-space:nowrap;"},
	{ field: "projRelAnnot", name: "Annot", width: '3'},
	{ field: "nbRun", name: "#Run", width: '2.5'},
	{ field: "nbPat", name: "#Pat", width: '2.5'},
	{ field: "runId", name: "runId", width: '13'},
	{ field: "capName", name: "Capture", width: '14'},
	{ field: "capValidation", name: "Validation", width: '6'},
	{ field: "plateform", name: "Plateform", width: '8'},
	{ field: "macName", name: "Machine", width: '10'},
	{ field: "MethAln", name: "Alignment", width: '10'},
	{ field: "MethSnp", name: "Calling", width: '24'},
	{ field: "MethPipe", name: "Other", width: '10'},
	{ field: "MethSeq", name: "MethSeq", width: '8'},
	{ field: "phenotype", name: "Phenotype", width: '15', formatter:backgroundCell},
	{ field: "UserGroups", name: "Users Group", width: '8',styles:"text-align:left;white-space:nowrap;", formatter:userColorGroup},
	{ field: "Users", name: "Users", width: '56', formatter:userColorGroup},
	{ field: "Unit", name: "Unit", width: '15'},
	{ field: "Site", name: "Site", width: '10'},
	{ field: "cDate", name: "Date" , datatype:"date", width: '7'},
];

function inactiveRadioButtonView(value,idx,cell) {
	var Cbutton;
	if (cell.field == "dejaVu" || cell.field == "somatic" || cell.field == "control"|| cell.field == "def") {
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

var seldejaVu;
var selSomatic;
function activeRadioButtonView(value,idx,cell) {
	var Cbutton;
	
	if (cell.field == "dejaVu") {
		Cbutton = new dijit.form.CheckBox({
			style:"border:0;margin: 0; padding: 0;text-align:center;",
			checked:false,
			value:0,
			disabled:false,
			onChange: function(e){
				if(e){seldejaVu=1;cell.customStyles.push("background: grey;")} else {
				seldejaVu=0};
			} 
		});
		if (value==1) {
			cell.customStyles.push("background: grey;");	
			Cbutton.attr('checked', true);
			seldejaVu=1;
		} else {seldejaVu=0;}				
	}
	if (cell.field == "somatic") {
		Cbutton = new dijit.form.CheckBox({
			style:"border:0;margin: 0; padding: 0;text-align:center;",
			checked:false,
			value:0,
			disabled:false,
			onChange: function(e){
				if(e){selSomatic=1;cell.customStyles.push("background: grey;")} else {
				selSomatic=0};
			} 
		});
		if (value==1) {
			selSomatic=1;
			cell.customStyles.push("background: grey;");	
			Cbutton.attr('checked', true);
		} else {selSomatic=0;}		
	}
	return Cbutton;
}

var layoutFreeRun = [
		{field: 'Row', name: 'Row', get: getRow, width:'3em'},
		{ field: "patientName",name: "Patient", width: '10'},
		{ field: "FreeRun",name: "Link",width: '3', formatter:bullet},
];

var layoutFreePatient = [
		{field: 'Row', name: 'Row', get: getRow, width:'3em'},
		{field: 'patientName',name: 'Patient',width: '15em'},
		{field: 'capName',name: 'Capture',width: '10em'},
		{field: "FreeRun",name: "Link",width: '3', formatter:bullet},
];
var layoutPatRun = [
		{ field: 'Row', name: 'Row', get: getRow, width:'3em'},
		{ field: "patientName",name: "Patient", width: '10', editable: true,singleClickEdit:true},
		{ field: 'capName',name: 'Capture',width: '10em'},
		{ field: "ProjectName",name: "Project Name",width: '8'},
		{ field: "FreeRun",name: "Link",width: '3', formatter:bullet},
];

var layoutProjRun = [
		{ field: "ProjectName",name: "Project Name",width: '8'},
		{ field: "ProjectId",name: "Project Id",width: '5'},
		{ field: "FreeRun",name: "Free",width: '3', formatter:bullet},
];

var layoutMeth = [
	{field: 'def',name: 'def',width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
	{field: 'methName',name: 'Method Name',width: 'auto'}];
var layoutMethod = [
		{ field: 'methName',name: 'Method Name',width: '12'},
		{ field: "methType",name: "Type",width: '7'}
];

var layoutCallRun = [
		{ field: 'Row', name: 'Row', get: getRow, width:'3em'},
		{ field: "patientName",name: "Patient", width: '10'},
		{ field: "MethSnp", name: "Calling", width: '15'},
		{ field: "ProjectName",name: "Project Name",width: '8'},
		{ field: "FreeRun",name: "Link",width: '3', formatter:bullet},
];

var layoutAlnRun = [
		{ field: 'Row', name: 'Row', get: getRow, width:'3em'},
		{ field: "patientName",name: "Patient", width: '10'},
		{ field: "MethAln", name: "Alignment", width: '15'},
		{ field: "ProjectName",name: "Project Name",width: '8'},
		{ field: "FreeRun",name: "Link",width: '3', formatter:bullet},
];

var layoutRun = [
		{ field: "Row", name: "Row",get: getRow, width: 3,filterable: false},
		{ field: "luser",name: "<img align='top' src='icons/user-icon.png'>",
		styles:"white-space:nowrap;margin:0;padding:0;text-align:center;",
		width: '2',filterable: false, formatter:ledbullet},
		{ field: "statRun",name: "<img align='middle' src='icons/exclamation.png'>",width: '1.5',
		styles:"white-space:nowrap;margin:0;padding:0;",
		formatter:bullet,filterable: false},
		{ field: "Rapport", name: "#L/T", width: '3.5',filterable: false},
		{ field: "RunId",name: "Run",width: '3',formatter:colorField,styles:'text-align:center;font-weight:bold;'},
		{ field: 'CaptureAnalyse',name: 'Ana',width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldAnalyse},
		{ field: "sp",name: "SP", width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldSpecies},
		{ field: "name",name: "Run Name", width: '24',formatter:linkRunName},
		{ field: "cDate", name: "Date", datatype:"date", width: '7'},
		{ field: "desRun",name: "Description", width: '12',styles:"text-align:left;white-space:nowrap;"},
		{ field: "pltRun",name: "Plt Run", width: '5',styles:"text-align:left;white-space:nowrap;"},
		{ field: "ProjectName",name: "Current Project",width: '9'},
		{ field: "ProjectDestName",name: "Target Project",width: '9'},
		{ field: "Gproject",name: "Genomic Project",width: '9'},
		{ field: 'CaptureName',name: 'Capture',width: '14em'},
		{ field: 'capValidation',name: 'Vatidation',width: '12em'},
		{ field: "capRel", name: "capRel", width: '4'},
		{ field: "projRel", name: "projRel", width: '5',styles:"text-align:left;white-space:nowrap;"},
		{ field: "projRelAnnot", name: "Annot", width: '3'},
		{ field: 'capMeth',name: 'CapMeth',width: '5'},
		{ field: "MethAln", name: "Alignment", width: '10'},
		{ field: "MethSnp", name: "Calling", width: '24'},
		{ field: "MethPipe", name: "Other", width: '10'},
		{ field: "methSeqName", name: "MethSeq", width: '8'},
		{ field: "plateformName", name: "Plateform", width: '10'},
		{ field: "macName",name: "Machine",width: '8'},
		{ field: "phenotype", name: "Phenotype", width: '15', formatter:backgroundCell},
		{ field: "UserGroups", name: "Groups", width: '8',styles:"text-align:left;white-space:nowrap;", formatter:userColorGroup},
		{ field: "Users", name: "Users", width: '15',styles:"text-align:left;white-space:nowrap;", formatter:userColorGroup},
];

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

var layoutCaptureData =  [
	{ field: "Row", name: "Row",get: getRow, width: 2.5,filterable: false},
	{ field: "FreeCap",name: "<img align='middle' src='icons/exclamation.png'>",
		styles:"white-space:nowrap;margin:0;padding:0;",
		width: '1.5',filterable: false, formatter:bullet},
	{ field: "captureId",name: "ID",width: '3', editable: false},
	{ field: 'capAnalyse',name: 'Ana',width: '2',styles: 'text-align: center;font-weight:bold;', formatter:colorFieldAnalyse},
	{ field: "sp",name: "SP", width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldSpecies},
	{ field: "capName",name: "Capture",width: '20', editable: false,formatter:colorField,styles:'font-weight:bold;'},
	{ field: "capDes",name: "Description",width: '14', editable: false,styles:"text-align:left;white-space:nowrap;"},
	{ field: "capVs",name: "Vs",width: '2', editable: false},
	{ field: "capType",name: "Type",width: '10', editable: false},
	{ field: "capMeth", name: "Method", width: '4', editable: false},
	{ field: "umi", name: "UMI", width: '4', editable: false,formatter:emptyA},
	{ field: "rel", name: "Rel", width: '4', editable: false},
	{ field: "capRelGene", name: "relG", width: '2.5', editable: false, formatter:backgroundCell},
	{ field: "capValidation", name: "Validation", width: '8', editable: false},
	{ field: "capFile",name: "Capture File",width: '10', editable: false,
	styles:"text-align:left;white-space:nowrap;"},
	{ field: "capFilePrimers",name: "Primer File",width: '10', editable: false,
	styles:"text-align:left;white-space:nowrap;"},
	{ field: "nbBun",name: "#bun",width: '3', editable: false},
	{ field: "nbTr",name: "#Tr",width: '4', editable: false},
	{ field: "bunName",name: "Bundle",width: '40', editable: false, formatter:bundleColorRel},
	{ field: "cDate", name: "Date" , datatype:"date", width: '7'},
	];

function viewPltRun(value,idx,cell) {
	var button;
	if (cell.field == "pltRun") {
		if (value.length>=8) {
			var tooltipDDB = new dijit.TooltipDialog({
				content: value
			});
             		button = new dijit.form.DropDownButton({
				style:"border:0;margin: 0; padding: 0;",
				label:value.substring(0,4),
                    		dropDown: tooltipDDB,
                 	});				
		} else {
			button=value;
		}
		return button;
	}
}

var layoutOneDoc = [
		{ field: "FileName", name: "Document", width: '25',filterable: false},
		{ field: "FileType", name: "ext", width: '3',filterable: false},
		{ field: "icon",name: "icon", width: 3, formatter:extension,filterable: false}
];

var layoutSearchPat = [
		{ field: "patName",name: "Patient",width: '20'},
		{ field: "runid",name: "Run",width: '4'},
		{ field: "projid",name: "Current Project Id",width: '5'},
		{ field: "ProjName",name: "Current Project",width: '10'},
		{ field: "projiddest",name: "Target Project Id",width: '5'},
		{ field: "ProjNameDest",name: "Target Project",width: '10'},
		{ field: "FreeRun",name: "Link",width: '4', formatter:bullet},
];

var layoutUnaProjGrid = [
	{ field: "Row", name: "Row",get: getRow, width: '2'},
	{ field: "id",name: "ID",width: '4'},
	{ field: "name",name: "Project Name",width: '9',formatter:colorField,styles:'font-weight:bold;'},
	{ field: 'CaptureAnalyse',name: 'Ana',width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldAnalyse},
	{ field: "cDate", name: "Date", datatype:"date", width: '8'},
	{ field: "userName",name: "Project Creator Name",width: '15'},
	{ field: "userMail",name: "Mail",width: '22'},
];

var layoutCapture = [
	{ field: "rel", name: "Rel", width: '4', filterable: false},
	{ field: "capName",name: "Capture",width: '14',styles:"text-align:left;white-space:nowrap;"},
	{ field: "capVs",name: "Vs",width: '1.5'},
	{ field: "capDes",name: "Description",width: '9',styles:"text-align:left;white-space:nowrap;"},
	{ field: "umi",name: "UMI",width: '4',styles:"text-align:left;white-space:nowrap;",formatter:emptyA},
];

var layoutCapData = [
	{ field: "Row", name: "Row",get: getRow, width: 3},
	{field: 'def',name: 'def',width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
	{ field: 'capAnalyse',name: 'Ana',width: '2',styles: 'text-align: center;font-weight:bold;', formatter:colorFieldAnalyse},
	{ field: "sp",name: "SP", width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldSpecies},
	{ field: "capName",name: "Capture",width: '20'},
	{ field: "rel", name: "Rel", width: '8', filterable: false},
	{ field: "cDate", name: "Date" , datatype:"date", width: '7'},
	{ field: "captureId",name: "capId",width: '20'},
];

var layoutPatProjRun = [
		{ field: 'Row', name: 'Row', get: getRow, width:'2.5em'},
		{ field: "patientName",name: "Patient", width: '8'},
		{ field: "RunId",name: "Run",width: '2.5'},
];

var layoutRunFree = [
	{ field: 'Row', name: 'Row', get: getRow, width:'2em'},
	{ field: "patientName",name: "Patient", width: '10'},
	{ field: "RunId",name: "Run", width: '2.5'},
	{ field: "ProjectDestName",name: "Target Project",width: '8'},
	{ field: "family",name: "Family", width: '8'},
	{ field: "group",name: "Group", width: '3'},
	{ field: "FreeRun",name: "Link",width: '2', formatter:bullet},
];

var layoutsmallFreeRun = [
	{ field: "RunId",name: "Run", width: '2.5'},
	{ field: "desRun",name: "Description", width: '10'},
	{ field: "nameRun",name: "Name", width: '15'},
	{ field: "cDate", name: "Date", datatype:"date", width: '7'},
	{ field: "FreeRun",name: "Lnk",width: '2', formatter:bullet},
];

var layoutGMac = [
	{ field: "name",name: "Name", width: '15'},
];
	
var layoutPedigree = [
	{field: 'patient',name: 'Patient',width: '10'},
	{field: "family",name: "Family", width: '10'},
		
];

var layoutPlateform = [{field: 'def',name: 'def',width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
	{field: 'plateformName',name: 'Plateform Name',width: 'auto'}];
var layoutMachine = [{field: 'def',name: 'def',width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
	{field: 'macName',name: 'Machine Name',width: 10},
	{field: 'macType',name: 'Type',width: 'auto'}];
var layoutUMI = [{field: 'umiName',name: 'UMI Name',width: 10},
			{field: 'umiMask',name: 'Mask',width: 'auto'}];
var layoutPERS = [{field: 'persName',name: 'Perspective Name',width: 10}];
var layoutTECH = [{field: 'techName',name: 'Technology Name',width: 10}];
var layoutPREP = [{field: 'prepName',name: 'Preparation Name',width: 10}];
var layoutPROF = [{field: 'profId',name: 'ID',width: 2},{field: 'profName',name: 'Profile Name',width: 20}];


var layoutPIPE = [{field: 'Name',name: 'PipeLine Name',width: 10},
			{field: 'content',name: 'Content',width: '50'}];
var layoutMethSeq = [{field: 'def',name: 'def',width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
{field: 'methSeqName',name: 'MethodSeq Name',width: 'auto'}];

var layoutRelease = [{field: 'def',name: 'def',width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
	{ field: "sp",name: "SP", width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldSpecies},
	{field: 'relName',name: 'Release Name',width: 'auto'}];


function empty(value) {
	if(value == "") {
		return "<img align='top' src='icons/exclamation.png'>";
	} else { return value}
}

function emptyA(value) {
	if(value == undefined) {
		return "";
	} else { return value}
}

function zero(value) {
	if (value == "0") {
		return "";
	} else { return value}
}

var layoutPatientProject
var layoutGenomicPatRun;
var layoutOneRun;
var layoutCaptureData;
var layoutBundle;

var jsonStore;
var runStore;
var userStore;
var directorStore;
var ugroupStore;
var usergroupProjStore;
var capStore;
var captureStore;
var captureMenuStore;
var analyseStore;
var valanalyseStore;
var freeRunStore;
var PatProjRunStore;
var macStore;
var umiStore;
var perspectiveStore;
var technologyStore;
var preparationStore;
var profiledataStore;

var pipelineStore;
var projStore;
var methSeqStore;
var CallStore;
var AlnStore;
var OtherStore;
var AlnNameStore;
var CallNameStore;
var OtherNameStore;

var plateformStore;
var plateformNameStore;
var relStore;
var relcapStore;
var relRefStore;
var typepatientStore;
var typepatientSelect;
var a_typepatientSelect;
var methodStore;

var patientProjectStore;
var genomicRunPatStore;
var statusStore;
var sexStore;
var machineStore;
var methSeqNameStore;

var fatherStore;
var motherStore;
var initfatherStore;
var initmotherStore;
var groupNameStore;

var memo1Store;
var memo2Store;

var bundleStore;
var capturebundleStore;
var bundleTransStore;
var relgeneNameStore;
var transmissionStore;
var schemasStore;
var schemasNameStore;
var typeCaptureStore;
var capmethStore;
var capmethNameStore;
var oneprojStore;
var umiNameStore;

var captureTrStore;
var captureUnTrStore;
var captureUnGeneStore;
var filterCapStore;
var yearStore;

var xhrArgsEx;
var deferredEx;


//Grid
var grid;
var grid2P;
var alnGrid;
var alnRGrid;
var a_alnRGrid;
var b_alnRGrid;
var methodGrid;
var gridProj;

var callGrid;
var callRGrid;
var a_callRGrid;
var b_callRGrid;
var otherRGrid;
var a_otherRGrid;
var b_otherRGrid;

var patientprojectGrid;
var docGrid;
var gridRundoc;
var patGrid;
var onedocGrid;
var captureGrid;
var a_captureGrid;
var captureInfoGrid;
var filterCapGrid;


var gridProjRun;
var PatProjRunGrid;
var freerunGrid;
var pedGrid;
var gridCap;
var gridBundle;
var gridCaptureBundle;
var gridBundleTrans;
var umiGrid;
var perspectiveGrid;
var technologyGrid;
var preparationGrid;
var profiledataGrid;

var pipelineGrid;
var schemasGrid;
var gridPatP;
var plateformDGrid;
var oneprojGrid;
var captureTrGrid;
var captureUnTrGrid;
var captureUnGeneGrid;
var unaProjGrid;
var ugroupGrid;
var usergroupProjGrid;
var capbedGrid;
var capbedStore;

var standby;
var selectedPlateformName;
var selectedMacName;
var PatFreeGroups;
var force;
var sforce;
var rcontrol;
var schemasfilterSelect;
var relgenefilterSelect;
//var yearSelect;
var analyseSelect;
var relcapgenefilterSelect;
var capmethodSelect;
var selPlt;
var selRelcap;

var boxva;
var boxan;

var valphenotype;

var checkCapBed;

var nostandby=0;
var fromproject=0;
var val_sl=1;
var btlog;
var logged=1;
var initl=1;
var logname="";
var nbweeks=0;
var checkDefPlt=0;
var checkDefMac=0;
var checkDefMseq=0;
var checkDefMaln=0;
var checkDefaMaln=0;
var checkDefbMaln=0;
var checkDefMcall=0;
var checkDefaMcall=0;
var checkDefbMcall=0;
var checkDefRel=1; //IMPORTANT
var checkDefCapd=1;
var checkDefaRel=0;
var checkDefaCapd=0;

var profileStore;
var profilefilterSelect;
var a_profilefilterSelect;

var speciesStore;
var speciesfilterSelect;
var a_speciesfilterSelect;
var b_speciesfilterSelect;

var pipelineNameStore;
var pipelinefilterSelect;
var a_pipelinefilterSelect;
var b_pipelinefilterSelect;

dojo.addOnLoad(function() {
	relog(logname,dojo.byId("btlog_0"));
	relog(logname,dojo.byId("btlog_1"));
	relog(logname,dojo.byId("btlog_2"));
	relog(logname,dojo.byId("btlog_3"));
	relog(logname,dojo.byId("btlog_4"));
	relog(logname,dojo.byId("btlog_5"));
	relog(logname,dojo.byId("btlog_6"));
	relog(logname,dojo.byId("btlog_7"));
	relog(logname,dojo.byId("btlog_8"));
//	relog(logname,dojo.byId("btlog_9"));// stats.js
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
}

function okfunction(items,request){
		// number of btlog_
	var nb_btlog=9;
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
	for(var i=0; i<nb_btlog+1; i++) {
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
	dijit.byId('login').hide();
	dijit.byId("loginForm").reset();				
	checkPassword(okfunction);  				
}

function hide_tab() {
	document.getElementById("TabMainRun").style.display = "none";
	dojo.style("buttonAddRun", {'visibility':'hidden'});
	dojo.style("buttonRefreshRun", {'visibility':'hidden'});
	document.getElementById("TabMainProj").style.display = "none";
	dojo.style("buttonAddProjUser", {'visibility':'hidden'});
	dojo.style("buttonRefreshProj", {'visibility':'hidden'});
	document.getElementById("TabMainData").style.display = "none";
	document.getElementById("TabMainMenuData").style.display = "none";
	document.getElementById("TabEditRun").style.display = "none";
	document.getElementById("TabEditProj").style.display = "none";
	document.getElementById("borderContainerUser").style.display = "none";
	document.getElementById("appSubCapture").style.display = "none";
	document.getElementById("leftCapture").style.display = "none";
	document.getElementById("rightCapture").style.display = "none";
	dijit.byId("FilterRunBox").set("disabled",true);
	dijit.byId("bt_resetSearchRun").set("disabled",true);
	dijit.byId("CPrun").set("disabled",true);
	dijit.byId("CPproj").set("disabled",true);
	dijit.byId("CPdata").set("disabled",true);
	dijit.byId("CPcapture").set("disabled",true);
	dijit.byId("statPoly").set("disabled",true);
}

function show_tab() {
	document.getElementById("TabMainRun").style.display = "block";
	dojo.style("buttonAddRun", {'visibility':'visible'});
	dojo.style("buttonRefreshRun", {'visibility':'visible'});
	document.getElementById("TabMainProj").style.display = "block";
	dojo.style("buttonAddProjUser", {'visibility':'visible'});
	dojo.style("buttonRefreshProj", {'visibility':'visible'});
	document.getElementById("gridDiv").style.display = "block";
	document.getElementById("gridRundocDiv").style.display = "block";
	document.getElementById("appSubCapture").style.display = "block";
	dijit.byId("FilterRunBox").set("disabled",false);
	dijit.byId("bt_resetSearchRun").set("disabled",false);
	document.getElementById("leftCapture").style.display = "block";
	document.getElementById("rightCapture").style.display = "block";
	dijit.byId("CPrun").set("disabled",false);
	dijit.byId("CPproj").set("disabled",false);
	dijit.byId("CPdata").set("disabled",false);
	dijit.byId("CPcapture").set("disabled",false);
	dijit.byId("statPoly").set("disabled",false);
	document.getElementById("TabMainData").style.display = "block";
	document.getElementById("TabMainMenuData").style.display = "block";
	document.getElementById("TabEditRun").style.display = "block";
	document.getElementById("TabEditProj").style.display = "block";
	document.getElementById("borderContainerUser").style.display = "block";
}
var valcontent;
function init(){
	if (dojo.cookie("slider_proj")) {
		val_sl = dojo.cookie("slider_proj");
//		if (val_sl==5) { val_sl=1; }
	}
	dijit.byId("slider_proj").attr('value',val_sl);
//################# Standby for loading : use sendData_v2 #############################
	standby = new dojox.widget.Standby({
	       	target: "winStandby"
	});
	document.body.appendChild(standby.domNode);
	standby.startup();

	//################# Init Year ########################
  	dojo.xhrGet({
            	url: url_path + "/manageData.pl?option=years",
            	handleAs: "json",
            	load: function (res) {
 			yearStore = new dojo.store.Memory({data: res});
          	}
        });
	yearSelect_Plt = new dijit.form.FilteringSelect({
		id: "yearSelect_Plt",
		name: "year",
		required:"true",
		style: "width: 8em;",
		autoComplete: true,
		store: yearStore,
		searchAttr: "year",
	},"yearSelect_Plt");
	yearSelect_Mac = new dijit.form.FilteringSelect({
		id: "yearSelect_Mac",
		name: "year",
		required:"true",
		style: "width: 8em;",
		autoComplete: true,
		store: yearStore,
		searchAttr: "year",
	},"yearSelect_Mac");
	yearSelect_MSeq = new dijit.form.FilteringSelect({
		id: "yearSelect_MSeq",
		name: "year",
		required:"true",
		style: "width: 8em;",
		autoComplete: true,
		store: yearStore,
		searchAttr: "year",
	},"yearSelect_MSeq");
	yearSelect_MAln = new dijit.form.FilteringSelect({
		id: "yearSelect_MAln",
		name: "year",
		required:"true",
		style: "width: 8em;",
		autoComplete: true,
		store: yearStore,
		searchAttr: "year",
	},"yearSelect_MAln");
	yearSelect_MCall = new dijit.form.FilteringSelect({
		id: "yearSelect_MCall",
		name: "year",
		required:"true",
		style: "width: 8em;",
		autoComplete: true,
		store: yearStore,
		searchAttr: "year",
	},"yearSelect_MCall");
	yearSelect_Rel = new dijit.form.FilteringSelect({
		id: "yearSelect_Rel",
		name: "year",
		required:"true",
		style: "width: 8em;",
		autoComplete: true,
		store: yearStore,
		searchAttr: "year",
	},"yearSelect_Rel");
	yearSelect_Capd = new dijit.form.FilteringSelect({
		id: "yearSelect_Capd",
		name: "year",
		required:"true",
		style: "width: 8em;",
		autoComplete: true,
		store: yearStore,
		searchAttr: "year",
	},"yearSelect_Capd");
	
	var analyseData ={
        	identifier: "name",
		items: [
			{name: "target"},
			{name: "exome"},
			{name: "genome"},
			{name: "rnaseq"},
			{name: "singlecell"},
		]
	}
        analyseDataStore = new dojo.data.ItemFileReadStore({
                data: analyseData
        });

	analyseSelect = new dijit.form.FilteringSelect({
		id: "analyseSelect",
		name: "analyseSelect",
		required:"true",
		style: "width: 8em;",
		autoComplete: true,
		store: analyseDataStore,
		searchAttr: "name",
	},"analyseSelect");

	//################# Init Schemas Validation DB ########################
// schemasStore for addCapture()
    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=schemas",
            handleAs: "json",
            load: function (res) {
 		schemasStore = new dojo.store.Memory({data: res});
           }
        });
    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=schemasName",
            handleAs: "json",
            load: function (res) {
 		schemasNameStore = new dojo.store.Memory({data: res});
           }
        });

    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=captureType",
            handleAs: "json",
            load: function (res) {
 		typeCaptureStore = new dojo.store.Memory({data: res});
           }
        });

    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=umiName",
            handleAs: "json",
            load: function (res) {
 		umiNameStore = new dojo.store.Memory({data: res});
           }
        });

	// ComboBox Select or Enter	
	schemasfilterSelect = new dijit.form.ComboBox({
//	schemasfilterSelect = new dijit.form.FilteringSelect({
		id: "capAnalyse",
		name: "capAnalyse",
		required:"true",
		value:"exome",
		autoComplete: false,
		store: schemasStore,
		searchAttr: "Name",
		regExp:"^[a-zA-Z0-9]+$",
		onChange: function(capAnalyse) {
			if (capAnalyse.toLowerCase().replace(/ /g,"") != "exome") {
				boxva = dijit.byId("capValidation");
				boxva.set("value",this.item ? this.item.Name:"");
			} else {
				boxva = dijit.byId("capValidation");
				boxva.attr("value","");
			}
		}
	},"capAnalyse");

	// ComboBox Select or Enter	
	typefilterSelect = new dijit.form.ComboBox({
		id: "capType",
		name: "capType",
		required:"true",
		autoComplete: true,
		store: typeCaptureStore,
		searchAttr: "name",
		placeHolder: "Select or Enter Type",
	},"capType");

	// Only Select
	umifilterSelect = new dijit.form.FilteringSelect({
		id: "capUMI",
		name: "capUMI",
		autoComplete: true,
		store: umiNameStore,
		searchAttr: "name",
		placeHolder: "Select UMI",
	},"capUMI");

	checkCapBed = new dijit.form.CheckBox({
        	name: "checkCapBed",
        	value: "checkCapBed",
        	checked: false,
        	onChange: function(b){
			if(b) {
				dijit.byId("checkCapBed").set('checked', true);
				document.getElementById("capBed").style.display = "block";
			} else {
				dijit.byId("checkCapBed").set('checked', false);
				document.getElementById("capBed").style.display = "none";
			}
		}
    	}, "checkCapBed").startup();

	//################# Init capture Method ########################
	var capmethData ={
        	identifier: "name",
		items: [
			{name: "capture"},
			{name: "pcr"},
		]
	}
        capmethStore = new dojo.data.ItemFileReadStore({
                data: capmethData
        });
// FilteringSelect Only Select
	capmethodSelect = new dijit.form.FilteringSelect({
		id: "capMethod",
		name: "capMethod",
		required:"true",
		autoComplete: false,
		style:"width:8em",
		store: capmethStore,
		searchAttr: "name",
		placeHolder: "Select a Method",
	},"capMethod");

   	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=captureMethName",
            handleAs: "json",
            load: function (res) {
 		capmethNameStore = new dojo.store.Memory({data: res});
           }
        });
// Species
     	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=speciesName",
            handleAs: "json",
            load: function (res) {
 		speciesStore = new dojo.store.Memory({data: res});
           }
        });
	speciesfilterSelect = new dijit.form.FilteringSelect({
		name: "speciesName",
		autoComplete: true,
		required:"true",
		store: speciesStore,
		searchAttr: "name",
		placeHolder: "Select a Species",
		style:"width:8em",
		onChange: function(value) {
			var e_radio=document.getElementById("relRadioCap");
			checkDefRel=1;
			checkDefCapd=1;
			initRadioRunRelCap(dojo.byId("relRadioCap"),e_radio.id,checkDefRel,checkDefCapd,value);
		}

	},"speciesName");

	a_speciesfilterSelect = new dijit.form.FilteringSelect({
		name: "speciesName",
		autoComplete: true,
		required:"true",
		store: speciesStore,
		searchAttr: "name",
		placeHolder: "Select a Species",
		style:"width:8em",
		onChange: function(value) {
			var e_radio=document.getElementById("a_relRadioCap");
			checkDefRel=1;
			checkDefCapd=1;
			initRadioRunRelCap(dojo.byId("a_relRadioCap"),e_radio.id,checkDefRel,checkDefCapd,value);
		}

	},"a_speciesName");
	b_speciesfilterSelect = new dijit.form.FilteringSelect({
		name: "speciesName",
		autoComplete: true,
		required:"true",
		store: speciesStore,
		searchAttr: "name",
		placeHolder: "Select a Species",
		style:"width:8em"
	},"b_speciesName");

// Profile
     	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=profileName",
            handleAs: "json",
            load: function (res) {
 		profileStore = new dojo.store.Memory({data: res});
           }
        });

	profilefilterSelect = new dijit.form.FilteringSelect({
		//id: "value",
		name: "profileName",
		autoComplete: true,
		required:"false",
		store: profileStore,
//		value:"value",
		searchAttr: "name",
		placeHolder: "Select a Profile",
	},"profileName");
	a_profilefilterSelect = new dijit.form.FilteringSelect({
		name: "a_profileName",
		autoComplete: true,
		required:"false",
		store: profileStore,
		searchAttr: "name",
		placeHolder: "Select a Profile",
	},"a_profileName");

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}
	//################# Init type Patient ########################
	var typepatientData ={
        	identifier: "name",
		items: [
			{name: "dna"},
			{name: "rna"},
		]
	}
        typepatientStore = new dojo.data.ItemFileReadStore({
                data: typepatientData
        });

	typepatientSelect = new dijit.form.FilteringSelect({
		id: "patientType",
		name: "patientType",
		required:"true",
		autoComplete: false,
		style:"width:10em",
		store: typepatientStore,
		searchAttr: "name",
		placeHolder: "Select a Type",
	},"patientType");

	a_typepatientSelect = new dijit.form.FilteringSelect({
		//id: "patientType",
		name: "a_patientType",
		required:"true",
		autoComplete: false,
		style:"width:10em",
		store: typepatientStore,
		searchAttr: "name",
		placeHolder: "Select a Type",
	},"a_patientType");


//#################Init Project List #############################
	standbyShow();
	jsonStore = new dojox.data.AndOrReadStore({ 
		url: url_path + "/manageProject.pl?" + "&numAnalyse=" + val_sl
	});

	var menusObjectJ = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};

	menusObjectJ.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectJ.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectJ.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(grid);"}));
	menusObjectJ.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(grid);"}));
	menusObjectJ.cellMenu.startup();
	menusObjectJ.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectJ.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectJ.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(grid);"}));
	menusObjectJ.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(grid);"}));
	menusObjectJ.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(grid);"}));
	menusObjectJ.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(grid);"}));
	menusObjectJ.selectedRegionMenu.startup();

	grid = new dojox.grid.EnhancedGrid({
        	id: "grid",
        	structure: layoutProject,
		selectionMode:"multiple",
		rowSelector: "2.5em",
//		rowsPerPage: 1000,  // IMPORTANT
		canSort:function(colIndex, field){
			return colIndex != 1 && field != 'statut';
		},
		plugins: {
			filter: {
				closeFilterbarButton: true,
				ruleCount: 5,
				itemsName: "name"
			},
			indirectSelection: {
				width: "1.5em",
				styles: "text-align: left;border: 0; margin: 0; padding: 0;",
			},
			nestedSorting: true,
			exporter: true,
			printer:true,
			selector:true,
			menus:menusObjectJ
		},
	}, document.createElement('div'));

	dojo.byId("gridDiv").appendChild(grid.domNode);
	sortDateGrid(jsonStore, date="cDate"); 

	grid.startup();
	grid.setStore(jsonStore);
	dojo.connect(grid, 'onRowDblClick', grid, function (e) {
		var itemP= grid.getItem(e.rowIndex);
			editProject(itemP);
		}
	);
	dojo.connect(grid, "onMouseOver", showTooltip);
	dojo.connect(grid, "onMouseOut", hideTooltip); 
	dojo.connect(grid, "onMouseOver", showTooltipField);
	dojo.connect(grid, "onMouseOut", hideTooltipField); 
	dojo.connect(grid, "onCellMouseOver", showRowTooltip);
	dojo.connect(grid, "onCellMouseOut", hideRowTooltip); 

	var d_sliderp="slider_proj";
	sliderChange(d_sliderp);
	//############### search Project Selection  ###########
	projStore = new dojo.data.ItemFileReadStore({ 
		url: url_path + "/manageData.pl?option=Project",
	});

	//search old project for patient run 
	gridProj = new dojox.grid.EnhancedGrid({
 		store: projStore,
       		id: "gridProj",
		structure: layoutSmallProject,
		selectionMode:"single",
		rowSelector: "0.4em",
		plugins: {
 				nestedSorting: true,
				dnd: true,
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
          			pagination: {
              				pageSizes: ["50", "100", "All"],
              				description: true,
              				sizeSwitch: true,
              				pageStepper: true,
              				gotoButton: true,
              				maxPageStep: 4,
					defaultPageSize: 20,
              				position: "bottom"
          			}
			}
	}, document.createElement('div'));
	dojo.byId("gridProjDiv").appendChild(gridProj.domNode);
	dojo.connect(gridProj, "onMouseOver", showTooltip);
	dojo.connect(gridProj, "onMouseOut", hideTooltip);
	gridProj.startup();
//#################Init User #####################################
    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=DirectorName",
            handleAs: "json",
            load: function (res) {
 		directorStore = new dojo.store.Memory({data: res});
           }
        });

	userStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=user"
	});
	var layoutUser = [
			{field: 'Name',name: 'Last Name',width: '12em'},
			{field: 'Firstname',name: 'First Name',width: '10em'},
			{field: 'Group',name: 'Group',width: '8em'},
			{field: 'Code',name: 'Lab Code',width: '10em'},
			{field: 'Team',name: 'Team',width: '18em',styles:"text-align:left;white-space:nowrap;"},
			{field: 'Site',name: 'Site',width: 'auto'},
	];

	groups_Table = new dojox.grid.EnhancedGrid({
			query: {UserId: '*'},
			store: userStore,
			rowSelector: "0.4em",
			structure: layoutUser,
			plugins: {
				filter: {
					closeFilterbarButton: true,
					ruleCount: 5,
					itemsName: "name"
				},
				nestedSorting: true,
				dnd: true,
				indirectSelection: {
					name: "Sel",
					width: "30px",
					styles: "text-align: center;",
				}
			}
	},document.createElement('div'));

//################# Init Meth #####################################
	AlnStore = new dojox.data.AndOrWriteStore({
			url: url_path + "/manageData.pl?option=methodAln"
	});
	alnRGrid.setStore(AlnStore);
	a_alnRGrid.setStore(AlnStore);

	CallStore = new dojox.data.AndOrWriteStore({
			url: url_path + "/manageData.pl?option=methodCall"
	});
	callRGrid.setStore(CallStore);	
	a_callRGrid.setStore(CallStore);

	OtherStore = new dojox.data.AndOrWriteStore({
			url: url_path + "/manageData.pl?option=methodOther"
	});
	otherRGrid.setStore(OtherStore);	
	a_otherRGrid.setStore(OtherStore);	
//	b_otherRGrid.setStore(OtherStore);
	// Method Call
	groups_MTable = new dojox.grid.EnhancedGrid({
			query: {methType: 'SNP'},
			store: CallStore,
			rowSelector: "0.4em",
			structure: layoutMeth,
			plugins: {
				nestedSorting: true,
				dnd: true,
				indirectSelection: {
					name: "Sel",
					width: "30px",
					styles: "text-align: center;",
				}
			}
	},document.createElement('div'));
	// Method Aln
	groups_ATable = new dojox.grid.EnhancedGrid({
		query: {methType: 'ALIGN'},
		store: AlnStore,
		rowSelector: "0.4em",
		structure: layoutMeth,
		plugins: {
			nestedSorting: true,
			dnd: true,
			indirectSelection: {
				name: "Sel",
				width: "30px",
				styles: "text-align: center;",
			}
		}
	},document.createElement('div'));
	// Method Other (SV SPLICES)
	groups_ATable = new dojox.grid.EnhancedGrid({
		query: {methType: 'SV'},
		store: OtherStore,
		rowSelector: "0.4em",
		structure: layoutMeth,
		plugins: {
			nestedSorting: true,
			dnd: true,
			indirectSelection: {
				name: "Sel",
				width: "30px",
				styles: "text-align: center;",
			}
		}
	},document.createElement('div'));

	// Method complete
	methodStore = new dojo.data.ItemFileWriteStore({
			url: url_path + "/manageData.pl?option=method"
	});
	methodGrid = new dojox.grid.EnhancedGrid({
		query: {methType: '*'},
		store: methodStore,
		rowSelector: "0.4em",
		selectionMode: 'multiple',
		rowsPerPage: 1000,  // IMPORTANT
    		keepRows: 1000,
		structure: layoutMethod,
		plugins: {
			nestedSorting: true,
			dnd: true,
			indirectSelection: {
				name: "Sel",
				width: "30px",
				styles: "text-align: center;",
			}
		}
	},document.createElement('div'));
	dojo.byId("methodGridDiv").appendChild(methodGrid.domNode);
	methodGrid.startup();

	var boxcontent = dijit.byId("pcontent");	
	dojo.connect(methodGrid.selection, "onSelected", function(rowIndex){
		var valcontent="";
		var selectedRows= methodGrid.selection.getSelected();
 		for(var i = 0; i < selectedRows.length; i++){
			valcontent+=selectedRows[i].methName+" ";
       		}
		boxcontent.attr("value",valcontent.trim());
	})
	dojo.connect(methodGrid.selection, "onDeselected", function(rowIndex){
		var valcontent="";
		var selectedRows= methodGrid.selection.getSelected();
 		for(var i = 0; i < selectedRows.length; i++){
			valcontent+=selectedRows[i].methName+" ";
       		}
		boxcontent.attr("value",valcontent.trim());		
	})

	//################# Init Pipeline Method #####################################
	pipelineStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=pipelineName"
	});
 
   	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=pipelineName",
            handleAs: "json",
            load: function (res) {
 		pipelineNameStore = new dojo.store.Memory({data: res});
           }
        });
	//pipelineGrid.setStore(pipelineStore);

	pipelinefilterSelect = new dijit.form.FilteringSelect({
		name: "pipelineName",
		autoComplete: true,
		required:"false",
		style: {width: '300px'},
		store: pipelineNameStore,
		searchAttr: "name",
		placeHolder: "Select a Pipeline Method",
	},"pipelineName");
	document.getElementById("pipeline").style.display = "none";
	document.getElementById("alncall").style.display = "block";
	dojo.connect(pipelinefilterSelect, 'onChange', pipelineAttributeValue);

	a_pipelinefilterSelect = new dijit.form.FilteringSelect({
		name: "a_pipelineName",
		autoComplete: true,
		required:"false",
		style: {width: '300px'},
		store: pipelineNameStore,
		searchAttr: "name",
		placeHolder: "Select a Pipeline Method",
	},"a_pipelineName");
	document.getElementById("a_pipeline").style.display = "none";
	document.getElementById("a_alncall").style.display = "block";
	dojo.connect(a_pipelinefilterSelect, 'onChange', a_pipelineAttributeValue);

	b_pipelinefilterSelect = new dijit.form.FilteringSelect({
		name: "b_pipelineName",
		autoComplete: true,
		required:"false",
		style: {width: '300px'},
		store: pipelineNameStore,
		searchAttr: "name",
		placeHolder: "Select a Pipeline Method",
	},"b_pipelineName");
	document.getElementById("b_pipeline").style.display = "none";
	document.getElementById("b_alncall").style.display = "block";
	dojo.connect(b_pipelinefilterSelect, 'onChange', b_pipelineAttributeValue);

	//################# Init Plateform
	var def_plt=1;
	plateformStore = new dojox.data.AndOrWriteStore({
			url: url_path + "/manageData.pl?option=plateform"
//			url: url_path + "/manageData.pl?option=plateform" + "&default=" + def_plt
	});
	plateformGrid.setStore(plateformStore);
	groups_FTable = new dojox.grid.EnhancedGrid({
		query: {plateformId: '*'},
		store: plateformStore,
		rowSelector: "0.4em",
		structure: layoutPlateform,
		plugins: {
			nestedSorting: true,
			dnd: true,

			indirectSelection: {
				name: "Sel",
				width: "30px",
				styles: "text-align: center;",
			}
		}
	},document.createElement('div'));
	//################# Init Machine
	macStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=machine"
	});
	machineGrid.setStore(macStore);
	//################# Init UMI
	umiStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=umi"
	});
	//################# Init Perspective
	//perspectiveStore = new dojo.data.ItemFileWriteStore({
	//	url: url_path + "/manageData.pl?option=perspective"
	//});
	//################# Init Technology
	technologyStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=technology"
	});
	//################# Init Preparation
	preparationStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=preparation"
	});
	//################# Init Profile data
	profiledataStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=profile"
	});
	//################# Init Meth Seq
	methSeqStore = new dojox.data.AndOrWriteStore({
			url: url_path + "/manageData.pl?option=methodSeq"
	});
	mseqGrid.setStore(methSeqStore);
	
	groups_STable = new dojox.grid.EnhancedGrid({
			query: {methodSeqId: '*'},
			store: methSeqStore,
			rowSelector: "0.4em",
			structure: layoutMethSeq,
			selectionMode: 'single',
			plugins: {
				nestedSorting: true,
				dnd: true,
				indirectSelection: {
					name: "Sel",
					width: "30px",
					styles: "text-align: center;",
				}
			}
	},document.createElement('div'));
	//################ Init Capture
   	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=relGeneName",
            handleAs: "json",
            load: function (res) {
 		relgeneNameStore = new dojo.store.Memory({data: res});
           }
        });
	analyseStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=analyse"
	});

    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=valanalyse",
            handleAs: "json",
            load: function (res) {
 		valanalyseStore = new dojo.store.Memory({data: res});
           }
        });
	dijit.byId("slider_cap").attr('value',val_sl);
	captureStore = new dojox.data.AndOrWriteStore({
			url: url_path + "/manageCapture.pl?option=capture" + "&numAnalyse=" + val_sl
	});

	captureGrid = new dojox.grid.EnhancedGrid({
		store: captureStore,
		structure: layoutCapture,
		selectionMode:"single",
		rowSelector: "0.4em",
		rowsPerPage: 1000,  // IMPORTANT
    		keepRows: 1000,
    		delayScroll: true,
		selectable: true,
		sortFields: [{attribute: 'rel', descending: true}],
		plugins: {
			indirectSelection: {
				width: "1.5em",
				styles: "text-align: left;border: 0; margin: 0; padding: 0;",
			},
			filter: {
				closeFilterbarButton: true,
				ruleCount: 5,
				itemsName: "name"
			},
 			nestedSorting: true,
			dnd: true,
			selector:true,
		}
	},document.createElement('div'));
	// For newrun() new Run Patient
	dojo.byId("captureDiv").appendChild(captureGrid.domNode);
	captureGrid.startup();
	dojo.connect(captureGrid, "onCellMouseOver", showRowTooltip);
	dojo.connect(captureGrid, "onCellMouseOut", hideRowTooltip); 

	a_captureGrid = new dojox.grid.EnhancedGrid({
		store: captureStore,
		structure: layoutCapture,
		selectionMode:"single",
		rowSelector: "0.4em",
//		rowsPerPage: 1000,  // IMPORTANT
		sortFields: [{attribute: 'rel', descending: true}],
		plugins: {
			indirectSelection: {
				width: "1.5em",
				styles: "text-align: left;border: 0; margin: 0; padding: 0;",
			},
			filter: {
				closeFilterbarButton: true,
				ruleCount: 5,
				itemsName: "name"
			},
 			nestedSorting: true,
			dnd: true,
			selector:true,
		}
	},document.createElement('div'));
	dojo.byId("a_captureDiv").appendChild(a_captureGrid.domNode);
	dojo.connect(a_captureGrid, "onCellMouseOver", showRowTooltip);
	dojo.connect(a_captureGrid, "onCellMouseOut", hideRowTooltip); 

	var sp_btsubmit_run=dojo.byId("bt_submit_run");
	var buttonformsubmit_run= new dijit.form.Button({
		showLabel: true,
		id:"RunSubmit",
		type:"submit",
		label:"Submit",
		value:"Submit",
		iconClass:"validIcon",
		style:"color:white",
		onClick:function(){
			newRun();
		}			
	});
	buttonformsubmit_run.startup();
	buttonformsubmit_run.placeAt(sp_btsubmit_run);

	var sp_btcloserun=dojo.byId("bt_close_run");
	var buttonformclose_run= new dijit.form.Button({
		showLabel: false,
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('runDialog').reset();dijit.byId('runDialog').hide();"
	});
	buttonformclose_run.startup();
	buttonformclose_run.placeAt(sp_btcloserun);

	dojo.connect(dijit.byId("buttonAddRun"), "onClick", function(e) {		
		profilefilterSelect.set('store',profileStore);
		profilefilterSelect.startup();
		speciesfilterSelect.set('store',speciesStore);
		speciesfilterSelect.startup();
		speciesfilterSelect.set("value",1);
		dijit.byId("runDialog").show();
		var e_radio=document.getElementById("relRadioCap");
		var desFormvalue = dijit.byId("relCapForm").getValues();
		var speciesFormvalue = dijit.byId("speciesForm").getValues();
		var checkDefRel=1;
		var checkDefCapd=1;
		initRadioRunRelCap(dojo.byId("relRadioCap"),e_radio.id,1,1,speciesFormvalue.speciesName);
		var checkDefRel=desFormvalue.rel_defbox;
		var checkDefCapd=desFormvalue.capd_defbox;
		dojo.connect(dijit.byId("rel_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefRel=1;} else {checkDefRel=0;}
			dijit.byId('capd_defbox').set('checked', true);
			checkDefCapd=1;
			speciesFormvalue = dijit.byId("speciesForm").getValues();
initRadioRunRelCap(dojo.byId("relRadioCap"),e_radio.id,checkDefRel,checkDefCapd,speciesFormvalue.speciesName);
		});

		var er= document.getElementById("runSamplesheet");
  		er.value = "";
		var desFormvalue = dijit.byId("desForm").getValues();

		var checkDefPlt=desFormvalue.plt_defbox;
		filterDefGrid("Plt",plateformGrid,1);
		dojo.connect(dijit.byId("plt_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefPlt=1;} else {checkDefPlt=0;}
			filterDefGrid("Plt",plateformGrid,checkDefPlt);
		});

		var checkDefMac=desFormvalue.mac_defbox;
		filterDefGrid("Mac",machineGrid,1);
		dojo.connect(dijit.byId("mac_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefMac=1;} else {checkDefMac=0;}
			filterDefGrid("Mac",machineGrid,checkDefMac);
		});

		var checkDefMseq=desFormvalue.mseq_defbox;
		filterDefGrid("MSeq",mseqGrid,1);
		dojo.connect(dijit.byId("mseq_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefMseq=1;} else {checkDefMseq=0;}
			filterDefGrid("MSeq",mseqGrid,checkDefMseq);
		});

		var checkDefMaln=desFormvalue.maln_defbox;
		filterDefGrid("MAln",alnRGrid,1);
		dojo.connect(dijit.byId("maln_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefMaln=1;} else {checkDefMaln=0;}
			filterDefGrid("MAln",alnRGrid,checkDefMaln);
		});

		var checkDefMcall=desFormvalue.mcall_defbox;
		filterDefGrid("MCall",callRGrid,1);
		dojo.connect(dijit.byId("mcall_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefMcall=1;} else {checkDefMcall=0;}
			filterDefGrid("MCall",callRGrid,checkDefMcall);
		});

//		dijit.byId("runDialog").show();
		captureGrid.selection.clear();
		dijit.byId('alnRGrid').selection.clear();
		dijit.byId('callRGrid').selection.clear();
		dijit.byId('otherRGrid').selection.clear();
	});
	//################ Init Run Type
	var rtypeStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/manageData.pl?option=runtype"
	});

	var rtypefilterSelect = new dijit.form.FilteringSelect({
		id: "rtypeInput",
		jsId:"rtypeInput",
		name: "runTypeName",
		value: "ngs",
		store: rtypeStore,
		searchAttr: "runTypeName"
	},"rtypeInput");

//######## Init Run #####################################
	dijit.byId("slider_run").attr('value',val_sl);
	runStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=allqRun" + "&numAnalyse=" + val_sl
		//url: url_path + "/manageData.pl?option=allqRunDev" + "&numAnalyse=" + val_sl //PLT
	});

	var menusObjectR = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};

	menusObjectR.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectR.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectR.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridRundoc);"}));
	menusObjectR.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridRundoc);"}));
	menusObjectR.cellMenu.startup();
	menusObjectR.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectR.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectR.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridRundoc);"}));
	menusObjectR.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(gridRundoc);"}));
	menusObjectR.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridRundoc);"}));
	//menusObjectR.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected2(gridRundoc,withShif=1);"}));
	menusObjectR.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(gridRundoc);"}));

	menusObjectR.selectedRegionMenu.startup();
	sortDateGrid(runStore, date="cDate");
	gridRundoc = new dojox.grid.EnhancedGrid({
			store: runStore,
			structure: layoutRun,
			rowSelector: "2.5em",
			//rowsPerPage: 1000,  // IMPORTANT
			selectionMode: 'multiple',
			canSort:function(colIndex, field){
				return colIndex != 1 && field != 'statRun' && field != 'Row' && field != 'Rapport';
			},
			plugins: {
				filter: {
					closeFilterbarButton: true,
					ruleCount: 5,
					itemsName: "name"
				},
          			pagination: {
              				pageSizes: ["25","50","100", "All"],
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
				selector:true,
				menus:menusObjectR
			}
	},document.createElement('div'));
	dojo.byId("gridRundocDiv").appendChild(gridRundoc.domNode);
	gridRundoc.startup();
	gridRundoc.store.fetch({onComplete:standbyHide});

	dojo.connect(gridRundoc, 'onRowDblClick', gridRundoc, function (e) {
		var itemR= gridRundoc.getItem(e.rowIndex);
			editOneRun(itemR,e.rowIndex);
		}
	);

	dojo.connect(gridRundoc, "onMouseOver", showTooltip);
	dojo.connect(gridRundoc, "onMouseOut", hideTooltip); 
	dojo.connect(gridRundoc, "onMouseOver", showTooltipField);
	dojo.connect(gridRundoc, "onMouseOut", hideTooltipField); 
	dojo.connect(gridRundoc, "onCellMouseOver", showRowTooltip);
	dojo.connect(gridRundoc, "onCellMouseOut", hideRowTooltip); 
	var d_sliderr="slider_run";
	sliderChange(d_sliderr);
// Patient Control in Run & Project
	dijit.byId("btn_control").set('checked', true);
	dijit.byId("btn_control2").set('checked', true);
	pcontrol=1;
// Person Info in Run & Project
 	dijit.byId("btn_person").set('checked', false);
 	dijit.byId("btn_person2").set('checked', false);

//####### store xhrGet ###################################################
	sexStore = new dojo.data.ItemFileReadStore({
		data: { identifier: 'value', label: 'name',
		items: [{value: 0,name: 'Unknown'},
		{value: 1,name: 'Male'},
		{value: 2,name: 'Female'}]
		}
	});

	statusStore = new dojo.data.ItemFileReadStore({
		data: { identifier: 'value', items: [{value: 0,name: 'Unknown'},
		{value: 1,name: 'Unaffected'},
		{value: 2,name: 'Affected'}]
		}
	});

    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=methSeqName",
            handleAs: "json",
            load: function (res) {
 		methSeqNameStore = new dojo.store.Memory({data: res});
           }
        });

   	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=AlnName",
            handleAs: "json",
            load: function (res) {
 		AlnNameStore = new dojo.store.Memory({data: res});
           }
        });

    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=CallName",
            handleAs: "json",
            load: function (res) {
 		CallNameStore = new dojo.store.Memory({data: res});
           }
        });

    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=OtherName",
            handleAs: "json",
            load: function (res) {
 		OtherNameStore = new dojo.store.Memory({data: res});
           }
        });

    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=machineName",
            handleAs: "json",
            load: function (res) {
 		machineStore = new dojo.store.Memory({data: res});
           }
        });

    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=plateformName",
            handleAs: "json",
            load: function (res) {
 		plateformNameStore = new dojo.store.Memory({data: res});
           }
        });

     	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=captureName",
            handleAs: "json",
            load: function (res) {
 		capStore = new dojo.store.Memory({data: res});
           }
        });

  	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=groupName",
            handleAs: "json",
            load: function (res) {
 		groupNameStore = new dojo.store.Memory({data: res});
           }
        });

  //################# init Phenotype #######################################
    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=phenotype",
            handleAs: "json",
            load: function (res) {
 		phenotypeStore = new dojo.store.Memory({data: res});
           }
        });

  //################# init release Gene #######################################
    	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=phenotypeName",
            handleAs: "json",
            load: function (res) {
 		phenotypeNameStore = new dojo.store.Memory({data: res});
           }
        });

  	dojo.xhrGet({
            url: url_path + "/manageData.pl?option=relGeneName",
            handleAs: "json",
            load: function (res) {
 		relgeneNameStore = new dojo.store.Memory({data: res});
           }
        });

//	relgenefilterSelect = new dijit.form.ComboBox({
	relgenefilterSelect = new dijit.form.FilteringSelect({
		id: "bunRelGene",
		name: "bunRelGene",
		required:"true",
		style: "width: 8em;",
		autoComplete: true,
		store: relgeneNameStore,
		searchAttr: "name",
	},"bunRelGene");

	relgenecapfilterSelect = new dijit.form.FilteringSelect({
		id: "capRelGene",
		name: "capRelGene",
		required:"true",
		style: "width: 8em;",
		autoComplete: true,
		store: relgeneNameStore,
		searchAttr: "name",
	},"capRelGene");

	var xhrArgsS1 = {
       		url: url_path + "/manageData.pl?option=gpatientProjectDest"+"&Sex=1",
 		handleAs: "json",
		preventCache: this.urlPreventCache,
		load: function (res) {
			memo1Store = new dojo.store.Memory({data: [],idProperty: "patname"});
			initfatherStore = new dojo.store.Memory({data: res, idProperty: "patname"});
			fatherStore = new dojo.store.Cache(initfatherStore,memo1Store);
		}
	}
	var deferredS1 = dojo.xhrGet(xhrArgsS1);

	var xhrArgsS2 = {
       		url: url_path + "/manageData.pl?option=gpatientProjectDest"+"&Sex=2",
 		handleAs: "json",
		preventCache: this.urlPreventCache,
		load: function (res) {
			memo2Store = new dojo.store.Memory({data: [],idProperty: "patname"});
			initmotherStore = new dojo.store.Memory({data: res, idProperty: "patname"});
			motherStore = new dojo.store.Cache(initmotherStore,memo2Store);
		}
	}
	var deferredS2 = dojo.xhrGet(xhrArgsS2);

	layoutOneRun = [
		{ field: "cDate", name: "Date",datatype:"date", width: '7'},
		{ field: "name", name: "Run Name (bcl directory)", width: '30', editable:true},
		{ field: "desRun",name: "Description", width: '20', editable:true},
		{ field: "pltRun",name: "Plateform Run Name (fastq directory)", width: '30', editable:true},
	];
//#################Init Capture #############################
	var sub="Cap";
	var BCcapture =  new dijit.layout.BorderContainer({
		}, "appSubCapture");
	cpCcapture = new dijit.layout.ContentPane({
		region: "center",
		style:"margin: 0; padding: 0;",
		id:"cp"+sub+"C"
	});
	BCcapture.addChild(cpCcapture);
	var div= document.createElement("div");
	div.id="grid"+sub+"Div";
	div.style="width: 100%; height: 100%;margin: 0; margin: 0;";

	var title="Capture";
	var bt_title=title.split(",");
	var bt_title_fn=bt_title[0].replace(/ /g,"_");
	var sp_btcap=dojo.byId("button_cap");
	var buttonform_cap= new dijit.form.Button({
		showLabel: true,
		iconClass:"plusIcon",
		style:"color:white",
 		label : "New "+bt_title[0],
		onclick:"viewNew"+bt_title_fn+"_"+sub+"();",
	});
	buttonform_cap.startup();
	buttonform_cap.placeAt(sp_btcap);
	cpCcapture.set('content',div);

	var sp_btclosecap=dojo.byId("bt_close_cap");
	var buttonformclose_cap= new dijit.form.Button({
//		id:"id_bt_closeexcap",
		showLabel: false,
		iconClass:"closeIcon",
		style:"color:white",
 		label : "Close",
		onClick:function() {
			closeEditCapture();
		}
	});
	buttonformclose_cap.startup();
	buttonformclose_cap.placeAt(sp_btclosecap);

	var menusObjectCapBun = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};
	menusObjectCapBun.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectCapBun.cellMenu.addChild(new dijit.MenuSeparator());
	menusObjectCapBun.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll('grid_"+sub+"');"}));
	menusObjectCapBun.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll('grid_"+sub+"');"}));
	menusObjectCapBun.cellMenu.startup();
	menusObjectCapBun.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectCapBun.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectCapBun.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll('grid_"+sub+"');"}));
	menusObjectCapBun.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected('grid_"+sub+"');"}));
	menusObjectCapBun.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll('grid_"+sub+"');"}));
	menusObjectCapBun.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected('grid_"+sub+"');"}));
	menusObjectCapBun.selectedRegionMenu.startup();

	gridCap = new dojox.grid.EnhancedGrid({
		id: "grid_"+sub,
		store: captureStore,
		rowSelector: "0.4em",
		structure: layoutCaptureData,
		selectionMode:"multiple",
		queryOptions:{ignoreCase:true},
		canSort:function(colIndex, field){
			return colIndex != 1 && field != 'FreeCap' && field != 'capD' && field != 'capPrimers' && field != 'flagGn' && field !='nbBun' && field !='nbTr';
		},

		plugins: {
			filter: {
				closeFilterbarButton: true,
				ruleCount: 5,
				itemsName: "name"
			},
			indirectSelection: {
				name: "Sel",
				width: "30px",
				styles: "text-align: center;",
			},
			nestedSorting: true,
			dnd: true,
			exporter: true,
			printer:true,
			selector:true,
			menus:menusObjectCapBun
		}
	});
	gridCap.setStore(captureStore);
	gridCap.placeAt(div.id);
	gridCap.startup();
	dojo.connect(gridCap, "onMouseOver", showTooltip);
	dojo.connect(gridCap, "onMouseOut", hideTooltip); 
	dojo.connect(gridCap, "onMouseOver", showTooltipField);
	dojo.connect(gridCap, "onMouseOut", hideTooltipField);
	dojo.connect(gridCap, "onCellMouseOver", showRowTooltip);
	dojo.connect(gridCap, "onCellMouseOut", hideRowTooltip); 
	var d_sliderc="slider_cap";
	sliderChange(d_sliderc);

	var cpBcapture = new dijit.layout.ContentPane({
		region: "bottom",
		align:"center",
		style:"color:white;margin: 0; padding: 0;",
		id:"cp"+sub+"B"
	});

	dojo.connect(gridCap, 'onRowDblClick', gridCap, function(e) {
			var itemC= gridCap.getItem(e.rowIndex); 
			var domBtcapFiles=dojo.byId("domBt_capFilesNext");
			var w_toolcapFile =dijit.byId("bt_capSubmit");
			if (w_toolcapFile) {
				domBtcapFiles.removeChild(toolbar_capFiles.domNode);
				w_toolcapFile.destroyRecursive();
			}
			document.getElementById("AccMain").style.display = "block";
			editCapture(itemC);
		}		
	);
	dojo.style(dijit.byId('loadF').domNode, {visibility:'hidden'});
	dojo.style(dijit.byId('a_loadF').domNode, {visibility:'hidden'});
	dijit.byId("btn_force").set('checked', false);
	dijit.byId("btn_sforce").set('checked', false);
	sforce=0;
	force=0;
	dojo.style(dijit.byId("bt_delProject").domNode,{'visibility':'hidden'});
	dojo.style(dijit.byId("bt_saveProject").domNode,{'visibility':'hidden'});
	dojo.style(dijit.byId("bt_remPatientProject").domNode,{'visibility':'visible'});	
	dojo.style('capColForm', 'display', 'none');
	dojo.style(dijit.byId("bt_addTrans").domNode,{'visibility':'hidden'});	
//################# Add patient to Run #############################
	var sp_btcloseaddpat=dojo.byId("bt_close_addpat");
	var buttonformclose_addpat= new dijit.form.Button({
		showLabel: false,
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('addPatientDialog').reset();dijit.byId('addPatientDialog').hide();"
	});
	buttonformclose_addpat.startup();
	buttonformclose_addpat.placeAt(sp_btcloseaddpat);

	var sp_btsubmit_addpat=dojo.byId("bt_submit_addpat");
	var buttonformsubmit_addpat= new dijit.form.Button({
		showLabel: true,
		id:"a_RunSubmit",
		type:"submit",
		label:"Submit",
		value:"Submit",
		iconClass:"validIcon",
		style:"color:white",
		onClick:function(){
			addPatient();
		}			
	});
	buttonformsubmit_addpat.startup();
	buttonformsubmit_addpat.placeAt(sp_btsubmit_addpat);
	dojo.connect(dijit.byId("buttonAddPat"), "onClick", function(e) {
		a_profilefilterSelect.set('store',profileStore);
		a_profilefilterSelect.startup();
		a_speciesfilterSelect.set('store',speciesStore);
		a_speciesfilterSelect.startup();
		a_speciesfilterSelect.set("value",1);
		var e_radio=document.getElementById("a_relRadioCap");
		var desFormvalue = dijit.byId("a_relCapForm").getValues();
		var speciesFormvalue = dijit.byId("a_desForm").getValues();
		var checkDefaRel=1;
		var checkDefaCapd=1;
		initRadioRunRelCap(dojo.byId("a_relRadioCap"),e_radio.id,1,1,speciesFormvalue.speciesName);
		var checkDefaRel=desFormvalue.a_rel_defbox;
		var checkDefaCapd=desFormvalue.a_capd_defbox;
		//initRadioRunRelCap(dojo.byId("a_relRadioCap"),e_radio.id,1,1);
		dojo.connect(dijit.byId("a_rel_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefaRel=1;} else {checkDefaRel=0;}
			dijit.byId('a_capd_defbox').set('checked', true);
			checkDefaCapd=1;
			speciesFormvalue = dijit.byId("a_desForm").getValues();			initRadioRunRelCap(dojo.byId("a_relRadioCap"),e_radio.id,checkDefaRel,checkDefaCapd,speciesFormvalue.speciesName);
		});

		var desFormvalue = dijit.byId("a_desForm").getValues();
		var checkDefaMaln=desFormvalue.a_maln_defbox;
		filterDefGrid("aMAln",a_alnRGrid,1);
		dojo.connect(dijit.byId("a_maln_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefaMaln=1;} else {checkDefaMaln=0;}
			filterDefGrid("aMAln",a_alnRGrid,checkDefaMaln);
		});

		filterDefGrid("aMCall",a_callRGrid,1);
		dojo.connect(dijit.byId("a_mcall_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefaMcall=1;} else {checkDefaMcall=0;}
			filterDefGrid("aMCall",a_callRGrid,checkDefaMcall);
		});

		dijit.byId("addPatientDialog").show();
		a_captureGrid.selection.clear();
		dijit.byId('a_alnRGrid').selection.clear();
		dijit.byId('a_callRGrid').selection.clear();
		dijit.byId('a_otherRGrid').selection.clear();
	});
//################# update patient by Copy/Paste #############################
	var sp_btsubmit_uppat=dojo.byId("bt_submit_uppat");
	var buttonformsubmit_uppat= new dijit.form.Button({
		showLabel: true,
		id:"uppatSubmit",
		type:"submit",
		label:"Submit",
		value:"Submit",
		iconClass:"validIcon",
		style:"color:white",
		onClick:function(){
			updateRunPatient();
		}			
	});
	buttonformsubmit_uppat.startup();
	buttonformsubmit_uppat.placeAt(sp_btsubmit_uppat);

	var sp_btcloseuppat=dojo.byId("bt_close_uppat");
	var buttonformclose_uppat= new dijit.form.Button({
		showLabel: false,
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('upPatientDialog').reset();dijit.byId('upPatientDialog').hide();"
	});
	buttonformclose_uppat.startup();
	buttonformclose_uppat.placeAt(sp_btcloseuppat);

//	var formUpPatDlg = dijit.byId("upPatientDialog");
//	dojo.connect(dijit.byId("buttonUpPat"), "onClick", formUpPatDlg, "show");
	dojo.connect(dijit.byId("buttonUpPat"), "onClick", function(e) {
		b_speciesfilterSelect.set('store',speciesStore);
		b_speciesfilterSelect.startup();
		b_speciesfilterSelect.set("value",1);		
		dijit.byId("upPatientDialog").show();
	});

//################# add Methods to patient  #############################
	var sp_btcloseaddmethpat=dojo.byId("bt_close_addmeth2pat");
	var buttonformclose_addmethpat= new dijit.form.Button({
		showLabel: false,
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('addMetodsToPatientDialog').reset();dijit.byId('addMetodsToPatientDialog').hide();"
	});
	buttonformclose_addmethpat.startup();
	buttonformclose_addmethpat.placeAt(sp_btcloseaddmethpat);

	var sp_btsubmit_addmethpat=dojo.byId("bt_submit_addmeth2pat");
	var buttonformsubmit_addmethpat= new dijit.form.Button({
		showLabel: true,
		id:"b_RunSubmit",
		type:"submit",
		label:"Submit",
		value:"Submit",
		iconClass:"validIcon",
		style:"color:white",
		onClick:function(){
			addMethodsToPatient();
		}			
	});
	buttonformsubmit_addmethpat.startup();
	buttonformsubmit_addmethpat.placeAt(sp_btsubmit_addmethpat);

//################# Init Identity vigilance/Bar code genotype #############################
	var sp_btsubmit_bcg=dojo.byId("bt_submit_bcg");
	var buttonformsubmit_bcg= new dijit.form.Button({
		showLabel: true,
		id:"BCGSubmit",
		type:"submit",
		label:"Submit",
		value:"Submit",
		iconClass:"validIcon",
		style:"color:white",
		onClick:function(){
			addBCG2patient();
		}			
	});
	buttonformsubmit_bcg.startup();
	buttonformsubmit_bcg.placeAt(sp_btsubmit_bcg);

	var sp_btclosebcg=dojo.byId("bt_close_bcg");
	var buttonformclose_bcg= new dijit.form.Button({
		showLabel: false,
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('bcgDialog').reset();dijit.byId('bcgDialog').hide();"
	});
	buttonformclose_bcg.startup();
	buttonformclose_bcg.placeAt(sp_btclosebcg);
	dojo.style(dijit.byId('loadBCG').domNode, {visibility:'hidden'});
	var formBCGDlg = dijit.byId("bcgDialog");
	dojo.connect(dijit.byId("buttonAddBCG"), "onClick", formBCGDlg, "show");
//################# Init DropDown Menu Profile #############################
	var sp_btDropDownProfile_Run=dojo.byId("dropDownRunProfile_bt");
	var sp_btDropDownProfile_Project=dojo.byId("dropDownProjectProfile_bt");

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
	var profileMenuStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=profileName",
		clearOnClose: true,
	});
	var no_profile="0 No Profile";
	menuDDM.addChild(new dijit.MenuItem({
					label: no_profile,
					onClick: function(){ 
							updateProfile(no_profile);
				}
        	})
	);

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
//################# Init DropDown Menu Species #############################
	var sp_btDropDownSpecies_Run=dojo.byId("dropDownRunSpecies_bt");
	var sp_btDropDownSpecies_Project=dojo.byId("dropDownProjectSpecies_bt");
  
	var menuDDS = new dijit.DropDownMenu({ style: "display: none;"});
        var buttonDDS = new dijit.form.DropDownButton({
		label: "Species",
		name: "Species",
		dropDown: menuDDS,
		iconClass:"speciesIcon",
        });
        var buttonDDS2 = new dijit.form.DropDownButton({
		label: "Species",
		name: "Species",
		dropDown: menuDDS,
		iconClass:"speciesIcon",
        });
	var speciesMenuStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=speciesName",
		clearOnClose: true,
	});
	var gotSpeciesList = function(items, request){
		dojo.forEach(items, function(i){
			var nameS= speciesMenuStore.getValue(i,"name");
			menuDDS.addChild(new dijit.MenuItem({
					label: nameS,
					onClick: function(){ 
							updateSpecies(nameS);
					 }
        			})
			);
		});
	}
	var gotSpeciesError = function(error, request){
  		alert("Failed Species Menu Store " +  error);
	}
	speciesMenuStore.fetch({
  		onComplete: gotSpeciesList,
  		onError: gotSpeciesError
	});

	sp_btDropDownSpecies_Run.appendChild(buttonDDS.domNode);
	buttonDDS.startup();
	buttonDDS.placeAt(sp_btDropDownSpecies_Run);

	sp_btDropDownSpecies_Project.appendChild(buttonDDS2.domNode);
	buttonDDS2.startup();
	buttonDDS2.placeAt(sp_btDropDownSpecies_Project);
//################# Init Unassigned Projects #############################
	unaProjDisplay(fromRun=1);
}// End init()

function filterDefGrid(table,grid,val) {
	if (table=="Plt") {
		if (val) {grid.setQuery({complexQuery:"plateformId:* AND def:1"});
		} else {grid.setQuery({complexQuery:"plateformId:*"});}
	}
	if (table=="Mac") {
		if (val) {grid.setQuery({complexQuery:"machineId:* AND def:1"});
		} else {grid.setQuery({complexQuery:"machineId:*"});}
	}
	if (table=="MSeq") {
		if (val) {grid.setQuery({complexQuery:"methodSeqId:* AND def:1"});
		} else {grid.setQuery({complexQuery:"methodSeqId:*"});}
	}
	if (table=="MAln" || table=="aMAln" || table=="bMAln" || table=="MCall" || table=="aMCall" || table=="bMCall") {
		if (val) {grid.setQuery({complexQuery:"methodId:* AND def:1"});
		} else {grid.setQuery({complexQuery:"methodId:*"});}
	}
	grid.store.fetch();
	grid.store.close();
	grid._refresh();
}

function pipelineAttributeValue() {
	var filterRes = dijit.byId("pipelineName").item;
	if (filterRes) {
		document.getElementById("pipelineName").value = filterRes.value+": "+filterRes.Name;
	}
}

function a_pipelineAttributeValue() {
	var filterRes = dijit.byId("a_pipelineName").item;
	if (filterRes) {
		document.getElementById("a_pipelineName").value = filterRes.value+": "+filterRes.Name;
	}
}

function b_pipelineAttributeValue() {
	var filterRes = dijit.byId("b_pipelineName").item;
	if (filterRes) {
		document.getElementById("b_pipelineName").value = filterRes.value+": "+filterRes.Name;
	}
}

function updateProfile(name) {
	var dialogProj = dijit.byId("viewProj");
	var fromProject=0;
	if( dialogProj.open ) {
 		fromProject=1;
	}
	if (fromProject) {
		upProfile(fromProject,patientprojectGrid,name);
	} else {
		upProfile(fromProject,patGrid,name);
	}
}

function upProfile(fromproject,grid,name) {
	var item = grid.selection.getSelected();
	var PatIdGroups = new Array();
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatIdGroups.push(Patvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("First Select Patients Please...");
		myError.show();
		return;
	}
	var profileId=name.split(" ")[0];
	var url_insert = url_path + "/manageData.pl?option=upPatientProfile" +
						"&PatIdSel=" + PatIdGroups +
						"&profileid=" + profileId;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				if (fromproject) {
					refreshControlProject();
				} else {
					refreshControlRun();
				}
			}
		}
	);
}

function updateSpecies(name) {
	var dialogProj = dijit.byId("viewProj");
	var fromProject=0;
	if( dialogProj.open ) {
 		fromProject=1;
	}
	if (fromProject) {
		upSpecies(fromProject,patientprojectGrid,name);
	} else {
		upSpecies(fromProject,patGrid,name);
	}
}

function upSpecies(fromproject,grid,name) {
	var item = grid.selection.getSelected();
	var PatIdGroups = new Array();
	var PersIdGroups = new Array();
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatIdGroups.push(Patvalue);
					}
					if (attribute == "p_personId" ) {
						PersIdGroups.push(Patvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("First Select Patients Please...");
		myError.show();
		return;
	}
	var url_insert = url_path + "/manageData.pl?option=upPatientSpecies" +
						"&PatIdSel=" + PatIdGroups +
						"&PersIdSel=" + PersIdGroups +
						"&species=" + name;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				if (fromproject) {
					refreshControlProject();
				} else {
					refreshControlRun();
				}
			}
		}
	);

}

function closeEditCapture() {
	dijit.byId('divCapBun').hide();
	dijit.byId('divBundleDB').reset();
	dijit.byId('divBundleDB').hide();
	exonFile=0;
	unactivateCapLoading();
	if (deferredEx) {
		if(!deferredEx.isResolved()) {
			deferredEx.cancel();
		}
		if(!deferredUnTr.isResolved()) {
			deferredUnTr.cancel();
		}
	}
}

function unactivateCapLoading(){
	dijit.byId("exDeposit").set('disabled', true);	
	dijit.byId("exRetrieve").set('disabled', true);	
}

function unaProjDisplay(fromRun) {
	var sp_btcloseunaProj=dojo.byId("bt_close_unaProj");
	var btcloseunaProj=dijit.byId("id_bt_close_unaProj");
	if (btcloseunaProj) {
	//	sp_btcloseunaProj.removeChild(btclosesunaProj.domNode);
		btcloseunaProj.destroyRecursive();
	}
	var buttonformclose_unaProj= new dijit.form.Button({
		showLabel: false,
		id:"id_bt_close_unaProj",
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('unaDialog').hide();"
	});
	buttonformclose_unaProj.startup();
	buttonformclose_unaProj.placeAt(sp_btcloseunaProj);
	nbweeks=12;// 9 weeks = 2 months
//	nbweeks=18;// 9 weeks = 2 months
//	nbweeks=27;// 9 weeks = 2 months
	var spNBW = dojo.byId("sp_nbweeks");
	spNBW.innerHTML= nbweeks;

	var unaProjStore = new dojo.data.ItemFileReadStore({ 
		url: url_path + "/unassignedProjects.pl?&nbweeks=" +nbweeks,
	});

	var menusObjectU = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};

	menusObjectU.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectU.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectU.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(unaProjGrid);"}));
	menusObjectU.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(unaProjGrid);"}));
	menusObjectU.cellMenu.startup();



	function fetchFailedUna(error, request) {
		alert("lookup failed unaProjGridDiv");
		alert(error);
	}

	function clearOldUnaList(size, request) {
                    var listUna = dojo.byId("unaProjGridDiv");
                    if (listUna) {
                        while (listUna.firstChild) {
                           listUna.removeChild(listUna.firstChild);
                        }
                    }
	}
	unaProjStore.fetch({
		onBegin: clearOldUnaList,
		onError: fetchFailedUna,
		onComplete: function(items){
			unaProjGrid = new dojox.grid.EnhancedGrid({
 				store: unaProjStore,
       				//id: "unaProjGrid",
				structure: layoutUnaProjGrid,
				selectionMode:"single",
				rowSelector: "0.4em",
				plugins: {
 					nestedSorting: true,
					dnd: true,
					exporter: true,
					printer:true,
					selector:true,
					menus:menusObjectU
 				}
			}, document.createElement('div'));
			dojo.byId("unaProjGridDiv").appendChild(unaProjGrid.domNode);
			unaProjGrid.startup();
			dojo.connect(unaProjGrid, "onMouseOver", showTooltip);
			dojo.connect(unaProjGrid, "onMouseOut", hideTooltip); 
		}
	});
	var unaDialogForm = dijit.byId("unaDialog");
	unaDialogForm.hide();
	if (fromRun) {
		showProgressDlg("Loading Unassigned Projects... ",true,"gridRundocDiv","NA");
	} else {
		showProgressDlg("Loading Unassigned Projects... ",true,"gridDiv","NA");

	}
	var gotList = function(items, request){
		var NBPROJ = 0;
		dojo.forEach(items, function(i){
			NBPROJ += unaProjStore.getValue(i,"Row");
		});
		if (NBPROJ == 0) {
			unaDialogForm.hide();
		} else {
			unaDialogForm.show();
		}
		if (fromRun) {
			showProgressDlg("Loading Unassigned Projects... ",false,"gridRundocDiv","NA");
		} else {
			showProgressDlg("Loading Unassigned Projects... ",false,"gridDiv","NA");

		}
	}
	var gotError = function(error, request){
  		alert("unaProjDisplay: The request to the store failed. " +  error);
	}
	unaProjStore.fetch({
  		onComplete: gotList,
  		onError: gotError
	});
}

function sliderChange(slider) {
	dojo.connect(dijit.byId(slider),"onChange",function(e) {
		dijit.byId('FilterProjBox').set('value',"");		   
		dijit.byId('FilterRunBox').set('value',"");		   
		dijit.byId('FilterCapBox').set('value',"");	
		if (e==1) {
			//All
			runStore = new dojox.data.AndOrWriteStore({url: url_path + "/manageData.pl?option=allqRun" + "&numAnalyse=1"});
			jsonStore = new dojox.data.AndOrReadStore({ url: url_path + "/manageProject.pl?" + "&numAnalyse=1"});
			captureStore = new dojox.data.AndOrWriteStore({ url: url_path + "/manageCapture.pl?option=capture" + "&numAnalyse=1"});	
			dijit.byId("slider_run").attr('value',1);
			dijit.byId("slider_proj").attr('value',1);
			dijit.byId("slider_cap").attr('value',1);
			val_sl=1;
		} else if (e==2) {
			//Exome
			runStore = new dojox.data.AndOrWriteStore({url: url_path + "/manageData.pl?option=allqRun" + "&numAnalyse=2"});
			jsonStore = new dojox.data.AndOrReadStore({ url: url_path + "/manageProject.pl?" + "&numAnalyse=2"});
			captureStore = new dojox.data.AndOrWriteStore({ url: url_path + "/manageCapture.pl?option=capture" + "&numAnalyse=2"});
			dijit.byId("slider_run").attr('value',2);
			dijit.byId("slider_proj").attr('value',2);
			dijit.byId("slider_cap").attr('value',2);
			val_sl=2;
		} else if (e==3) {
			//Genome
			runStore = new dojox.data.AndOrWriteStore({url: url_path + "/manageData.pl?option=allqRun" + "&numAnalyse=3"});
			jsonStore = new dojox.data.AndOrReadStore({ url: url_path + "/manageProject.pl?" + "&numAnalyse=3"});
			captureStore = new dojox.data.AndOrWriteStore({ url: url_path + "/manageCapture.pl?option=capture" + "&numAnalyse=3"});
			dijit.byId("slider_run").attr('value',3);
			dijit.byId("slider_proj").attr('value',3);
			dijit.byId("slider_cap").attr('value',3);
			val_sl=3;
		} else if (e==4) {
			//Target
			runStore = new dojox.data.AndOrWriteStore({url: url_path + "/manageData.pl?option=allqRun" + "&numAnalyse=4"});
			jsonStore = new dojox.data.AndOrReadStore({ url: url_path + "/manageProject.pl?" + "&numAnalyse=4"});
			captureStore = new dojox.data.AndOrWriteStore({ url: url_path + "/manageCapture.pl?option=capture" + "&numAnalyse=4"});
			dijit.byId("slider_run").attr('value',4);			
			dijit.byId("slider_proj").attr('value',4);
			dijit.byId("slider_cap").attr('value',4);
			val_sl=4;
		} else if (e==5) {
			//RNAseq
			runStore = new dojox.data.AndOrWriteStore({url: url_path + "/manageData.pl?option=allqRun" + "&numAnalyse=5"});
			jsonStore = new dojox.data.AndOrReadStore({ url: url_path + "/manageProject.pl?" + "&numAnalyse=5"});
			captureStore = new dojox.data.AndOrWriteStore({ url: url_path + "/manageCapture.pl?option=capture" + "&numAnalyse=5"});
			dijit.byId("slider_run").attr('value',5);			
			dijit.byId("slider_proj").attr('value',5);
			dijit.byId("slider_cap").attr('value',5);
			val_sl=5;
		} else if (e==6) {
			//SingleCell
			runStore = new dojox.data.AndOrWriteStore({url: url_path + "/manageData.pl?option=allqRun" + "&numAnalyse=6"});
			jsonStore = new dojox.data.AndOrReadStore({ url: url_path + "/manageProject.pl?" + "&numAnalyse=6"});
			captureStore = new dojox.data.AndOrWriteStore({ url: url_path + "/manageCapture.pl?option=capture" + "&numAnalyse=6"});
			dijit.byId("slider_run").attr('value',6);			
			dijit.byId("slider_proj").attr('value',6);
			dijit.byId("slider_cap").attr('value',6);
			val_sl=6;
		} else if (e==7) {
			//Amplicon
			runStore = new dojox.data.AndOrWriteStore({url: url_path + "/manageData.pl?option=allqRun" + "&numAnalyse=7"});
			jsonStore = new dojox.data.AndOrReadStore({ url: url_path + "/manageProject.pl?" + "&numAnalyse=7"});
			captureStore = new dojox.data.AndOrWriteStore({ url: url_path + "/manageCapture.pl?option=capture" + "&numAnalyse=7"});
			dijit.byId("slider_run").attr('value',7);			
			dijit.byId("slider_proj").attr('value',7);
			dijit.byId("slider_cap").attr('value',7);
			val_sl=7;
		} else if (e==8) {
			//Other
			runStore = new dojox.data.AndOrWriteStore({url: url_path + "/manageData.pl?option=allqRun" + "&numAnalyse=8"});
			jsonStore = new dojox.data.AndOrReadStore({ url: url_path + "/manageProject.pl?" + "&numAnalyse=8"});
			captureStore = new dojox.data.AndOrWriteStore({ url: url_path + "/manageCapture.pl?option=capture" + "&numAnalyse=8"});
			dijit.byId("slider_run").attr('value',8);			
			dijit.byId("slider_proj").attr('value',8);
			dijit.byId("slider_cap").attr('value',8);
			val_sl=8;
		}
		dojo.cookie(slider, val_sl, { expires: 100 });
		grid.startup();
		grid.setStore(jsonStore);
		gridRundoc.setStore(runStore);
		gridCap.setStore(captureStore);
	}); 
}

var rrCap;
function initRadioRunRelCap(doId,spid,defrel,defcap,valspecies) {
	if (spid=="a_relRadioCap") {
		if (defrel) {dijit.byId('a_rel_defbox').set('checked', true);} else {dijit.byId('a_rel_defbox').set('checked', false);}
		if (defcap) {dijit.byId('a_capd_defbox').set('checked', true);} else {dijit.byId('a_capd_defbox').set('checked', false);}
	} else {
		if (defrel) {dijit.byId('rel_defbox').set('checked', true);} else {dijit.byId('rel_defbox').set('checked', false);}
		if (defcap) {dijit.byId('capd_defbox').set('checked', true);} else {dijit.byId('capd_defbox').set('checked', false);}
	}

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

	function fetchCapFailed(error, request) {
		alert("lookup Cap failed.");
		alert(error);
	}

	function clearOldCapList(size, request) {
		var listRel = doId;
		if (listRel) {
			while (listRel.firstChild) {
				listRel.removeChild(listRel.firstChild);
			}
		}
	}
	function gotRelCap(items, request) {
		var listRel = doId;
		var None=0;
		if (listRel) {
			None=findRelNone();
			var i;
			var defSpanCap = dojo.doc.createElement('div');
			var cpt=1; 
			for (i = 0; i < items.length; i++) {
				if(items[i].speciesId !=valspecies) {continue;}
				if (defrel) {
					if(items[i].def==0) {continue;}
				}
				if(items[i].relName=="HG18") {continue;}

				if(cpt==0) {cpt=1};
				var item = items[i];
				var iname = 'crrDB';
				var cbname = items[i].relName;
				var id = iname + i;
				var title =cbname;
				var rrCap=dijit.byId(id);
				if(typeof(rrCap)!=="undefined") {
					rrCap.destroy();
				}
				rrCap = new dijit.form.RadioButton({
//				crCap = new dojox.mobile.RadioButton({
					id: id,
					name: iname,
					title:cbname,
					onClick:function() {
						selRelcap=getSelectedRel(spid);
						defcap=1;
						if (spid=="a_relRadioCap") {
							dijit.byId('a_capd_defbox').set('checked', true);
							changeRelCap(a_captureGrid,spid,defcap);
						} else {
							dijit.byId('capd_defbox').set('checked', true);
							changeRelCap(captureGrid,spid,defcap);
						}
					}
				});
				if (item.relName=="HG19") {
//				if (item.relName=="HG19_MT"){
					rrCap.set('checked', true);
					selRelcap="HG19";
					//selRelcap="HG19_MT";
					captureStore = new dojox.data.AndOrWriteStore({url: url_path + url_captureStore});
					if (spid=="a_relRadioCap") {
						dojo.connect(dijit.byId("a_capd_defbox"), 'onChange', function(checked){
							if (checked==true) {defcap=1;} else {defcap=0;}
							var i_radio=document.getElementById("a_relRadioCap");
							changeRelCap(captureGrid,i_radio.id,defcap);
						});

						if (defcap) {
							a_captureGrid.setStore(captureStore,query={rel: selRelcap,def: defcap,speciesId: valspecies});
						} else {
							a_captureGrid.setStore(captureStore,query={rel: selRelcap,speciesId: valspecies});
						}
						dijit.byId(a_captureGrid)._refresh();
					} else {
						dojo.connect(dijit.byId("capd_defbox"), 'onChange', function(checked){
							if (checked==true) {defcap=1;} else {defcap=0;}
							var i_radio=document.getElementById("relRadioCap");
							changeRelCap(captureGrid,i_radio.id,defcap);
						});
						if (defcap) {
							captureGrid.setStore(captureStore,query={rel: selRelcap,def: defcap,speciesId: valspecies});
						} else {
							captureGrid.setStore(captureStore,query={rel: selRelcap,speciesId: valspecies});
						}
						dijit.byId(captureGrid)._refresh();
					}
				}
				var defLabel = dojo.doc.createElement('label');
				// write next line when multiple 6
				if((cpt%4 == 0) && (cpt >0)) {cbname=cbname + "<br>";}
				cpt++;
				defLabel.innerHTML = cbname ;
				defSpanCap.appendChild(defLabel);
				//dojo.place(rrCap.domNode, dojo.byId("relRadioCap"), "last");
				//dojo.place(defLabel, dojo.byId("relRadioCap"), "last");
				dojo.place(rrCap.domNode, doId, "last");
				dojo.place(defLabel, doId, "last");
				if (i==items.length-1 && None) {
					var iname = 'crrDB';
					var id = iname + i +1;
					var cbname ="None";
					var title =cbname;
					var rrCap=dijit.byId(id);
					if(typeof(rrCap)!=="undefined") {
						rrCap.destroy();
					}
					rrCap = new dijit.form.RadioButton({
						id: id,
						name: iname,
						title:cbname,
						onClick:function() {
							if (spid=="a_relRadioCap") {
								changeRelCap(a_captureGrid,spid,defcap);
							} else {
								changeRelCap(captureGrid,spid,defcap);
							}
						}
					});
					var defLabel = dojo.doc.createElement('label');
					if (defrel) {
						if((cpt%4 == 0) && (cpt >0)) {cbname=cbname + "<br>";} 
					} else {
						if((cpt%6 == 0) && (cpt >0)) {cbname=cbname + "<br>";} 
					}
					cpt++;
					defLabel.innerHTML = cbname ;
					defSpanCap.appendChild(defLabel);
					var spanP = document.createElement("span");
					spanP.innerHTML = "<img src='icons/information.png' id='tipNone'>";
					dojo.place(rrCap.domNode,doId, "last");
					dojo.place(defLabel, doId, "last");
					dojo.place(spanP, doId, "last");
					var tipN = new dijit.Tooltip({
						connectId:["tipNone"],
						position:["below"],
						label: 	"<div class='tooltip'><b>None</b> when Genome Release is not indicated on Exon Capture.<br><b>Update</b> your Exon capture information to specify the Genome Release</div>"
					});
				}
			}
		}
	}
	relcapStore.fetch({
		onBegin: clearOldCapList,
		onComplete: gotRelCap,
		onError: fetchCapFailed,
		queryOptions: {ignoreCase: true, deep: true},
		sort:[{ attribute: "relName", descending: false }]
	});
}

function getSelectedRel(spid){
	var f ;
	if (spid=="a_relRadioCap") {
		f = dojo.byId("a_relCapForm");
	} else {
		f = dojo.byId("relCapForm");
	}
	var crrCapRel = "";
	for (var i = 0; i < f.elements.length; i++) {
		var elem = f.elements[i];
		if (elem.name == "button") {
			continue;
		}
		if (elem.type == "radio" && !elem.checked) {
			continue;
		}
		crrCapRel += elem.title;
	}
	return crrCapRel;
}

var crrCap;
function changeRelCap(Grid,spid,def){
	var sliderFormvalue = dijit.byId("slider_run").attr("value");
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
	var f ;
	var desFormvalue;
	var speciesFormvalue;
	if (spid=="a_relRadioCap") {
		f = dojo.byId("a_relCapForm");
		desFormvalue = dijit.byId("a_relCapForm").getValues();
		speciesFormvalue = dijit.byId("a_desForm").getValues();
	} else {
		f = dojo.byId("relCapForm");
		desFormvalue = dijit.byId("relCapForm").getValues();
		speciesFormvalue = dijit.byId("speciesForm").getValues();
	}
	crrCap = "";
	for (var i = 0; i < f.elements.length; i++) {
		var elem = f.elements[i];
		if (elem.name == "button") {
			continue;
		}
		if (elem.type == "radio" && !elem.checked) {
			continue;
		}
		crrCap += elem.title;
	}
	selField=crrCap;
	valspecies=speciesFormvalue.speciesName;
	if (spid=="a_relRadioCap") {
		dojo.connect(dijit.byId("a_capd_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefaCapd=1;} else {checkDefaCapd=0;}
			var i_radio=document.getElementById("a_relRadioCap");
			changeRelCap(captureGrid,i_radio.id,checkDefaCapd);
		});
		captureStore = new dojox.data.AndOrWriteStore({url: url_path + url_captureStore});
		if (def) {
			a_captureGrid.setStore(captureStore,query={rel: selField,def:'1',speciesId: valspecies});
		} else {
			a_captureGrid.setStore(captureStore,query={rel: selField,speciesId: valspecies});
		}
		dijit.byId(a_captureGrid)._refresh();

	} else {
		dojo.connect(dijit.byId("capd_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefCapd=1;} else {checkDefCapd=0;}
			var i_radio=document.getElementById("relRadioCap");
			changeRelCap(captureGrid,i_radio.id,checkDefCapd);
		});

		captureStore = new dojox.data.AndOrWriteStore({url: url_path + url_captureStore});
		if (def) {
			captureGrid.setStore(captureStore,query={rel: selField,def:'1',speciesId: valspecies});
		} else {
			captureGrid.setStore(captureStore,query={rel: selField,speciesId: valspecies});
		}
		dijit.byId(captureGrid)._refresh();
	}
}

function findRelNone() {
	var RelNone=0;
	var gotNoneList = function(items, request){
		dojo.forEach(items, function(i){
			var relval=captureStore.getValue( i, 'rel' );
			if (relval=="") {RelNone=1;return RelNone;}
		});
		return RelNone;

	}
	var gotNoneError = function(error, request){
  		alert("FindRelNone: The request to the store failed. ");
	}

	captureStore.fetch({
  		onComplete: gotNoneList,
	});
	return RelNone;
}

function chgCol(a){
	if(this.checked) {
		dojo.style('patForm', 'display', '');
	} else {
		dojo.style('patForm', 'display', 'none');
	}
}

function a_chgCol(a){
	if(this.checked) {
		dojo.style('a_patForm', 'display', '');
	} else {
		dojo.style('a_patForm', 'display', 'none');
	}
}

function chgFil(a){
	if(this.checked) {
		dojo.style(dijit.byId('loadF').domNode, {visibility:'visible'});
		dijit.byId("RunSubmit").setDisabled(true)
		
	} else {
		dojo.style(dijit.byId('loadF').domNode, {visibility:'hidden'});
		dijit.byId("RunSubmit").setDisabled(false)
	}
}

function a_chgFil(a){
	if(this.checked) {
		dojo.style(dijit.byId('a_loadF').domNode, {visibility:'visible'});
		dijit.byId("a_RunSubmit").setDisabled(true)
		
	} else {
		dojo.style(dijit.byId('a_loadF').domNode, {visibility:'hidden'});
		dijit.byId("a_RunSubmit").setDisabled(false)
	}
}

function chgForce(a){
	if(this.checked) {
		force=1;
	} else {
		force=0;
	}
}

function chgSomatic(a){
	if(this.checked) {
		sforce=1;
	} else {
		sforce=0;
	}
}

function chgControl(a){
	if(this.checked) {
		pcontrol=1;
	} else {
		pcontrol=0;
	}
}

function chgCapFile(a){
	if(this.checked) {
		dojo.style(dijit.byId('loadFC').domNode,{'display':'block'});
		dojo.style('capColForm', 'display', 'none');
		document.getElementById('FileNameCap').disabled = true;
	} else {
		dojo.style(dijit.byId('loadFC').domNode,{'display':'none'});
		dojo.style('capColForm', 'display', '');
		document.getElementById('FileNameCap').disabled = false;
	}
}

function chgCapCol(a){
	if(this.checked) {
		dojo.style(dijit.byId('loadFC').domNode,{'display':'none'});
		dojo.style('capColForm', 'display', '');
		document.getElementById('FileNameCap').disabled = false;
		
	} else {
		dojo.style(dijit.byId('loadFC').domNode,{'display':'block'});
		dojo.style('capColForm', 'display', 'none');
				document.getElementById('FileNameCap').disabled = true;
	}
}

function chgTrsCol(){
	var getLabBundle= document.getElementById("labBundle").innerHTML;
	initNewBun=1;
	if (getLabBundle == "BUNDLE") {initNewBun=0;}
	if(trs_col.checked) {
		dojo.style(dijit.byId("bt_addTrans").domNode,{'visibility':'visible'});	
		if (initNewBun) {
			dojo.style(dijit.byId("bt_addTrans").domNode,{'visibility':'hidden'});
		}	
		dojo.style(dijit.byId('loadFCtrs').domNode,{'display':'none'});
		dojo.style('trsColForm', 'display', '');
		
	} else {
		dojo.style(dijit.byId('loadFCtrs').domNode,{'display':'block'});
		dojo.style('trsColForm', 'display', 'none');
	}
}

function chgTrsFile(){
	var getLabBundle= document.getElementById("labBundle").innerHTML;
	initNewBun=1;
	if (getLabBundle == "BUNDLE") {initNewBun=0;}
	if(trs_file.checked) {
		dojo.style(dijit.byId("bt_addTrans").domNode,{'visibility':'hidden'});	
		dojo.style(dijit.byId('loadFCtrs').domNode,{'display':'block'});
		dojo.style('trsColForm', 'display', 'none');
	} else {
		dojo.style(dijit.byId("bt_addTrans").domNode,{'visibility':'visible'});
		if (initNewBun) {dojo.style(dijit.byId("bt_addTrans").domNode,{'visibility':'hidden'});}
		dojo.style(dijit.byId('loadFCtrs').domNode,{'display':'none'});
		dojo.style('trsColForm', 'display', '');
	}
}

function chgPipe(a){
	if(this.checked) {
		pipelinefilterSelect.set('store',pipelineNameStore);
		pipelinefilterSelect.startup();
		document.getElementById("pipeline").style.display = "block";
		document.getElementById("alncall").style.display = "none";
		document.getElementById("othermeth").style.display = "none";		
	} else {
		document.getElementById("pipeline").style.display = "none";
		document.getElementById("alncall").style.display = "block";
		document.getElementById("othermeth").style.display = "block";
	}
}

function a_chgPipe(a){
	if(this.checked) {
		a_pipelinefilterSelect.set('store',pipelineNameStore);
		a_pipelinefilterSelect.startup();
		document.getElementById("a_pipeline").style.display = "block";
		document.getElementById("a_alncall").style.display = "none";
		document.getElementById("a_othermeth").style.display = "none";		
	} else {
		document.getElementById("a_pipeline").style.display = "none";
		document.getElementById("a_alncall").style.display = "block";
		document.getElementById("a_othermeth").style.display = "block";
	}
}

function b_chgPipe(a){
	if(this.checked) {
		b_pipelinefilterSelect.set('store',pipelineNameStore);
		b_pipelinefilterSelect.startup();
		document.getElementById("b_pipeline").style.display = "block";
		document.getElementById("b_alncall").style.display = "none";
		document.getElementById("b_othermeth").style.display = "none";		
	} else {
		document.getElementById("b_pipeline").style.display = "none";
		document.getElementById("b_alncall").style.display = "block";
		document.getElementById("b_othermeth").style.display = "block";
	}
}

/*########################################################################
##################### End INIT
##########################################################################*/

dojo.addOnLoad(function() {
	dojo.connect(dijit.byId("searchRunForm"),"onKeyDown",function(e) { 
    		if (e.keyCode == dojo.keys.ENTER) {
			wordsearchRun(gridRundoc);
		}
	}); 
});

var filterRunValue;
function wordsearchRun(grid) {
	filterRunValue=dijit.byId('FilterRunBox').get('value');
	filterRunValue = "'*" + filterRunValue + "*'";
        grid.queryOptions = {ignoreCase: true};
	grid.setQuery({complexQuery: "patName:"+filterRunValue + "OR desRun:" +filterRunValue+"OR ProjectDestName:"+filterRunValue+"OR ProjectName:"+filterRunValue+"OR RunId:"+filterRunValue+"OR name:"+filterRunValue+"OR CaptureName:"+filterRunValue+"OR CaptureAnalyse:"+filterRunValue+"OR pltRun:"+filterRunValue+"OR patBC:"+filterRunValue});
	grid.store.fetch();
	grid.store.close();
	dijit.byId(grid)._refresh();
}

function resetSearchRun(grid) {
	var sliderFormvalue = dijit.byId("slider_run").attr("value");
	dijit.byId('FilterRunBox').set('value',"");		   
//	QuerydependRunSlider();
	wordsearchRun(grid);
	grid.selection.clear();
}

function wordsearchRunORI() {
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
	filterRunValue=dijit.byId('FilterRunBox').get('value');
	filterRunValue = "'*" + filterRunValue + "*'";
	gridRundoc.setQueryAfterLoading({complexQuery: "patName:"+filterRunValue + "OR desRun:" +filterRunValue+"OR ProjectDestName:"+filterRunValue+"OR ProjectName:"+filterRunValue+"OR RunId:"+filterRunValue+"OR name:"+filterRunValue+"OR CaptureName:"+filterRunValue+"OR CaptureAnalyse:"+filterRunValue+"OR pltRun:"+filterRunValue}, {ignoreCase:true});
	gridRundoc.store.fetch();
	gridRundoc.store.close();
	dijit.byId(gridRundoc)._refresh();
}

/*########################################################################
##################### New Run/Patient
##########################################################################*/

function newRun() {
	var alphanum=/^[a-zA-Z0-9-_ \.\>]+$/;

//Plateform
	var itemPlateform = plateformGrid.selection.getSelected();
	var selPlateform;
	if (itemPlateform.length) {
	dojo.forEach(itemPlateform, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(plateformGrid.store.getAttributes(selectedItem), function(attribute) {
				var Plateformvalue = plateformGrid.store.getValues(selectedItem, attribute);
				if (attribute == "plateformName" ) {
					selPlateform = Plateformvalue;
					return selPlateform;
				}
			});
		}
	}); 
	} else {
		textError.setContent("Select a sequencing Plateform");
		myError.show();
		return;
	}
//Machine 
	var itemMachine = machineGrid.selection.getSelected();
	var selMachine;
	if (itemMachine.length) {
	dojo.forEach(itemMachine, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(machineGrid.store.getAttributes(selectedItem), function(attribute) {
				var Machinevalue = machineGrid.store.getValues(selectedItem, attribute);
				if (attribute == "macName" ) {
					selMachine = Machinevalue;
					return selMachine;
				}
			});
		}
	}); 
	} else {
		textError.setContent("Select a sequencing Machine");
		myError.show();
		return;
	}
//MethodSeq
	var itemMethodSeq = mseqGrid.selection.getSelected();
	var selMethodSeq;
	if (itemMethodSeq.length) {
	dojo.forEach(itemMethodSeq, function(selectedItem) {
		if (selectedItem !== null) {
			dojo.forEach(mseqGrid.store.getAttributes(selectedItem), function(attribute) {
				var MethodSeqvalue = mseqGrid.store.getValues(selectedItem, attribute);
				if (attribute == "methSeqName" ) {
					selMethodSeq = MethodSeqvalue;
					return selMethodSeq;
				}
			});
		}
	}); 
	} else {
		textError.setContent("Select a sequencing Method");
		myError.show();
		return;
	}
// Pipeline Method
	var btn=0;
	var filterRes=0;
	if(dijit.byId("btn_pipe").get("checked")) {
		btn=1;
		filterRes = dijit.byId("pipelineName").item.value;
	}
//Alignment Method field
	var itemAln = alnRGrid.selection.getSelected();
	var AlnGroups = new Array();
	if (! btn) {
		if (itemAln.length) {
			dojo.forEach(itemAln, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(alnRGrid.store.getAttributes(selectedItem), function(attribute) {
						var Alnvalue = alnRGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methName" ) {
							AlnGroups.push(Alnvalue);
							return AlnGroups;
						}
					});
				}
			});
		} else {
			textError.setContent("Select an Alignment method");
			myError.show();
			return;
		}
	}
//Method Call field
	var itemCall = callRGrid.selection.getSelected();
	var CallGroups = new Array(); 
	if (! btn) {
		if (itemCall.length) {
			dojo.forEach(itemCall, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(callRGrid.store.getAttributes(selectedItem), function(attribute) {
						var Callvalue = callRGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methName" ) {
							CallGroups.push(Callvalue);
							return CallGroups;
						}
					});
				}
			}); 
		} else {
			textError.setContent("Select a method call");
			myError.show();
		return;
		}
	}
//Method Other field
	var itemOthers = otherRGrid.selection.getSelected();
	var OthersGroups = new Array(); 
	if (! btn) {
		if (itemOthers.length) {
			dojo.forEach(itemOthers, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(otherRGrid.store.getAttributes(selectedItem), function(attribute) {
						var Othersvalue = otherRGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methName" ) {
							OthersGroups.push(Othersvalue);
							return OthersGroups;
						}
					});
				}
			}); 
		}
	}

//Capture
	var itemC = captureGrid.selection.getSelected();
	var selcap;
	if (itemC.length) {
		dojo.forEach(itemC, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(captureGrid.store.getAttributes(selectedItem), function(attribute) {
					var RPvalue = captureGrid.store.getValues(selectedItem, attribute);
					if (attribute == "captureId" ) {
						selcap=RPvalue;						
  					} 
				});
			} 
		});
	} else {
		textError.setContent("Select an Exon Capture");
		myError.show();
		return;
	}
// Name Run
	var desFormvalue = dijit.byId("desForm").getValues();
	var check_name = desFormvalue.Rname;
	var reg =new RegExp("\t","g");
	check_name =check_name.replace(reg,'');
	if(contains(check_name," ")) {
		textError.setContent("No space please for run name!!!");
		myError.show();
		return;
	}
// Plateform Name Run
//	var desFormvalue = dijit.byId("desForm").getValues();
	var check_pltname = desFormvalue.PLTname;
	var reg =new RegExp("\t","g");
	check_pltname =check_pltname.replace(reg,'');
	var chainalphanum= /^[a-zA-Z0-9-_]*$/;
	if (check_pltname.search(chainalphanum) == -1) {
		textError.setContent("No space please for plateform run name");
		myError.show();
		return;
	}

// Description Run
	var check_des = desFormvalue.Rdescription;
	var reg =new RegExp("\t","g");
	check_des =check_des.replace(reg,'');
	var alphanum= /^[a-zA-Z0-9-_ \.\>]*$/;
	if (check_des.search(alphanum) == -1) {
		textError.setContent("Enter a run Description with no accent");
		myError.show();
		return;
	}

// profileName
	var check_pro = desFormvalue.profileName;
	var regexp3 = /^[0-9]+$/;
// speciesName

//	var relcapFormvalue = dijit.byId("relCapForm").getValues();
	var speciesFormvalue = dijit.byId("speciesForm").getValues();
	var s_species = speciesFormvalue.speciesName;
	if (s_species.length ==0){		
			textError.setContent("Select a Species");
			myError.show();
			return;
	}

// Number of Patient 
	var check_Rnbpat = desFormvalue.Rnbpat;
//	if (isNaN(check_Rnbpat) || check_Rnbpat <=0 || check_Rnbpat >=600){		
	if (check_Rnbpat >=600){		
			textError.setContent("Enter a number of Patient (min:1,max:600)");
			myError.show();
			return;
	}
//Type Patient
	var s_patientType = document.getElementById("patientType").value;
	if (s_patientType.length ==0){		
			textError.setContent("Select a Sample Type");
			myError.show();
			return;
	}
// Flowcell
	if (desFormvalue.fc ==null) {
		textError.setContent("Select a Flowcell ...");
		myError.show();
		return;
	}	
//Patient
	var runpatFormvalue = dijit.byId("patForm").getValues();
	var check_lpat = runpatFormvalue.Rpatient;
	if(contains(check_lpat,"+")) {
		textError.setContent("No sign + in patient line!!!");
		myError.show();
		return;
	}
	var LinesPatient=runpatFormvalue.Rpatient.split("\n");
	var reg =new RegExp("\t","g");
	var groupPatient=[];
	var namePatient=[];
	var familyPatient=[];
	var nameFather=[];
	var nameMother=[];
	var sexPatient=[];
	var statusPatient=[];
	var bcPatient=[];
	var bc2Patient=[];
	var bcgPatient=[];
	var namePerson=[];
	for(var i=0; i<LinesPatient.length; i++) {
		var fgrp;
		var fpat;
		var ffam;
		var ffat;
		var fmot;
		var fsex;
		var fsta;
		var fbc;
		var fbc2;
		var fbcg;
		var fpers;
		var fieldPatient=LinesPatient[i].split("\t");
//		var fieldPatient=LinesPatient[i].split("\\s+");.toLowerCase()
		if (fieldPatient == ""){
			break;
		}
		// Header
		if (i==0) {
			fieldPatient=fieldPatient.filter(Boolean);
			if (fieldPatient[0].toLowerCase()!= "patient") {
				textError.setContent("<b>Error</b> Patient field is mandatory and must be at First Column");
				myError.show();
				return;
			}
		}
		if (i==0) {
			fieldPatient=fieldPatient.filter(Boolean);
			var HeaderLine=fieldPatient.toString().toLowerCase().replace(/,/g," ");
			var okmatch=HeaderLine.match("patient");
			if (! okmatch) {
				textError.setContent("<b>Error</b> Patient field is mandatory");
				myError.show();
				return;
			}
			for (var j=0; j<fieldPatient.length; j++) {
				switch (fieldPatient[j].toLowerCase().replace(/ /g,"")) {
					case "group":
					fgrp=j;
					break;
					case "patient":
					fpat=j;
					break;
					case "family":
					ffam=j;
					break;
					case "father":
					ffat=j;
					break;
					case "mother":
					fmot=j;
					break;
					case "sex":
					fsex=j;
					break;
					case "status":
					fsta=j;
					break;
					case "bc":
					fbc=j;
					break;
					case "bc2":
					fbc2=j;
					break;
					case "iv":
					fbcg=j;
					break;
					case "person":
					fpers=j;
					break;
					default:
					textError.setContent("The Header Tabulated List is not Good!!!<BR>"+
					"Field in Header: Patient Group Family Father Mother Sex Status BC BC2 IV Person<BR>"+
					"Needs First field Patient then no order, no case sensitive,BC=Bar Code,BC2=Bar Code 2,IV=Identity Vigilance,Person=Reffering Person Name");
					myError.show();
					return;
				}			
			}
			continue;
		}
		if (typeof(fieldPatient[fpat])=="undefined"||typeof(fpat)=="undefined")	{
			textError.setContent("The column Patient is required!!!");
			myError.show();
			return;
		}
		if (fieldPatient[fpat] == "") {
			textError.setContent("The column Patient name is empty!!!");
			myError.show();
			return;
		}
		if (fieldPatient[fpat] ==0){		
			textError.setContent("Enter a patient name");
			myError.show();
			return;
		}
		if(contains(fieldPatient[fpat]," ")) {
			textError.setContent(fieldPatient[fpat]+": No space please for patient name!!!");
			myError.show();
			return;
		}
		groupPatient.push(fieldPatient[fgrp]);
		namePatient.push(fieldPatient[fpat]);

		if (typeof(fieldPatient[fpers]) != "undefined") {
			if(contains(fieldPatient[fpers]," ")) {
				textError.setContent(fieldPatient[fpers]+": No space please for reffering person name!!!");
				myError.show();
				return;
			}
		}
		// if no family name entered, family name = patient name
		if (typeof(fieldPatient[ffam]) == "undefined" || fieldPatient[ffam]=="") {
			fieldPatient[ffam]=fieldPatient[fpat];
		}
		if (typeof(fieldPatient[ffam]) != "undefined" || fieldPatient[ffam]!="") {
			if(contains(fieldPatient[ffam]," ")) {
				textError.setContent(fieldPatient[ffam]+": No space please for Family name!!!");
				myError.show();
				return;
			}
		}
		familyPatient.push(fieldPatient[ffam]);

		if (typeof(fieldPatient[ffat])=="undefined"||typeof(ffat)=="undefined"||fieldPatient[ffat]==0) {fieldPatient[ffat]=""}
		nameFather.push(fieldPatient[ffat]);
		if (typeof(fieldPatient[fmot])=="undefined"||typeof(ffat)=="undefined"||fieldPatient[fmot]==0) {fieldPatient[fmot]=""}
		nameMother.push(fieldPatient[fmot]);
		var num012=/^[0-2]/;
if (typeof(fsex) == "undefined" || typeof(fieldPatient[fsex]) == "undefined" || fieldPatient[fsex].replace(/ /g,"") == "") {fieldPatient[fsex]=1}
		if (fieldPatient[fsex]=="?") {fieldPatient[fsex]=0};
		if (fieldPatient[fsex].toString().search(num012) == -1) {
			textError.setContent("Enter Sex with code 0 or 1 or 2");
			myError.show();
			return;
		}
		sexPatient.push(fieldPatient[fsex]);

if (typeof(fsta) == "undefined" || typeof(fieldPatient[fsta]) == "undefined" || fieldPatient[fsta].replace(/ /g,"") == "") {fieldPatient[fsta]=2}
		if (fieldPatient[fsta].toString().search(num012) == -1) {
			textError.setContent("Enter Status with code 0 or 1 or 2");
			myError.show();
			return;
		}
		statusPatient.push(fieldPatient[fsta]);

if (typeof(fbc) == "undefined" ||typeof(fieldPatient[fbc]) == "undefined"||fieldPatient[fbc]==0) {fieldPatient[fbc]=""}
		//bcPatient.push(fieldPatient[fbc].toUpperCase());
		bcPatient.push(fieldPatient[fbc]);
if (typeof(fbc2) == "undefined" ||typeof(fieldPatient[fbc2]) == "undefined"||fieldPatient[fbc2]==0) {fieldPatient[fbc2]=""}
		//bc2Patient.push(fieldPatient[fbc2].toUpperCase());
		bc2Patient.push(fieldPatient[fbc2]);
if (typeof(fbcg) == "undefined" ||typeof(fieldPatient[fbcg]) == "undefined"||fieldPatient[fbcg]==0) {fieldPatient[fbcg]=""}
		bcgPatient.push(fieldPatient[fbcg].toUpperCase());
if (typeof(fpers) == "undefined" ||typeof(fieldPatient[fpers]) == "undefined"||fieldPatient[fpers]==0) {fieldPatient[fpers]=""}
		namePerson.push(fieldPatient[fpers]);
	}
// ### Patient Name Length ####//
	for(var i=0; i<namePatient.length;i++ ) {
		if (namePatient[i].length >45) {
			textError.setContent("Max Length exceeded <b>[max=45]</b> for Patient Name :"+namePatient[i]);
			myError.show();
			return;
		}
	}
// tableau associatif Patient Famille Sex
	var assoc_SexPat= new Array();
	var assoc_FamPat= new Array();
	for(var i=0; i<namePatient.length;i++ ) {  
		for(var j=0; j<sexPatient.length;j++ )
		{
			if(i==j) {
				assoc_SexPat[namePatient[i]]=sexPatient[j];
				assoc_FamPat[namePatient[i]]=familyPatient[j];
			}
		}		
	}
// Error Sex for Father
	for(var i=0; i<nameFather.length;i++ )
 	{  
		if (nameFather[i]!=="" && assoc_SexPat[nameFather[i]]!=1) {
			textError.setContent("Error Sex for Father: <b>"+nameFather[i]+"</b>");
			myError.show();
			return;
		}
	}
//Error Sex for Mother
	for(var i=0; i<nameMother.length;i++ ) {  
		if (nameMother[i]!=="" && assoc_SexPat[nameMother[i]]!=2) {
			textError.setContent("Error Sex for Mother: <b>"+nameMother[i]+"</b>");
			myError.show();
			return;
		}
	}

//	for (var key in assoc_SexPat) {
//		var value=assoc_SexPat[key];
//		console.log("key: "+ key + " value: "+ value); 
//	}
//
//	for (var key in assoc_FamPat) {
//		var value=assoc_FamPat[key];
//		console.log("key: "+ key + " value: "+ value); 
//	}

//Error Father Family

	for(var i=0; i<namePatient.length;i++ ) {  
		for(var j=0; j<nameFather.length;j++ )
		{
			if(i==j) {
				if (nameFather[j] !=="" ) {
					if (assoc_FamPat[namePatient[i]] !== assoc_FamPat[nameFather[j]]) {
						textError.setContent("<b>Error Family: </b> "+
						"Patient/Family: "+ namePatient[i] +"/"+assoc_FamPat[namePatient[i]] +" ==> "+
						"Father/Family: " +  nameFather[j]+"/"+assoc_FamPat[nameFather[j]]);
						myError.show();
						return;
					}
					if (namePatient[i] == nameFather[j]) {
						textError.setContent("<b>Error Father: </b> " +
							"<b>Same Name</b> for Patient " + namePatient[i] + " and Father "+ nameFather[j]);
						myError.show();
						return;
					}
				}
			}
		}
	}
//test Mother Family
	for(var i=0; i<namePatient.length;i++ ) {  
		for(var j=0; j<nameMother.length;j++ )
		{
			if(i==j) {
				if (nameMother[j] !=="" ) {
					if (assoc_FamPat[namePatient[i]] !== assoc_FamPat[nameMother[j]]) {
						textError.setContent("<b>Error Family: </b> "+
						"Patient/Family: "+ namePatient[i] +"/"+assoc_FamPat[namePatient[i]] +" ==> "+
						"Mother/Family: " +  nameMother[j]+"/"+assoc_FamPat[nameMother[j]]);
						myError.show();
						return;
					}
					if (namePatient[i] == nameMother[j]) {
						textError.setContent("<b>Error Mother: </b> " +
							"<b>Same Name</b> for Patient " + namePatient[i] + " and Mother "+ nameMother[j]);
						myError.show();
						return;
					}
				}
			}
		}
	}

//	if (namePatient.length !== check_Rnbpat) {

	check_Rnbpat=namePatient.length;
// Sample sheet file 
	var s_runSamplesheet = document.getElementById("runSamplesheet").value;

	var rtypeFormvalue = "ngs";
	var prog_url=url_path + "/new_polyproject.pl";
	var options="opt=newRunG" +
					"&name=" + check_name +
					"&pltname=" + check_pltname +
					"&description="+ check_des +
					"&plateform="+ selPlateform +
					"&typePatient="+ s_patientType +
					"&species="+ s_species +
					"&machine="+ selMachine  +
					"&mseq="+ selMethodSeq +
					"&capture=" + selcap +
					"&nbpat=" + check_Rnbpat +
					"&fc=" + desFormvalue.fc +
					"&group=" + groupPatient +
					"&patient="+ namePatient +
					"&family="+ familyPatient +
					"&father=" + nameFather +
					"&mother=" + nameMother +
					"&sex="+ sexPatient +
					"&status="+ statusPatient +
					"&bc=" + bcPatient +					
					"&bc2=" + bc2Patient +					
					"&iv=" + bcgPatient +					
					"&type="+ rtypeFormvalue +
					"&person="+ namePerson +
					"&file="+ s_runSamplesheet +
					"&profileId="+ desFormvalue.profileName
					;
	if (btn) {
		options=options	+ 
		"&method_pipeline="+ filterRes;
	} else {
		options=options	+ 
		"&method_align="+ AlnGroups +
		"&method_call="+ CallGroups +
		"&method_other="+ OthersGroups;
	}
// #############################
// Method POST
	var res=senDataExtendedPost(prog_url,options);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshRunDoc(nostandby=1);
				refreshPolyList(stand=1);
				url_lastRunId = url_path+"/manageData.pl?option=lastRun";
				var lastRunIdStore = new dojo.data.ItemFileReadStore({ url: url_lastRunId });
				var gotList = function(items, request){
					gridRundoc.selection.clear();
					var lastRunIdnext;
					dojo.forEach(items, function(i){
						lastRunIdnext=lastRunIdStore.getValue( i, 'run_id' );
					});
					gridRundoc.store.fetch({onComplete: function (items){
							dojo.forEach(gridRundoc._by_idx, function(item, index){
							var sItem = gridRundoc.getItem(index);
							if (sItem.RunId.toString() == lastRunIdnext.toString()) {
									gridRundoc.selection.addToSelection(index);
									myMessage.hide();
									reloadPatient(namePatient,sexPatient);
									editRun();
								}
							});
						}
					});
				}
				var gotError = function(error, request){
  					alert("New Run: The request to the store failed. " +  error);
				}

				lastRunIdStore.fetch({
  					onComplete: gotList,
  					onError: gotError
				});
			} else if (response.status=="Extended") {
				if (response.extend) {
					initProposalName_forRun(response,prog_url,options,namePatient,sexPatient);
				};
			}
		}
	);

}

var tmp_personRunIdentGrid;
var nb_searchPR=0;
function initProposalName_forRun(response,prog_url,options,namePatient,sexPatient){

	var sp_btclosepersonrun=dojo.byId("bt_close_personRun");
	var btclosepersonrun=dijit.byId("id_bt_close_personRun");
	if (btclosepersonrun) {
		sp_btclosepersonrun.removeChild(btclosepersonrun.domNode);
		btclosepersonrun.destroyRecursive();
	}
	var buttonformclose_personrun= new dijit.form.Button({
		id:"id_bt_close_personRun",
		showLabel: false,
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('personrunDialog').reset();dijit.byId('personrunDialog').hide();"
	});
	buttonformclose_personrun.startup();
	buttonformclose_personrun.placeAt(sp_btclosepersonrun);

	var sp_btsubmitpersonrun=dojo.byId("bt_submit_personRun");
	var btsubmitpersonrun=dijit.byId("id_bt_submit_personRun");
	if (btsubmitpersonrun) {
		sp_btsubmitpersonrun.removeChild(btsubmitpersonrun.domNode);
		btsubmitpersonrun.destroyRecursive();
	}
	var buttonformsubmit_personrun= new dijit.form.Button({
		showLabel: true,
		id:"id_bt_submit_personRun",
		//type:"submit", avoid closing window when error by submitting
		label:"Submit",
		value:"Submit",
		iconClass:"validIcon",
		style:"color:white",
		onClick:function(){
			applyProposalName_forRun(nb_searchPR,prog_url,options,namePatient,sexPatient);
		}			
	});
	buttonformsubmit_personrun.startup();
	buttonformsubmit_personrun.placeAt(sp_btsubmitpersonrun);

        var tmp_personIdentStore = new dojo.data.ItemFileWriteStore({
                data: response.extend
	});

	var gotList = function(items, request){
		nb_searchPR=0;
		var searchP=new Array();
		dojo.forEach(items, function(i){
			searchP.push(tmp_personIdentStore.getValue(i,"person_s").toString());
		});
		nb_searchPR=searchP.unique().length;
	}
	var gotError = function(error, request){
  			alert("New Run: nb proposal search person name: The request to the store failed. " +  error);
	}
	tmp_personIdentStore.fetch({
  		onComplete: gotList,
  		onError: gotError
	});

	var layoutTmpPerson = [
        	{ field: "Row", name: "Row", width: '3'},
        	{ field: "person_s", name: "Person Search", width: '10'},
       		{ field: "person", name: "Name", width: '10em',formatter:newPerson},
        	{ field: "patient", name: "Patient", width: '10'},
		{ field: "run", name: "Run", width: '4'},
		{ field: "project", name: "project", width: '9'},
		{ field: 'capAnalyse',name: 'Ana',width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldAnalyse},
		{ field: "family", name: "Family", width: '10'},
		{ field: "sex", name: "Sex", width: '3'},
		{ field: "status", name: "Status", width: '3'},
        	{ field: "iv_vcf", name: "IV VCF", width: '12'}
//       		{ field: "imax", name: "imax", width: '3'}
    	];

	function myStyleRowPersonName(row){
		var item=tmp_personRunIdentGrid.getItem(row.index);
		var color = "background:#b8a9c9;";
		if (item.imax >0) {
			row.customStyles += color;
		}
	}

	function clearOldIdentList(size, request) {
                    var listIdent = dojo.byId("tmp_personRunIdentGrid");
                    if (listIdent) {
                        while (listIdent.firstChild) {
                           listIdent.removeChild(listIdent.firstChild);
                        }
                    }
	}
	function fetchIdentFailed(error, request) {
		alert("Run: lookup Proposal Person Name failed.");
		alert(error);
	}

	tmp_personIdentStore.fetch({
		onBegin: clearOldIdentList,
		onError: fetchIdentFailed,
		onComplete: function(items){
			tmp_personRunIdentGrid = new dojox.grid.EnhancedGrid({
				store: tmp_personIdentStore,
				structure: layoutTmpPerson,
				onStyleRow: myStyleRowPersonName,
				rowSelector: "0.4em",
				rowsPerPage: 1000,  // IMPORTANT
				selectionMode: 'multiple',
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
					dnd:{copyOnly: true},
					exporter: true,
					printer:true,
					selector:true,
				}
			},document.createElement('div'));
			dojo.byId("tmp_personRunIdentGrid").appendChild(tmp_personRunIdentGrid.domNode);
			tmp_personRunIdentGrid.startup();
			dijit.byId("personrunDialog").show();
		}
	});
}

function selection_Person(e) {
	tmp_personRunIdentGrid.selection.clear();
	dojo.forEach(tmp_personRunIdentGrid._by_idx, function(item, index){								
		var sItem = tmp_personRunIdentGrid.getItem(index);
		if(e.value=="new"){
			if (sItem.person.toString().match(/^(New Person)/)) {
				tmp_personRunIdentGrid.selection.addToSelection(index);
			}
		}
		if(e.value=="old"){
			if (!sItem.person.toString().match(/^(New Person)/)) {
				tmp_personRunIdentGrid.selection.addToSelection(index);
			}
		}

	});

	if(e.value=="clear"){
		tmp_personRunIdentGrid.selection.clear();
	}
} 

/*#############  Apply Proposal Person Name tuc  ##############################*/
function applyProposalName_forRun(nb_seachPers,prog_url,options,namePatient,sexPatient) {
	var item = tmp_personRunIdentGrid.selection.getSelected();
	var personGroups = new Array(); 
	var personsearchGroups = new Array(); 
	var personIdGroups = new Array(); 
	if (item.length != nb_seachPers ) {
		textError.setContent("For Run, The Number of <b>Person Selected</b> is different from the Number of <b>Person Searched</b>");
		myError.show();
		return;
	}
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(tmp_personRunIdentGrid.store.getAttributes(selectedItem), function(attribute) {
					var Personvalue = tmp_personRunIdentGrid.store.getValues(selectedItem, attribute);
					if (attribute == "person" ) {
						if (Personvalue.toString().match(/^(New Person)/)) {
							var sp_value=Personvalue.toString().split("/");
							Personvalue=sp_value[1];
						}
						personGroups.push(Personvalue);
						return personGroups;
					}
					if (attribute == "person_s" ) {
						personsearchGroups.push(Personvalue);
						return personsearchGroups;
					}
					if (attribute == "person_id" ) {
						personIdGroups.push(Personvalue);
						return personIdGroups;
					}					
				});
			}
		});
		if (personsearchGroups.unique().length != nb_seachPers ) {
			textError.setContent("For Run, Number of <b>Person Searched and Selected</b> is different from the Number of <b>Person Searched</b>");
			myError.show();
			return;
		}

	}
	var ext_options="&s_personsearch="+ personsearchGroups +
	"&s_person="+ personGroups +
	"&s_person_id="+ personIdGroups;
	options=options	+ ext_options;

	var res=senDataExtendedPost(prog_url,options);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshRunDoc(nostandby=1);
				refreshPolyList(stand=1);
				url_lastRunId = url_path+"/manageData.pl?option=lastRun";
				var lastRunIdStore = new dojo.data.ItemFileReadStore({ url: url_lastRunId });
				dijit.byId("personrunDialog").reset();
				dijit.byId("personrunDialog").hide();
				var gotList = function(items, request){
					gridRundoc.selection.clear();
					var lastRunIdnext;
					dojo.forEach(items, function(i){
						lastRunIdnext=lastRunIdStore.getValue( i, 'run_id' );
					});
					//dijit.byId("personrunDialog").reset();
					//dijit.byId("personrunDialog").hide();
					gridRundoc.store.fetch({onComplete: function (items){
							dojo.forEach(gridRundoc._by_idx, function(item, index){
								var sItem = gridRundoc.getItem(index);
								if (sItem.RunId.toString() == lastRunIdnext.toString()) {

									gridRundoc.selection.addToSelection(index);
									myMessage.hide();
									reloadPatient(namePatient,sexPatient);
									editRun();
								}
							});
						}
					});


				}
				var gotError = function(error, request){
  					alert("New Run: The request to the store failed. " +  error);
				}

				lastRunIdStore.fetch({
  					onComplete: gotList,
  					onError: gotError
				});
			}
		}
	);
}

/*########################################################################
#######################	New Add Patient     ##############################
##########################################################################*/
function addPatient() {
	selrun = document.getElementById("ADDPATrunId").innerHTML;
// Pipeline Method
	var btn=0;
	var filterRes=0;
	if(dijit.byId("a_btn_pipe").get("checked")) {
		btn=1;
		filterRes = dijit.byId("a_pipelineName").item.value;
	}
//Alignment Method field
	var itemAln = a_alnRGrid.selection.getSelected();
	var AlnGroups = new Array(); 
	if (! btn) {
		if (itemAln.length) {
			dojo.forEach(itemAln, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(a_alnRGrid.store.getAttributes(selectedItem), function(attribute) {
						var Alnvalue = a_alnRGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methName" ) {
							AlnGroups.push(Alnvalue);
							return AlnGroups;
						}
					});
				}
			});
		} else {
			textError.setContent("Select an Alignment method");
			myError.show();
			return;
		}
	}
//Method Call field
	var itemCall = a_callRGrid.selection.getSelected();
	var CallGroups = new Array(); 
	if (! btn) {
		if (itemCall.length) {
			dojo.forEach(itemCall, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(a_callRGrid.store.getAttributes(selectedItem), function(attribute) {
						var Callvalue = a_callRGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methName" ) {
							CallGroups.push(Callvalue);
							return CallGroups;
						}
					});
				}
			}); 
		} else {
			textError.setContent("Select a method call");
			myError.show();
			return;
		}
	}
//Method Other field
	var itemOthers = a_otherRGrid.selection.getSelected();
	var OthersGroups = new Array(); 
	if (! btn) {
		if (itemOthers.length) {
			dojo.forEach(itemOthers, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(a_otherRGrid.store.getAttributes(selectedItem), function(attribute) {
						var Othersvalue = a_otherRGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methName" ) {
							OthersGroups.push(Othersvalue);
							return OthersGroups;
						}
					});
				}
			}); 
		}
	}
//Capture
	var itemC = a_captureGrid.selection.getSelected();
	var selcap;
	if (itemC.length) {
		dojo.forEach(itemC, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(a_captureGrid.store.getAttributes(selectedItem), function(attribute) {
					var RPvalue = a_captureGrid.store.getValues(selectedItem, attribute);
					if (attribute == "captureId" ) {
						selcap=RPvalue;						
  					} 
				});
			} 
		});
	} else {
		textError.setContent("Select an Exon Capture");
		myError.show();
		return;
	}

	var desFormvalue = dijit.byId("a_desForm").getValues();
// Number of Patient 
	var check_Rnbpat = desFormvalue.a_Rnbpat;
//	if (isNaN(check_Rnbpat) || check_Rnbpat <=0 || check_Rnbpat >=600){		
	if (check_Rnbpat >=600){		
			textError.setContent("Enter a number of Patient (min:1,max:600)");
			myError.show();
			return;
	}
// Flowcell
	if (desFormvalue.a_fc ==null) {
		textError.setContent("Select a Flowcell ...");
		myError.show();
		return;
	}	

//Type Patient
	var s_patientType = document.getElementById("a_patientType").value;
	if (s_patientType.length ==0){		
			textError.setContent("Select a Sample Type");
			myError.show();
			return;
	}

// speciesName
	var s_species = desFormvalue.speciesName;
	if (s_species.length ==0){		
			textError.setContent("Select a Species");
			myError.show();
			return;
	}

//Patient
	var runpatFormvalue = dijit.byId("a_patForm").getValues();
	var check_lpat = runpatFormvalue.a_Rpatient;
	if(contains(check_lpat,"+")) {
		textError.setContent("No sign + in patient line!!!");
		myError.show();
		return;
	}

	var LinesPatient=runpatFormvalue.a_Rpatient.split("\n");
	var groupPatient=[];
	var namePatient=[];
	var familyPatient=[];
	var nameFather=[];
	var nameMother=[];
	var sexPatient=[];
	var statusPatient=[];
	var bcPatient=[];
	var bc2Patient=[];
	var bcgPatient=[];
	var namePerson=[];

	for(var i=0; i<LinesPatient.length; i++) {
		var fgrp;
		var fpat;
		var ffam;
		var ffat;
		var fmot;
		var fsex;
		var fsta;
		var fbc;
		var fbc2;
		var fbcg;
		var fpers;
		var fieldPatient=LinesPatient[i].split("\t");
//		var fieldPatient=LinesPatient[i].split("\\s+");.toLowerCase()
		if (fieldPatient == ""){
			break;
		}
		// Header
		if (i==0) {
			fieldPatient=fieldPatient.filter(Boolean);
			if (fieldPatient[0].toLowerCase()!= "patient") {
				textError.setContent("<b>Error</b> Patient field is mandatory and must be at First Column");
				myError.show();
				return;
			}
		}
		if (i==0) {
			fieldPatient=fieldPatient.filter(Boolean);
			var HeaderLine=fieldPatient.toString().toLowerCase().replace(/,/g," ");
			var okmatch=HeaderLine.match("patient");
			if (! okmatch) {
				textError.setContent("<b>Error</b> Patient field is mandatory");
				myError.show();
				return;
			}

			for (var j=0; j<fieldPatient.length; j++) {
				switch (fieldPatient[j].toLowerCase().replace(/ /g,"")) {
					case "group":
					fgrp=j;
					break;
					case "patient":
					fpat=j;
					break;
					case "family":
					ffam=j;
					break;
					case "father":
					ffat=j;
					break;
					case "mother":
					fmot=j;
					break;
					case "sex":
					fsex=j;
					break;
					case "status":
					fsta=j;
					break;
					case "bc":
					fbc=j;
					break;
					case "bc2":
					fbc2=j;
					break;
					case "iv":
					fbcg=j;
					break;
					case "person":
					fpers=j;
					break;
					default:
					textError.setContent("The Header Tabulated List is not Good!!!<BR>"+
					"Field in Header: Patient Group Family Father Mother Sex Status BC BC2 IV Person<BR>"+
					"Needs First field Patient then no order, no case sensitive,BC=Bar Code,BC2=Bar Code 2,IV=Identity Vigilance,Person=Reffering Person Name");
					myError.show();
					return;
				}			
			}
			continue;
		}

		if (typeof(fieldPatient[fpat])=="undefined"||typeof(fpat)=="undefined")	{
			textError.setContent("The column Patient is required!!!");
			myError.show();
			return;
		}
		if (fieldPatient[fpat] == "") {
			textError.setContent("The column Patient name is empty!!!");
			myError.show();
			return;
		}
		if (fieldPatient[fpat] ==0){		
			textError.setContent("Enter a patient name");
			myError.show();
			return;
		}
		if(contains(fieldPatient[fpat]," ")) {
			textError.setContent(fieldPatient[fpat]+": No space please for patient name!!!");
			myError.show();
			return;
		}
		groupPatient.push(fieldPatient[fgrp]);
		namePatient.push(fieldPatient[fpat]);
		if (typeof(fieldPatient[fpers]) != "undefined") {
			if(contains(fieldPatient[fpers]," ")) {
				textError.setContent(fieldPatient[fpers]+": No space please for reffering person name!!!");
				myError.show();
				return;
			}
		}
		// if no family name entered, family name = patient name
		if (typeof(fieldPatient[ffam]) == "undefined" || fieldPatient[ffam]=="") {
			fieldPatient[ffam]=fieldPatient[fpat];
		}
		if (typeof(fieldPatient[ffam]) != "undefined" || fieldPatient[ffam]!="") {
			if(contains(fieldPatient[ffam]," ")) {
				textError.setContent(fieldPatient[ffam]+": No space please for Family name!!!");
				myError.show();
				return;
			}
		}
		familyPatient.push(fieldPatient[ffam]);

		if (typeof(fieldPatient[ffat])=="undefined"||typeof(ffat)=="undefined"||fieldPatient[ffat]==0) {fieldPatient[ffat]=""}
		nameFather.push(fieldPatient[ffat]);
		if (typeof(fieldPatient[fmot])=="undefined"||typeof(ffat)=="undefined"||fieldPatient[fmot]==0) {fieldPatient[fmot]=""}
		nameMother.push(fieldPatient[fmot]);
if (typeof(fsex) == "undefined" || typeof(fieldPatient[fsex]) == "undefined" || fieldPatient[fsex].replace(/ /g,"") == "") {fieldPatient[fsex]=1}
		if (fieldPatient[fsex]=="?") {fieldPatient[fsex]=0};
		sexPatient.push(fieldPatient[fsex]);
if (typeof(fsta) == "undefined" || typeof(fieldPatient[fsta]) == "undefined" || fieldPatient[fsta].replace(/ /g,"") == "") {fieldPatient[fsta]=2}
		statusPatient.push(fieldPatient[fsta]);
if (typeof(fbc) == "undefined" ||typeof(fieldPatient[fbc]) == "undefined"||fieldPatient[fbc]==0) {fieldPatient[fbc]=""}
		//bcPatient.push(fieldPatient[fbc].toUpperCase());
		bcPatient.push(fieldPatient[fbc]);
if (typeof(fbc2) == "undefined" ||typeof(fieldPatient[fbc2]) == "undefined"||fieldPatient[fbc2]==0) {fieldPatient[fbc2]=""}
		//bc2Patient.push(fieldPatient[fbc2].toUpperCase());
		bc2Patient.push(fieldPatient[fbc2]);
if (typeof(fbcg) == "undefined" ||typeof(fieldPatient[fbcg]) == "undefined"||fieldPatient[fbcg]==0) {fieldPatient[fbcg]=""}
		bcgPatient.push(fieldPatient[fbcg].toUpperCase());
if (typeof(fpers) == "undefined" ||typeof(fieldPatient[fpers]) == "undefined"||fieldPatient[fpers]==0) {fieldPatient[fpers]=""}
		namePerson.push(fieldPatient[fpers]);
	}
// ### Patient Name Length ####//
	for(var i=0; i<namePatient.length;i++ ) {
		if (namePatient[i].length >45) {
			textError.setContent("Max Length exceeded <b>[max=45]</b> for Patient Name :"+namePatient[i]);
			myError.show();
			return;
		}
	}
// tableau associatif Patient Famille Sex
	var assoc_SexPat= new Array();
	var assoc_FamPat= new Array();
	for(var i=0; i<namePatient.length;i++ ) {  
		for(var j=0; j<sexPatient.length;j++ )
		{
			if(i==j) {
				assoc_SexPat[namePatient[i]]=sexPatient[j];
				assoc_FamPat[namePatient[i]]=familyPatient[j];
			}
		}		
	}
// Error Sex for Father
	for(var i=0; i<nameFather.length;i++ )
 	{  
		if (nameFather[i]!=="" && assoc_SexPat[nameFather[i]]!=1) {
			textError.setContent("Error Sex for Father: <b>"+nameFather[i]+"</b>");
			myError.show();
			return;
		}
	}
//Error Sex for Mother
	for(var i=0; i<nameMother.length;i++ ) {  
		if (nameMother[i]!=="" && assoc_SexPat[nameMother[i]]!=2) {
			textError.setContent("Error Sex for Mother: <b>"+nameMother[i]+"</b>");
			myError.show();
			return;
		}
	}

//Error Father Family

	for(var i=0; i<namePatient.length;i++ ) {  
		for(var j=0; j<nameFather.length;j++ )
		{
			if(i==j) {
				if (nameFather[j] !=="" ) {
					if (assoc_FamPat[namePatient[i]] !== assoc_FamPat[nameFather[j]]) {
						textError.setContent("<b>Error Family: </b> "+
						"Patient/Family: "+ namePatient[i] +"/"+assoc_FamPat[namePatient[i]] +" ==> "+
						"Father/Family: " +  nameFather[j]+"/"+assoc_FamPat[nameFather[j]]);
						myError.show();
						return;
					}
					if (namePatient[i] == nameFather[j]) {
						textError.setContent("<b>Error Father: </b> " +
							"<b>Same Name</b> for Patient " + namePatient[i] + " and Father "+ nameFather[j]);
						myError.show();
						return;
					}
				}
			}
		}
	}
//test Mother Family
	for(var i=0; i<namePatient.length;i++ ) {  
		for(var j=0; j<nameMother.length;j++ )
		{
			if(i==j) {
				if (nameMother[j] !=="" ) {
					if (assoc_FamPat[namePatient[i]] !== assoc_FamPat[nameMother[j]]) {
						textError.setContent("<b>Error Family: </b> "+
						"Patient/Family: "+ namePatient[i] +"/"+assoc_FamPat[namePatient[i]] +" ==> "+
						"Mother/Family: " +  nameMother[j]+"/"+assoc_FamPat[nameMother[j]]);
						myError.show();
						return;
					}
					if (namePatient[i] == nameMother[j]) {
						textError.setContent("<b>Error Mother: </b> " +
							"<b>Same Name</b> for Patient " + namePatient[i] + " and Mother "+ nameMother[j]);
						myError.show();
						return;
					}
				}
			}
		}
	}
	check_Rnbpat=namePatient.length;
	var prog_url=url_path + "/manageData.pl";
	var options="option=addPatientRun" +
					"&RunSel="+ selrun +
					"&typePatient="+s_patientType +
					"&species="+ s_species +
					"&capture=" + selcap +
					"&nbpat=" + check_Rnbpat +
					"&fc=" + desFormvalue.a_fc +
					"&group=" + groupPatient +
					"&patient="+ namePatient +
					"&family="+ familyPatient +
					"&father=" + nameFather +
					"&mother=" + nameMother +
					"&sex="+ sexPatient +
					"&status="+ statusPatient +
					"&bc=" + bcPatient +					
					"&bc2=" + bc2Patient +					
					"&iv=" + bcgPatient +					
					"&person="+ namePerson +
					"&profileId="+ desFormvalue.a_profileName
					;
	if (btn) {
		options=options	+ 
		"&method_pipeline="+ filterRes;
	} else {
		options=options	+ 
		"&method_align="+ AlnGroups +
		"&method_call="+ CallGroups +
		"&method_other="+ OthersGroups;
	}
//console.log(prog_url);
//console.log(options);
//console.log(namePerson);
	var res=senDataExtendedPost(prog_url,options);
	res.addCallback(
		function(response) {
			if (response.status=="OK") {
				refreshRunDoc(nostandby=1);
				preReloadPatient(selrun);
				dijit.byId('addPatientDialog').reset();
				dijit.byId('addPatientDialog').hide();
			} else if (response.status=="Extended") {
				if (response.extend) {
					initProposalName(response,selrun,prog_url,options);
				};
			}
		}
	);
}

//###################################### Proposal for a Uniq Person Name #############################
var tmp_personIdentGrid;
var nb_searchP=0;
function initProposalName(response,selrun,prog_url,options,namePatient,sexPatient){
	var CP_addpers = dojo.byId("ADDPERSrunId");
	CP_addpers.innerHTML= selrun;

	var sp_btcloseperson=dojo.byId("bt_close_person");
	var btcloseperson=dijit.byId("id_bt_close_person");
	if (btcloseperson) {
		sp_btcloseperson.removeChild(btcloseperson.domNode);
		btcloseperson.destroyRecursive();
	}
	var buttonformclose_person= new dijit.form.Button({
		id:"id_bt_close_person",
		showLabel: false,
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('personDialog').reset();dijit.byId('personDialog').hide();"
	});
	buttonformclose_person.startup();
	buttonformclose_person.placeAt(sp_btcloseperson);

	var sp_btsubmitperson=dojo.byId("bt_submit_person");
	var btsubmitperson=dijit.byId("id_bt_submit_person");
	if (btsubmitperson) {
		sp_btsubmitperson.removeChild(btsubmitperson.domNode);
		btsubmitperson.destroyRecursive();
	}
	var buttonformsubmit_person= new dijit.form.Button({
		showLabel: true,
		id:"id_bt_submit_person",
		//type:"submit", avoid closing window when error by submitting
		label:"Submit",
		value:"Submit",
		iconClass:"validIcon",
		style:"color:white",
		onClick:function(){
			applyProposalName(nb_searchP,prog_url,options,namePatient,sexPatient);
		}			
	});
	buttonformsubmit_person.startup();
	buttonformsubmit_person.placeAt(sp_btsubmitperson);

	var layoutTmpPerson = [
        	{ field: "Row", name: "Row", width: '3'},
        	{ field: "person_s", name: "Person Search", width: '10'},
        	{ field: "person", name: "Name", width: '10em',formatter:newPerson},
		{ field: 'person_id',name: 'PersonId',width: '6em'},
        	{ field: "patient", name: "Patient", width: '10'},
		{ field: "run", name: "Run", width: '4'},
		{ field: "project", name: "project", width: '9'},
		{ field: 'capAnalyse',name: 'Ana',width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldAnalyse},
        	{ field: "family", name: "Family", width: '10'},		
		{ field: "sex", name: "Sex", width: '3'},
		{ field: "status", name: "Status", width: '3'},
        	{ field: "iv_vcf", name: "IV VCF", width: '12'}
//       		{ field: "imax", name: "imax", width: '3'}
    	];

        var tmp_personIdentStore = new dojo.data.ItemFileWriteStore({
                data: response.extend
	});

	function myStyleRowPersonName(row){
		var item=tmp_personIdentGrid.getItem(row.index);
		var color = "background:#b8a9c9;";
		if (item.imax >0) {
			row.customStyles += color;
		}
	}

	var gotList = function(items, request){
		nb_searchP=0;
		var searchP=new Array();
		dojo.forEach(items, function(i){
			searchP.push(tmp_personIdentStore.getValue(i,"person_s").toString());
		});
		nb_searchP=searchP.unique().length;
	}
	var gotError = function(error, request){
  			alert("nb proposal search person name: The request to the store failed. " +  error);
	}
	tmp_personIdentStore.fetch({
  		onComplete: gotList,
  		onError: gotError
	});

	function clearOldIdentList(size, request) {
                    var listIdent = dojo.byId("tmp_personIdentGrid");
                    if (listIdent) {
                        while (listIdent.firstChild) {
                           listIdent.removeChild(listIdent.firstChild);
                        }
                    }
	}
	function fetchIdentFailed(error, request) {
		alert("lookup Proposal Person Name failed.");
		alert(error);
	}

	tmp_personIdentStore.fetch({
		onBegin: clearOldIdentList,
		onError: fetchIdentFailed,
		onComplete: function(items){
			tmp_personIdentGrid = new dojox.grid.EnhancedGrid({
				store: tmp_personIdentStore,
				structure: layoutTmpPerson,
				onStyleRow: myStyleRowPersonName,
				rowSelector: "0.4em",
				selectionMode: 'multiple',
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
					dnd:{copyOnly: true},
					exporter: true,
					printer:true,
					selector:true,
				}
			},document.createElement('div'));
			dojo.byId("tmp_personIdentGrid").appendChild(tmp_personIdentGrid.domNode);
			tmp_personIdentGrid.startup();
			dijit.byId("personDialog").show();
		}
	});
}

/*#############  Apply Proposal Person Name tuc  ##############################*/
function applyProposalName(nb_seachPers,prog_url,options,namePatient,sexPatient) {
	selrun = document.getElementById("ADDPERSrunId").innerHTML;
	var item = tmp_personIdentGrid.selection.getSelected();
	var personGroups = new Array(); 
	var personsearchGroups = new Array(); 
	var personIdGroups = new Array();
	if (item.length != nb_seachPers ) {
		textError.setContent("Number of <b>Person Selected</b> is different from the Number of <b>Person Searched</b>");
		myError.show();
		return;
	}
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(tmp_personIdentGrid.store.getAttributes(selectedItem), function(attribute) {
					var Personvalue = tmp_personIdentGrid.store.getValues(selectedItem, attribute);
					if (attribute == "person" ) {
						if (Personvalue.toString().match(/^(New Person)/)) {
							var sp_value=Personvalue.toString().split("/");
							Personvalue=sp_value[1];
						}
						personGroups.push(Personvalue);
						return personGroups;
					}
					if (attribute == "person_s" ) {
						personsearchGroups.push(Personvalue);
						return personsearchGroups;
					}
					if (attribute == "person_id" ) {
						personIdGroups.push(Personvalue);
						return personIdGroups;
					}					
				});
			}
		});
		if (personsearchGroups.unique().length != nb_seachPers ) {
			textError.setContent("Number of <b>Person Searched and Selected</b> is different from the Number of <b>Person Searched</b>");
			myError.show();
			return;
		}
	}
	var ext_options="&s_personsearch="+ personsearchGroups +
	"&s_person="+ personGroups +
	"&s_person_id="+ personIdGroups;
	options=options	+ ext_options;
//console.log(prog_url);
//console.log(options);
//console.log(namePatient);
	var res=senDataExtendedPost(prog_url,options,namePatient,sexPatient);
	res.addCallback(
		function(response) {
			if (response.status=="OK") {
				dijit.byId("personDialog").reset();
				dijit.byId("personDialog").hide();

				refreshRunDoc(nostandby=1);
				preReloadPatient(selrun);
				if (options.toString().match("addPatientRun")) {
					dijit.byId('addPatientDialog').reset();
					dijit.byId('addPatientDialog').hide();
				}
				if (options.toString().match("updatePatientRun")) {
					dijit.byId('upPatientDialog').reset();
					dijit.byId('upPatientDialog').hide();
				}

				if (options.toString().match("upPatient")) {
					reloadPatient(namePatient,sexPatient);
					if (fromproject) {
						refreshPatientProject();
					} else {
						refreshPatRun();
					}
				}
			}			 
		}
	);
}


/*########################################################################
#######################	New Polyproject     ##############################
##########################################################################*/

dojo.addOnLoad(function() {
	var dbStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=database"
	});
	var dbfilterSelect = new dijit.form.FilteringSelect({
		id: "databaseSelect",
		name: "database",
		value: "Polyexome",
		store: dbStore,
		searchAttr: "dbName"
	},"databaseSelect");
});

/*########################################################################
##################### Add/Edit Document       ############################
##########################################################################*/

function downLoad(e){
	var exFile=0;
	var RunIdSel;
	var itemD = onedocGrid.selection.getSelected();
	if (itemD.length) {
		dojo.forEach(itemD, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(onedocGrid.store.getAttributes(selectedItem), function(attribute) {
					var RPvalue = onedocGrid.store.getValues(selectedItem, attribute);
					if (attribute == "FileName" ) {
						if (RPvalue !="") {
							exFile=1;
						};
					}
					if (attribute == "RunId" ) {
						RunIdSel=RPvalue;
					}
				});
			} 
		});
	} 
	if (exFile) {
		var el = document.getElementById("fileRunid");
		el.value = RunIdSel;
		var fo = document.getElementById("formdownload");
		fo.action=url_ftpfile;
		fo.submit();
	}
}

var selrun;
var selproj;
var selrel;
function addDoc2Run() {
	selrun = document.getElementById("SrunId").innerHTML;
	div_addDocument.show(selrun);
}

function addSample2Run() {
	div_addSampleSheet.show();
}


/*########################################################################
##################### Add Remove User Group
##########################################################################*/
function AddRemUserGroup(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	dojo.style(dojo.byId('gusergroup'), "padding", "0");
	var j_ug = dojo.byId("gusergroup");
	j_ug.innerHTML= "";

	var itemProj = grid.selection.getSelected();
	var ProjIdGroups = new Array();
	var ProjNameGroups = new Array();
	if (itemProj.length) {
		dojo.forEach(itemProj, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "id" ) {
						ProjIdGroups.push(Projvalue.toString());
					}
					else if (attribute == "name" ) {
						ProjNameGroups.push(Projvalue.toString());
					}
				});
			} 			
		});
		addUserGroup(ProjIdGroups,ProjNameGroups);
	} else {
		textError.setContent("Please select one or more Projects !");
		myError.show();
		return;
	}
}

var userid;
function addUserGroup(id,name){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var sp = dojo.byId("gprojid");
	sp.innerHTML= id;
	var jp = dojo.byId("gprojname");
	jp.innerHTML= name;


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
			onclick:"dijit.byId('usergroupDialog').reset();dijit.byId('usergroupDialog').hide();"
	});
	buttonformclose_group.startup();
	buttonformclose_group.placeAt(sp_btclosegroup);
	usergroupDialog.show();

	//Grid of Group
	var ugroupStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=ugroup"
	});
	var layoutUgroup = [
		{field: 'group',name: "Group",width: '12em'},
//		{field: 'bt',name: "BTU",width: '4em',formatter:ButtonUserGroup},
		{field: 'bt',name: "<b>&nbsp;&nbsp;</b>",width: '2.5em',formatter:ButtonUserGroup},
	];

	function fetchFailedUgroup(error, request) {
		alert("lookup failed Ugroup.");
		alert(error);
	}

	function clearOldUgroupList(size, request) {
                    var listGroup = dojo.byId("gridGroupDiv");
                    if (listGroup) {
                        while (listGroup.firstChild) {
                           listGroup.removeChild(listGroup.firstChild);
                        }
                    }
	}
	ugroupStore.fetch({
		onBegin: clearOldUgroupList,
		onError: fetchFailedUgroup,
		onComplete: function(items){
			ugroupGrid = new dojox.grid.EnhancedGrid({
				query: {group: '*'},
				store: ugroupStore,
				rowSelector: "0.4em",
				selectionMode: 'multiple',
				structure: layoutUgroup,
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
			dojo.byId("gridGroupDiv").appendChild(ugroupGrid.domNode);
			ugroupGrid.startup();		
		}
	});

	//Grid of User's Group
	var userGroupStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=userGroup"+"&GrpSel="+ userid
	});

	var layoutUserGroup = [
				{field: 'Name',name: "Last Name",width: '12em'},
				{field: 'Firstname',name: "First Name",width: '10em'},
				{field: 'Site',name: 'Site',width: '10em'},
				{field: 'Code',name: 'Lab Code',width: '10em'},
				{field: 'Team',name: 'Team',width: '26em',styles:"text-align:left;white-space:nowrap;"}
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
				structure: layoutUserGroup,
				plugins: {
					nestedSorting: true,
					dnd: true
				}
			},document.createElement('div'));
			dojo.byId("userGroupGridDiv").appendChild(usergroupGrid.domNode);
			usergroupGrid.startup();		
		}
	});

	//Grid of Project's users group
	var usergroupProjStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=usergroupProject"+"&ProjSel="+ id
	});

	var layoutUserGroupProj = [{field: 'Group',name: "Group",width: '12em'}
	];

	function fetchFailedUserGroupProj(error, request) {
		alert("lookup failed UserGroupPro.");
		alert(error);
	}
	function clearOldUserGroupProjList(size, request) {
                    var listUserGroup = dojo.byId("usergroupProjGridDiv");
                    if (listUserGroup) {
                        while (listUserGroup.firstChild) {
                           listUserGroup.removeChild(listUserGroup.firstChild);
                        }
                    }
	}
	usergroupProjStore.fetch({
		onBegin: clearOldUserGroupProjList,
		onError: fetchFailedUserGroupProj,
		onComplete: function(items){
			usergroupProjGrid = new dojox.grid.EnhancedGrid({
				query: {Group: '*'},
				store: usergroupProjStore,
				rowSelector: "0.4em",
				selectionMode: 'multiple',
				structure: layoutUserGroupProj,
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
			dojo.byId("usergroupProjGridDiv").appendChild(usergroupProjGrid.domNode);
			usergroupProjGrid.startup();		
		}
	});
}

function ButtonUserGroup(value,idx,cell) {
	var sp_val=value.toString().split("#");
	var Cbutton;
	if (cell.field == "bt") {
		Cbutton = new dijit.form.Button({
			style:"background:transparent;",
			label:"<span class='userButton'><img src='icons/user.png'></span>",
			baseClass:"userButton2",
			onClick: function(e){
				userGroupStore = new dojo.data.ItemFileWriteStore({
					url: url_path + "/manageData.pl?option=userGroup"+"&GrpSel="+ sp_val[0].toString()
				});
				usergroupGrid.setStore(userGroupStore);
				usergroupGrid.store.close();
				dojo.style(dojo.byId('gusergroup'), "padding", "0 1px 0 1px");
				var j_ug = dojo.byId("gusergroup");
				j_ug.innerHTML= sp_val[1].toString();
			} 
		});
	}
	return Cbutton;
}

function addProjects2Group() {
	var ProjSelected = document.getElementById("gprojname").innerHTML;
	var ProjId = document.getElementById("gprojid").innerHTML;
	var itemUgroup = ugroupGrid.selection.getSelected();
	var groupIdGroups = new Array();
	if (itemUgroup.length) {
		dojo.forEach(itemUgroup, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(ugroupGrid.store.getAttributes(selectedItem), function(attribute) {
					var GroupIdvalue = ugroupGrid.store.getValues(selectedItem, attribute);
					if (attribute == "groupId" ) {
						groupIdGroups.push(GroupIdvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select one Group from List of Groups !");
		myError.show();
		return;
	} 

	var url_insert = url_path + "/manageData.pl?option=addProject2Group"+"&ProjSel="+ProjId+"&GrpSel="+groupIdGroups;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				var usergroupProjStore = new dojo.data.ItemFileWriteStore({
	        			url: url_path + "/manageData.pl?option=usergroupProject"+"&ProjSel="+ ProjId
				});
				usergroupProjGrid.setStore(usergroupProjStore);
				usergroupProjGrid.store.close();

				refreshPolyList(stand=1);
			}
		}
	);
}; 

function removeUserGroupProject() {
	var ProjSelected = document.getElementById("gprojname").innerHTML;
	var ProjId = document.getElementById("gprojid").innerHTML;
	var itemUgroup = usergroupProjGrid.selection.getSelected();
	var groupIdGroups = new Array();
	if (itemUgroup.length) {
		dojo.forEach(itemUgroup, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(usergroupProjGrid.store.getAttributes(selectedItem), function(attribute) {
					var GroupIdvalue = usergroupProjGrid.store.getValues(selectedItem, attribute);
					if (attribute == "GroupId" ) {
						groupIdGroups.push(GroupIdvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select one or more Groups from Project's Group!");
		myError.show();
		return;
	}
	var url_insert = url_path + "/manageData.pl?option=remProject2Group"+"&ProjSel="+ProjId+"&GrpSel="+groupIdGroups;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				var usergroupProjStore = new dojo.data.ItemFileWriteStore({
	        			url: url_path + "/manageData.pl?option=usergroupProject"+"&ProjSel="+ ProjId
				});
				usergroupProjGrid.setStore(usergroupProjStore);
				usergroupProjGrid.store.close();

				refreshPolyList(stand=1);
			}
		}
	);
}; 

function refreshUgroupList() {
	var url_group = url_path+"/manageData.pl?option=ugroup";
	var ugroupStore = new dojo.data.ItemFileWriteStore({ url: url_group });
	ugroupGrid.setStore(ugroupStore);
	ugroupGrid.store.close();
}; 

/*########################################################################
##################### Add Remove User
##########################################################################*/

function AddRemUser() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var itemProj = grid.selection.getSelected();
	var ProjIdGroups = new Array();
	var ProjNameGroups = new Array();
	if (itemProj.length) {
		dojo.forEach(itemProj, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "id" ) {
						ProjIdGroups.push(Projvalue.toString());
					}
					else if (attribute == "name" ) {
						ProjNameGroups.push(Projvalue.toString());
					}
				});
			} 			
		});
		addUser(ProjIdGroups,ProjNameGroups);
	} else {
		var sp_btclosewuserproj=dojo.byId("bt_close_wuserproj");
		var btclosewuserproj=dijit.byId("id_bt_closewuserproj");
		if (btclosewuserproj) {
			sp_btclosewuserproj.removeChild(btclosewuserproj.domNode);
			btclosewuserproj.destroyRecursive();
		}
		var buttonformclose_wuserproj= new dijit.form.Button({
			showLabel: false,
			id:"id_bt_closewuserproj",
			iconClass:"closeIcon",
			type:"button",
			style:"color:white",
			onclick:"dijit.byId('warnUserDialog').hide();"
		});
		buttonformclose_wuserproj.startup();
		buttonformclose_wuserproj.placeAt(sp_btclosewuserproj);
		warnUserDialog.show();
	} 
}

function removeUserAllProjects(){
	var sp_btcloseremuserproj=dojo.byId("bt_close_remuserproj");
	var btcloseremuserproj=dijit.byId("id_bt_closeremuserproj");
	if (btcloseremuserproj) {
		sp_btcloseremuserproj.removeChild(btcloseremuserproj.domNode);
		btcloseremuserproj.destroyRecursive();
	}
	var buttonformclose_remuserproj= new dijit.form.Button({
		showLabel: false,
		id:"id_bt_closeremuserproj",
		iconClass:"closeIcon",
		type:"button",
		style:"color:white",
		onclick:"dijit.byId('remuserDialog').hide();"
	});
	buttonformclose_remuserproj.startup();
	buttonformclose_remuserproj.placeAt(sp_btcloseremuserproj);
	remuserDialog.show();
	dojo.byId("remgridUserDiv").appendChild(groups_Table.domNode);
	groups_Table.startup();
	groups_Table.setStore(userStore);
//	groups_Table.store.close();
	dijit.byId(groups_Table)._refresh();
}

function removeUserForAllProject() {
	var itemUser = groups_Table.selection.getSelected();
	var UserGroups = new Array(); 
	if (itemUser.length) {
		dojo.forEach(itemUser, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(groups_Table.store.getAttributes(selectedItem), function(attribute) {
					var Uservalue = groups_Table.store.getValues(selectedItem, attribute);
					if (attribute == "UserId" ) {
							UserGroups.push(Uservalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select one User !");
		myError.show();
		return;
	} 
	if (UserGroups.length>1) {
		textError.setContent("Please select Only one User !");
		myError.show();
		return;
	}
	
	var url_insert = url_path + "/manageData.pl?option=remUserAllProjects"+"&User="+UserGroups;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				groups_Table.selection.clear();
				groups_Table.setStore(userStore);
				refreshPolyList(stand=1);
			}
		}
	);
}

function addUser(id,name){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var sp = dojo.byId("projid");
	sp.innerHTML= id;
	var jp = dojo.byId("projname");
	jp.innerHTML= name;

	var sp_btnew_user=dojo.byId("button_newuser");
	var btnewuser=dijit.byId("id_bt_newuser");
	if (btnewuser) {
		sp_btnew_user.removeChild(btnewuser.domNode);
		btnewuser.destroyRecursive();
	}
	var buttonformnew_user= new dijit.form.Button({
		id:"id_bt_newuser",
		showLabel: true,
		label:"New User",
		iconClass:"plusUserIcon",
		onclick:"viewNewUser();",
	});
	buttonformnew_user.startup();
	buttonformnew_user.placeAt(sp_btnew_user);


	var sp_btcloseuserproj=dojo.byId("bt_close_userproj");
	var btcloseuserproj=dijit.byId("id_bt_closeuserproj");
	if (btcloseuserproj) {
		sp_btcloseuserproj.removeChild(btcloseuserproj.domNode);
		btcloseuserproj.destroyRecursive();
	}
	var buttonformclose_userproj= new dijit.form.Button({
		showLabel: false,
		id:"id_bt_closeuserproj",
		iconClass:"closeIcon",
		type:"button",
		style:"color:white",
		onclick:"dijit.byId('userDialog').hide();"
	});
	buttonformclose_userproj.startup();
	buttonformclose_userproj.placeAt(sp_btcloseuserproj);

	userDialog.show();
	//Grid of List of Users
	dojo.byId("gridUserDiv").appendChild(groups_Table.domNode);
	dojo.connect(groups_Table, "onCellMouseOver", showRowTooltip);
	dojo.connect(groups_Table, "onCellMouseOut", hideRowTooltip); 
	groups_Table.startup();
	groups_Table.setStore(userStore);
	dijit.byId(groups_Table)._refresh();
	//Grid of Project's users
	var userProjStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=userProject"+"&ProjSel="+ id + "&nogroup=1"
	});
	var layoutUserProj = [{field: 'name',name: "Last Name",width: '12em'},
	                     {field: 'Firstname',name: "First Name",width: '10em'}
	];
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearOldUserList(size, request) {
                    var listUser = dojo.byId("userGridDiv");
                    if (listUser) {
                        while (listUser.firstChild) {
                           listUser.removeChild(listUser.firstChild);
                        }
                    }
	}
	userProjStore.fetch({
		onBegin: clearOldUserList,
		onError: fetchFailed,
		onComplete: function(items){
			userGrid = new dojox.grid.EnhancedGrid({
				query: {name: '*'},
				store: userProjStore,
				rowSelector: "0.4em",
				selectionMode: 'multiple',
				structure: layoutUserProj,
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
			dojo.byId("userGridDiv").appendChild(userGrid.domNode);
			userGrid.startup();		
		}
	});
}

function UserExpiryDate() {
	var url_insert = url_path + "/searchUsersExpiryDate.pl";
	var res=sendData_noStatusTextStandby(url_insert);
	res.addCallback(
		function(response) {
			console.log(response);
		}
	);
}

function addUserProject() {
	var ProjSelected = document.getElementById("projname").innerHTML;
	var ProjId = document.getElementById("projid").innerHTML;
	var itemUser = groups_Table.selection.getSelected();
	var UserGroups = new Array();
	if (itemUser.length) {
		dojo.forEach(itemUser, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(groups_Table.store.getAttributes(selectedItem), function(attribute) {
					var Uservalue = groups_Table.store.getValues(selectedItem, attribute);
					if (attribute == "UserId" ) {
						UserGroups.push(Uservalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select one or more Users from List of Users !");
		myError.show();
		return;
	} 

	var url_insert = url_path + "/manageData.pl?option=addUser"+"&ProjSel="+ProjId+"&User="+UserGroups;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				var userProjStore = new dojo.data.ItemFileWriteStore({
	        			url: url_path + "/manageData.pl?option=userProject"+"&ProjSel="+ ProjId + "&nogroup=1"
				});
				userGrid.setStore(userProjStore);
				userGrid.store.close();
				dijit.byId(userGrid)._refresh();
				refreshUserList(userGrid);
				groups_Table.selection.clear();
				groups_Table.setStore(userStore);
				refreshPolyList(stand=1);
			}
		}
	);
}

function removeUserProject() {
	var ProjSelected = document.getElementById("projname").innerHTML;
	var ProjId = document.getElementById("projid").innerHTML;
	var itemUser = userGrid.selection.getSelected();
	var UserGroups = new Array(); 
	if (itemUser.length) {
		dojo.forEach(itemUser, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(userGrid.store.getAttributes(selectedItem), function(attribute) {
					var Uservalue = userGrid.store.getValues(selectedItem, attribute);
					if (attribute == "UserId" ) {
							UserGroups.push(Uservalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select one or more Users from Project's Users !");
		myError.show();
		return;
	} 
	var url_insert = url_path + "/manageData.pl?option=remUser"+"&ProjSel="+ProjId+"&User="+UserGroups;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				var userProjStore = new dojo.data.ItemFileWriteStore({
	        			url: url_path + "/manageData.pl?option=userProject"+"&ProjSel="+ ProjId + "&nogroup=1"
				});
				userGrid.setStore(userProjStore);
				userGrid.store.close();
				dijit.byId(userGrid)._refresh();
				refreshUserList(userGrid);
				groups_Table.selection.clear();
				groups_Table.setStore(userStore);
				refreshPolyList(stand=1);
			}
		}
	);
}

function refreshUserList(userGrid) {
//	standbyHide();
	var ProjId = document.getElementById("projid").innerHTML;
	var userProjStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=userProject"+"&ProjSel="+ ProjId + "&nogroup=1"
	});
	userGrid.setStore(userProjStore,query={name: '*'});
	dijit.byId(userGrid).setQuery({name: '*'});
	userGrid.store.fetch();
	userGrid.store.close();
	userGrid.sort();
	userGrid._refresh();
}

function refreshAllUsersList() {
	var userStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=user"
	});
	groups_Table.setStore(userStore);
	groups_Table.store.close();
	dijit.byId(groups_Table)._refresh();
}

/*########################################################################
##################### Edit Project
##########################################################################*/
var polyStore;

function show_bt_Project() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var selProjId = document.getElementById("projUid").innerHTML;
	var polyStore = QuerydependProjSlider(selProjId);
	var gotList = function(items, request){
		var NBRUN = "";
		dojo.forEach(items, function(i){
			NBRUN += polyStore.getValue(i,"nbRun");
		});
		if (NBRUN == 0) {
			dojo.style(dijit.byId("bt_delProject").domNode,{'visibility':'visible'});
			dojo.style(dijit.byId("bt_remPatientProject").domNode,{'visibility':'hidden'});
		} else {
			dojo.style(dijit.byId("bt_delProject").domNode,{'visibility':'hidden'});
			dojo.style(dijit.byId("bt_remPatientProject").domNode,{'visibility':'visible'});
		}
	}
	var gotError = function(error, request){
  		alert("show_bt_Project: The request to the store failed. " +  error);
	}
	polyStore.fetch({
  		onComplete: gotList,
  		onError: gotError
	});
}

function editProject(itemProj) {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var selPcapRel = grid.store.getValue(itemProj, "capRel");

	var sp_btDropDownCapture_Project=dojo.byId("dropDownProjectCapture_bt");
	var btbuttonDDC=dijit.byId("id_buttonDDC2");
	if (btbuttonDDC) {
		sp_btDropDownCapture_Project.removeChild(btbuttonDDC.domNode);
		btbuttonDDC.destroyRecursive();
	}

        var menuDDC = new dijit.DropDownMenu({ style: "display: none;"});
        var buttonDDC2 = new dijit.form.DropDownButton({
		label: "Capture",
		name: "Capture",
		id:"id_buttonDDC2",
		dropDown: menuDDC,
		iconClass:"captureIcon",
        });
	captureMenuStore = new dojox.data.AndOrWriteStore({
	        url: url_path + "/manageData.pl?option=captureName",
		clearOnClose: true,
	});

	var gotCaptureList = function(items, request){
		dojo.forEach(items, function(i){
			var nameC= captureMenuStore.getValue(i,"name").split("|")[0].trim();
			//var nameC=nameCinit.split("|")[0].trim();
			menuDDC.addChild(new dijit.MenuItem({
					label: nameC,
					onClick: function(){ 
							updateCapture(nameC);
					 }
        			})
			);
		});
	}
	var gotCaptureError = function(error, request){
  		alert("Failed Capture Menu Store " +  error);
	}
	captureMenuStore.fetch({
		query: { name: "*", caprel: selPcapRel },
 		onComplete: gotCaptureList,
  		onError: gotCaptureError
	});
	sp_btDropDownCapture_Project.appendChild(buttonDDC2.domNode);
	buttonDDC2.startup();
	buttonDDC2.placeAt(sp_btDropDownCapture_Project);

	var selProjId = grid.store.getValue(itemProj, "id");
	var selProjName = grid.store.getValue(itemProj, "name");
	var selProjSom = grid.store.getValue(itemProj, "somatic");
	var polyStore = QuerydependProjSlider(selProjId);
	dijit.byId("btn_person2").set('checked', false);
	showProject(selProjId,selProjName,selProjSom);
}

function showProject(id,name,somatic){
	var spU = dojo.byId("projUid");
	spU.innerHTML= id;
	var jpU = dojo.byId("projUname");
	jpU.innerHTML= name;
	var hU = dojo.byId("projUpname");
	hU.value= name;
//Control field
	var bc2=dijit.byId("btn_control2");
	if(bc2.checked==false) {pcontrol=0} else {pcontrol=1};

	var DependentFilteringSelect = dojo.declare("dojox.grid.cells.DependentFilteringSelect", dojox.grid.cells._Widget, {
 	       	widgetClass:'dijit.form.ComboBox',
        	_currentItem: null,
        	focus: function(inRowIndex, inNode) {
            		if (this.widgetProps.grid && inRowIndex != null) {
                		this._currentItem = this.widgetProps.grid.getItem(inRowIndex);
          	 	}
           	 	this.inherited(arguments);
        	},
        	createWidget: function(inNode, inDatum, inRowIndex) {
			var widgetProps = this.widgetProps;
			dojo.aspect.before(widgetProps.store, "query", dojo.hitch(this, function(query, options) {
//			console.log("ONFOCUS currentItem: " + this._currentItem.toSource());		
//			console.log("ONFOCUS currentItem: " + arguments.toSource());		
				widgetProps.onQuery(this._currentItem, query, options);
            		}));
			return this.inherited(arguments);
		}
	});

	layoutPatientProject = [
		{ field: "Row", name: "Row",get: getRow, width: 3},
		{ field: "group", name: "Group", width: '6', editable:true,required:true,
		type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.ComboBox',widgetProps:{store:groupNameStore,ignoreCase: false}},
		{ field: "control",name: "PC",width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
		{ field: "capAnalyse", name: "Ana", width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldAnalyse},
		{ field: "sp",name: "SP", width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldSpecies},
		{ field: "p_personName",name: "Person", width: '10em', editable: true,formatter:colorPerson,
		type:'dojox.grid.cells._Widget',
		widgetClass: dijit.form.ValidationTextBox, 
		widgetProps:{required:false,regExp:"^[a-zA-Z0-9-_/]+$"}},
		{ field: "patientName",name: "Patient", width: '10em', editable: true,
		type:'dojox.grid.cells._Widget',
		widgetClass: 'dijit.form.ValidationTextBox', 
		widgetProps:{required:true,regExp:"^[a-zA-Z0-9-_/]+$"}},
		{ field: "family",name: "Family", width: '8em', editable: true,formatter:emptyA,
		type: 'dojox.grid.cells._Widget',
		widgetClass: 'dijit.form.ValidationTextBox',
		widgetProps:{required:false,regExp:"^[a-zA-Z0-9-_/]+$"}},
/*################################### Father  ###########################################*/
	{
             	name: 'Father',
               	field: 'father',width: '10em',
                editable: true,
                type: DependentFilteringSelect,
		formatter:emptyA,
                widgetProps: {
			searchAttr: 'patname',
			labelAttr: 'patproj',
			store: fatherStore,
			required:false,
			autoComplete: true,
			onQuery: function(item, query, options) {
				var selPatproj;
				dojo.forEach(patientprojectGrid._by_idx, function(item, index){
					var selectedItem = patientprojectGrid.getItem(index);
					dojo.forEach(patientprojectGrid.store.getAttributes(selectedItem),
					function(attribute) {
						var Pvalue = patientprojectGrid.store.getValues
						(selectedItem, attribute);
						if (attribute == "ProjectName" ) {
 							selPatproj = Pvalue;
						}
					});
				});
				if (item && (selPatproj == name)) {
					if (item.ProjectName == undefined ) {
						item.ProjectName=name;
					}
					if (item.ProjectName.toString()) {
						item.ProjectName=name;
						var regexp = new RegExp(item.ProjectName.toString());
					} else {
						var regexp = new RegExp("Nothing");
					}
					query.projname=regexp;
				}
                    	}
                }},	
/*################################### Mother  ###########################################*/
	{
                name: 'Mother',
                field: 'mother',width: '10em',
                editable: true,
		type: DependentFilteringSelect,
		formatter:emptyA,
                widgetProps: {
			searchAttr: 'patname',
			labelAttr: 'patproj',
			store: motherStore,
			required:false,
			autoComplete: true,
			onQuery: function(item, query, options) {
				var selPatproj;
				dojo.forEach(patientprojectGrid._by_idx, function(item, index){
					var selectedItem = patientprojectGrid.getItem(index);
					dojo.forEach(patientprojectGrid.store.getAttributes(selectedItem),
					function(attribute) {
						var Pvalue = patientprojectGrid.store.getValues
						(selectedItem, attribute);
						if (attribute == "ProjectName" ) {
 							selPatproj = Pvalue;
						}
					});
				});
				if (item && (selPatproj == name)) {
					if (item.ProjectName == undefined ) {
						item.ProjectName=name;
					}
					if (item.ProjectName.toString()) {
						var regexp = new RegExp(item.ProjectName.toString());
					} else {
						var regexp = new RegExp("Nothing");
					}
					query.projname=regexp;
				}
			}
                }},
		{ field: 'Sex',name: 'Sex',width: '3em', editable: true,styles: 'text-align: center;',
		type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',
		widgetProps:{store:sexStore,required:false}},
		{ field: 'Status',name: 'Status',width: '3em',styles: 'text-align: center;', editable: true,
		type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',
		widgetProps:{store:statusStore,required:false}},
//		{ field: "p_personName",name: "Person", width: '10em', editable: true,formatter:colorPerson,
//		type:'dojox.grid.cells._Widget',
//		widgetClass: dijit.form.ValidationTextBox, 
//		widgetProps:{required:false,regExp:"^[a-zA-Z0-9-_/]+$"}},
		{ field: 'Gproject',name: 'Genomic Project',width: '10em'},
		{ field: 'type',name: 'Type',width: '4em'},
//		{ field: 'species',name: 'Species',width: '6em'},
		{ field: "profile", name: "Profile", width: '15em'},
		{ field: 'iv',name: 'IV',width: '12em', editable: true,formatter:zero,
		type:'dojox.grid.cells._Widget',widgetClass:dijit.form.ValidationTextBox,
		widgetProps:{required:false,regExp:"^[1-4]+$"}},
		{ field: 'iv_vcf',name: 'IV_VCF',width: '12em', formatter:zero},
		{ field: 'bc',name: 'BC',width: '8em', editable: true,formatter:zero,
		type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.ValidationTextBox',
		widgetProps:{required:false,regExp:"^[a-zA-Z0-9]+$"}},
		{ field: 'bc2',name: 'BC2',width: '8em', editable: true,formatter:zero,
		type:'dojox.grid.cells._Widget',widgetClass:dijit.form.ValidationTextBox,
		widgetProps:{required:false,regExp:"^[a-zA-Z0-9_-]+$"}},
		{ field: 'flowcell',name: 'FC',width: '3em', editable: true,
		type: 'dojox.grid.cells.Select', options: [ 'A','B',' '],formatter:zero,
		widgetProps:{required:false}},
		{ field: "phenotype", name: "Phenotype", width: '15'},
		{ field: "RunId",name: "Run",width: '4', formatter:colorRun},
		{ field: "nameRun",name: "Run Name", width: '20', formatter:colorRun},
		{ field: "desRun",name: "Run Description", width: '15', formatter:colorRun},
		{ field: "macName",name: "macName",width: '8', formatter:colorRun},
		{ field: "capName", name: "Capture", width: '12', formatter:colorRun},
		{ field: "methAln",name: "Alignment",width: '10', formatter:colorRun},
		{ field: "methSnp",name: "Calling",width: '15', formatter:colorRun},
		{ field: "methPipe", name: "Other", width: '10', formatter:colorRun},
		{ field: "methSeqName", name: "MethSeq", width: '8', formatter:colorRun},
		{ field: "plateformName", name: "Plateform", width: '8', formatter:colorRun},
		{ field: 'p_personId',name: 'PersonId',width: '6em', formatter:colorPerson},
		{ field: 'p_family',name: 'pFamily',width: '10em', formatter:colorPerson},
		{ field: 'p_familyId',name: 'FamilyId',width: '6em', formatter:colorPerson},
		{ field: 'p_fatherId',name: 'FatherId',width: '6em', formatter:colorPerson},
		{ field: 'p_motherId',name: 'MotherId',width: '6em', formatter:colorPerson},
		{ field: 'p_Sex',name: 'pSex',width: '3em', formatter:colorPerson},
		{ field: 'p_Status',name: 'pStatus',width: '3em', formatter:colorPerson},
		{ field: 'major',name: 'Major',width: '12em', formatter:colorPerson},
		{ field: "cDate", name: "Date", width: '7', formatter:colorRun},
	];
	var spOnco = dojo.byId("projOnco");
	if (somatic==1) {
		spOnco.innerHTML= "<span class='Onco'></span>";
		document.getElementById("depositOnco").style.display = "block";
	} else {
		spOnco.innerHTML= "<span></span>";
		document.getElementById("depositOnco").style.display = "none";
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
		onclick:"dijit.byId('btn_force').set('checked', false);dijit.byId('viewProj').reset;"
	});
	buttonformclose_proj.startup();
	buttonformclose_proj.placeAt(sp_btcloseproj);
	show_bt_Project();
	viewProj.show();
//---------------------------- Fetch Data Grid User Project -------------------------------
	standbyShow();
	var userProjectStore = new dojo.data.ItemFileWriteStore({
		clearOnClose:true,
	        url: url_path + "/manageData.pl?option=userProject"+"&ProjSel="+ id
	});

	var subU1 = [
		{field: 'Row',name: "Row",width: '3em', rowSpan: 2},
		{field: "group", name: "Group",width: '10em', formatter:backgroundCell},
		{field: 'name',name: "Name",width: '15em'},
		{field: 'Firstname',name: "First Name",width: '20em'},
		{field: 'Email',name: "Email",width: '20em'},
		{field: 'unit',name: "Code",width: '10em'},
		{field: 'organisme',name: "Institute",width: '10em'}
	];
	var subU2 = [
		{ field: "Team", name: "Team",colSpan:2},
		{ field: "Responsable", name: "Team Leader"},
		{ field: "Director", name: "Director",colSpan:2},
		{field: 'site',name: "Site"}
	];

	var layoutUserProject = {
		rows:[
			subU1,
			subU2
		]
	};
	function clearOldUserList(size, request) {
                    var listUser = dojo.byId("userprojectGridDiv");
                    if (listUser) {
                        while (listUser.firstChild) {
                           listUser.removeChild(listUser.firstChild);
                        }
                    }
	}

	userProjectStore.fetch({
		onBegin: clearOldUserList,
		onError: fetchFailed,
		onComplete: function(items){
			userprojectGrid = new dojox.grid.EnhancedGrid({
				query: {Name: '*'},
				store: userProjectStore,
				structure: layoutUserProject,
				rowSelector: "0.4em",
				plugins: {
					nestedSorting: true,
					dnd: true,
				}
			},document.createElement('div'));
			dojo.byId("userprojectGridDiv").appendChild(userprojectGrid.domNode);
			userprojectGrid.startup();
			userprojectGrid.setStore(userProjectStore);
			userprojectGrid.store.fetch({onComplete:standbyHide});
		}
	});

//---------------------------- Fetch Data Grid Patient Project -------------------------------
	var patientProjectStore = new dojo.data.ItemFileWriteStore({
		clearOnClose:true,
	        url: url_path + "/manageData.pl?option=patientProject"+"&ProjSel="+ id
	});

	var menusObjectP = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};

	menusObjectP.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectP.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectP.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(patientprojectGrid);"}));
	menusObjectP.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(patientprojectGrid);"}));
	menusObjectP.cellMenu.startup();
	menusObjectP.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectP.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectP.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(patientprojectGrid);"}));
	menusObjectP.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(patientprojectGrid);"}));
	menusObjectP.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(patientprojectGrid);"}));
	menusObjectP.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(patientprojectGrid);"}));
	menusObjectP.selectedRegionMenu.startup();

	function clearOldPatientList(size, request) {
                    var listPatProj = dojo.byId("patientprojectGridDiv");
                    if (listPatProj) {
                       while (listPatProj.firstChild) {
                           listPatProj.removeChild(listPatProj.firstChild);
                        }
                    }
	}

	function myStyleRowPhenotype(row){
		var itemR=patientprojectGrid.getItem(row.index);
		if (itemR) {
			if (itemR.Status==2 && itemR.phenotype.toString()!= "") {
 				var ndsex = dojo.query('td[idx="11"]'  /* <= put column index here-> for Status */, row.node)[0];
				var ndphe = dojo.query('td[idx="21"]'  /* <= put column index here-> for phenotype */, row.node)[0];
				ndsex.style.backgroundColor = "#CCCC99";
				ndphe.style.backgroundColor = "#CCCC99";
			}
		}
	}

	patientProjectStore.fetch({
		onBegin: clearOldPatientList,
		onError: fetchFailed,
		onComplete: function(items){
			patientprojectGrid = new dojox.grid.EnhancedGrid({
				//query: {Row: '*'},
				store: patientProjectStore,
				structure: layoutPatientProject,
				onStyleRow: myStyleRowPhenotype,
				rowsPerPage: 1000,  // IMPORTANT
				selectionMode:"multiple",
				rowSelector: "0.4em",
				plugins: {
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
					menus:menusObjectP
				}
			},document.createElement('div'));
			dojo.byId("patientprojectGridDiv").appendChild(patientprojectGrid.domNode);
			dojo.connect(patientprojectGrid, "onMouseOver", showTooltip);
			dojo.connect(patientprojectGrid, "onMouseOut", hideTooltip);	
			patientprojectGrid.layout.setColumnVisibility(2,false);
			if (somatic==1) {patientprojectGrid.layout.setColumnVisibility(2,true)};
	       		//patientprojectGrid.structure[6].widgetProps.grid = patientprojectGrid;
	       		//patientprojectGrid.structure[7].widgetProps.grid = patientprojectGrid;
	       		patientprojectGrid.structure[8].widgetProps.grid = patientprojectGrid;
	       		patientprojectGrid.structure[9].widgetProps.grid = patientprojectGrid;
			patientprojectGrid.startup();			
			patientprojectGrid.store.close();
			patientprojectGrid.setStore(patientProjectStore);
			patientprojectGrid.store.fetch({});
			set_ColVisibility2(patientprojectGrid,false);
		}
	});

	layoutOneProject = [
		{ field: "name",name: "Name",width: '8'},
		{ field: "id",name: "ID",width: '4'},
		{ field: "dejaVu",name: "Vu",width: '2',styles:"text-align:center;",formatter:activeRadioButtonView,
			type: 'dojox.grid.cells.CheckBox', editable: true},
		{ field: "somatic",name: "So",width: '1.5',styles:"text-align:center;",formatter:activeRadioButtonView},
		{ field: "description", name: "Description", width: '18', editable: true},
		{ field: "phenotype", name: "Phenotype", width: '15', editable:true,type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',
			widgetProps:{store:phenotypeNameStore,required:false}},
		{ field: "Rel", name: "Rel", width: '4'},
		{ field: "cDate", name: "Date", datatype:"date", width: '8'},
		{ field: "nbPat", name: "#Pat", width: '3'},
		{ field: "nbRun", name: "#Run", width: '3'},
	];
	oneprojStore = QuerydependProjSlider(id);
	oneprojStore.fetch({
		onBegin: clearOldOneProjList,
		onError: fetchFailed,
		onComplete: function(items){
			oneprojGrid = new dojox.grid.EnhancedGrid({
				store: oneprojStore,
				structure: layoutOneProject,
			},document.createElement('div'));
			dojo.byId("oneprojGridDiv").appendChild(oneprojGrid.domNode);
			dojo.connect(oneprojGrid, "onMouseOver", showTooltip);
			dojo.connect(oneprojGrid, "onMouseOut", hideTooltip);
			oneprojGrid.startup();

		}
	});
	function clearOldOneProjList(size, request) {
                    var listProj = dojo.byId("oneprojGridDiv");
                    if (listProj) {
                        while (listProj.firstChild) {
                           listProj.removeChild(listProj.firstChild);
                        }
                    }
	}

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}
};

function saveProject(){
	var ProjSel = document.getElementById("projUid").innerHTML;
	var selprojDes;
	var selprojAna;
	var selprojPhe
	dojo.forEach(oneprojGrid._by_idx, function(item, index){
		var selectedItem = oneprojGrid.getItem(index);
		dojo.forEach(oneprojGrid.store.getAttributes(selectedItem), function(attribute) {
			var Pvalue = oneprojGrid.store.getValues(selectedItem, attribute);
			if (attribute == "description" ) {
 				selprojDes = Pvalue;
			} else if (attribute == "capAnalyse") {
				selprojAna = Pvalue;
			}  else if (attribute == "phenotype") {
				selprojPhe = Pvalue;
			}
		});
	});

	var check_des = selprojDes.toString();
	var reg =new RegExp("\t","g");
	check_des =check_des.replace(reg,'');
	var alphanum= /^[a-zA-Z0-9-_ \.\>:]*$/;
	if (check_des.search(alphanum) == -1) {
		textError.setContent("Enter a project Description with no accent");
		myError.show();
		return;
	}
	var url_insert = url_path + "/manageData.pl?option=saveProject"+
						"&ProjSel=" + ProjSel +
						"&description=" + selprojDes +
						"&dejaVu=" + seldejaVu +
						"&somatic=" + selSomatic;
	url_insert=url_insert + "&phenotype=" + selprojPhe;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				oneprojStore = QuerydependProjSlider(ProjSel);
				oneprojGrid.setStore(oneprojStore);
				oneprojGrid.store.close();
				dijit.byId(oneprojGrid)._refresh();
				refreshPolyList(stand=1);
				refreshProject();
			}
		}
	);
}

function delProject(){
	var ProjSel = document.getElementById("projUid").innerHTML;
	var url_insert = url_path + "/manageData.pl?option=delProject"+
						"&ProjSel="+ ProjSel;
	var resP=sendData_v2(url_insert);
	resP.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('viewProj').reset();
				dijit.byId('viewProj').hide();
				refreshPolyList(stand=1);
				refreshProject();
			}
		}
	);
}

function removePatientProject(){
	var ProjSel = document.getElementById("projUid").innerHTML;
	var item = patientprojectGrid.selection.getSelected();
	var PatIdGroups = new Array();
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(patientprojectGrid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = patientprojectGrid.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatIdGroups.push(Patvalue.toString());
					}
 				});
			} 
		});

	} else {
		textError.setContent("Please Select one or more Patients");
		myError.show();
		return;
	}
	var url_insert = url_path + "/manageData.pl?option=removePatientProj"+
						"&ProjSel=" + ProjSel +
						"&PatIdSel=" + PatIdGroups;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshPatientProject();
//				refreshPolyList(stand=1);
			}
		}
	);
}

/*####################################################################*/
/* Somatic */
function somaticDeposit() {
	selproj = document.getElementById("projUname").innerHTML;
	var url_insert = url_path + "/somatic_file.pl?opt=extract" +
				"&project="  + selproj+
				"&dirsom=1" +
				"&force=" + sforce;
	sendData_v2(url_insert);
}


/*####################################################################*/
/* Pedrigree */
function pedigreeDeposit() {
	selproj = document.getElementById("projUname").innerHTML;
	var url_insert = url_path + "/pedigree_file.pl?opt=extract" +
				"&project="  + selproj +
				"&dirped=1" +
				"&force=" + force;
	sendData_v2(url_insert);
}

var pedGrid;
function pedigreeRetrieve() {
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	selproj = document.getElementById("projUname").innerHTML;
	var pedprojname = dojo.byId("pedprojname");
	pedprojname.innerHTML= selproj;

	var sp_btcloseped=dojo.byId("bt_close_ped");
	var btcloseped=dijit.byId("id_bt_closeped");
	if (btcloseped) {
		sp_btcloseped.removeChild(btcloseped.domNode);
		btcloseped.destroyRecursive();
	}
	var buttonformclose_ped= new dijit.form.Button({
		id:"id_bt_closeped",
		showLabel: false,
		type:"submit",
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('pedigreeDialog').reset();dijit.byId('pedigreeDialog').hide"
	});
	buttonformclose_ped.startup();
	buttonformclose_ped.placeAt(sp_btcloseped);

	var sp_btsubmitped=dojo.byId("bt_submit_ped");
	var btsubmitped=dijit.byId("id_bt_submitped");
	if (btsubmitped) {
		sp_btsubmitped.removeChild(btsubmitped.domNode);
		btsubmitped.destroyRecursive();
	}
	var buttonformsubmit_ped= new dijit.form.Button({
		id:"id_bt_submitped",
		showLabel: true,
 		label : "Submit",
		type:"submit",
		iconClass:"validIcon",
		style:"color:white",
		onClick:function(){
			insertPedigree();
		}			
	});
	buttonformsubmit_ped.startup();
	buttonformsubmit_ped.placeAt(sp_btsubmitped);


	pedigreeDialog.show();
	var pedStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/pedigree_file.pl?opt=insert" + 				
				"&project="  + selproj +
				"&view=1"
	});
	var layoutPedigree = [
		{field: 'patient',name: 'Patient',width: '10'},
		{field: "family",name: "Family", width: '10'},
		{field: "father",name: "Father", width: '10'},
		{field: "mother",name: "Mother", width: '10'},
		{field: "sex",name: "Sex", width: '3'},
		{field: "status",name: "Status", width: '4'},
		
	];
	var menusObjectPed = {
//		headerMenu: new dijit.Menu(),
//		rowMenu: new dijit.Menu(),
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};
	menusObjectPed.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectPed.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectPed.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(pedGrid);"}));
	menusObjectPed.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(pedGrid);"}));
	menusObjectPed.cellMenu.startup();
	menusObjectPed.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectPed.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectPed.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(pedGrid);"}));
	menusObjectPed.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(pedGrid);"}));

	standbyHide();
	standbyShow();
	function clearOldPedList(size, request) {
                    var listPed = dojo.byId("pedGrid");
                    if (listPed) {
                        while (listPed.firstChild) {
                           listPed.removeChild(listPed.firstChild);
                        }
                    }
	}
	function fetchFailed(error, request) {
		alert("lookup failed.");standbyHide;
		alert(error);
	}
	if(!pedGrid){
		pedStore.fetch({
			onBegin: clearOldPedList,
			onError: fetchFailed,
			onComplete: function(items){
				pedGrid =  new dojox.grid.EnhancedGrid({
					id:'pedGrid',
					store: pedStore,
					rowSelector: "0.4em",
					structure: layoutPedigree,
					//rowsPerPage: 1000,  // IMPORTANT
					plugins: {
						exporter: true,
						printer:true,
						menus:menusObjectPed
					}
				},document.createElement('div'));
				dojo.byId("pedGrid").appendChild(pedGrid.domNode);
				pedGrid.startup();
				pedGrid.setStore(pedStore);
				pedGrid.store.fetch({onComplete:standbyHide});
				if (items.length == 1) {
					textError.setContent("<b>No ped file in Project Folder </b>: " + selproj);
					myError.show();
					dijit.byId('pedigreeDialog').reset();
					dijit.byId('pedigreeDialog').hide();
					return;
				}
			}
		});
	} else { 
		pedGrid.store.close();
		pedGrid.setStore(pedStore);
		pedGrid.store.fetch({onComplete:standbyHide});
		dijit.byId(pedGrid)._refresh();
		pedGrid.store.fetch({onComplete:function(items){
				if (items.length == 1) {
					textError.setContent("<b>No ped file in Project Folder </b>: " + selproj);
					myError.show();
					dijit.byId('pedigreeDialog').reset();
					dijit.byId('pedigreeDialog').hide();
					return;
				}
			}
		});
	}
}

function insertPedigree() {
	selproj = document.getElementById("projUname").innerHTML;
	var selProjId = document.getElementById("projUid").innerHTML;
	var url_insert = url_path + "/pedigree_file.pl?opt=insert" + "&project="  + selproj;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('pedigreeDialog').reset();
				dijit.byId('pedigreeDialog').hide();
				refreshPatientProject();
			}
		}
	);	
}

/*########################################################################
##################### Edit Run
##########################################################################*/
function editOneRun(itemRun) {
	var selRcapRel = gridRundoc.store.getValue(itemRun, "capRel");

	var sp_btDropDownCapture_Run=dojo.byId("dropDownRunCapture_bt");
	var btbuttonDDC=dijit.byId("id_buttonDDC");
	if (btbuttonDDC) {
		sp_btDropDownCapture_Run.removeChild(btbuttonDDC.domNode);
		btbuttonDDC.destroyRecursive();
	}

        var menuDDC = new dijit.DropDownMenu({ style: "display: none;"});
        var buttonDDC = new dijit.form.DropDownButton({
		label: "Capture",
		name: "Capture",
		id:"id_buttonDDC",
		dropDown: menuDDC,
		iconClass:"captureIcon",
        });
	captureMenuStore = new dojox.data.AndOrWriteStore({
	        url: url_path + "/manageData.pl?option=captureName",
		clearOnClose: true,
	});

	var gotCaptureList = function(items, request){
		dojo.forEach(items, function(i){
			//var nameC= captureMenuStore.getValue(i,"name").split("|")[0].trim();//ori
			// sort name with no case sensitive
      			items.sort(function(a, b) {
       				var nameA = captureMenuStore.getValue(a, "value").toLowerCase();
        			var nameB = captureMenuStore.getValue(b, "value").toLowerCase();
        			if (nameA < nameB) return -1;
        			if (nameA > nameB) return 1;
        			return 0;
      			});
			var nameC= captureMenuStore.getValue(i,"name").split("|")[0].trim();

			var lng_nameC= captureMenuStore.getValue(i,"name");
			menuDDC.addChild(new dijit.MenuItem({
					label: lng_nameC,
					onClick: function(){ 
							updateCapture(nameC);
					 }
        			})
			);
		});
	}
	var gotCaptureError = function(error, request){
  		alert("Failed Capture Menu Store " +  error);
	}
	var capRel=selRcapRel.toString().split(" ");
	var query_line="";
	for(var i=0; i<capRel.length; i++) {
		if (i==0) {query_line="caprel:" + capRel[i];} else {query_line+=" OR caprel:" + capRel[i];}
	}
	captureMenuStore.fetch({
		query: {complexQuery:query_line},
		onComplete: gotCaptureList,
  		onError: gotCaptureError
	});

	sp_btDropDownCapture_Run.appendChild(buttonDDC.domNode);
	buttonDDC.startup();
	buttonDDC.placeAt(sp_btDropDownCapture_Run);

	checkPassword(okfunction);
	if(! logged) {
		return
	}
	var selRunId = gridRundoc.store.getValue(itemRun, "RunId");
	var selRSomatic = gridRundoc.store.getValue(itemRun, "somatic");
	var selRcapAnalyse = gridRundoc.store.getValue(itemRun, "CaptureAnalyse");
	showRun(selRunId,selRSomatic,selRcapRel,selRcapAnalyse);
}

function updateCapture(name) {
	var dialogProj = dijit.byId("viewProj");
	var fromProject=0;
	if( dialogProj.open ) {
 		fromProject=1;
	}
	if (fromProject) {
		upCapturePatient(fromProject,patientprojectGrid,name);
	} else {
		upCapturePatient(fromProject,patGrid,name);
	}
}
function upCapturePatient(fromproject,grid,name) {
	var item = grid.selection.getSelected();
	var PatIdGroups = new Array();
	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatIdGroups.push(Patvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("First Select Patients Please...");
		myError.show();
		return;
	}
	var url_insert = url_path + "/manageData.pl?option=upPatientCapture" +
						"&PatIdSel=" + PatIdGroups +
						"&capture=" + name;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				if (fromproject) {
					refreshControlProject();
				} else {
					refreshControlRun();
				}
			}
		}
	);
}

function editRun() {
	var itemRun = gridRundoc.selection.getSelected();
	var selRunId;
	var selRSomatic;
	var selRcapRel;
	var selRcapAnalyse;
	if (itemRun.length) {
		dojo.forEach(itemRun, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridRundoc.store.getAttributes(selectedItem), function(attribute) {
					var RPvalue = gridRundoc.store.getValues(selectedItem, attribute);
					if (attribute == "RunId" ) {
						selRunId = RPvalue;
					}
					if (attribute == "somatic" ) {
						selRSomatic = RPvalue.toString();
					}
					if (attribute == "capRel" ) {
						selRcapRel = RPvalue.toString();
					}
					if (attribute == "CaptureAnalyse" ) {
						selRcapAnalyse = RPvalue.toString();
					}

				});
			} 			
		});
	} else {
		textError.setContent("Please select a Run !");
		myError.show();
		return;
	}
	showRun(selRunId,selRSomatic,selRcapRel,selRcapAnalyse);
}

var RunDependentFilteringSelect;
function showRun(rid,somatic,capRel,capAnalyse){
//###############################
	RunDependentFilteringSelect = dojo.declare("dojox.grid.cells.DependentFilteringSelect", dojox.grid.cells._Widget, {
 	       	widgetClass:'dijit.form.ComboBox',
        	_currentItem: null,
        	focus: function(inRowIndex, inNode) {
            		if (this.widgetProps.grid && inRowIndex != null) {
                		this._currentItem = this.widgetProps.grid.getItem(inRowIndex);
           	 	}
           	 	this.inherited(arguments);
        	},
        	createWidget: function(inNode, inDatum, inRowIndex) {
			var widgetProps = this.widgetProps;
			dojo.aspect.before(widgetProps.store, "query", dojo.hitch(this, function(query, options) {
//			console.log("ONFOCUS currentItem: " + this._currentItem.toSource());		
//			console.log("ONFOCUS currentItem: " + arguments.toSource());		
				widgetProps.onQuery(this._currentItem, query, options);
            		}));
			return this.inherited(arguments);
		}
	});

	layoutGenomicPatRun = [
		{ field: 'Row', name: '#', get: getRow, width:'2em'},
		{ field: "FreeRun",name: "<img align='top' src='icons/exclamation.png'>",
		styles:"white-space:nowrap;margin:0;padding:0;",
		width: '1.5',filterable: false, formatter:bullet},
		{ field: "group", name: "Group", width: '6', editable:true,required:true,
		type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.ComboBox',
		widgetProps:{store:groupNameStore,ignoreCase: false}},
		{ field: "control",name: "PC",width: '1.5',styles:"text-align:center;",formatter:inactiveRadioButtonView},
		{ field: "capAnalyse", name: "Ana", width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldAnalyse},
		{ field: "sp",name: "SP", width: '2',styles: 'text-align: center;font-weight:bold;',formatter:colorFieldSpecies},
		{ field: "p_personName",name: "Person", width: '10em', editable: true,formatter:colorPerson,
		type:'dojox.grid.cells._Widget',
		widgetClass: dijit.form.ValidationTextBox, 
		widgetProps:{required:false,regExp:"^[a-zA-Z0-9-_/]+$"}},
		{ field: "patientName",name: "Patient", width: '10em', editable: true,
		type:'dojox.grid.cells._Widget',
		widgetClass: dijit.form.ValidationTextBox, 
		widgetProps:{required:true,regExp:"^[a-zA-Z0-9-_/]+$"}},
		{ field: "family",name: "Family", width: '8em', editable: true,formatter:emptyA,type: 'dojox.grid.cells._Widget',
		widgetClass: dijit.form.ValidationTextBox, widgetProps:{required:false,regExp:"^[a-zA-Z0-9-_/]+$"}},
/*################################### Project Current ###########################################*/
		{
                'name': 'Current Project',
                field: 'ProjectCurrentName',width: '10em',
 		formatter:emptyA,
		},
/*################################### Project Name Dest ###########################################*/
		{
                'name': 'Target Project',
               // field: 'ProjectName',width: '10em',
                field: 'ProjectNameDest',width: '10em',
 		formatter:emptyA,
		},
/*################################### Father  ###########################################*/
	{
                'name': 'Father',
                field: 'father',width: '10em',
                editable: true,
                type: RunDependentFilteringSelect,
		formatter:emptyA,
                widgetProps: {
			searchAttr: 'patname',
			labelAttr: 'patproj',
			store: fatherStore,
			required:false,
			autoComplete: true,
			onQuery: function(item, query, options) {
				if (item) {
					if (item.ProjectNameDest == undefined ) {
						item.ProjectNameDest="";
					}
					if (item.ProjectCurrentName == undefined ) {
						item.ProjectCurrentName="";
					}
					if (item.ProjectNameDest.toString()) {
						var regexp = new RegExp(item.ProjectNameDest.toString());
					} else if (item.ProjectCurrentName.toString()){
						var regexp = new RegExp(item.ProjectCurrentName.toString());
					} else {
						var regexp = new RegExp("Nothing");
					}
					query.projname=regexp;
				}
                    	}
                }},	
/*################################### Mother  ###########################################*/
	{
                'name': 'Mother',
                field: 'mother',width: '10em',
                editable: true,
		type: RunDependentFilteringSelect,
		formatter:emptyA,
                widgetProps: {
			searchAttr: 'patname',
			labelAttr: 'patproj',
			store: motherStore,
			required:false,
			autoComplete: true,
			onQuery: function(item, query, options) {
				if (item) {
					if (item.ProjectName == undefined ) {
						item.ProjectName="";
					}
					if (item.ProjectCurrentName == undefined ) {
						item.ProjectCurrentName="";
					}
					if (item.ProjectName.toString()) {
						var regexp = new RegExp(item.ProjectName.toString());
					} else if (item.ProjectCurrentName.toString()){
						var regexp = new RegExp(item.ProjectCurrentName.toString());
					} else {
						var regexp = new RegExp("Nothing");
					}
					query.projname=regexp;
				}
			}
                }},
/*################################### Other ###########################################*/
		{ field: 'Sex',name: 'Sex',width: '3em', editable: true,styles: 'text-align: center;',type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect', widgetProps:{store:sexStore,required:false}},
		{ field: 'Status',name: 'Status',width: '3em',styles: 'text-align: center;', editable: true, type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',widgetProps:{store:statusStore,required:false}},
		{ field: 'Gproject',name: 'Genomic Project',width: '10em'},
		{ field: "type", name: "Type",datatype:"date", width: '4em', editable: true,styles: 'text-align: center;',type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect', widgetProps:{store:typepatientStore,required:false}},
//		{ field: 'species',name: 'Species',width: '6em'},
		{ field: "profile", name: "Profile", width: '15em'},
		{ field: 'iv',name: 'IV',width: '12em', editable: true,formatter:zero,
		type:'dojox.grid.cells._Widget',widgetClass:dijit.form.ValidationTextBox,
		widgetProps:{required:false,regExp:"^[1-4]+$"}},
		{ field: 'iv_vcf',name: 'IV_VCF',width: '12em', formatter:zero},
		{ field: 'bc',name: 'BC',width: '8em', editable: true,formatter:zero,
		type:'dojox.grid.cells._Widget',widgetClass:dijit.form.ValidationTextBox,
		widgetProps:{required:false,regExp:"^[a-zA-Z0-9_-]+$"}},
		{ field: 'bc2',name: 'BC2',width: '8em', editable: true,formatter:zero,
		type:'dojox.grid.cells._Widget',widgetClass:dijit.form.ValidationTextBox,
		widgetProps:{required:false,regExp:"^[a-zA-Z0-9_-]+$"}},
		{ field: 'flowcell',name: 'FC',width: '3em', editable: true,
		type: dojox.grid.cells.Select, options: [ 'A','B',' '],formatter:zero,
		widgetProps:{required:false}},
		{ field: "phenotype", name: "Phenotype", width: '12em'},
		{ field: "MethAln", name: "Alignment", width: '10em', editable: true,required:true,
		type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',
		widgetProps:{store:AlnNameStore}},
		{ field: "MethSnp", name: "Calling", width: '15em',editable: true,required:true,
		type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',
		widgetProps:{store:CallNameStore}},
		{ field: "MethPipe", name: "Other", width: '15em',editable: true,required:true,
		type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',
		widgetProps:{store:OtherNameStore}},
		{ field: 'capName',name: 'Capture',width: '12em',editable: true,
		type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',
		widgetProps:{store:capStore,required:true}
		},
		{ field: 'capRel',name: 'capRel',width: '12em'},
		{ field: "machine",name: "Machine",width: '8em', editable: true,required:true,
		type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',
		widgetProps:{store:machineStore}},
		{ field: "methseq", name: "MethSeq", width: '8em', editable:true,required:true,
type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',widgetProps:{store:methSeqNameStore}},
		{ field: "Plateform", name: "Plateform", width: '10', editable:true,required:true,
type:'dojox.grid.cells._Widget',widgetClass:'dijit.form.FilteringSelect',widgetProps:{store:plateformNameStore}},
		{ field: 'p_personId',name: 'PersonId',width: '6em', formatter:colorPerson},
		{ field: 'p_family',name: 'pFamily',width: '10em', formatter:colorPerson},
		{ field: 'p_familyId',name: 'FamilyId',width: '6em', formatter:colorPerson},
		{ field: 'p_fatherId',name: 'FatherId',width: '6em', formatter:colorPerson},
		{ field: 'p_motherId',name: 'MotherId',width: '6em', formatter:colorPerson},
		{ field: 'p_Sex',name: 'pSex',width: '3em', formatter:colorPerson},
		{ field: 'p_Status',name: 'pStatus',width: '3em', formatter:colorPerson},
		{ field: 'major',name: 'Major',width: '12em', formatter:colorPerson},
		{ field: 'oproject',name: 'copyProject',width: '10em'},
		{ field: "UserGroups",name: "Groups",width: '12em',formatter:userColorGroup},
		{ field: "Users",name: "Users",width: '30em',formatter:userColorGroup},
		{ field: "cDate", name: "Date",datatype:"date", width: '8em'},
	];

//##############################
	var sp_btclosepatrun=dojo.byId("bt_close_patrun");
	var buttonformclose_patrun= new dijit.form.Button({
		showLabel: false,
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('showrunDialog').reset();dijit.byId('showrunDialog').hide();"
	});
	buttonformclose_patrun.startup();
	buttonformclose_patrun.placeAt(sp_btclosepatrun);
	drid=rid;

	var h = dojo.byId("SrunId");
	h.innerHTML= drid;
	var CA = dojo.byId("SrunAnalyse");
	CA.innerHTML= capAnalyse;
	var CP = dojo.byId("SrunRel");
	CP.innerHTML= capRel;
	var CP_bcg = dojo.byId("BCGrunId");
	CP_bcg.innerHTML= drid;
	var CP_uppat = dojo.byId("UPPATrunId");
	CP_uppat.innerHTML= drid;
	var CP_addpat = dojo.byId("ADDPATrunId");
	CP_addpat.innerHTML= drid;

//Control field
	var bc=dijit.byId("btn_control");
	if(bc.checked==false) {pcontrol=0} else {pcontrol=1};

	runStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=allqRun" + "&numAnalyse=" + val_sl
	});
	var url_runStore=init_url(SelRun=drid);
	var onerunStore = new dojox.data.AndOrWriteStore({url: url_path + url_runStore});
	var onedocStore = new dojox.data.AndOrWriteStore({url: url_path + url_runStore});

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearOldRunList(size, request) {
                    var listRun = dojo.byId("onerunGridDiv");
                    if (listRun) {
                        while (listRun.firstChild) {
                           listRun.removeChild(listRun.firstChild);
                        }
                    }
	}
	onerunStore.fetch({
		onBegin: clearOldRunList,
		onError: fetchFailed,
		onComplete: function(items){
			onerunGrid = new dojox.grid.EnhancedGrid({
				store: onerunStore,
				structure: layoutOneRun,
			},document.createElement('div'));
			dojo.byId("onerunGridDiv").appendChild(onerunGrid.domNode);
			onerunGrid.startup();

		}
	});
	function clearOldDocList(size, request) {
                    var listDoc = dojo.byId("onedocGridDiv");
                    if (listDoc) {
                        while (listDoc.firstChild) {
                           listDoc.removeChild(listDoc.firstChild);
                        }
                    }
	}
	onedocStore.fetch({
		onBegin: clearOldDocList,
		onError: fetchFailed,
		onComplete: function(items){
			onedocGrid = new dojox.grid.EnhancedGrid({
				store: onedocStore,
				structure: layoutOneDoc,
			},document.createElement('div'));
			dojo.byId("onedocGridDiv").appendChild(onedocGrid.domNode);
			onedocGrid.startup();
			dojo.connect(onedocGrid , 'onRowDblClick',downLoad);
		}
	});
	var srOnco = dojo.byId("runOnco");
	if (somatic==1) {
		srOnco.innerHTML= "<span class='rOnco'></span>";
	} else {
		srOnco.innerHTML= "<span></span>";
	}

	showrunDialog.show();
	standbyHide();
	standbyShow();

	var RunPatStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=runProject"+"&RunSel="+ drid
	});

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	dijit.byId("slider_cap").attr('value',val_sl);
	captureStore = new dojox.data.AndOrWriteStore({
			url: url_path + "/manageCapture.pl?option=capture" + "&numAnalyse=" + val_sl
	});
//############################################New Module##########################
	genomicRunPatStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=gpatient"+"&RunSel="+ drid,
		clearOnClose: true,
	});

	function clearOldPatientList(size, request) {
		var listPat = dojo.byId("runGridDiv");
		if (listPat) {
			while (listPat.firstChild) {
				listPat.removeChild(listPat.firstChild);
			}
		}
	}

	var menusObject = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};

	menusObject.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObject.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObject.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(patGrid);"}));
	menusObject.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(patGrid);"}));
	menusObject.cellMenu.startup();
	menusObject.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObject.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObject.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(patGrid);"}));
	menusObject.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(patGrid);"}));
	menusObject.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(patGrid);"}));
	menusObject.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(patGrid);"}));
	menusObject.selectedRegionMenu.startup();

	var selRegionMenu;

	function myStyleRowRunPhenotype(row){
		var itemR=patGrid.getItem(row.index);
		if (itemR) {
			if (itemR.Status==2 && itemR.phenotype.toString()!= "") {
 				//var nd12 = dojo.query('td[idx="13"]'  /* <= put column index here-> for Status */, row.node)[0];
				//var nd17 = dojo.query('td[idx="22"]'  /* <= put column index here-> for phenotype */, row.node)[0];
 				//var nd14 = dojo.query('td[idx="14"]'  /* <= put column index here-> for Status */, row.node)[0];
				//var nd23 = dojo.query('td[idx="23"]'  /* <= put column index here-> for phenotype */, row.node)[0];
				//nd13.style.backgroundColor = "#CCCC99";
				//nd23.style.backgroundColor = "#CCCC99";
				//var nd15 = dojo.query('td[idx="15"]'  /* <= put column index here-> for Status */, row.node)[0];
				//var nd23 = dojo.query('td[idx="23"]'  /* <= put column index here-> for phenotype */, row.node)[0];
				var ndsex = dojo.query('td[idx="14"]'  /* <= put column index here-> for Status */, row.node)[0];
				var ndphe = dojo.query('td[idx="24"]'  /* <= put column index here-> for phenotype */, row.node)[0];
				ndsex.style.backgroundColor = "#CCCC99";
				ndphe.style.backgroundColor = "#CCCC99";
			}
		}
	}
	dijit.byId("btn_person").set('checked', false);
	if(!patGrid){
		genomicRunPatStore.fetch({
			onBegin: clearOldPatientList,
			onError: fetchFailed,
			onComplete: function(items){
				patGrid = new dojox.grid.EnhancedGrid({
					store: genomicRunPatStore,
					query: {PatId: '*'},
					id:"runGridDivId",
					structure: layoutGenomicPatRun,			
					onStyleRow: myStyleRowRunPhenotype,
					selectionMode:"multiple",
					rowsPerPage: 1000,  // IMPORTANT
					rowSelector: "0.4em",
					canSort:function(colIndex, field){
						return colIndex != 1 && field != 'FreeRun' && field != 'control';
					},
					plugins: {
						filter: {
							closeFilterbarButton: true,
							ruleCount: 5,
							itemsName: "name"
						},
 						nestedSorting: true,
						dnd:{copyOnly: true},
						exporter: true,
						printer:true,
						indirectSelection: {
							headerSelector:true, 
							width: "20px",
							styles: "text-align: center;",
						},
						selector:true,
						menus:menusObject
					}			
				},document.createElement('div'));
				dojo.byId("runGridDiv").appendChild(patGrid.domNode);
				dojo.connect(patGrid, "onMouseOver", showTooltip);
				dojo.connect(patGrid, "onMouseOut", hideTooltip);
				dojo.connect(patGrid, "onMouseOver", showTooltipField);
				dojo.connect(patGrid, "onMouseOut", hideTooltipField);
        			//patGrid.structure[8].widgetProps.grid = patGrid;
       				//patGrid.structure[9].widgetProps.grid = patGrid;
        			//patGrid.structure[9].widgetProps.grid = patGrid;
       				//patGrid.structure[10].widgetProps.grid = patGrid;
        			//patGrid.structure[10].widgetProps.grid = patGrid;
       				//patGrid.structure[11].widgetProps.grid = patGrid;
        			patGrid.structure[11].widgetProps.grid = patGrid;
       				patGrid.structure[12].widgetProps.grid = patGrid;
				patGrid.startup();
				patGrid.setStore(genomicRunPatStore);
				patGrid.store.fetch({onComplete:standbyHide});
				set_ColVisibility(patGrid,false);
			}
		});
	} else { 
		patGrid.store.save();
		patGrid.store.close();
		patGrid.setStore(genomicRunPatStore);
		patGrid.store.fetch({onComplete:standbyHide});
		dijit.byId(patGrid)._refresh();
		set_ColVisibility(patGrid,false);
	}
}

function set_ColVisibility(grid,visibility){
	grid.beginUpdate();
//	grid.layout.setColumnVisibility(32, visibility);
	grid.layout.setColumnVisibility(33, visibility);
	grid.layout.setColumnVisibility(34, visibility);
	grid.layout.setColumnVisibility(35, visibility);
	grid.layout.setColumnVisibility(36, visibility);
	grid.layout.setColumnVisibility(37, visibility);
	grid.layout.setColumnVisibility(38, visibility);
	grid.layout.setColumnVisibility(39, visibility);
	grid.endUpdate();
}

function chgPerson(a){
	if(this.checked) {
		set_ColVisibility(patGrid,true);
	} else {
		set_ColVisibility(patGrid,false);
	}
}

function chgPerson2(a){
	if(this.checked) {
		set_ColVisibility2(patientprojectGrid,true);
	} else {
		set_ColVisibility2(patientprojectGrid,false);
	}
}

function set_ColVisibility2(grid,visibility){
	grid.beginUpdate();
	grid.layout.setColumnVisibility(31, visibility);// pas de User Plt
	grid.layout.setColumnVisibility(32, visibility);
	grid.layout.setColumnVisibility(33, visibility);
	grid.layout.setColumnVisibility(34, visibility);
	grid.layout.setColumnVisibility(35, visibility);
	grid.layout.setColumnVisibility(36, visibility);
	grid.layout.setColumnVisibility(37, visibility);
	grid.layout.setColumnVisibility(38, visibility);
	grid.endUpdate();
}

function init_url(SelRun=selrun){
	var sliderFormvalue = dijit.byId("slider_run").attr("value");
	var url_runStore="/manageData.pl?option=allqRun";
	if (sliderFormvalue==1) {
		url_runStore+= "&numAnalyse=1";
	} else if (sliderFormvalue==2) {
		url_runStore+= "&numAnalyse=2";
	} else if (sliderFormvalue==3) {
		url_runStore+= "&numAnalyse=3";
	} else if (sliderFormvalue==4) {
		url_runStore+= "&numAnalyse=4";
	} else if (sliderFormvalue==5) {
		url_runStore+= "&numAnalyse=5";
	} else if (sliderFormvalue==6) {
		url_runStore+= "&numAnalyse=6";
	} else if (sliderFormvalue==7) {
		url_runStore+= "&numAnalyse=7";
	} else if (sliderFormvalue==8) {
		url_runStore+= "&numAnalyse=8";
	}
	url_runStore+= "&SelRun=" + SelRun;
	return url_runStore;
}


/*########################################################################
##################### Update Run Patient from Copy/Paste File
##########################################################################*/
// Patient copy/paste
function updateRunPatient() {
	selrun = document.getElementById("SrunId").innerHTML;
	var runpatFormvalue = dijit.byId("uppatForm").getValues();
// speciesName
	var s_species = runpatFormvalue.speciesName;
	if (s_species.length ==0){		
			textError.setContent("Select a Species");
			myError.show();
			return;
	}
	var LinesPatientUP=runpatFormvalue.RpatientUP.split("\n");
	LinesPatientUP = LinesPatientUP.filter(Boolean);// avoid empty element in array
	var reg =new RegExp("\t","g");

	var groupPatient=[];
	var namePatient=[];
	var familyPatient=[];
	var nameFather=[];
	var nameMother=[];
	var sexPatient=[];
	var statusPatient=[];
	var bcPatient=[];
	var bc2Patient=[];
	var bcgPatient=[];
	var namePerson=[];
	var fpat;
	var fgrp;
	var ffam;
	var ffat;
	var fmot;
	var fsex;
	var fsta;
	var fbc;
	var fbc2;
	var fbcg;
	var fpers;

	var param="";
	for(var i=0; i<LinesPatientUP.length; i++) {
		var fieldPatient=LinesPatientUP[i].split("\t");
		if (fieldPatient == ""){
			break;
		}
		// Header
		if (i==0) {
			for (var j=0; j<fieldPatient.length; j++) {
				switch (fieldPatient[j].toLowerCase().replace(/ /g,"")) {
					case "patient":
					fpat=j;
					break;
					case "family":
					ffam=j;
					break;
					case "father":
					ffat=j;
					break;
					case "mother":
					fmot=j;
					break;
					case "sex":
					fsex=j;
					break;
					case "status":
					fsta=j;
					break;
					case "group":
					fgrp=j;
					break;
					case "bc":
					fbc=j;
					break;
					case "bc2":
					fbc2=j;
					break;
					case "iv":
					fbcg=j;
					break;
					case "person":
					fpers=j;
					break;

					default:
						textError.setContent("The Header Tabulated List is not Good!!!<BR>"+
					"Field in Header: Patient Group Family Father Mother Sex Status BC BC2 IV Person<BR>"+
					"Needs First field Patient then no order, no case sensitive,BC=Bar Code,BC2=Bar Code 2,IV=Identity Vigilance,Person=Reffering Person Name");
						myError.show();
						return;
				}
			}			
			continue;
		}
		if (typeof(fpat) != "undefined") {
			if (fieldPatient[fpat]) {
				namePatient.push(fieldPatient[fpat]);
			}
		}
		if (typeof(ffam) != "undefined") {
			if (fieldPatient[ffam]) {
				familyPatient.push(fieldPatient[ffam]);
			} else {
				familyPatient.push("");
			}
		}
		if (typeof(ffat) != "undefined") {
			if (fieldPatient[ffat]) {
				nameFather.push(fieldPatient[ffat]);
			} else {
				nameFather.push("");
			}
		}
		if (typeof(fmot) != "undefined") {
			if (fieldPatient[fmot]) {
				nameMother.push(fieldPatient[fmot]);
			} else {
				nameMother.push("");
			}
		}
		if (typeof(fsex) != "undefined") {
			if (fieldPatient[fsex]) {
				if (fieldPatient[fsex]==0||fieldPatient[fsex]=="?") {sexPatient.push(1)} else {sexPatient.push(fieldPatient[fsex])};
			} else {
				sexPatient.push(1);
			}
		}
		if (typeof(fsta) != "undefined") {
			if (fieldPatient[fsta]) {
				if (fieldPatient[fsta]==0||fieldPatient[fsta]=="?") {statusPatient.push(2)} else {statusPatient.push(fieldPatient[fsta])};

			} else {
				statusPatient.push(2);
			}
		}
		if (typeof(fgrp) != "undefined") {
			if (fieldPatient[fgrp]) {
				groupPatient.push(fieldPatient[fgrp]);
			} else {
				groupPatient.push("");
			}
		}
		if (typeof(fbc) != "undefined") {
			if (fieldPatient[fbc]) {
				bcPatient.push(fieldPatient[fbc]);
			} else {
				bcPatient.push("");
			}
		}
		if (typeof(fbc2) != "undefined") {
			if (fieldPatient[fbc2]) {
				bc2Patient.push(fieldPatient[fbc2]);
			} else {
				bc2Patient.push("");
			}
		}
		if (typeof(fbcg) != "undefined") {
			if (fieldPatient[fbcg]) {
				bcgPatient.push(fieldPatient[fbcg]);
			} else {
				bcgPatient.push("");
			}
		}
		if (typeof(fpers) != "undefined") {
			if (fieldPatient[fpers]) {
				namePerson.push(fieldPatient[fpers]);
			} else {
				namePerson.push("");
			}
		}
	}
	param +="&RunSel="+ selrun;
	param +="&species="+ s_species;
	if (fpat>=0) {
		param +="&name=" + namePatient;
	}
	if (ffam>=0) {
		param +="&family=" + familyPatient;
	}
	if (ffat>=0) {
		param +="&father=" + nameFather;
	}
	if (fmot>=0) {
		param +="&mother=" + nameMother;
	}
	if (fsex>=0) {
		param +="&sex="+ sexPatient;
	}
	if (fsta>=0) {
		param +="&status="+ statusPatient;
	}
	if (fgrp>=0) {
		param +="&group="+ groupPatient;
	}
	if (fbc>=0) {
		param +="&bc="+ bcPatient;
	}
	if (fbc2>=0) {
		param +="&bc2="+ bc2Patient;
	}
	if (fbcg>=0) {
		param +="&iv="+ bcgPatient;
	}
	if (fpers>=0) {
		param +="&person="+ namePerson;
	}

	if (!fieldPatient[fpat]) {
		textError.setContent("Error: <b>No Patients entered...</b>");
		myError.show();
		return;
	}


	var url_insert = url_path + "/manageData.pl?option=updatePatientRun" + param;
	var prog_url=url_path + "/manageData.pl";
	var options="option=updatePatientRun" + param;

	var res=senDataExtendedPost(prog_url,options);
	res.addCallback(
		function(response) {
			if (response.status=="OK") {
				dijit.byId("personDialog").reset();
				dijit.byId("personDialog").hide();
				preReloadPatient(selrun);
				dijit.byId('upPatientDialog').reset();
				dijit.byId('upPatientDialog').hide();
			} else if (response.status=="Extended") {
				if (response.extend) {
					initProposalName(response,selrun,prog_url,options);
				};
			}
		}
	);
}

function preReloadPatient(runid) {
	genomicRunPatStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=gpatient"+"&RunSel="+ runid,
		clearOnClose: true,
	});
	patGrid.store.save();
	patGrid.store.close();
	patGrid.setStore(genomicRunPatStore);
	patGrid.sort();
	patGrid._refresh();
	var PatNameGroups = new Array();
	var PatSexGroups = new Array();
	var PatGroups = new Array();
	var ProjectCurrentGroups = new Array();
	patGrid.store.fetch({onComplete: function (items){
		dojo.forEach(patGrid._by_idx, function(item, index){
//		dojo.forEach(patGrid._by_idty, function(item, index){
			var selectedItem = patGrid.getItem(index);
			dojo.forEach(patGrid.store.getAttributes(selectedItem), function(attribute) {
				var Pvalue = patGrid.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatGroups.push(Pvalue);
					} else if (attribute == "patientName" ) {
						PatNameGroups.push(Pvalue.toString());
					} else if (attribute == "Sex" ) {
						PatSexGroups.push(Pvalue.toString());
					} else if (attribute == "ProjectCurrentName") {
						ProjectCurrentGroups.push(Pvalue.toString());
					}

			});
		});
		reloadPatient(PatNameGroups,PatSexGroups,ProjectCurrentGroups[0].toString());
		}
	});
}

/*########################################################################
##################### Identity Vigilance
##########################################################################*/
//IV load File

function load_patientFile() {
	dojo.byId('optPat').value ="insert";
	div_uploadPatientfile.show();
}

function bcg_uploadFile() {
	dojo.byId('optPat').value ="insertBCG";
	div_uploadPatientfile.show();
}

// BCG copy/paste
function addBCG2patient() {
	selrun = document.getElementById("SrunId").innerHTML;
	var runpatFormvalue = dijit.byId("bcgForm").getValues();
	var LinesPatientBCG=runpatFormvalue.RpatientBCG.split("\n");
	LinesPatientBCG = LinesPatientBCG.filter(Boolean);// ovoid empty element in array
	var reg =new RegExp("\t","g");
	var namePatient=[];
	var bcgPatient=[];
	var fpat;
	var fbcg;
	for(var i=0; i<LinesPatientBCG.length; i++) {
		var fieldPatient=LinesPatientBCG[i].split("\t");
//		var fieldPatient=LinesPatientBCG[i].split("\\s+");
		if (fieldPatient == ""){
			break;
		}
		// Header
		if (i==0) {
			for (var j=0; j<fieldPatient.length; j++) {
				switch (fieldPatient[j].toLowerCase().replace(/ /g,"")) {
					case "patient":
						fpat=j;
					break;
					case "iv":
						fbcg=j;
					break;
					default:
						textError.setContent("The Header Tabulated List is not Good!!!<BR>"+
						"Field in Header: Patient IV<BR>");
						myError.show();
						return;
				}
			}			
			continue;
		}
		if (typeof(fieldPatient[fpat])=="undefined"||typeof(fpat)=="undefined")	{
			fieldPatient[fpat] ="";
		}
		if (fieldPatient[fpat] == "") {
			textError.setContent("Error: The column Patient is empty!!!");
			myError.show();
			return;
		}
		if (typeof(fieldPatient[fbcg])=="undefined"||typeof(fbcg)=="undefined")	{
			fieldPatient[fbcg] = "";
		}
		if (fieldPatient[fbcg] == "") {
			textError.setContent("Error: The column IV is empty!!!");
			myError.show();
			return;
		}
		namePatient.push(fieldPatient[fpat]);
		bcgPatient.push(fieldPatient[fbcg]);

	}
	if (namePatient.length != bcgPatient.length) {
			textError.setContent("Error: The number of patients and IV are different!!!");
			myError.show();
			return;
	}
	var url_insert = url_path + "/manageData.pl?option=upPatientIV"+"&RunSel="+ selrun + "&name=" + namePatient + "&iv=" + bcgPatient;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				dijit.byId('bcgDialog').reset();
				dijit.byId('bcgDialog').hide();
				refreshPatRun();
			}
		}
	);
}

function chgBCGCol(a){
	if(this.checked) {
		dojo.style('bcgForm', 'display', '');
	} else {
		dojo.style('bcgForm', 'display', 'none');
	}
}

function chgBCGFil(a){
	if(this.checked) {
		dojo.style(dijit.byId('loadBCG').domNode, {visibility:'visible'});
		dijit.byId("BCGSubmit").setDisabled(true);
		
	} else {
		dojo.style(dijit.byId('loadBCG').domNode, {visibility:'hidden'});
		dijit.byId("BCGSubmit").setDisabled(false);
	}
}


/*###################### Create New Project ##################*/
function viewNewProject(){
	dojo.style('targetNewProj', 'visibility', 'visible');
	var selAnalyse = document.getElementById("SrunAnalyse").innerHTML;
	document.getElementById("TablePhenotype").style.visibility="visible";
	valphenotype="";
	var qphenotypeMultiSelect=dijit.byId("phenotypeSelect_id");
	if (qphenotypeMultiSelect ){
		qphenotypeMultiSelect.reset();
		qphenotypeMultiSelect._updateSelection();
	}
}

function createNewProject(){
//Description project
	var alphanum=/^[a-zA-Z0-9-_ \.\>]+$/;
	var newprojFormvalue = dijit.byId("newProjDesForm").getValues();
	var check_des = newprojFormvalue.description;
	if (check_des.search(alphanum) == -1) {
		textError.setContent("Enter a Project Description with no accent");
		myError.show();
		return;
	}
	if (newprojFormvalue.description.length ==0){		
		textError.setContent("Enter a Project Description");
		myError.show();
		return;
	}

//Release field
	var f = dojo.byId("relNewForm");
	var gp = "";
	for (var i = 0; i < f.elements.length; i++) {
		var elem = f.elements[i];
		if (elem.name == "button") {
			continue;
		}
		if (elem.type == "radio" && !elem.checked) {
			continue;
		}
		gp += elem.title;
	}
	if (!gp.length) {
		textError.setContent("Select a Human Genome release number");
		myError.show();
		return;
	}
//dejaVu field
	var tg=dijit.byId("TNdejavu");
	var tgvalue;
	if(tg.checked==false) {tgvalue=0} else {tgvalue=1};

//Somatic field
	var ts=dijit.byId("TNsomatic");
	var tsvalue;
	if(ts.checked==false) {tsvalue=0} else {tsvalue=1};

//Database field
	var database="Polyexome";

//Phenotype field
	var s_phe=dijit.byId("phenotypeSelect_id").value;
	if (!s_phe.length) {		
		textError.setContent("Enter a Phenotype, please...");
		myError.show();
		return;
	}
	valphenotype=s_phe.toString();
	var selAnalyse = document.getElementById("SrunAnalyse").innerHTML;
	var url_insert = url_path + "/new_polyproject.pl?opt=newPoly" +
					"&golden_path="+ gp +
					"&description="+ check_des +
					"&database=" + database +
					"&dejaVu=" + tgvalue +
					"&somatic=" + tsvalue;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshProject();
				// control lastProject by project_id and description
				url_lastProjId = url_path+"/manageData.pl?option=lastDesProject";
				var lastProjIdStore = new dojo.data.ItemFileReadStore({ url: url_lastProjId });
				var gotList = function(items, request){
					var lastProjIdnext;
					var lastProjDesnext;
					dojo.forEach(items, function(i){
						lastProjIdnext=lastProjIdStore.getValue( i, 'project_id' );
						lastProjDesnext=lastProjIdStore.getValue( i, 'description' );
					});
					gridProj.store.fetch({onComplete: function (items){
							dojo.forEach(gridProj._by_idx, function(item, index){
								var sItem = gridProj.getItem(index);
								if ((sItem.id.toString() == lastProjIdnext.toString()) && (sItem.description.toString() == check_des)) {
									gridProj.selection.addToSelection(index);
										addProject2Patient(valphenotype);
										myMessage.hide();
								}
							});
						}
					});
				}
				var gotError = function(error, request){
  					alert("Create New Project: The request to the store failed. " +  error);
				}

				lastProjIdStore.fetch({
  					onComplete: gotList,
  					onError: gotError
				});
				refreshPolyList(stand=1);
				document.getElementById('TablePhenotype').style.visibility='hidden';
				dojo.style('targetNewProj', 'visibility', 'hidden');
			}
		}
	);
}

function refreshProject() {
	projStore = new dojo.data.ItemFileReadStore({ 
		url: url_path + "/manageData.pl?option=Project",
	});
	gridProj.store.close();
	gridProj.setStore(projStore);
	gridProj.sort();
	gridProj._refresh();
};

/*###################### Search Project  add/new Current or Taget Project ##################*/
var tproject;
function SearchAndNewProject(){
	checkPassword(okfunction);
	if(! logged) {
		return
	}
	selrun = document.getElementById("SrunId").innerHTML;
	selrel = document.getElementById("SrunRel").innerHTML;
	dojo.style('targetNewProj','visibility','hidden');
	document.getElementById('TablePhenotype').style.visibility='hidden';
	var sp_btclosesearchP=dojo.byId("bt_close_searchP");
	var btclosesearchP=dijit.byId("id_bt_closesearchP");
	if (btclosesearchP) {
		sp_btclosesearchP.removeChild(btclosesearchP.domNode);
		btclosesearchP.destroyRecursive();
	}
	var buttonformclose_searchP= new dijit.form.Button({
		showLabel: false,
		id:"id_bt_closesearchP",
		iconClass:"closeIcon",
		style:"color:white",
		onclick:"dijit.byId('searchProjectDialog').reset();dijit.byId('searchProjectDialog').hide();"
	});
	buttonformclose_searchP.startup();
	buttonformclose_searchP.placeAt(sp_btclosesearchP);

	var itemO = patGrid.selection.getSelected();
	var PatNameGroups = new Array();
	var ProjectGroups = new Array();
	var ProjectCurrentGroups = new Array();
	var AlnGroups = new Array();
	var CallGroups = new Array();
	var captureGroups = new Array();
	var machineGroups = new Array();
	var plateformGroups = new Array();
	var methseqGroups = new Array();
	var PatDateGroups = new Array();
	var ProfileGroups = new Array();

	if (itemO.length) {
		dojo.forEach(itemO, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(patGrid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = patGrid.store.getValues(selectedItem, attribute);
					if (attribute == "patientName" ) {
						PatNameGroups.push(Patvalue.toString());
					} else if (attribute == "ProjectName") {
						ProjectGroups.push(Patvalue.toString());
					} else if (attribute == "ProjectCurrentName") {
						ProjectCurrentGroups.push(Patvalue.toString());
					} else if (attribute == "cDate" ) {
 						PatDateGroups.push(Patvalue.toString());
 					} else if (attribute == "profile" ) {
 						ProfileGroups.push(Patvalue.toString());
 					}
				});
			} 
		});

	} else {
		textError.setContent("Please Select one or more Patients");
		myError.show();
		return;
	}
	if(contains(PatNameGroups,"")) {
		textError.setContent("Enter a Patient Name for a new Row...");
		myError.show();
		return;
	}
	var ok_profile=1;
	dojo.forEach(ProfileGroups, function(item, index){
		if (item.length == 0){
			ok_profile=0;
		}
	});
	if (! ok_profile) {
		textError.setContent("Select a profile for each patient selected before adding Project...");
		myError.show();
		return;
	}
	var rid = dojo.byId("currentrunid");
	rid.innerHTML= selrun;
	var curtag=dojo.byId("curtag");
	if (tproject) {
		curtag.innerHTML= "&nbsp;&nbsp;Current Projet&nbsp;&nbsp;";

		var ErrorCurrentProject=[];
		var Index;
		dojo.forEach(PatNameGroups, function(item, index){
			var item0=item;
			Index=index;
			dojo.forEach(ProjectCurrentGroups, function(item, index){
				if(index == Index) {
					if(item) {
						ErrorCurrentProject.push(item0);
					}
				}
			});
		});
		if(ErrorCurrentProject != "") {
			textError.setContent("<b>Current Projects Errors</b> for Patient: " + ErrorCurrentProject +
			" <br> A Current Project has already been assigned to this patient");
			myError.show();
			return;
		}

		var addRowPat=[];
		dojo.forEach(PatDateGroups, function(item, index){
			if (item.length == 0){
				addRowPat.push(PatNameGroups[index]);
			}
		});
		if(PatNameGroups.length != PatDateGroups.filter(Boolean).length) {
textError.setContent("Before adding Current Project, <b>Save</b> your selected Patient: <b>"+addRowPat+"</b>");
			myError.show();
			return;
		}
	} else {
		curtag.innerHTML= "&nbsp;&nbsp;Target Projet&nbsp;&nbsp;";

		var ErrorTargetProject=[];
		var Index;
		dojo.forEach(PatNameGroups, function(item, index){
			var item0=item;
			Index=index;
			dojo.forEach(ProjectGroups, function(item, index){
				if(index == Index) {
					if(item) {
						ErrorTargetProject.push(item0);
					}
				}
			});
		});		
	}

	dijit.byId('newProjDesForm').reset();
	//selrel = document.getElementById("SrunRel").innerHTML;
	initRadioRel(def=selrel);
	gridProj.selection.clear();
//	document.getElementById('TablePhenotype').style.visibility='hidden';
	searchProjectDialog.show();
}

function direct_addProject2Patient(){
	valphenotype="";
	addProject2Patient(valphenotype);
}

function addProject2Patient(valphenotype){
	var selAnalyse = document.getElementById("SrunAnalyse").innerHTML;
	var itemO = patGrid.selection.getSelected();
	var PatGroups = new Array();
	var PatNameGroups = new Array();
	var PatDateGroups = new Array();
	var PatSexGroups = new Array();

	if (itemO.length) {
		dojo.forEach(itemO, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(patGrid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = patGrid.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatGroups.push(Patvalue);
					} else if (attribute == "patientName" ) {
						PatNameGroups.push(Patvalue.toString());
					} else if (attribute == "cDate" ) {
 						PatDateGroups.push(Patvalue.toString());
 					} else if (attribute == "Sex" ) {
						PatSexGroups.push(Patvalue.toString());
					} 
				});
			} 
		});
	}

	var itemP = gridProj.selection.getSelected();
	var selProjName;
	var selProjId;
	var selProjPheid;
	if (itemP.length) {
		dojo.forEach(itemP, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridProj.store.getAttributes(selectedItem), function(attribute) {
					var Projvalue = gridProj.store.getValues(selectedItem, attribute);
					if (attribute == "id" ) {
						selProjId = Projvalue;
					} else if (attribute == "name" ) {
						selProjName = Projvalue;
					} 
					else if (attribute == "pheid" ) {
						selProjPheid = Projvalue;
					}
				});
			} 
		});
	} else {
		textError.setContent("Please Select a Project");
		myError.show();
		return;
	}
	patGrid.rowSelectCell.toggleAllSelection(false);
	var choiceUp=[];
	dojo.forEach(PatDateGroups, function(item, index){
		var maj;
		if (item.length == 0){
			maj="A";
		} else {
			maj="U";
		}
		choiceUp.push(maj);
	});
	if (selProjPheid.toString()) {
		valphenotype=valphenotype+","+selProjPheid;
	}
	if (tproject) {
		//Current Project
		var url_insert = url_path + "/new_polyproject.pl?opt=addPatientProj" +
						"&run=" + selrun +
						"&project=" + selProjId +
						"&projname=" + selProjName +
						"&PatIdSel=" + PatGroups +
						"&PatNameSel=" + PatNameGroups;
	} else {
		//Target Project
		var url_insert = url_path + "/manageData.pl?option=upPatientProj" +
						"&choice=" + choiceUp +
						"&run=" + selrun +
						"&project=" + selProjId +
						"&projname=" + selProjName +
						"&PatIdSel=" + PatGroups +
						"&PatNameSel=" + PatNameGroups;
	}

	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				if (valphenotype.toString()) {					
					if (valphenotype.toString() != "999") {
						addPhenotype2ProjectPatient(valphenotype,selProjId,PatGroups);
					}
				}
				dijit.byId('searchProjectDialog').reset();
				dijit.byId('searchProjectDialog').hide();
				reloadPatient(PatNameGroups,PatSexGroups,selProjName);
				patGrid.store.save();
				patGrid.store.close();
				patGrid.setStore(genomicRunPatStore);
				refreshPatRun();
				refreshRunDoc(nostandby=1);
				refreshPolyList(stand=1);
			}
		}
	);
}

function addPhenotype2ProjectPatient(phenotypeGroup,projid,patidGroup) {
	var url_insert = url_path + "/manageData.pl?option=addPhenotype" + 
			"&PheIdSel=" + phenotypeGroup +
			"&ProjIdSel=" + projid +
			"&PatIdSel=" + patidGroup;
	var res=sendData(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshProject();
				refreshPatRun();
			}
		}
	);
}

function chgControl2patient(fromproject) {
	if (fromproject) {
		changeControl2patient(fromproject,patientprojectGrid);
	} else {
		changeControl2patient(fromproject,patGrid);
	}
}

function changeControl2patient(fromproject,grid){
	var itemO = grid.selection.getSelected();
	var PatGroups = new Array();
	var PatNameGroups = new Array();
	if (itemO.length) {
		dojo.forEach(itemO, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatGroups.push(Patvalue);
					} else if (attribute == "patientName" ) {
						PatNameGroups.push(Patvalue.toString());
					} 
				});
			} 
		});
	} else {
		textError.setContent("Please Select Patient to change as Patient Control or Not");
		myError.show();
		return;
	}
	var url_insert = url_path + "/manageData.pl?option=upPatientControl" +
						"&PatIdSel=" + PatGroups +
						"&control=" + pcontrol;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				if (fromproject) {
					refreshControlProject();
				} else {
					refreshControlRun();
				}
			}
		}
	);
}

function refreshControlRun(){
	patGrid.store.save();
	patGrid.store.close();
	patGrid.setStore(genomicRunPatStore);
	patGrid.selection.clear();
}

function refreshControlProject(){
	var selProjId = document.getElementById("projUid").innerHTML;
	var patientProjectStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=patientProject"+"&ProjSel="+ selProjId,
		clearOnClose: true,
	});
	patientprojectGrid.setStore(patientProjectStore);
	patientprojectGrid.store.close();
	dijit.byId(patientprojectGrid)._refresh();
}

/*########################################################################
##################### Add/Del Patient  from Edit Run #####################
##########################################################################*/
function upRun() {
	selrun = document.getElementById("SrunId").innerHTML;
	var selrunName;
	var selrunDes;
	var selrunPlt;
	dojo.forEach(onerunGrid._by_idx, function(item, index){
		var selectedItem = onerunGrid.getItem(index);
		dojo.forEach(onerunGrid.store.getAttributes(selectedItem), function(attribute) {
			var Pvalue = onerunGrid.store.getValues(selectedItem, attribute);
			if (attribute == "name" ) {
				selrunName = Pvalue;
			} else if (attribute == "desRun" ) {
 				selrunDes = Pvalue;
			}  else if (attribute == "pltRun" ) {
 				selrunPlt = Pvalue;
			}
		});
	});

	var check_name = selrunName.toString();
	var reg =new RegExp("\t","g");
	check_name =check_name.replace(reg,'');
	if(contains(check_name," ")) {
		textError.setContent("No space please for run name!!!");
		myError.show();
		return;
	}

	var check_des = selrunDes.toString();
	var reg =new RegExp("\t","g");
	check_des =check_des.replace(reg,'');
	var alphanum= /^[a-zA-Z0-9-_ \.\>]*$/;
	if (check_des.search(alphanum) == -1) {
		textError.setContent("Enter a run Description with no accent");
		myError.show();
		return;
	}

	var url_insert = url_path + "/manageData.pl?option=upRun" +
						"&run=" + selrun +
						"&name=" + selrunName +
						"&description="+ selrunDes +
						"&pltrun=" + selrunPlt;
	var res=sendData_v2(url_insert);
	res.addCallback(
		function(response) {
			if(response.status=="OK"){
				refreshOneRun();
			}
		}
	);
}

function upPatient(fromproject) {
	if (fromproject) {
		updatePatient(fromproject,patientprojectGrid)
	} else {
		updatePatient(fromproject,patGrid)
	}
}

function updatePatient(fromproject,grid){
	var item = grid.selection.getSelected();
	selrun = document.getElementById("SrunId").innerHTML;
	var RunGroups = new Array();
	var PatIdGroups = new Array();
	var PatNameGroups = new Array();
	var ProjectGroups = new Array();
	var ProjectCurrentGroups = new Array();
	var groupGroups = new Array();
	var FamilyGroups = new Array();
	var FatherGroups = new Array();
	var MotherGroups = new Array();
	var PatSexGroups = new Array();
	var PatStatusGroups = new Array();
	var desPatGroups = new Array();
	var PatBCGroups = new Array();
	var PatBC2Groups = new Array();
	var PatBCGGroups = new Array();
	var flowcellGroups = new Array();
	var captureGroups = new Array();
	var machineGroups = new Array();
	var plateformGroups = new Array();
	var methseqGroups = new Array();
	var AlnGroups = new Array();
	var CallGroups = new Array();
	var OthersGroups = new Array();
	var cdateGroups = new Array();
	var FreeRunGroups = new Array();
	var typeGroups = new Array();
	var personGroups = new Array();

	if (item.length) {
		dojo.forEach(item, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = grid.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatIdGroups.push(Patvalue);
					} else if (attribute == "patientName" ) {
						PatNameGroups.push(Patvalue.toString());
					} else if (attribute == "ProjectName") {
						ProjectGroups.push(Patvalue.toString());
					} else if (attribute == "ProjectCurrentName") {
						ProjectCurrentGroups.push(Patvalue.toString());
					} else if (attribute == "group" ) {
						groupGroups.push(Patvalue.toString());
					} else if (attribute == "family" ) {
						FamilyGroups.push(Patvalue.toString());
					} else if (attribute == "father" ) {
						FatherGroups.push(Patvalue.toString());
					} else if (attribute == "mother" ) {
						MotherGroups.push(Patvalue.toString());
					} else if (attribute == "Sex" ) {
						PatSexGroups.push(Patvalue.toString());
					} else if (attribute == "Status" ) {
						PatStatusGroups.push(Patvalue.toString());
					} else if (attribute == "desPat" ) {
						desPatGroups.push(Patvalue.toString());
					} else if (attribute == "bc" ) {
						PatBCGroups.push(Patvalue.toString());
					} else if (attribute == "bc2" ) {
						PatBC2Groups.push(Patvalue.toString());
					} else if (attribute == "iv" ) {
						PatBCGGroups.push(Patvalue.toString());
					} else if (attribute == "flowcell" ) {
						flowcellGroups.push(Patvalue.toString());
					} else if (attribute == "capName" ) {
						captureGroups.push(Patvalue.toString());
					} else if (attribute == "machine" ) {
						machineGroups.push(Patvalue.toString());
					} else if (attribute == "Plateform" ) {
						plateformGroups.push(Patvalue.toString());
					} else if (attribute == "methseq" ) {
						methseqGroups.push(Patvalue.toString());
					} else if (attribute == "MethAln" ) {
						AlnGroups.push(Patvalue.toString());
					} else if (attribute == "MethSnp" ) {
						CallGroups.push(Patvalue.toString());
					} else if (attribute == "MethPipe" ) {
						OthersGroups.push(Patvalue.toString());
					} else if (attribute == "cDate" ) {
						cdateGroups.push(Patvalue.toString());
					} else if (attribute == "RunId" ) {
						RunGroups.push(Patvalue.toString());
					} else if (attribute == "type" ) {
						typeGroups.push(Patvalue.toString());
					} else if (attribute == "p_personName" ) {
						personGroups.push(Patvalue.toString());
					}
					if (attribute == "FreeRun" ) {
						FreeRunGroups.push(Patvalue.toString());
					}
				});
			} 
		});
	}

	if(item.length==0) {
		textError.setContent("<b>Select</b> rows , <b>Double Click</b> on each field to Edit, then Click on <b>Save</b> to Valid");
		myError.show();
		return;
	}
//############ Error Patient Name #########################
	var ErrorPatName=[];
	dojo.forEach(PatNameGroups, function(item, index){
		if (item.length == 0){
			ErrorPatName.push(index);
			return;
		}
	});
	if(ErrorPatName != "") {
		textError.setContent("Please Enter a <b>Patient Name</b>");
		myError.show();
		return;
	}
	dojo.forEach(PatNameGroups, function(item, index){
		if (item.length > 45){
			ErrorPatName.push(item);
			return;
		}
	});
	if(ErrorPatName != "") {
		textError.setContent("Max Length exceeded <b>[max=45]</b> for Patient Name: "+ErrorPatName);
		myError.show();
		return;
	}
//############ Choice New or Update Patient #########################
	var choiceUp=[];
	var addRowPat=[];
	dojo.forEach(cdateGroups, function(item, index){
		var maj;
		if (item.length == 0){
			// Obsolete : $fieldCh[$i] eq "A" ==> updatePatient choice="A" maj="A" in addRow replace by addpatient
			addRowPat.push(PatNameGroups[index]);
			maj="A";
		} else {
			maj="U";
		}
		choiceUp.push(maj);
	});
//################## Error Project ##############################//
// Error Project empty
	var ErrorProjectEmpty=[];
	var Index;
	dojo.forEach(PatNameGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(ProjectGroups, function(item, index){
			if(index == Index) {
				var item1=item;
				dojo.forEach(ProjectCurrentGroups, function(item, index){
					if(index == Index) {
						if(!item && !item1) {
							ErrorProjectEmpty.push(item0);
						}
					}
				});
			}
		});
	});
	if(ErrorProjectEmpty != "" && choiceUp.toString().indexOf("A") == -1) {
		if(PatNameGroups.length != cdateGroups.filter(Boolean).length) {
		textError.setContent("Please, <b>Save</b> first your selected new Patient: <b>"+addRowPat+"</b>");
			myError.show();
			return;
		}
		textError.setContent("<b>Projects Errors</b> for Patient: " + ErrorProjectEmpty + " <br> For each Patient, Get a Current or Traget Project from Buttons");
		myError.show();
		return;
	}

// Error Project on Parent
	var ErrorProject=[];
	var Index;	
	dojo.forEach(ProjectGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(FatherGroups, function(item, index){
			if(index == Index) {
				var res=checkProjectPatient(item,item0);
				if (res){
					var error=item + "(Father) ";
					ErrorProject.push(error);
				}
			}
		});
	});

	var Index;	
	dojo.forEach(ProjectCurrentGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(FatherGroups, function(item, index){
			if(index == Index) {
				var res=checkProjectPatient(item,item0);
				if (res){
					var error=item + "(Father) ";
					ErrorProject.push(error);
				}
			}
		});
	});

	var Index;
	dojo.forEach(ProjectGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(MotherGroups, function(item, index){
			if(index == Index) {
				var res=checkProjectPatient(item,item0);
				if (res){
					var error=item + "(Mother) ";
					ErrorProject.push(error);
				}
			}
		});
	});
	var Index;
	dojo.forEach(ProjectCurrentGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(MotherGroups, function(item, index){
			if(index == Index) {
				var res=checkProjectPatient(item,item0);
				if (res){
					var error=item + "(Mother) ";
					ErrorProject.push(error);
				}
			}
		});
	});

	if(ErrorProject != "") {
		textError.setContent("<b>Projects Errors</b> for Patient: " + ErrorProject + " <br> Please check Project should be the same at each members of a family");
		myError.show();
		return;
	}

// function checkProjectPatient
	function checkProjectPatient(Pat,Proj){
		var selName;
		var selProj;
		var selProjCurrent;
		var retName;
		dojo.forEach(grid._by_idx, function(item, index){
			var selectedItem = grid.getItem(index);
			dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
				var Pvalue = grid.store.getValues(selectedItem, attribute);
				if (attribute == "patientName" ) {
 					selName = Pvalue;
 				} else if (attribute == "ProjectName" ) {
 					selProj = Pvalue;
 				} else if (attribute == "ProjectCurrentName" ) {
 					selProjCurrent = Pvalue;
 				}
			});
			if (selName==Pat) {
				if (selProj != Proj && selProjCurrent != Proj) {
					retName=selName;
					return;
				}
			}
		});
		return retName;		
	};

//################## Error Parent Family ##############################//
// Controle  Family from FatherGroups & MotherGroups
	var ErrorFamily=[];
	var Index;
	dojo.forEach(FatherGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(FamilyGroups, function(item, index){
			if(index == Index) {
				var res=checkFamily(item0,item);
				if (res){
					var error=item0 + "(Father) ";
					ErrorFamily.push(error);
				}
			}
		});
	});
	var Index;
	dojo.forEach(MotherGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(FamilyGroups, function(item, index){
			if(index == Index) {
				var res=checkFamily(item0,item);
				if (res){
					var error=item0 + "(Mother) ";
					ErrorFamily.push(error);
				}
			}
		});
	});

// Controle  Family from Patient
	var Index;
	dojo.forEach(PatNameGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(FamilyGroups, function(item, index){
			if(index == Index) {
				var res=checkFatherFamily(item0,item);
				if (res){
					var error=item0 + "(Father) ";
					ErrorFamily.push(error);
				}
				var res1=checkMotherFamily(item0,item);
				if (res1){
					var error=item0 + "(Mother) ";
					ErrorFamily.push(error);
				}
			}
		});
	});

	if(ErrorFamily != "") {
		textError.setContent("<b>Family Errors</b> for Patient: " + ErrorFamily.unique() + " <br> Please check Family Patient according to Father and Mother of each selection");
		myError.show();
		return;
	}
// function checkFamily checkFatherFamily checkMotherFamily
	function checkFamily(Pat,Fam){
		var selName;
		var selFam;
		var retName;
		dojo.forEach(grid._by_idx, function(item, index){
			var selectedItem = grid.getItem(index);
			dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
				var Pvalue = grid.store.getValues(selectedItem, attribute);
				if (attribute == "patientName" ) {
 					selName = Pvalue;
 				} else if (attribute == "family" ) {
 					selFam = Pvalue;
 				}
			});

			if (selName==Pat) {
				if (selFam != Fam) {
					retName=selName;
					return;
				}
			}
		});
		return retName;		
	};

	function checkFatherFamily(Pat,Fam){
		var selName;
		var selFam;
		var retName;
		dojo.forEach(grid._by_idx, function(item, index){
			var selectedItem = grid.getItem(index);
			dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
				var Pvalue = grid.store.getValues(selectedItem, attribute);
				if (attribute == "father" ) {
 					selName = Pvalue;
 				}
				else if (attribute == "family" ) {
 					selFam = Pvalue;
 				}
			});
			if (selName==Pat) {
				if (selFam != Fam) {
					retName=selName;
					return;
				}
			}
		});
		return retName;		
	};

	function checkMotherFamily(Pat,Fam){
		var selName;
		var selFam;
		var retName;
		dojo.forEach(grid._by_idx, function(item, index){
			var selectedItem = grid.getItem(index);
			dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
				var Pvalue = grid.store.getValues(selectedItem, attribute);
				if (attribute == "mother" ) {
 					selName = Pvalue;
 				} else if (attribute == "family" ) {
 					selFam = Pvalue;
 				}
			});
			if (selName==Pat) {
				if (selFam != Fam) {
					retName=selName;
					return;
				}
			}
		});
		return retName;		
	};
//################## Error Parent Name ##############################//
	var Index;
	var ErrorParent=[];
	dojo.forEach(PatNameGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(FatherGroups, function(item, index){
			if(index == Index) {
				var item1=item;
				dojo.forEach(MotherGroups, function(item, index){
					if(index == Index) {
						var item2=item;
						if (item1=="" && item2=="") {
						} else if( item0 == item1 || item0 == item2 || item1 == item2) {
							ErrorParent.push(item0.toString());
							return;
						}
					}					
				});
			}
		});
			
	});
	if(ErrorParent != "") {
		textError.setContent("<b>Pedigree Errors</b> on patient :" + ErrorParent + " <br> Please check name for Patient,Father and Mother of each selection");
		myError.show();
		return;
	}
//################## Error Sex Mother & Father ##############################//
// Error Sex Mother
	var ErrorSexMother=[];
	var indexN;
	dojo.forEach(PatNameGroups, function(item, index){
		var itemN=item;
		indexN=index;
		dojo.forEach(MotherGroups, function(item, index){
			var itemSM=item;
			if(indexN == index) {
				var patSM=itemSM;
				if (patSM) {
					var res=checkSex(patSM,2);
					if (res){
						ErrorSexMother.push(patSM);
					}
				} else {
					dojo.forEach(PatSexGroups, function(item, index){
						if(indexN == index) {
							if(item != 2 ) {
								var res1=checkMother(itemN);
								if (res1){
									ErrorSexMother.push(itemN);
								}
							}
						}
					});
				}
			}
		});
	});
	if(ErrorSexMother != "") {
		textError.setContent("<b>Sex Error</b> for Mother :" + ErrorSexMother.unique());
		myError.show();
		return;
	}

// Error Sex Father
	var ErrorSexFather=[];
	var indexN;
	dojo.forEach(PatNameGroups, function(item, index){
		var itemN=item;
		indexN=index;
		dojo.forEach(FatherGroups, function(item, index){
			var itemSF=item;
			if(indexN == index) {
				var patSF=itemSF;
				if (patSF) {
					var res=checkSex(patSF,1);
					if (res){
						ErrorSexFather.push(patSF);
					}
				} else {
					dojo.forEach(PatSexGroups, function(item, index){
						if(indexN == index) {
							if(item != 1 ) {
								var res1=checkFather(itemN);
								if (res1){
									ErrorSexFather.push(itemN);
								}
							}
						}
					});
				}
			}
		});
	});
	if(ErrorSexFather != "") {
		textError.setContent("<b>Sex Error</b> for Father :" + ErrorSexFather.unique());
		myError.show();
		return;
	}

// function checkSex checkFather checkMother
	function checkSex(patSM,sex){
		var selName;
		var selSex;
		var retName;
		dojo.forEach(grid._by_idx, function(item, index){
			var selectedItem = grid.getItem(index);
			dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
				var Pvalue = grid.store.getValues(selectedItem, attribute);
				if (attribute == "patientName" ) {
 					selName = Pvalue;
 				} else if (attribute == "Sex" ) {
 					selSex = Pvalue;
 				}
			});
			if (selName==patSM) {
				if ((sex == 2 && selSex == 1) || (sex == 2 && selSex == 0)) {
					retName=selName;
					return;
				}
				if ((sex == 1 && selSex == 2) || (sex == 1 && selSex == 0)) {
					retName=selName;
					return;
				}
			}
		});
		return retName;
	};

	function checkFather(Pat){
		var selName;
		var retName;
//		dojo.forEach(grid._by_idx, function(item, index){
		dojo.forEach(grid._by_idty, function(item, index){
			var selectedItem = grid.getItem(index);
			dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
				var Pvalue = grid.store.getValues(selectedItem, attribute);
				if (attribute == "father" ) {
 					selName = Pvalue;
 				}
			});
			if (selName==Pat) {
				retName=selName;
				return;
			}
		});
		return retName;		
	};

	function checkMother(Pat){
		var selName;
		var retName;
		dojo.forEach(grid._by_idx, function(item, index){
			var selectedItem = grid.getItem(index);
			dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute) {
				var Pvalue = grid.store.getValues(selectedItem, attribute);
				if (attribute == "mother" ) {
 					selName = Pvalue;
 				}
			});
			if (selName==Pat) {
				retName=selName;
				return;
			}
			
		});
		return retName;		
	};
//################## Error Machine ##############################//
	if(machineGroups.unique().length>1) {
		textError.setContent("Please Use only <b>One Machine Name per Run</b><br>To change Machine Name, select Only one patient");		
		myError.show();
		return;
	}
	var ErrorMachine=[];
	dojo.forEach(machineGroups, function(item, index){
		if (item.length == 0){
			ErrorMachine.push(index);
			return;
		}
	});
	if(ErrorMachine != "") {
		textError.setContent("Please Enter a <b>Machine Name</b>");
		myError.show();
		return;
	}
//################## Error Plateform  ##############################//
// Only One Plateform allowed (Run -> Run_Plateform)
	if(plateformGroups.unique().length>1) {
		textError.setContent("Please Use only <b>One Plateform Name per Run</b><br>To change Plateform Name, select Only one patient");		
		myError.show();
		return;
	}
	var ErrorPlateform=[];
	dojo.forEach(plateformGroups, function(item, index){
		if (item.length == 0){
			ErrorPlateform.push(index);
			return;
		}
	});
	if(ErrorPlateform != "") {
		textError.setContent("Please Enter a <b>Plateform Name</b>");
		myError.show();
		return;
	}
//################## Error MethSeq  ##############################//
// Only One Methseq allowed (Run -> Run_Method_seq)
	if(methseqGroups.unique().length>1) {
		textError.setContent("Please Use only <b>One Sequencing Method per Run</b><br>To change Sequencing Method Name, select Only one patient");		
		myError.show();
		return;
	}
	var ErrorMethSeq=[];
	dojo.forEach(methseqGroups, function(item, index){
		if (item.length == 0){
			ErrorMethSeq.push(index);
			return;
		}
	});
	if(ErrorMethSeq != "") {
		textError.setContent("Please Enter a <b>Sequencing Method</b>");
		myError.show();
		return;
	}
//################## Error Capture  ##############################//
	var ErrorCapture=[];
	dojo.forEach(captureGroups, function(item, index){
		if (item.length == 0){
			ErrorCapture.push(index);
			return;
		}
	});
	if(ErrorCapture != "") {
		textError.setContent("Please Enter an <b>Exon Capture</b>");
		myError.show();
		return;
	}
//################## Error Method ALN Call  ##############################//
	var ErrorAln=[];
	dojo.forEach(AlnGroups, function(item, index){
		if (item.length == 0){
			ErrorAln.push(index);
			return;
		}
	});
	if(ErrorAln != "") {
		textError.setContent("Please Enter an <b>Alignment Method</b>");
		myError.show();
		return;
	}

	var ErrorCall=[];
	dojo.forEach(CallGroups, function(item, index){
		if (item.length == 0){
			ErrorCall.push(index);
			return;
		}
	});
	if(ErrorCall != "") {
		textError.setContent("Please Enter an <b>Calling Method</b>");
		myError.show();
		return;
	}

// ################## Error BC & BC2
	var ErrorBC=[];
	var Index;
	dojo.forEach(PatNameGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(PatBCGroups, function(item, index){
			if(index == Index) {
				if(item==0) {
					ErrorBC.push(item0);
				}
			}
		});
	});
	var ErrorBC2=[];
	var Index;
	dojo.forEach(PatNameGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(PatBC2Groups, function(item, index){
			if(index == Index) {
				if(item==0) {
					ErrorBC2.push(item0);
				}
			}
		});
	});

// ################## Error BC genotype / Identity Vigilance
	var ErrorBCG=[];
	var Index;
	dojo.forEach(PatNameGroups, function(item, index){
		var item0=item;
		Index=index;
		dojo.forEach(PatBCGGroups, function(item, index){
			if(index == Index) {
				if(item==0) {
					ErrorBCG.push(item0);
				}
			}
		});
	});
//##### if no family, family name= patient name

	for(var i=0; i<PatNameGroups.length;i++ )
 	{  
		for(var j=0; j<FamilyGroups.length;j++ )
		{
			if(i==j) {
				if (FamilyGroups[j]=="") {
					FamilyGroups[j]=PatNameGroups[i];
				}
			}
		}
	}
	var selproj=0;
	var reg =new RegExp("NGSRun","g");
	for(var i=0; i<ProjectGroups.length;i++ )
 	{  
  		if(ProjectGroups[i]=="NGSRun")
  		ProjectGroups.splice(i,1,"");  
  	}  
	var partial=0;
	if (fromproject) {
		partial=1;
		selrun= RunGroups;
	}

	AlnGroups=AlnGroups.toString().replace(/ /g,":");
	CallGroups=CallGroups.toString().replace(/ /g,":");
	OthersGroups=OthersGroups.toString().replace(/ /g,":");
	var url_insert = url_path + "/manageData.pl?option=upPatient" +
						"&partial=" + partial +
						// Obsolete : $fieldCh[$i] eq "A" ==> updatePatient choice="A" maj="A" in addRow replace by addpatient
						"&choice=" + choiceUp +
						"&run=" + selrun +
//						"&project=" + selproj +
						"&projname=" + ProjectGroups +
						"&currentprojname=" + ProjectCurrentGroups +
						"&PatIdSel=" + PatIdGroups +
						"&family=" + FamilyGroups +			
						"&father=" + FatherGroups +
						"&mother=" + MotherGroups +
						"&sex="+ PatSexGroups +
						"&status="+ PatStatusGroups +
						"&desPat="+ desPatGroups +
						"&bc="+ PatBCGroups +
						"&bc2="+ PatBC2Groups +
						"&iv="+ PatBCGGroups +
						"&flowcell=" + flowcellGroups +
						"&capture=" + captureGroups +
						"&machine=" + machineGroups.unique() +
						"&plateform=" + plateformGroups.unique() +
						"&methseq=" + methseqGroups.unique() +
						"&aln="+ AlnGroups +
						"&call="+ CallGroups +
						"&others="+ OthersGroups +
						"&PatNameSel=" + PatNameGroups +
						"&personSel=" + personGroups +
						"&type=" + typeGroups +
						"&GroupNameSel=" + groupGroups;

	var param="&partial=" + partial +
	// Obsolete : $fieldCh[$i] eq "A" ==> updatePatient choice="A" maj="A" in addRow replace by addpatient
		"&choice=" + choiceUp +
		"&run=" + selrun +
//		"&project=" + selproj +
		"&projname=" + ProjectGroups +
		"&currentprojname=" + ProjectCurrentGroups +
		"&PatIdSel=" + PatIdGroups +
		"&family=" + FamilyGroups +			
		"&father=" + FatherGroups +
		"&mother=" + MotherGroups +
		"&sex="+ PatSexGroups +
		"&status="+ PatStatusGroups +
		"&desPat="+ desPatGroups +
		"&bc="+ PatBCGroups +
		"&bc2="+ PatBC2Groups +
		"&iv="+ PatBCGGroups +
		"&flowcell=" + flowcellGroups +
		"&capture=" + captureGroups +
		"&machine=" + machineGroups.unique() +
		"&plateform=" + plateformGroups.unique() +
		"&methseq=" + methseqGroups.unique() +
		"&aln="+ AlnGroups +
		"&call="+ CallGroups +
		"&others="+ OthersGroups +
		"&PatNameSel=" + PatNameGroups +
		"&personSel=" + personGroups +
		"&type=" + typeGroups +
		"&GroupNameSel=" + groupGroups;

	var prog_url=url_path + "/manageData.pl";
	var options="option=upPatient" + param;

	var res=senDataExtendedPost(prog_url,options,PatNameGroups,PatSexGroups);
	res.addCallback(
		function(response) {
			if (response.status=="OK") {
				dijit.byId("personDialog").reset();
				dijit.byId("personDialog").hide();
				reloadPatient(PatNameGroups,PatSexGroups);
				if (fromproject) {
					refreshPatientProject();
				} else {
					refreshPatRun();
				}
			} else if (response.status=="Extended") {
				if (response.extend) {				
					if (Array.isArray(selrun)) {selrun=selrun.unique()}
					initProposalName(response,selrun,prog_url,options,PatNameGroups,PatSexGroups);
				};
			}
		}
	);
}

/*###################### Delete Patient ##################*/
function delPat2Run() {	
	selrun = document.getElementById("SrunId").innerHTML;
	var itemR = patGrid.selection.getSelected();
	var PatGroups = new Array();
	var PatNameGroups = new Array();
	var FatherGroups = new Array();
	var MotherGroups = new Array();
	var PatSexGroups = new Array();
	var MethGroups = new Array(); 
	var PatFreeGroups = new Array();
	var ProjectGroups = new Array();
	var ProjectCurrentGroups = new Array();
	var FreeGroups = [];
	if (itemR.length) {
		dojo.forEach(itemR, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(patGrid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = patGrid.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatGroups.push(Patvalue);
					} else if (attribute == "patientName" ) {
						PatNameGroups.push(Patvalue.toString());
					} else if (attribute == "father" ) {
						FatherGroups.push(Patvalue.toString());
					} else if (attribute == "mother" ) {
						MotherGroups.push(Patvalue.toString());
					} else if (attribute == "Sex" ) {
						PatSexGroups.push(Patvalue.toString());
					} else if (attribute == "MethSnp" ) {
						MethGroups.push(Patvalue.toString());
					} else if (attribute == "MethAln" ) {
						MethGroups.push(Patvalue.toString());
					}
					if (attribute == "FreeRun" ) {
						PatFreeGroups.push(Patvalue.toString());
					}
				});
			} 
		});
	}
//################## Error Parent Name ##############################//
	var ErrorParentFather=[];
	var ErrorParentMother=[];
	dojo.forEach(PatNameGroups, function(item, index){
		var res1=checkFather(item);
		if (res1){
			ErrorParentFather.push(item);
		}

	});
	dojo.forEach(PatNameGroups, function(item, index){
		var res2=checkMother(item);
		if (res2){
			ErrorParentMother.push(item);
		}

	});
	if(ErrorParentFather != "") {
		textError.setContent("<b>Not Deleted</b> because of patient Father :" + ErrorParentFather.unique());
		myError.show();
		return;
	}

	if(ErrorParentMother != "") {
		textError.setContent("<b>Not Deleted</b> because of patient Mother :" + ErrorParentMother.unique());
		myError.show();
		return;
	}

	function checkFather(Pat){
		var selName;
		var retName;
		dojo.forEach(patGrid._by_idx, function(item, index){
			var selectedItem = patGrid.getItem(index);
			dojo.forEach(patGrid.store.getAttributes(selectedItem), function(attribute) {
				var Pvalue = patGrid.store.getValues(selectedItem, attribute);
				if (attribute == "father" ) {
 					selName = Pvalue;
 				}
			});
			if (selName==Pat) {
				retName=selName;
				return;
			}
		});
		return retName;		
	};

	function checkMother(Pat){
		var selName;
		var retName;
		dojo.forEach(patGrid._by_idx, function(item, index){
			var selectedItem = patGrid.getItem(index);
			dojo.forEach(patGrid.store.getAttributes(selectedItem), function(attribute) {
				var Pvalue = patGrid.store.getValues(selectedItem, attribute);
				if (attribute == "mother" ) {
 					selName = Pvalue;
 				}
			});
			if (selName==Pat) {
				retName=selName;
				return;
			}
		});
		return retName;		
	};

//################## Error PatFreeGroups ##############################//
	if(contains(PatFreeGroups,"")) {
		textError.setContent("<b>Not Deleted</b> because Current Projet ou Target Project are assigned to patient");
		myError.show();
		return;
	}
	if(itemR.length==0) {
		textError.setContent("Please select lines !");
		myError.show();
		return;
	} else {
		var url_insert = url_path + "/manageData.pl?option=delPatient"+
						"&RunSel="+ selrun +
						"&PatSel="+PatGroups;
		var res=sendData_v2(url_insert);
		res.addCallback(
			function(response) {
				if(response.status=="OK"){
					patGrid.store.save();
					patGrid.store.close();
					patGrid.setStore(genomicRunPatStore);
					patGrid.selection.clear();
					reloadPatient(PatNameGroups,PatSexGroups);
					refreshPatRun();
				}
			}
		);
	}
}

/*########################################################################
##################### Add Methods
##########################################################################*/
function showMethods(){
	var itemPat = patGrid.selection.getSelected();
	var PatIdGroups = new Array();
	var PatNameGroups = new Array();
	var SelRunId = new Array();

	if (itemPat.length) {
		dojo.forEach(itemPat, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(patGrid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = patGrid.store.getValues(selectedItem, attribute);
					if (attribute == "RunId" ) {
						SelRunId = Patvalue.toString();
					}
				});
			} 			
		});
	} else  {
		textError.setContent("Please select one or more Patients !");
		myError.show();
		return;
	}
	var CP_addmethpat = dojo.byId("ADDMETHPATrunId");
	CP_addmethpat.innerHTML= SelRunId;
	b_pipelinefilterSelect.set('store',pipelineNameStore);
	b_pipelinefilterSelect.startup();
	b_alnRGrid.setStore(AlnStore);
	b_callRGrid.setStore(CallStore);
	b_otherRGrid.setStore(OtherStore);
	var desFormvalue = dijit.byId("b_desForm").getValues();
	var checkDefbMaln=desFormvalue.b_maln_defbox;

	filterDefGrid("bMAln",b_alnRGrid,1);
	dojo.connect(dijit.byId("b_maln_defbox"), 'onChange', function(checked){
			if (checked==true) {checkDefbMaln=1;} else {checkDefbMaln=0;}
			filterDefGrid("bMAln",b_alnRGrid,checkDefbMaln);
	});

	filterDefGrid("bMCall",b_callRGrid,1);
	dojo.connect(dijit.byId("b_mcall_defbox"), 'onChange', function(checked){
		if (checked==true) {checkDefbMcall=1;} else {checkDefbMcall=0;}
		filterDefGrid("bMCall",b_callRGrid,checkDefbMcall);
	});

	addMetodsToPatientDialog.show();

	dijit.byId('b_alnRGrid').selection.clear();
	dijit.byId('b_callRGrid').selection.clear();
	dijit.byId('b_otherRGrid').selection.clear();
}

function addMethodsToPatient(){
	var itemPat = patGrid.selection.getSelected();
	var PatIdGroups = new Array();
	var PatNameGroups = new Array();
	var SelRunId = new Array();
	if (itemPat.length) {
		dojo.forEach(itemPat, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(patGrid.store.getAttributes(selectedItem), function(attribute) {
					var Patvalue = patGrid.store.getValues(selectedItem, attribute);
					if (attribute == "PatId" ) {
						PatIdGroups.push(Patvalue.toString());
					}
					else if (attribute == "patientName" ) {
						PatNameGroups.push(Patvalue.toString());
					}
					else if (attribute == "RunId" ) {
						SelRunId = Patvalue.toString();
					}
				});
			} 			
		});
		addMethods2Patient(PatIdGroups,PatNameGroups,SelRunId);
	}
}

function addMethods2Patient(patId,patName,runId){
// Pipeline Method
	var btn=0;
	var filterRes=0;
	if(dijit.byId("b_btn_pipe").get("checked")) {
		btn=1;
		filterRes = dijit.byId("b_pipelineName").item.value;
	}
//Alignment Method field
	var itemAln = b_alnRGrid.selection.getSelected();
	var AlnGroups = new Array(); 
	if (! btn) {
		if (itemAln.length) {
			dojo.forEach(itemAln, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(b_alnRGrid.store.getAttributes(selectedItem), function(attribute) {
						var Alnvalue = b_alnRGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methName" ) {
							AlnGroups.push(Alnvalue);
							return AlnGroups;
						}
					});
				}
			});
		} else {
			textError.setContent("Select an Alignment method");
			myError.show();
			return;
		}
	}
//Method Call field
	var itemCall = b_callRGrid.selection.getSelected();
	var CallGroups = new Array(); 
	if (! btn) {
		if (itemCall.length) {
			dojo.forEach(itemCall, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(b_callRGrid.store.getAttributes(selectedItem), function(attribute) {
						var Callvalue = b_callRGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methName" ) {
							CallGroups.push(Callvalue);
							return CallGroups;
						}
					});
				}
			}); 
		} else {
			textError.setContent("Select a method call");
			myError.show();
			return;
		}
	}
//Method Other field
	var itemOthers = b_otherRGrid.selection.getSelected();
	var OthersGroups = new Array(); 
	if (! btn) {
		if (itemOthers.length) {
			dojo.forEach(itemOthers, function(selectedItem) {
				if (selectedItem !== null) {
					dojo.forEach(b_otherRGrid.store.getAttributes(selectedItem), function(attribute) {
						var Othersvalue = b_otherRGrid.store.getValues(selectedItem, attribute);
						if (attribute == "methName" ) {
							OthersGroups.push(Othersvalue);
							return OthersGroups;
						}
					});
				}
			}); 
		}
	}
	var prog_url=url_path + "/manageData.pl";
	var options="option=addMethodsToPatient" +
					"&RunSel="+ runId +
					"&patient="+ patName +
					"&patientid="+ patId;

	if (btn) {
		options=options	+ 
		"&method_pipeline="+ filterRes;
	} else {
		options=options	+ 
		"&method_align="+ AlnGroups +
		"&method_call="+ CallGroups +
		"&method_other="+ OthersGroups;
	}
	var res=senDataExtendedPost(prog_url,options);
	res.addCallback(
		function(response) {
			if (response.status=="OK") {
				refreshRunDoc(nostandby=1);
				preReloadPatient(runId);
				dijit.byId('addMetodsToPatientDialog').reset();
				dijit.byId('addMetodsToPatientDialog').hide();
			} 
		}
	);
}


/*########################################################################
					Filters
##########################################################################*/
var filterDataWord ={
	label: "name",
	identifier: 'value',
	items: [
		{value: "",name:""},
		{value: "name",name: "Project Name"},
		{value: "id",name: "Project ID"},
		{value: "runId",name: "run ID"},
		{value: "description",name: "Description"},
		{value: "Users",name: "User"},
		{value: "patName",name: "Patient"},
	]
}

var filterDataName ={
	label: "name",
	identifier: 'value',
	items: [
		{value: "",name:""},
		{value: "MethSnp",name:"Calling"},
		{value: "MethAln",name:"Alignment"},
		{value: "MethSeq",name:"MethSeq"},
		{value: "plateform",name:"Plateform"},
		{value: "macName",name:"Machine"},
		{value: "capName",name:"Capture"},
		{value: "capAnalyse",name:"Analyse"},
		{value: "Rel",name:"Release"},
		{value: "Site",name:"Site"},
		{value: "Unit",name:"Unit"},
	]
}

var filterValue;
dojo.addOnLoad(function() {
	siteStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=userList" +"&uniqSite"
	});

	unitStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/manageData.pl?option=userList" +"&uniqUnit"
	});

//	relStore = new dojo.data.ItemFileWriteStore({
	relStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=release"
	});

	relcapStore = new dojox.data.AndOrWriteStore({
		url: url_path + "/manageData.pl?option=release" +"&hascapture=1"
	});

//	reldefStore = new dojox.data.AndOrWriteStore({
//		url: url_path + "/manageData.pl?option=releasedef"
//	});

	relRefStore = new dojo.data.ItemFileWriteStore({
		url: url_path + "/manageData.pl?option=releaseRef"
	});


//	dojo.connect(dijit.byId("searchProjForm"),"onKeyPress",function(e) {  
	dojo.connect(dijit.byId("searchProjForm"),"onKeyDown",function(e) {  
//     intermediateChanges="true"   ==>  e.keyCode==0 Trop Lent : uniquement byEnter
//   		if (e.keyCode == dojo.keys.ENTER || e.keyCode==0) {
    		if (e.keyCode == dojo.keys.ENTER) {
			wordsearchProj();
		}
	}); 

});

function wordsearchProj() {
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
	filterValue=dijit.byId('FilterProjBox').get('value');
	filterValue = "'*" + filterValue + "*'";
		//grid.setQueryAfterLoading({complexQuery: "patName:"+filterValue+"OR Users:"+filterValue+"OR name:"+filterValue+"OR description:"+filterValue+"OR runId:"+filterValue+"OR capName:"+filterValue+"OR capAnalyse:"+filterValue+"OR patBC:"+filterValue+"OR UserGroups:"+filterValue}, {ignoreCase:true});
grid.setQueryAfterLoading({complexQuery: "patName:"+filterValue+"OR Users:"+filterValue+"OR name:"+filterValue+"OR description:"+filterValue+"OR runId:"+filterValue+"OR capName:"+filterValue+"OR capAnalyse:"+filterValue+"OR patBC:"+filterValue+"OR UserGroups:"+filterValue+"OR persId:"+filterValue+"OR persName:"+filterValue}, {ignoreCase:true});
	grid.store.fetch();
	grid.store.close();
	dijit.byId(grid)._refresh();
}

function resetSearchProj(grid) {
	var sliderFormvalue = dijit.byId("slider_proj").attr("value");
	dijit.byId('FilterProjBox').set('value',"");		   
	wordsearchProj(grid);
	grid.selection.clear();
}

function QuerydependProjSlider(projectId){
	var sliderFormvalue = dijit.byId("slider_proj").attr("value");
	var url_jsonStore="/manageProject.pl?";
	if (sliderFormvalue==1) {
		url_jsonStore+= "&numAnalyse=1";
	} else if (sliderFormvalue==2) {
		url_jsonStore+= "&numAnalyse=2";
	} else if (sliderFormvalue==3) {
		url_jsonStore+= "&numAnalyse=3";
	} else if (sliderFormvalue==4) {
		url_jsonStore+= "&numAnalyse=4";
	} else if (sliderFormvalue==5) {
		url_jsonStore+= "&numAnalyse=5";
	} else if (sliderFormvalue==6) {
		url_jsonStore+= "&numAnalyse=6";
	} else if (sliderFormvalue==7) {
		url_jsonStore+= "&numAnalyse=7";
	} else if (sliderFormvalue==8) {
		url_jsonStore+= "&numAnalyse=8";
	}

	if (projectId) {
		var libprojRStore = new dojo.data.ItemFileWriteStore({url: url_path + url_jsonStore + "&ProjSel=" + projectId});
		return libprojRStore;
	} else {
		var libprojRoWStore = new dojox.data.AndOrWriteStore({url: url_path + url_jsonStore});
		return libprojRoWStore;
	}
}

// phenotype
function initPhenotype() {
	require([
    		"dojo/_base/declare","dojo/_base/lang","dojo/_base/array","dojo/on","dojo/dom",
		"dojo/dom-class","dijit/registry",
		"dojo/store/Memory","dojo/store/Observable","dojo/data/ObjectStore",
		"dojox/form/CheckedMultiSelect"
	], function( declare,lang,array,on,dom,domClass,registry,Memory,Observable,DataStore,CheckedMultiSelect) 
		{
			var dataStore = new DataStore({
				objectStore:phenotypeStore,
				labelProperty:"label"
			});
			valphenotype="";
			var qphenotypeMultiSelect=registry.byId("phenotypeSelect_id");
			if(!qphenotypeMultiSelect ){
				qphenotypeMultiSelect = new MyCheckedMultiSelect({
					dropDown: true,
					id:"phenotypeSelect_id",
					store: phenotypeStore,
					multiple: true,
					labelAttr: "label",
					searchAttr:"label",
					sortByLabel: false,
					label: "Multiple Selection",
					onChange: function(item) {
						valphenotype=item.toString();

					}

				},"phenotypeSelect_id");
   				qphenotypeMultiSelect.startup();
			} else {
				qphenotypeMultiSelect.reset();
				qphenotypeMultiSelect._updateSelection();
			}
		}
	)
}

/*########################################################################
					END
##########################################################################*/

function contains(arr, findValue) {
    var i = arr.length;
     
    while (i--) {
       if (arr[i] === findValue) return true;
    }
    return false;
}

function launchPrint() {
	printDialog.show();
};

function standbyShow() {
	myStandby.show(); 
 	standby.show(); 
}

function standbyHide() {
	standby.hide();
	myStandby.hide();
};

function refreshPolyList(stand) {
	if (typeof(stand) == "undefined" ) {standbyShow();};
	jsonStore=QuerydependProjSlider();
	grid.setStore(jsonStore);
	if (typeof(stand) == "undefined" ) {grid.store.fetch({onComplete:standbyHide});};
	if (typeof(stand) != "undefined" ) {grid.store.fetch({});};
	grid.store.close();
	grid._refresh();
};

function refreshProjectRun() {
	var patientProjectStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=patientProject"+"&ProjSel="+ selProjId
	});
	patientprojectGrid.setStore(patientProjectStore);
	patientprojectGrid.store.close();
	dijit.byId(patientprojectGrid)._refresh();	
};

function refreshRunDoc() {
	if (!nostandby) {standbyHide();}
	if (!nostandby) {standbyShow();}
	QuerydependRunSlider();
	if (!nostandby) {gridRundoc.store.fetch({onComplete:standbyHide});}
	gridRundoc.store.close();
	dijit.byId(gridRundoc)._refresh();
	nostandby=0;
};

function refreshOneRun() {
	selrun = document.getElementById("SrunId").innerHTML;
	var url_runStore=init_url(SelRun=selrun);
	var onerunStore = new dojox.data.AndOrWriteStore({url: url_path + url_runStore});
	onerunGrid.setStore(onerunStore);
	onerunGrid.store.close();
	dijit.byId(onerunGrid)._refresh();
};

function refreshOneRunDoc() {	
	selrun = document.getElementById("SrunId").innerHTML;
	var url_runStore=init_url(SelRun=selrun);
	var onedocStore = new dojox.data.AndOrWriteStore({url: url_path + url_runStore});
	onedocGrid.setStore(onedocStore);
	onedocGrid.store.close();
	dijit.byId(onedocGrid)._refresh();
};

function QuerydependRunSlider(){
	var sliderFormvalue = dijit.byId("slider_run").attr("value");
	var url_runStore="/manageData.pl?option=allqRun";
	if (sliderFormvalue==1) {
		url_runStore+= "&numAnalyse=1";
	} else if (sliderFormvalue==2) {
		url_runStore+= "&numAnalyse=2";
	} else if (sliderFormvalue==3) {
		url_runStore+= "&numAnalyse=3";
	} else if (sliderFormvalue==4) {
		url_runStore+= "&numAnalyse=4";
	} else if (sliderFormvalue==5) {
		url_runStore+= "&numAnalyse=5";
	} else if (sliderFormvalue==6) {
		url_runStore+= "&numAnalyse=6";
	} else if (sliderFormvalue==7) {
		url_runStore+= "&numAnalyse=7";
	} else if (sliderFormvalue==8) {
		url_runStore+= "&numAnalyse=8";
	}

	runStore = new dojox.data.AndOrWriteStore({url: url_path + url_runStore});
	gridRundoc.setStore(runStore);
}

function reloadFather() {
	var xhrArgsF = {
       		url: url_path + "/manageData.pl?option=gpatientProjectDest"+"&Sex=1",
 		handleAs: "json",
		load: function (res) {
			initfatherStore = new dojo.store.Memory({data: res, idProperty: "patname"});
		}
	}
	var deferredF = dojo.xhrGet(xhrArgsF);
}

function reloadMother() {
	var xhrArgsM = {
       		url: url_path + "/manageData.pl?option=gpatientProjectDest"+"&Sex=2",
 		handleAs: "json",
		load: function (res) {
			initmotherStore = new dojo.store.Memory({data: res, idProperty: "patname"});
		}
	}
	var deferredM = dojo.xhrGet(xhrArgsM);
}

function reloadPatient(PatNameGroups,PatSexGroups,ProjectName) {
	dojo.forEach(PatNameGroups, function(item, index){
		var initm=initmotherStore.get(item);
		var m=motherStore.get(item);
		var initf=initfatherStore.get(item);
		var f=fatherStore.get(item);
	});
	var Index2;
	dojo.forEach(PatNameGroups, function(item, index){
		var item0=item;
		Index2=index;
		dojo.forEach(PatSexGroups, function(item, index){
			if(Index2 == index) {
				if (item == 1) {
					initfatherStore.query({patname:item0}).forEach(function(e,index){
//						if (ProjectName && e.projname=="NGSRun") {
						if (ProjectName) {
							e.projname=ProjectName.toString();
						}
						fatherStore.put({id:e.id, patproj:e.patproj, patname:e.patname, projectid:e.projectid, projname:e.projname});
						initmotherStore.remove(item0);
						motherStore.remove(item0);
					});
					initmotherStore.query({patname:item0}).forEach(function(e,index){
//						if (ProjectName && e.projname=="NGSRun") {
						if (ProjectName) {
							e.projname=ProjectName.toString();
						}
						fatherStore.put({id:e.id, patproj:e.patproj, patname:e.patname, projectid:e.projectid, projname:e.projname});
						initmotherStore.remove(item0);
						motherStore.remove(item0);
					});

				} 
				if (item == 2) {
					initmotherStore.query({patname:item0}).forEach(function(e,index){
//						if (ProjectName && e.projname=="NGSRun") {
						if (ProjectName) {
							e.projname=ProjectName.toString();
						}
						motherStore.put({id:e.id, patproj:e.patproj, patname:e.patname, projectid:e.projectid, projname:e.projname});
						initfatherStore.remove(item0);
						fatherStore.remove(item0);
					});
					initfatherStore.query({patname:item0}).forEach(function(e,index){
//						if (ProjectName && e.projname=="NGSRun") {
						if (ProjectName) {
							e.projname=ProjectName.toString();
						}
						motherStore.put({id:e.id, patproj:e.patproj, patname:e.patname, projectid:e.projectid, projname:e.projname});
						initfatherStore.remove(item0);
						fatherStore.remove(item0);
					});
				} 
			}
		});
	});
	reloadFather();
	reloadMother();
}

function refreshPatRun() {
	selrun = document.getElementById("SrunId").innerHTML;
	genomicRunPatStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=gpatient"+"&RunSel="+ selrun,
		clearOnClose: true,
	});
	patGrid.store.save();
	patGrid.store.close();
	patGrid.setStore(genomicRunPatStore);
	patGrid.sort();
	patGrid._refresh();
};


// Not used
function refreshProj() {	
	selrun = document.getElementById("SrunId").innerHTML;
	var RunPatStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=runProject"+"&RunSel=" + selrun
	});
	gridProjRun.setStore(RunPatStore);
	gridProjRun.store.close();
	dijit.byId(gridProjRun)._refresh();
};

function refreshPatientProject() {	
	var selProjId = document.getElementById("projUid").innerHTML;
	var patientProjectStore = new dojo.data.ItemFileWriteStore({
	        url: url_path + "/manageData.pl?option=patientProject"+"&ProjSel="+ selProjId,
		clearOnClose: true,
	});
	patientprojectGrid.setStore(patientProjectStore);
	patientprojectGrid.store.close();
	dijit.byId(patientprojectGrid)._refresh();

	var gotList = function(items, request){
		var NBRUN = 0;
		dojo.forEach(items, function(i){
			NBRUN += patientProjectStore.getValue(i,"Row");
		});
		if (NBRUN == 0) {
			dojo.style(dijit.byId("bt_delProject").domNode,{'visibility':'visible'});
			dojo.style(dijit.byId("bt_remPatientProject").domNode,{'visibility':'hidden'});
		} else {
			dojo.style(dijit.byId("bt_delProject").domNode,{'visibility':'hidden'});
			dojo.style(dijit.byId("bt_remPatientProject").domNode,{'visibility':'visible'});
		}
	}
	var gotError = function(error, request){
  		alert("Refresh Patient Project: The request to the store failed. " +  error);
	}
	patientProjectStore.fetch({
  		onComplete: gotList,
  		onError: gotError
	});
}

Array.prototype.unique = function()
{
    var tmp = {}, out = [];
    for(var i = 0, n = this.length; i < n; ++i)
    {
        if(!tmp[this[i]]) { tmp[this[i]] = true; out.push(this[i]); }
    }
    return out;
}

function changeHtml(value){
	var l = value.length;
	var s = value.indexOf(";");
	var res1 = value.substring(s+1,l);
			
	return"<"+res1;
}










