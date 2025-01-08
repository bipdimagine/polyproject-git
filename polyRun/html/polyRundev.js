/**
 * @author plaza
 */


require(["dijit/Dialog","dojo/data/ItemFileReadStore","dojo/data/ItemFileWriteStore","dojox/data/AndOrReadStore",
"dojox/data/AndOrWriteStore","dojo/parser", 
"dijit/layout/BorderContainer", "dijit/layout/ContentPane","dijit/layout/AccordionContainer",
"dijit/DropDownMenu","dijit/Menu","dijit/MenuItem", "dijit/MenuSeparator", "dijit/PopupMenuItem","dijit/form/ComboBox","dijit/form/CheckBox","dijit/form/RadioButton","dijit/form/Form",
"dijit/TitlePane","dijit/form/TextBox","dijit/form/Textarea","dojox/grid/cells/dijit",
"dijit/form/Button","dijit/form/FilteringSelect","dijit/form/ValidationTextBox","dojox/grid/DataGrid",
"dojox/grid/enhanced/plugins/Pagination","dojox/grid/EnhancedGrid","dojox/grid/enhanced/plugins/DnD",
"dojox/grid/enhanced/plugins/Menu","dojox/grid/enhanced/plugins/NestedSorting","dojox/grid/enhanced/plugins/IndirectSelection","dojox/grid/enhanced/plugins/Filter","dojox/grid/enhanced/plugins/exporter/CSVWriter",
"dojox/grid/enhanced/plugins/exporter/TableWriter","dojox/grid/enhanced/plugins/Printer",
"dojo/ready","dojo/store/Memory", "dijit/form/ComboBox", "dijit/registry",
"dojox/grid/LazyTreeGrid","dijit/tree/ForestStoreModel","dojox/grid/LazyTreeGridStoreModel",
"dojox/grid/TreeGrid","dojo/dom-style","dojo/dom","dojo/on","dojo/json",

"dojox/charting/Chart2D","dojox/charting/widget/Chart2D","dojox/charting/themes/PlotKit/blue",
"dojox/charting/widget/Legend","dojox/charting/widget/SelectableLegend",

"dojox/charting/plot2d/StackedAreas","dojox/charting/Chart","dojox/charting/axis2d/Default",
"dojox/charting/themes/Wetland","dojox/charting/plot2d/Lines","dojox/charting/action2d/Tooltip",
"dojox/charting/widget/Legend","dojox/gfx/utils",
"dojox/widget/Standby"

]);

var layoutRunCov = [
		{ field: "RunId",name: "Run",width: '5'},
		{ field: "pltRun", name: "Plateform Run", width: '8.5',styles:"text-align:left;white-space:nowrap;"},
		{ field: "nbpatient", name: "#Pat", width: '2.5'},
		{ field: "patient",name: "Patient",width: '15', formatter:colorCov},
		{ field: "project",name: "Project",width: '10', formatter:colorCov},
		{ field: "cov5",name: "%cov5",width: '5', formatter:colorCov},
		{ field: "cov15",name: "%cov15",width: '5', formatter:colorCov},
		{ field: "cov30",name: "%cov30",width: '5', formatter:colorCov},
		{ field: "cov99",name: "covMoy",width: '5', formatter:colorCov},
		{ field: "flagStat",name: "Stats",width: '3',styles:"text-align:center;",formatter:bulletStat},
];

var layoutRunStatOld= [
		{ field: "Row", name: "Row",get: getRow, width: '2'},
		{ field: "RunId",name: "Run",width: '3'},
		{ field: "pltRun", name: "Plateform Run", width: '8',styles:"text-align:left;white-space:nowrap;"},
		{ field: "ctrlstat",name: "<img align='top' src='icons/exclamation.png'>",width: '2', formatter:colorstatCov,filterable: false},
		{ field: "patient",name: "Patient",width: '15'},
		{ field: "project",name: "Project",width: '8'},
		{ field: "baitset", name: "Bait Set", width: '10'},
		{ field: "genomesize", name: "Genome <br>Size", width: '7'},
//baitterritory
//		{ field: "baitterritory", name: "Bait <br>Territory", width: '6'},
		{ field: "baitterritory", name: "Bait <br>Territory", width: '8'},
		{ field: "targetterritory", name: "Target <br>Territory", width: '6'},
		{ field: "baitdesignefficiency", name: "Bait<br>Design<br>Efficiency", width: '4'},	
		{ field: "totalreads", name: "Total <br>Reads", width: '6'},
		{ field: "pfreads", name: "PF Reads", width: '6'},
		{ field: "pfuniquereads", name: "PF Unique <br>Reads", width: '6'},
		{ field: "pctpfreads", name: "% PF <br>Reads", width: '4'},
		{ field: "pctpfuqreads", name: "% PF <br>UQ <br>Reads", width: '4'},
		{ field: "pfuqreadsaligned", name: "PF UQ <br>Reads <br>Aligned", width: '6'},
		{ field: "pctpfuqreadsaligned", name: "% PF UQ <br>Reads <br>Aligned", width: '4'},
		{ field: "pfbasesaligned", name: "PF <br>Bases <br>Aligned", width: '7'},
		{ field: "pfuqbasesaligned", name: "PF UQ <br>Bases <br>Aligned", width: '7'},
		{ field: "onbaitbases", name: "On Bait <br>Bases", width: '7'},
		{ field: "nearbaitbases", name: "Near Bait <br>Bases", width: '7'},
		{ field: "offbaitbases", name: "Off Bait <br>Bases", width: '7'},
		{ field: "ontargetbases", name: "On Target <br>Bases", width: '7'},
		{ field: "pctselectedbases", name: "% <br>Selected <br>Bases", width: '4'},
		{ field: "pctoffbait", name: "% Off<br> Bait", width: '4', formatter:colorStat},
		{ field: "onbaitvsselected", name: "On Bait vs <br>Selected", width: '6'},
		{ field: "meanbaitcoverage", name: "Mean Bait <br>Coverage", width: '7'},
		{ field: "meantargetcoverage", name: "Mean Target <br>Coverage", width: '7'},
		{ field: "mediantargetcoverage", name: "Median Target <br>Coverage", width: '7'},
		{ field: "pctusablebasesonbait", name: "% Usable <br>Bases<br> On Bait", width: '5'},
		{ field: "pctusablebasesontarget", name: "% Usable <br>Bases<br> On Target", width: '5'},
		{ field: "foldenrichment", name: "Fold <br>Enrichment", width: '8'},
		{ field: "zerocvgtargetspct", name: "%Zero <br>CVG <br>Targets", width: '4'},
		{ field: "pctexcdupe", name: "% Exc<br>Dupe", width: '4'},
		{ field: "pctexcmapq", name: "% Exc<br>Mapq", width: '4'},
		{ field: "pctexcbaseq", name: "% Exc<br>Baseq", width: '4'},
		{ field: "pctexcoverlap", name: "% Exc<br>Overlap", width: '4'},
		{ field: "pctexcofftarget", name: "% Exc<br>Off Target", width: '4'},
		{ field: "fold80basepenalty", name: "Fold 80 <br>Base Penalty", width: '6'},
		{ field: "pcttargetbases1x", name: "% Target <br>Bases<br> 1X", width: '4'},
		{ field: "pcttargetbases2x", name: "% Target <br>Bases<br> 2X", width: '4'},
		{ field: "pcttargetbases10x", name: "% Target <br>Bases<br> 10X", width: '4'},
		{ field: "pcttargetbases20x", name: "% Target <br>Bases<br> 20X", width: '4'},
		{ field: "pcttargetbases30x", name: "% Target <br>Bases<br> 30X", width: '4'},
		{ field: "pcttargetbases40x", name: "% Target <br>Bases<br> 40X", width: '4'},
		{ field: "pcttargetbases50x", name: "% Target <br>Bases<br> 50X", width: '4'},
		{ field: "pcttargetbases100x", name: "% Target <br>Bases<br> 100X", width: '4'},
		{ field: "hslibrarysize", name: "HS <br>Library <br>Size", width: '6'},
		{ field: "hspenalty10x", name: "HS <br>Penalty<br> 10X", width: '6'},
		{ field: "hspenalty20x", name: "HS <br>Penalty<br> 20X", width: '6'},
		{ field: "hspenalty30x", name: "HS <br>Penalty<br> 30X", width: '6'},
		{ field: "hspenalty40x", name: "HS <br>Penalty<br> 40X", width: '6'},
		{ field: "hspenalty50x", name: "HS <br>Penalty<br> 50X", width: '6'},
		{ field: "hspenalty100x", name: "HS <br>Penalty<br> 100X", width: '6'},
		{ field: "atdropout", name: "AT <br>Dropout", width: '7'},
		{ field: "gcdropout", name: "GC <br>Dropout", width: '7'},
		{ field: "hetsnpsensitivity", name: "HET SNP <br>Sensitivity", width: '6'},
		{ field: "hetsnpq", name: "HET SNP <br>Q", width: '6'},
		{ field: "sample", name: "Sample", width: '6'},
		{ field: "library", name: "Library", width: '6'},
		{ field: "readgroup", name: "Read <br>Group", width: '6'}
];




var layoutRunStat= [
		{ field: "Row", name: "Row",get: getRow, width: '2'},
		{ field: "RunId",name: "Run",width: '3'},
		{ field: "pltRun", name: "Plateform Run", width: '8',styles:"text-align:left;white-space:nowrap;"},
		{ field: "ctrlstat",name: "<img align='top' src='icons/exclamation.png'>",width: '2', formatter:colorstatCov,filterable: false},
		{ field: "patient",name: "Patient",width: '15'},
		{ field: "project",name: "Project",width: '8'},


		{ field: "BAIT_SET", name: "Bait Set", width: '10'},
		{ field: "GENOME_SIZE", name: "Genome <br>Size", width: '7'},
		{ field: "BAIT_TERRITORY", name: "Bait <br>Territory", width: '8'},
		{ field: "TARGET_TERRITORY", name: "Target <br>Territory", width: '6'},
		{ field: "BAIT_DESIGN_EFFICIENCY", name: "Bait<br>Design<br>Efficiency", width: '4'},	
		{ field: "TOTAL_READS", name: "Total <br>Reads", width: '6'},
		{ field: "PF_READS", name: "PF Reads", width: '6'},
		{ field: "PF_UNIQUE_READS", name: "PF Unique <br>Reads", width: '6'},
		{ field: "PCT_PF_READS", name: "% PF <br>Reads", width: '4'},
		{ field: "PCT_PF_UQ_READS", name: "% PF <br>UQ <br>Reads", width: '4'},
		{ field: "PF_UQ_READS_ALIGNED", name: "PF UQ <br>Reads <br>Aligned", width: '6'},
		{ field: "PCT_PF_UQ_READS_ALIGNED", name: "% PF UQ <br>Reads <br>Aligned", width: '4'},
		{ field: "PF_BASES_ALIGNED", name: "PF <br>Bases <br>Aligned", width: '8'}, //supp nouv
		{ field: "PF_UQ_BASES_ALIGNED", name: "PF UQ <br>Bases <br>Aligned", width: '8'},
		{ field: "ON_BAIT_BASES", name: "On Bait <br>Bases", width: '7'},
		{ field: "NEAR_BAIT_BASES", name: "Near Bait <br>Bases", width: '7'},
		{ field: "OFF_BAIT_BASES", name: "Off Bait <br>Bases", width: '7'},
		{ field: "ON_TARGET_BASES", name: "On Target <br>Bases", width: '7'},
		{ field: "PCT_SELECTED_BASES", name: "% <br>Selected <br>Bases", width: '4'},
		{ field: "PCT_OFF_BAIT", name: "% Off<br> Bait", width: '4', formatter:colorStat},
		{ field: "ON_BAIT_VS_SELECTED", name: "On Bait vs <br>Selected", width: '6'},
		{ field: "MEAN_BAIT_COVERAGE", name: "Mean Bait <br>Coverage", width: '7'},
		{ field: "MEAN_TARGET_COVERAGE", name: "Mean Target <br>Coverage", width: '7'},
		{ field: "MEDIAN_TARGET_COVERAGE", name: "Median Target <br>Coverage", width: '7'}, //supp nouv
		{ field: "PCT_USABLE_BASES_ON_BAIT", name: "% Usable <br>Bases<br> On Bait", width: '5'},
		{ field: "PCT_USABLE_BASES_ON_TARGET", name: "% Usable <br>Bases<br> On Target", width: '5'},
		{ field: "FOLD_ENRICHMENT", name: "Fold <br>Enrichment", width: '8'},
		{ field: "ZERO_CVG_TARGETS_PCT", name: "%Zero <br>CVG <br>Targets", width: '4'}, // c'est %
		{ field: "PCT_EXC_DUPE", name: "% Exc<br>Dupe", width: '4'}, //supp nouv
		{ field: "PCT_EXC_MAPQ", name: "% Exc<br>Mapq", width: '4'}, //supp nouv
		{ field: "PCT_EXC_BASEQ", name: "% Exc<br>Baseq", width: '4'}, //supp nouv
		{ field: "PCT_EXC_OVERLAP", name: "% Exc<br>Overlap", width: '4'}, //supp nouv
		{ field: "PCT_EXC_OFF_TARGET", name: "% Exc<br>Off Target", width: '4'}, //supp nouv
		{ field: "FOLD_80_BASE_PENALTY", name: "Fold 80 <br>Base Penalty", width: '6'},
		{ field: "PCT_TARGET_BASES_1X", name: "% Target <br>Bases<br> 1X", width: '4'},
		{ field: "PCT_TARGET_BASES_2X", name: "% Target <br>Bases<br> 2X", width: '4'},
		{ field: "PCT_TARGET_BASES_10X", name: "% Target <br>Bases<br> 10X", width: '4'},
		{ field: "PCT_TARGET_BASES_20X", name: "% Target <br>Bases<br> 20X", width: '4'},
		{ field: "PCT_TARGET_BASES_30X", name: "% Target <br>Bases<br> 30X", width: '4'},
		{ field: "PCT_TARGET_BASES_40X", name: "% Target <br>Bases<br> 40X", width: '4'}, //supp nouv
		{ field: "PCT_TARGET_BASES_50X", name: "% Target <br>Bases<br> 50X", width: '4'}, //supp nouv
		{ field: "PCT_TARGET_BASES_100X", name: "% Target <br>Bases<br> 100X", width: '4'}, //supp nouv
		{ field: "HS_LIBRARY_SIZE", name: "HS <br>Library <br>Size", width: '6'},
		{ field: "HS_PENALTY_10X", name: "HS <br>Penalty<br> 10X", width: '6'},
		{ field: "HS_PENALTY_20X", name: "HS <br>Penalty<br> 20X", width: '6'},
		{ field: "HS_PENALTY_30X", name: "HS <br>Penalty<br> 30X", width: '6'},
		{ field: "HS_PENALTY_40X", name: "HS <br>Penalty<br> 40X", width: '6'}, //supp nouv
		{ field: "HS_PENALTY_50X", name: "HS <br>Penalty<br> 50X", width: '6'}, //supp nouv
		{ field: "HS_PENALTY_100X", name: "HS <br>Penalty<br> 100X", width: '6'}, //supp nouv
		{ field: "AT_DROPOUT", name: "AT <br>Dropout", width: '7'},
		{ field: "GC_DROPOUT", name: "GC <br>Dropout", width: '7'},
		{ field: "HET_SNP_SENSITIVITY", name: "HET SNP <br>Sensitivity", width: '6'}, //supp nouv
		{ field: "HET_SNP_Q", name: "HET SNP <br>Q", width: '6'}, //supp nouv
		{ field: "SAMPLE", name: "Sample", width: '6'},
		{ field: "LIBRARY", name: "Library", width: '6'}, //supp nouv
		{ field: "READ_GROUP", name: "Read <br>Group", width: '6'} //supp nouv
];

var layoutRun = [
		{ field: "Row", name: "Row",get: getRow, width: '2'},
		{ field: "RunId",name: "Run",width: '3'},
		{ field: "pltRun", name: "Plt Run", width: '6',styles:'text-align:left;white-space:nowrap;'},
		{ field: "nbpatient", name: "#Pat", width: '2'},
		{ field: "cov99",name: "covMoy",width: '5', formatter:colormCov},
		{ field: "cov30",name: "cov30",width: '4', formatter:colormCov},
		{ field: "cov15",name: "cov15",width: '4', formatter:colormCov},
		{ field: "cov5",name: "cov5",width: '4', formatter:colormCov},
		{ field: "ctrl",name: "<img align='top' src='icons/exclamation.png'>",width: '2', formatter:colorpatCov,filterable: false},
		{ field: "cDate", name: "Date",datatype:"date", width: '6.5'},
		{ field: "description",width: '20'},
		{ field: "plateform", width: '8'},
		{ field: "machine", width: '8'},
		{ field: "gMachine", width: '8'},
		{ field: "gRun", width: '3'}
];

var layoutGMac = [
		{ field: "name",name: "Subname", width: '7'},
];

var gmacData ={
	identifier: "name",
	label: "name",
	items: [
		{name: "Others",mac:"SOLID5500",plt:"IMAGINE"},
		{name: "SOLID5500_A",mac:"SOLID5500",plt:"IMAGINE"},
		{name: "SOLID5500_B",mac:"SOLID5500",plt:"IMAGINE"},
		{name: "SOLID5500_C",mac:"SOLID5500",plt:"COCHIN"},
		{name: "SOLID5500_D",mac:"SOLID5500",plt:"IMAGINE"},
		{name: "SOLID5500_L",mac:"SOLID5500",plt:"LIFETECH_US"},
		{name: "WILDFIRE_US",mac:"WILDFIRE",plt:"LIFETECH_US"},
	]
}

var layoutPlateform = [
	{
//		noscroll:true,
		cells:[	{ field: "plateformName",name: "Plateform", width: '7.5'},]
	}
];

var layoutProject = [
	{ field: "projectName",name: "Name",width: '20'},
	{ field: "RunId", name: "Run", width: '4'},
	{ field: "pltRun", name: "Plateform Run", width: '8'},
];

var layoutsearchRun = [
	{ field: "RunId", name: "Run", width: '3'},
	{ field: "pltRun",name: "Plateform Run", width: '8'},
	{ field: "plateformName",name: "Plateform", width: '7'},
	{ field: "machine", width: '7'},
//	{ field: "gMachine", width: '7'},
	{ field: "cDate", name: "Date",datatype:"date", width: '6.5'},
];
//				"styles": "text-align: center;white-space: nowrap;",

var layoutLargerun = [
//		{ field: "runRange",name: "Run Beg:End", width: '6'},
		{ field: "runBegin",name: "Begin", width: '3'},
		{ field: "runEnd",name: "End", width: '3'},
		{ field: "cDate",name: "date", width: '6.5'},
		{ field: "nbrun", name: "nb", width: '1.5'},
];

var macStore;
var runStore;
var projStore;
var runstatStore;
var searchRunStore;

var gmacGrid;
var plateformGrid;
var largerunGrid;
var projGrid;
var legend;
var gridStat;
var searchRunGrid;

var selPlt;
var selGmac;
var selRun;
var selLargerun;

var gname;
var noGP;

var standby;
var numchart;
var libchart;
var libleg;
var libcov;

var selMacPlt;

var cssFiles = ["print_style1.css"];

function otherRadio(a){
	if(this.checked) {
		var mainTab=dijit.byId("TabCoverage");
		var subAcc=dijit.byId("AccCoverage");
		mainTab.selectChild("TabRunCov");
		subAcc.selectChild("AccRunMeanCov");

		var emptyCells = { items: "" };
		runStore = new dojo.data.ItemFileWriteStore({data: emptyCells});
		runGrid.setStore(runStore);
		runGrid.store.close();
		dijit.byId(runGrid)._refresh();
		selLargerun="";
		if(this.params.title=="SOLID5500") {
			dojo.style(gmacGrid.domNode, 'display', '');
			dojo.style(plateformGrid.domNode, 'display', 'none');
			dojo.style(largerunGrid.domNode, 'display', 'none');
			noGP=0;
			selPlt="";
		} else if (this.params.title=="SOLEXA")
		{
			selMacPlt="SOLEXA";
			dojo.style(gmacGrid.domNode, 'display', 'none');
			dojo.style(plateformGrid.domNode, 'display', '');
			dojo.style(largerunGrid.domNode, 'display', 'none');
			noGP=0;			
			selGmac="";
		} else if (this.params.title=="HISEQ2500-1")
		{
			var largerunStore = new dojo.data.ItemFileReadStore({ 
				url: url_path + "/statRun.pl?opt=splitlist&split=15&mac=HISEQ2500-1",
			});
			largerunGrid.setStore(largerunStore);
			largerunGrid.startup();
			dojo.style(gmacGrid.domNode, 'display', 'none');
			dojo.style(plateformGrid.domNode, 'display', 'none');
			dojo.style(largerunGrid.domNode, 'display', '');
			noGP=0;			
		} else if (this.params.title=="HISEQ2500-2")
		{
			var largerunStore = new dojo.data.ItemFileReadStore({ 
				url: url_path + "/statRun.pl?opt=splitlist&split=15&mac=HISEQ2500-2",
			});
			largerunGrid.setStore(largerunStore);
			largerunGrid.startup();
			dojo.style(gmacGrid.domNode, 'display', 'none');
			dojo.style(plateformGrid.domNode, 'display', 'none');
			dojo.style(largerunGrid.domNode, 'display', '');
			noGP=0;			
		} else if (this.params.title=="IONTORRENT")
		{
			var largerunStore = new dojo.data.ItemFileReadStore({ 
				url: url_path + "/statRun.pl?opt=splitlist&split=15&mac=IONTORRENT",
			});
			largerunGrid.setStore(largerunStore);
			largerunGrid.startup();
			dojo.style(gmacGrid.domNode, 'display', 'none');
			dojo.style(plateformGrid.domNode, 'display', 'none');
			dojo.style(largerunGrid.domNode, 'display', '');
			noGP=0;			
		} else if (this.params.title=="MISEQ")
		{
			var largerunStore = new dojo.data.ItemFileReadStore({ 
				url: url_path + "/statRun.pl?opt=splitlist&split=15&mac=MISEQ",
			});
			largerunGrid.setStore(largerunStore);
			largerunGrid.startup();
			dojo.style(gmacGrid.domNode, 'display', 'none');
			dojo.style(plateformGrid.domNode, 'display', 'none');
			dojo.style(largerunGrid.domNode, 'display', '');
			noGP=0;			
		} else if (this.params.title=="NEXTSEQ500")
		{
			var largerunStore = new dojo.data.ItemFileReadStore({ 
				url: url_path + "/statRun.pl?opt=splitlist&split=15&mac=NEXTSEQ500",
			});
			largerunGrid.setStore(largerunStore);
			largerunGrid.startup();
			dojo.style(gmacGrid.domNode, 'display', 'none');
			dojo.style(plateformGrid.domNode, 'display', 'none');
			dojo.style(largerunGrid.domNode, 'display', '');
			noGP=0;			
		}  else if (this.params.title=="NOVASEQ")
		{
			var largerunStore = new dojo.data.ItemFileReadStore({ 
				url: url_path + "/statRun.pl?opt=splitlist&split=15&mac=NOVASEQ",
			});
			largerunGrid.setStore(largerunStore);
			largerunGrid.startup();
			dojo.style(gmacGrid.domNode, 'display', 'none');
			dojo.style(plateformGrid.domNode, 'display', 'none');
			dojo.style(largerunGrid.domNode, 'display', '');
			noGP=0;			
		} else
		{	
			this.params.title=="";	
			dojo.style(gmacGrid.domNode, 'display', 'none');
			dojo.style(plateformGrid.domNode, 'display', 'none');
			dojo.style(largerunGrid.domNode, 'display', 'none');
			noGP=1;			
		}

		gmacStore = new dojo.data.ItemFileReadStore({
               		 data: gmacData
		});
		gmacGrid.setStore(gmacStore);
		dijit.byId(gmacGrid).setQuery({mac:this.params.title.toString()});
		gmacGrid.store.fetch();
		gmacGrid.store.close();

		var plateformStore = new dojo.data.ItemFileReadStore({
			url: url_path + "/statRun.pl?opt=plateform"
		});
		plateformGrid.setStore(plateformStore);
		plateformGrid.store.fetch();
		plateformGrid.store.close();



		if (noGP==1) {
			selPlt="";
			selGmac="";
			selLargerun="";
			standbyShow();
			runFilterMachine();
		}
	}
}

var gname;
var cname;
var rb;

function initRadioButton() {
	standby = new dojox.widget.Standby({
	       	target: "winStandby"
	});
	document.body.appendChild(standby.domNode);
	standby.startup();
	standbyShow();
	macStore = new dojo.data.ItemFileReadStore({
		url: url_path + "/statRun.pl?opt=machine"
	});
	var emptyCells = { items: "" };
	var gmacStore = new dojo.data.ItemFileWriteStore({data: emptyCells});

	function clearOldMList(size, request) {
		var list = dojo.byId("macRadio");
		if (list) {
			while (list.firstChild) {
				list.removeChild(list.firstChild);
			}
		}
	}

	function gotMachine(items, request) {
		var list = dojo.byId("macRadio");
		if (list) {
			var i;
			var cpt=1;
			var defSpan = dojo.doc.createElement('div');
			for (i = 0; i < items.length; i++) {
				if(items[i].macName=="SOLID3") {continue;}
				if(items[i].macName=="SOLID4") {continue;}
				var item = items[i];
				var name = 'mac';
				var cbname = item.macName;
				var id = name + i;
				var title =cbname;
				var cb = new dijit.form.RadioButton({
					id: id,
					name: name,
					title:cbname,
					onChange: otherRadio
				});
				var defLabel = dojo.doc.createElement('label');
				// write next line when multiple 5
				if((cpt%5 == 0) && (cpt >0)) {
					cbname=cbname + "<br>";
				}
				cpt++;
				defLabel.innerHTML = cbname ;
				defSpan.appendChild(defLabel);
				dojo.place(cb.domNode, dojo.byId("macRadio"), "last");
				dojo.place(defLabel, dojo.byId("macRadio"), "last");
				standbyHide();
			}
		}
	}
	function fetchFailed(error, request) {
		alert("gotMachine:lookup failed.");
		alert(error);
	}

	macStore.fetch({
		onBegin: clearOldMList,
		onComplete: gotMachine,
		onError: fetchFailed,
		queryOptions: {
			deep: true
		}
	});
}
dojo.addOnLoad(initRadioButton);

function init(){
//######## Init Genomic Machine Solid5500 #####################################
	var emptyCells = { items: "" };
	var gmacStore = new dojo.data.ItemFileWriteStore({data: emptyCells});

	gmacGrid = new dojox.grid.EnhancedGrid({
 				store: gmacStore,
				structure: layoutGMac,
				selectionMode:"single",
				plugins: {
 					nestedSorting: true,
					dnd: true,
					indirectSelection: {
//						name: "Sel",
						width: "1.35em",
					styles: "text-align: left;margin:0;padding:0;white-space: nowrap;",
					},
				}
	}, document.createElement('div'));
	dojo.byId("gmacGridDiv").appendChild(gmacGrid.domNode);
//	gmacGrid.startup();
	dojo.connect(gmacGrid, "onClick", function(e) {
		var selectedIndex = gmacGrid.focus.rowIndex;
		var selectedItem = gmacGrid.getItem(selectedIndex);
		selGmac = gmacGrid.store.getValue(selectedItem, "name");
		var mainTab=dijit.byId("TabCoverage");
		var subAcc=dijit.byId("AccCoverage");
		mainTab.selectChild("TabRunCov");
		subAcc.selectChild("AccRunMeanCov");
		standbyShow();
		runFilterMachine();
	});
	dojo.connect(gmacGrid, "onMouseOver", showTooltipRow);
	dojo.connect(gmacGrid, "onMouseOut", hideTooltipRow); 
	//################# Init Plateform
	var emptyCells2 = { items: "" };
	var plateformStore = new dojo.data.ItemFileWriteStore({data: emptyCells2});
// A TESTER avec dataGrid
	plateformGrid = new dojox.grid.EnhancedGrid({
 				store: plateformStore,
				structure: layoutPlateform,
				selectionMode:"single",
				plugins: {
 					nestedSorting: true,
					dnd: true,
					indirectSelection: {
//						name: "Sel",
						width: "1.35em",
					styles: "text-align: left;margin:0;padding:0;white-space: nowrap;",
					},

				}
	}, document.createElement('div'));
	dojo.byId("plateformGridDiv").appendChild(plateformGrid.domNode);
	dojo.connect(plateformGrid, "onClick", function(e) {
		var selectedIndex = plateformGrid.focus.rowIndex;
		var selectedItem = plateformGrid.getItem(selectedIndex);
		selPlt = plateformGrid.store.getValue(selectedItem, "plateformName");
		var mainTab=dijit.byId("TabCoverage");
		var subAcc=dijit.byId("AccCoverage");
		mainTab.selectChild("TabRunCov");
		subAcc.selectChild("AccRunMeanCov");
		if (selMacPlt=="SOLEXA" && selPlt=="IMAGINE") {
			var largerunStore = new dojo.data.ItemFileReadStore({ 
				url: url_path + "/statRun.pl?opt=splitlist&split=15&mac=SOLEXA&plt=IMAGINE",
			});
			largerunGrid.setStore(largerunStore);
			largerunGrid.startup();
			dojo.style(largerunGrid.domNode, 'display', '');
			noGP=0;			
		} else if (selMacPlt=="SOLEXA" && selPlt=="UNKNOWN") {
			var largerunStore = new dojo.data.ItemFileReadStore({ 
				url: url_path + "/statRun.pl?opt=splitlist&split=15&mac=SOLEXA&plt=UNKNOWN",
			});
			largerunGrid.setStore(largerunStore);
			largerunGrid.startup();
			dojo.style(largerunGrid.domNode, 'display', '');
			noGP=0;			

		} else {
			dojo.style(largerunGrid.domNode, 'display', 'none');
			selGmac="";
			selLargerun="";
			noGP=0;			
			standbyShow();
			runFilterMachine();
		}
	});
	//################# Init Large Run Machine
	var emptyCells3 = { items: "" };
	var largerunStore = new dojo.data.ItemFileWriteStore({data: emptyCells3});
	largerunGrid = new dojox.grid.EnhancedGrid({
 				store: largerunStore,
				structure: layoutLargerun,
				selectionMode:"single",
				plugins: {
 					nestedSorting: true,
					dnd: true,
					indirectSelection: {
						name: "Run",
						width: "2.2em",
						styles: "text-align: left;margin:0;padding:0;",
					},
				}
	}, document.createElement('div'));
	dojo.byId("largerunGridDiv").appendChild(largerunGrid.domNode);
	dojo.connect(largerunGrid, "onClick", function(e) {
		var selectedIndex = largerunGrid.focus.rowIndex;
		var selectedItem = largerunGrid.getItem(selectedIndex);
		selLargerun = largerunGrid.store.getValue(selectedItem, "runlist");
		var mainTab=dijit.byId("TabCoverage");
		var subAcc=dijit.byId("AccCoverage");
		mainTab.selectChild("TabRunCov");
		subAcc.selectChild("AccRunMeanCov");
		standbyShow();
		runFilterMachine();
		
	});

//################# Init Cov Run List ######################################
	var emptyCells = { items: "" };
	runStore = new dojo.data.ItemFileWriteStore({data: emptyCells});

	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}
	function clearOldRunList(size, request) {
                    var listRun = dojo.byId("covrunGridDiv");
                    if (listRun) {
                        while (listRun.firstChild) {
                           listRun.removeChild(listRun.firstChild);
                        }
                    }
	}
//grid.layout.setColumnVisibility(/* int */columnIndex, /* bool */ visible)
	var menusObjectPC = {
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};

	menusObjectPC.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectPC.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectPC.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(runGrid);"}));
	menusObjectPC.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(runGrid);"}));
	menusObjectPC.cellMenu.startup();


	menusObjectPC.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectPC.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectPC.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(runGrid);"}));
	menusObjectPC.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(runGrid);"}));
	menusObjectPC.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(runGrid);"}));
	menusObjectPC.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(runGrid);"}));
	menusObjectPC.selectedRegionMenu.startup();


	runStore.fetch({
		onBegin: clearOldRunList,
		onError: fetchFailed,
		onComplete: function(items){
			runGrid = new dojox.grid.EnhancedGrid({
				store: runStore,
				query: {RunId: '*'},
				structure: layoutRun,
				loadingMessage: "Loading data...",
				selectionMode:"multiple",
				plugins: {
					indirectSelection: {
						headerSelector:true, 
						width: "20px",
						styles: "text-align: center;",
					},
          				pagination: {
              					pageSizes: ["50", "100", "All"],
              					description: true,
              					sizeSwitch: true,
              					pageStepper: true,
              					gotoButton: true,
              					maxPageStep: 3,
						defaultPageSize: 16,
              					position: "bottom"
          				},
					filter: {
						closeFilterbarButton: true,
						ruleCount: 5,
						itemsName: "patcov",
					},
 					nestedSorting: true,
					dnd: true,
					exporter: true,
					printer:true,
					selector:true,
					menus:menusObjectPC
				}
			},document.createElement('div'));
			dojo.byId("covrunGridDiv").appendChild(runGrid.domNode);
			runGrid.startup();
			dojo.connect(dijit.byId("dijit_form_Button_9"), "onClick", runFilterRunSelection);
			dojo.connect(runGrid, "onMouseOver", showTooltip);
			dojo.connect(runGrid, "onMouseOut", hideTooltip); 
			dojo.connect(runGrid, "onMouseOver", showTooltipCell);
			dojo.connect(runGrid, "onMouseOut", hideTooltipCell); 
		}
	});
//################# Init Grid Patient Coverage ######################################

	var emptyCells = { items: "" };
	var runcovStore = new dojo.data.ItemFileWriteStore({data: emptyCells,clearOnClose: true});
	var ModelCov = new dijit.tree.ForestStoreModel({store: runcovStore, childrenAttrs: ['children']});

	runcovStore.fetch({
		onBegin: clearCovList,
		onError: fetchFailed,
		onComplete: function(items){
			gridCov = new dojox.grid.LazyTreeGrid({
	      			id: "gridCov",
	        		treeModel: ModelCov,
	        		structure: layoutRunCov,
//				selectionMode:"multiple",
//				selectionMode:"single",
				rowSelector: "true",
				selectable:"true",
				keepSelection:"true",
				autoWidth:"true",
				autoHeight:"true",
//				expandoCell: 1,

			}, document.createElement('div'));
			dojo.byId("gridcovDiv").appendChild(gridCov.domNode);
			gridCov.startup();
			dojo.connect(gridCov, "onMouseOver", showTooltipByName);
			dojo.connect(gridCov, "onMouseOut", hideTooltipByName); 
		}
	});

	function clearCovList(size, request) {
                    var listCov = dojo.byId("gridcovDiv");
                    if (listCov) {
                        while (listCov.firstChild) {
                           listCov.removeChild(listCov.firstChild);
                        }
                    }
	}
//################# Init Grid Patient Statistics ######################################

	var emptyCellsS = { items: "" };
//	var runstatStore = new dojox.data.AndOrWriteStore({data: emptyCellsS});
	runstatStore = new dojo.data.ItemFileWriteStore({data: emptyCellsS,clearOnClose:true});
//	var runstatStore = new dojo.data.ItemFileReadStore({data: emptyCellsS,clearOnClose:true});

	var menusObjectPS = {
//		headerMenu: new dijit.Menu(),
//		rowMenu: new dijit.Menu(),
		cellMenu: new dijit.Menu(),
		selectedRegionMenu: new dijit.Menu()
	};

	menusObjectPS.cellMenu.addChild(new dijit.MenuItem({label: "Preview - Save", iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569", disabled:true}));
	menusObjectPS.cellMenu.addChild(new dijit.MenuSeparator());	
	menusObjectPS.cellMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridStat);"}));
	menusObjectPS.cellMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridStat);"}));
	menusObjectPS.cellMenu.startup();

	menusObjectPS.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview - Save", disabled:true, iconClass:"dijitEditorIcon dijitEditorIconCopy",style:"background-color: #495569"}));
	menusObjectPS.selectedRegionMenu.addChild(new dijit.MenuSeparator());
	menusObjectPS.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview All", iconClass:"htmlIcon", onclick:"previewAll(gridStat);"}));
	menusObjectPS.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Preview Selected", iconClass:"htmlIcon", onclick:"previewSelected(gridStat);"}));
	menusObjectPS.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export All", iconClass:"excelIcon", onclick:"exportAll(gridStat);"}));
	menusObjectPS.selectedRegionMenu.addChild(new dijit.MenuItem({label: "Export Selected", iconClass:"excelIcon", onclick:"exportSelected(gridStat);"}));
	menusObjectPS.selectedRegionMenu.startup();

	runstatStore.fetch({
		onBegin: clearStatList,
		onError: fetchFailedC,
		onComplete: function(items){
				gridStat = new dojox.grid.EnhancedGrid({
					store: runstatStore,
					query: {patient: '*'},
					id:"runGridDivId",
					structure: layoutRunStat,			
					selectionMode:"multiple",
					rowSelector: "0.4em",
					plugins: {
						indirectSelection: {
							headerSelector:true, 
//							name: "Sel",
							width: "20px",
							styles: "text-align: center;",
						},
						filter: {
							closeFilterbarButton: true,
							ruleCount: 5,
							itemsName: "name"
						},
 						nestedSorting: true,
						dnd:{copyOnly: true},
						exporter: true,
						printer:true,
						selector:true,
						menus:menusObjectPS
					}			
				},document.createElement('div'));
			dojo.byId("gridstatDiv").appendChild(gridStat.domNode);
			gridStat.startup();
			gridStat.setStore(runstatStore);
			dojo.connect(gridStat, "onMouseOver", showTooltip);
			dojo.connect(gridStat, "onMouseOut", hideTooltip); 
//			dojo.connect(gridStat, "onMouseOver", showTooltipByName);
//			dojo.connect(gridStat, "onMouseOut", hideTooltipByName); 
		}
	});

	function fetchFailedC(error, request) {
		alert("lookup failed.");
		alert(error);
	}

	function clearStatList(size, request) {
                    var listStat = dojo.byId("gridstatDiv");
                    if (listStat) {
                        while (listStat.firstChild) {
                           listStat.removeChild(listStat.firstChild);
                        }
                    }
	}

//################# Init Project List #############################
	projStore = new dojo.data.ItemFileReadStore({ 
		url: url_path + "/statRun.pl?opt=project",
	});
	
	projGrid = new dojox.grid.EnhancedGrid({
 		store: projStore,
     		id: "projGrid",
		query: {projectName: '*'},
		structure: layoutProject,
		selectionMode:"multiple",
		rowSelector: "0.2em",
		plugins: {
 				nestedSorting: true,
				dnd: true,
				indirectSelection: {
					name: "Sel",
					width: "1.5",
					styles: "text-align: center;",
				},
				filter: {
					closeFilterbarButton: true,
					ruleCount: 15,
					itemsName: "name"
				},
			}
	}, document.createElement('div'));
	dojo.byId("projGridDiv").appendChild(projGrid.domNode);
	projGrid.startup();

//################# Init run List #############################
	searchRunStore = new dojo.data.ItemFileReadStore({ 
		url: url_path + "/statRun.pl?opt=run",
	});
	searchRunGrid = new dojox.grid.EnhancedGrid({
 		store: searchRunStore,
       		id: "searchRunGrid",
		query: {RunId: '*'},
		structure: layoutsearchRun,
//		selectionMode:"single",
		selectionMode:"multiple",
		rowSelector: "0.2em",
		plugins: {
 				nestedSorting: true,
				dnd: true,
				indirectSelection: {
					name: "Sel",
					width: "1.5em",
					styles: "text-align: center;",
				},
				filter: {
					closeFilterbarButton: true,
					ruleCount: 5,
					itemsName: "runname"
				},
			}
	}, document.createElement('div'));
	dojo.byId("runGridDiv").appendChild(searchRunGrid.domNode);
	searchRunGrid.startup();
}
dojo.addOnLoad(init);

function clearRunSelection() {
	searchRunGrid.selection.clear();
}

function runFilterRun() {
	var mainTab=dijit.byId("TabCoverage");
	var subAcc=dijit.byId("AccCoverage");
	mainTab.selectChild("TabRunCov");
	subAcc.selectChild("AccRunMeanCov");
	var itemR = searchRunGrid.selection.getSelected();
	var RunGroups = new Array();
	if (itemR.length) {
		dojo.forEach(itemR, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(searchRunGrid.store.getAttributes(selectedItem), function(attribute) {
					var Runvalue = searchRunGrid.store.getValues(selectedItem, attribute);
					if (attribute == "RunId" ) {
						RunGroups.push(Runvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select runs !");
		myError.show();
		return;
	}
	var param="&run=" + RunGroups;
     	var xhrArgs={
 		url: url_path + "/statRun.pl?opt=runlist" + param,
		handleAs: "json",
		load: function (res) {
 			runStore = new dojo.data.ItemFileWriteStore({data: res});
 			runGrid.setStore(runStore);
			runGrid.store.close();
			dijit.byId(runGrid)._refresh();
			function fetchFailed(error, request) {
				alert("lookup failed.");
				alert(error);
			}
			function clearOldList(size, request) {
				var list = dojo.byId("chart99");
				if (list) {
					while (list.firstChild) {
						list.removeChild(list.firstChild);
					}
 				}
			}
			//dojo.connect(searchRunGrid, "onMouseOver", showTooltipCell);
			//dojo.connect(searchRunGrid, "onMouseOut", hideTooltipCell); 
			numchart="99";
			runStore.fetch({query:{Row:"*",cov99:"*"},onBegin: clearOldList,
				onComplete: viewCovMoy,onError: fetchFailed});
		}
		
        }
	var deffered = dojo.xhrGet(xhrArgs);
}


function clearProjectSelection() {
	projGrid.selection.clear();
}

function runFilterProject() {
	var mainTab=dijit.byId("TabCoverage");
	var subAcc=dijit.byId("AccCoverage");
	mainTab.selectChild("TabRunCov");
	subAcc.selectChild("AccRunMeanCov");
	var itemP = projGrid.selection.getSelected();
	var RunGroups = new Array();
	if (itemP.length) {
		dojo.forEach(itemP, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(projGrid.store.getAttributes(selectedItem), function(attribute) {
					var Runvalue = projGrid.store.getValues(selectedItem, attribute);
					if (attribute == "RunId" ) {
						RunGroups.push(Runvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select projects !");
		myError.show();
		return;
	}
	var param="&run=" + RunGroups;
	var url_in = url_path + "/statRun.pl?opt=runlist" + param;
	runStore = new dojo.data.ItemFileWriteStore({
		url: url_in
	});
	runGrid.setStore(runStore);
	runGrid.store.close();
	dijit.byId(runGrid)._refresh();


	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}
	function clearOldList(size, request) {
		var list = dojo.byId("chart99");
		if (list) {
			while (list.firstChild) {
				list.removeChild(list.firstChild);
			}
 		}
	}
	dojo.connect(runGrid, "onMouseOver", showTooltipCell);
	dojo.connect(runGrid, "onMouseOut", hideTooltipCell); 
	numchart="99";
	runStore.fetch({query:{Row:"*",cov99:"*"},onBegin: clearOldList,onComplete: viewCovMoy,onError: fetchFailed});

}

function runFilterMachine() {
//	standbyShow();
	var f = dojo.byId("macForm");
	var mc = "";	
	for (var i = 0; i < f.elements.length; i++) {
		var elem = f.elements[i];
		if (elem.name == "button") {
			continue;
		}
		if (elem.type == "radio" && !elem.checked) {
			continue;
		}
		mc += elem.title;
	}
	if (typeof(selGmac) == "undefined") {selGmac=""}
	if (typeof(selPlt) == "undefined") {selPlt=""}
	var param="&mac=" + mc;
	if(selGmac != "") {
			if (selGmac == "Others") {selGmac=""}
			param=param + "&gmac=" + selGmac;
	}
	if(selPlt != "") {param=param + "&plateform=" + selPlt}
	if (typeof(selLargerun) == "undefined") {selLargerun=""}
	if(selLargerun != "") {
		param="&listrun=" + selLargerun;
	}
    	var xhrArgs={
 		url: url_path + "/statRun.pl?opt=runlist" + param,
		handleAs: "json",
//              	timeout: 800000, // Time in milliseconds
              	timeout: 0, // infinite no time out
		load: function (res) {
 			runStore = new dojo.data.ItemFileWriteStore({data: res});
 			runGrid.setStore(runStore);
			runGrid.store.close();
			dijit.byId(runGrid)._refresh();
			function fetchFailed(error, request) {
				alert("lookup failed.");
				alert(error);
			}
			function clearOldList(size, request) {
				var list = dojo.byId("chart99");
				if (list) {
					while (list.firstChild) {
						list.removeChild(list.firstChild);
					}
 				}
			}
			numchart="99";
			runStore.fetch({query:{Row:"*",cov99:"*"},onBegin: clearOldList,
				onComplete: viewCovMoy,onError: fetchFailed});
		},
		error: function(error) {
			standbyHide();
			if (error=="504") {
				textError.setContent("Reload polyRun because of <b>Time-out Error:</b> " + error);
			} else {
				textError.setContent("Reload polyRun because of <b>Status Error:</b> " + error);
			}
			myError.show();
			return;
		}
        };
	var deffered = dojo.xhrGet(xhrArgs);
}

function runFilterRunSelection() {
	dijit.byId(runGrid)._refresh();
	var indexLength = runGrid._by_idx.length; 
	var tabRunId = new Array(); 
	for (var i = 0; i < indexLength; i++) { 
		element = runGrid._by_idx[i]; 
		tabRunId.push(element.item.RunId);
    	} 
	param="&run=" + tabRunId;
	var url_in = url_path + "/statRun.pl?opt=runlist" + param;
	runStore = new dojo.data.ItemFileWriteStore({
		url: url_in
	});
	runGrid.setStore(runStore);
	runGrid.store.close();
	numchart="99";
	function fetchFailed(error, request) {
		alert("lookup failed.");
				}
	function clearOldList(size, request) {
		var list = dojo.byId("chart99");
		if (list) {
			while (list.firstChild) {
				list.removeChild(list.firstChild);
			}
 		}
	}
	runStore.fetch({query:{Row:"*",cov99:"*"}, onBegin: clearOldList,
		onComplete: viewCovMoy,onError: fetchFailed});
}

function treatCov(num){
	numchart=num;
	libchart='chart'+numchart;
	function fetchFailed(error, request) {
		alert("lookup failed.");
		alert(error);
	}
	function clearOldList(size, request) {
		var list = dojo.byId(libchart);
		while (list.hasChildNodes())
		{
			list.removeChild(list.lastChild); // remove all the children graphics
  		}
	}
	if(numchart==5){
		runStore.fetch({query:{Row:"*",cov5:"*"}, onBegin: clearOldList, onComplete: viewCovMoy,onError: fetchFailed});
	} else if(numchart==15) {
		runStore.fetch({query:{Row:"*",cov15:"*"}, onBegin: clearOldList, onComplete: viewCovMoy,onError: fetchFailed});
	} else if(numchart==30) {
		runStore.fetch({query:{Row:"*",cov30:"*"}, onBegin: clearOldList, onComplete: viewCovMoy,onError: fetchFailed});
	} else if(numchart==99) {
		runStore.fetch({query:{Row:"*",cov99:"*"}, onBegin: clearOldList, onComplete: viewCovMoy,onError: fetchFailed});
	}
}


var viewCovMoy = function(items){
	standbyHide();
	if(items.length> 0) {
		libchart='chart'+numchart;
		var chart = new dojox.charting.Chart2D(libchart);
       		chart.addPlot('default', {type: 'Columns', gap:5,markers: true});

		var arrayRun=[];
		var xlabelArray=new Array();
		for (var i = 0; i <= items.length; i++){
				if (i== items.length ) {
					var xlabel= {"value":i+1,"text":""};
				} else {
					var xlabel= {"value":i+1,"text":items[i].RunId};
				}
				xlabelArray[i]=xlabel;
		}
		var ln = xlabelArray.length;
		var colorfill=["#80B0FF","#FE7000","#FF0000"];
		var myLabelFuncX = function(text, value, precision){
		if(text==0){return " ";}
		};
		chart.addAxis('x',{title:'Run',titleOrientation:'away',
			natural:true,
			majorTicks:true,
			minorTicks:true,
			microTicks: true,
			stroke: "green",
			majorTick: {length: 0},
			minorTick: {length: 0},	
			microTick: {length: 0},	
			majorLabels: true,minorLabels: true,microLabels: true,rotation:-90,min:0, max:ln,
			labelFunc: myLabelFuncX,
			labels:xlabelArray}
		);

		var myLabelFuncY = function(text, value, precision){
			if(text==200){return ">"+ text;}
		};	
		chart.addAxis('y', { vertical: true,min:0, max:200,title:'mCov',labelFunc: myLabelFuncY,
			includeZero: true});

		var arrayCovSup=[];
		libcov='cov'+numchart;
		for (var i = 0; i < items.length; i++){	
				dojo.forEach(runGrid.store.getAttributes(items[i]), function(attribute) {
					var Value = runGrid.store.getValues(items[i], attribute);
					if (attribute == libcov ) {
						arrayCovSup.push(Value);
					}
				});
		}
		var myArraySup = arrayCovSup.join().split(",");
		var myArrayMid = arrayCovSup.join().split(",");
		var myArrayInf = arrayCovSup.join().split(",");
	
		for(var i=0; i<myArraySup.length; i++) {
			if (myArraySup[i] > 80) {
				myArraySup[i] = +myArraySup[i]; 
			} else { 
				myArraySup[i] =0;
			}
		}
		for(var i=0; i<myArrayMid.length; i++) {
			if ( myArrayMid[i]> 50 && myArrayMid[i] < 80) {
				myArrayMid[i] = +myArrayMid[i]; 
			} else { 
				myArrayMid[i] =0;
			}
		}
		for(var i=0; i<myArrayInf.length; i++) {
			if (myArrayInf[i] < 50) {
				myArrayInf[i] = +myArrayInf[i]; 
			} else { 
				myArrayInf[i] =0;
			}
		}
		chart.addSeries(" mCov > 80 ",myArraySup,{stroke: {color: colorfill[0]},fill: colorfill[0]});
		chart.addSeries(" mCov 80-50 ",myArrayMid,{stroke: {color: colorfill[1]},fill: colorfill[1]});
		chart.addSeries(" mCov < 50 ",myArrayInf,{stroke: {color: colorfill[2]},fill: colorfill[2]});
		var magnify = new dojox.charting.action2d.Highlight(chart, "default");
        	var anim4c = new dojox.charting.action2d.Shake(chart,'default');
		chart.setTheme(dojox.charting.themes.PlotKit.blue);

		var anim4b = new dojox.charting.action2d.Tooltip(chart, 'default',{
			text:function(o) {
				var xinfo=xlabelArray[parseInt(dojo.currency.format(o.x))].text;
				return("Run: "+ xinfo+"<br>Cov: " + dojo.currency.format(o.y));
			}
		});

//		new dojox.charting.action2d.MouseZoomAndPan(chart, "default", { axis: 'x', enableScroll: true });
//		var magnify = new dojox.charting.action2d.Highlight(chart, "default");
//        	var anim4c = new dojox.charting.action2d.Shake(chart,'default');
		if (ln < 3) {
			chart.resize(150, 500);
		} else if (ln < 6){
			chart.resize(200, 500);
		} else if (ln < 8){
			chart.resize(250, 500);
		} else if (ln < 40){
			chart.resize(720, 500);
		} else if (ln < 50){
			chart.resize(1000, 500);
		} else {
			chart.resize(1200, 500);
		}
//		chart.setTheme(dojox.charting.themes.PlotKit.blue);
		chart.render();
		if (legend != undefined) {
  			legend.destroyRecursive(true); 
		} 
		libleg='legend'+numchart;
		legend = new dojox.charting.widget.Legend({chart: chart, horizontal: true}, libleg);
	}
}

function selectRun(){
	var mainTab=dijit.byId("TabCoverage");
	var subTab=dijit.byId("TabPatCov");
	mainTab.selectChild(subTab);
	var itemR = runGrid.selection.getSelected();
	var RunGroups = new Array();
	if (itemR.length) {
		dojo.forEach(itemR, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(runGrid.store.getAttributes(selectedItem), function(attribute) {
					var Runvalue = runGrid.store.getValues(selectedItem, attribute);
					if (attribute == "RunId" ) {
						RunGroups.push(Runvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select runs !");
		myError.show();
		return;
	}
	searchcov(RunGroups);
}
var gridCov;
function searchcov(RunGroups){
	var emptyCells = { items: "" };
	runcovStore = new dojo.data.ItemFileWriteStore({data: emptyCells});
	gridCov.setStore(runcovStore);
	gridCov.store.close();
	dijit.byId(gridCov)._refresh();
	var runcovStore= new dojo.data.ItemFileReadStore({ 
		url: url_path + "/statRun.pl?opt=runcov" + "&run=" + RunGroups
	});
	gridCov.setStore(runcovStore);
	gridCov.store.close();
	dijit.byId(gridCov)._refresh();
	// gridstat

//	runstatStore= new dojox.data.AndOrWriteStore({ 
//	var runstatStore= new dojo.data.ItemFileReadStore({ 
	runstatStore= new dojo.data.ItemFileWriteStore({ 
		url: url_path + "/statRun2.pl?opt=runstat" + "&run=" + RunGroups
	});
	gridStat.setStore(runstatStore);
	gridStat.store.close();
	dijit.byId(gridStat)._refresh();

	dojo.connect(dijit.byId('gridCov'), 'onStyleRow' , this, function(row) {
		var item = gridCov.getItem(row.index);
		if (item) {
			var selnbpat = gridCov.store.getValue(item, "nbpatient",null);
			if (selnbpat ==0) {
                            row.customStyles += "background-color:red;";
                        }
		}
		gridCov.focus.styleRow(row);
		gridCov.edit.styleRow(row);
	});
}

var c=null;
var cn=null;
var listUL;
var listCP;
function selectPatStat(){
	var itemS = gridStat.selection.getSelected();
	var runStatGroups = new Array();
	var projStatGroups = new Array();
	var patStatGroups = new Array();
	var TB2xGroups = new Array();
	var TB10xGroups = new Array();
	var TB20xGroups = new Array();
	var TB30xGroups = new Array();
	var meanTCovGroups = new Array();
	if (itemS.length) {
		dojo.forEach(itemS, function(selectedItem) {
			if (selectedItem !== null) {
				dojo.forEach(gridStat.store.getAttributes(selectedItem), function(attribute) {
					var Statvalue = gridStat.store.getValues(selectedItem, attribute);
					if (attribute == "RunId" ) {
						runStatGroups.push(Statvalue);
					} else if (attribute == "project" ) {
						projStatGroups.push(Statvalue);
					} else if (attribute == "patient" ) {
						patStatGroups.push(Statvalue);
					} else if (attribute == "pcttargetbases2x" ) {
						TB2xGroups.push(Statvalue);
					} else if (attribute == "pcttargetbases10x" ) {
						TB10xGroups.push(Statvalue);
					} else if (attribute == "pcttargetbases20x" ) {
						TB20xGroups.push(Statvalue);
					} else if (attribute == "pcttargetbases30x" ) {
						TB30xGroups.push(Statvalue);
					} else if (attribute == "pcttargetbases20x" ) {
						TB20xGroups.push(Statvalue);
					} else if (attribute == "meantargetcoverage" ) {
						meanTCovGroups.push(Statvalue);
					}
				});
			} 
		});
	} else {
		textError.setContent("Please select Patient");
		myError.show();
		return;
	}
	var list = dojo.byId("listGraph");
	if(listUL) {
		while (listUL.firstChild) {
			listUL.removeChild(listUL.firstChild);
		}
	}
	listUL=document.createElement('ul');
	listUL.id="display-inline-block-chart";
	list.appendChild(listUL);
	for (var i=0; i<patStatGroups.length; i++) {
		//Chart Raw
		var li = document.createElement("li");
		listUL.appendChild(li);
		var div = document.createElement("div");
		div.id="chartRaw"+i;
		li.appendChild(div);
		var div2 = document.createElement("div");
		div2.id="Legend"+i;
		li.appendChild(div2);

drawPatStatMulti(i,runStatGroups[i],projStatGroups[i],patStatGroups[i],TB2xGroups[i],TB10xGroups[i],TB20xGroups[i],TB30xGroups[i]);
		//Chart Normalized
		var li = document.createElement("li");
		listUL.appendChild(li);
		var div = document.createElement("div");
		div.id="chartNorm"+i;
		li.appendChild(div);
drawPatStatNormMulti(i,runStatGroups[i],projStatGroups[i],patStatGroups[i],TB2xGroups[i],TB10xGroups[i],TB20xGroups[i],TB30xGroups[i],meanTCovGroups[i]);
	}
	if (patStatGroups.length<6) {
		var listI = dojo.byId("listCMP");
		if(listCP) {
			while (listCP.firstChild) {
				listCP.removeChild(listCP.firstChild);
			}
		}
		listCP=document.createElement('ul');
		listCP.id="display-inline-block-chartCP";
		listI.appendChild(listCP);
		var pl;
		var lnpl;
		for (var i=0; i<patStatGroups.length; i++) {
			for (var j=0; j<patStatGroups.length; j++) {
				if (i==j) {break};
				var patStatGroupsComp = new Array();
				var runStatGroupsComp = new Array();
				var projStatGroupsComp = new Array();
				var TB2xGroupsComp = new Array();
				var TB10xGroupsComp = new Array();
				var TB20xGroupsComp = new Array();
				var TB30xGroupsComp = new Array();
				patStatGroupsComp.push(patStatGroups[i]);
				patStatGroupsComp.push(patStatGroups[j]);
				runStatGroupsComp.push(runStatGroups[i]);
				runStatGroupsComp.push(runStatGroups[j]);
				projStatGroupsComp.push(projStatGroups[i]);
				projStatGroupsComp.push(projStatGroups[j]);
				TB2xGroupsComp.push(TB2xGroups[i]);
				TB2xGroupsComp.push(TB2xGroups[j]);
				TB10xGroupsComp.push(TB10xGroups[i]);
				TB10xGroupsComp.push(TB10xGroups[j]);
				TB20xGroupsComp.push(TB20xGroups[i]);
				TB20xGroupsComp.push(TB20xGroups[j]);
				TB30xGroupsComp.push(TB30xGroups[i]);
				TB30xGroupsComp.push(TB30xGroups[j]);
				pl=i;
				lnpl=j;
				switch (j) {
					case 0:
drawPatCompare(pl,lnpl,patStatGroupsComp,TB2xGroupsComp,TB10xGroupsComp,TB20xGroupsComp,TB30xGroupsComp);
					if (pl==1) {
						drawEmpty(pl,lnpl+1);
						drawEmpty(pl,lnpl+2);
						drawEmpty(pl,lnpl+3);
					}
					break;
					case 1:
drawPatCompare(pl,lnpl,patStatGroupsComp,TB2xGroupsComp,TB10xGroupsComp,TB20xGroupsComp,TB30xGroupsComp);
					if (pl==2){
						drawEmpty(pl,lnpl+2);
						drawEmpty(pl,lnpl+3);
					}
					break;					
					case 2:
drawPatCompare(pl,lnpl,patStatGroupsComp,TB2xGroupsComp,TB10xGroupsComp,TB20xGroupsComp,TB30xGroupsComp);
					if (pl==3){
						drawEmpty(pl,lnpl+3);
					}
					break;
					case 3:
drawPatCompare(pl,lnpl,patStatGroupsComp,TB2xGroupsComp,TB10xGroupsComp,TB20xGroupsComp,TB30xGroupsComp);
					break;
				}
			}
		}
	} else {
		if(listCP) {
			while (listCP.firstChild) {
				listCP.removeChild(listCP.firstChild);
			}
		}
	}
}

function drawEmpty(pl,lnpl){
	var li = document.createElement("li");
	listCP.appendChild(li);
	var div = document.createElement("div");
	div.id="patComp"+lnpl+"_"+pl;
	div.style.fontSize="20px";
	li.appendChild(div);
	var pc = new dojox.charting.Chart("patComp"+lnpl+"_"+pl,{
      		titlePos: "top",
		titleFont: "normal normal bold 10pt Arial",
		titleGap: 5,
		titleFontColor: "orange"
	});
	pc.title="   ";
	pc.addPlot("default", {type: "Lines",markers: true});
	pc.addAxis("y",{ vertical: true,
				title:'% Target',
				titleFont: "normal normal bold 8pt Arial",
				titleFontColor:"#2D495D",
				font: "normal normal bold 6pt Arial",
				from:80,to:101,
				min:80,max:100,
				stroke:{color:"#60A1EA"},
				minorTick:{color:"#60A1EA"},
				majorTick:{color:"#60A1EA"},
				fixed:true,
	});
	pc.addAxis('x',{
				title:'% Target',
				titleFont: "normal normal bold 8pt Arial",
				titleFontColor:"#2D495D",
				font: "normal normal bold 6pt Arial",
				titleOrientation:'away',
				from:80,to:101,
				min:80,max:100,
				stroke:{color:"#60A1EA"},
				minorTick:{color:"#60A1EA"},
				majorTick:{color:"#60A1EA"},
				fixed:true,
	});
	pc.addSeries("Series B", [{x:80,y:80},{x:101,y:101}],{stroke: {color: "grey",style: "ShortDash",width:1}});
	pc.surface.setDimensions(200,200);
	pc.render();
}


function drawPatCompare(pl,lnpl,patStatGroups,TB2xGroups,TB10xGroups,TB20xGroups,TB30xGroups) {	
	var li = document.createElement("li");
	listCP.appendChild(li);
	var div = document.createElement("div");
	div.id="patComp"+lnpl+"_"+pl;
	div.style.fontSize="20px";
	li.appendChild(div);
	var arraySerie=[];
	for (var i = 0; i < 4; i++){
		var serie;
		if (i==0) serie= {x:parseFloat(TB2xGroups[1]),y:parseFloat(TB2xGroups[0])}
		if (i==1) serie= {x:parseFloat(TB10xGroups[1]),y:parseFloat(TB10xGroups[0])}
		if (i==2) serie= {x:parseFloat(TB20xGroups[1]),y:parseFloat(TB20xGroups[0])}
		if (i==3) serie= {x:parseFloat(TB30xGroups[1]),y:parseFloat(TB30xGroups[0])}
		arraySerie[i]=serie;
	}
	var pc = new dojox.charting.Chart("patComp"+lnpl+"_"+pl,{
      		titlePos: "top",
		titleFont: "normal normal bold 8pt Arial",
		titleGap: 1,
		titleFontColor: "orange"
	});
	pc.title=patStatGroups[0].toString()+" vs "+patStatGroups[1].toString();
	pc.addPlot("default", {type: "Lines",markers: true});
	pc.addAxis("y",{ vertical: true,
				title:'% Target '+patStatGroups[0],
				titleFont: "normal normal bold 8pt Arial",
				titleFontColor:"#2D495D",
				font: "normal normal bold 6pt Arial",
				from:80,to:101,
				min:80,max:100,
				stroke:{color:"#60A1EA"},
				minorTick:{color:"#60A1EA"},
				majorTick:{color:"#60A1EA"},
				fixed:true,
	});
	pc.addAxis('x',{
				title:'% Target '+patStatGroups[1],
				titleFont: "normal normal bold 8pt Arial",
				titleFontColor:"#2D495D",
				font: "normal normal bold 6pt Arial",
				from:80,to:101,
				min:80,max:100,
				titleOrientation:'away',
				stroke:{color:"#60A1EA"},
				minorTick:{color:"#60A1EA"},
				majorTick:{color:"#60A1EA"},
				fixed:true,
	});
	pc.addSeries("Series A", arraySerie,{stroke: {color: "#60A1EA"}});
	pc.addSeries("Series B", [{x:80,y:80},{x:101,y:101}],{stroke: {color: "grey",style: "ShortDash",width:1}});
	var pcT = new dojox.charting.action2d.Tooltip(pc, 'default',{
		text:function(o) {
			switch (o.index) {
				case 3: var xinfo="30X";break;
				case 2: var xinfo="20X";break;
				case 1: var xinfo="10X";break;
				case 0: var xinfo="2X";break;
			}
			return(xinfo + " "+ patStatGroups[0]+": " + o.y + " " + patStatGroups[1]+": "+ o.x);
		}
	})
	pc.surface.setDimensions(200,200);
	pc.render();
}


function drawPatStatMulti(ind,runStatGroups,projStatGroups,patStatGroups,TB2xGroups,TB10xGroups,TB20xGroups,TB30xGroups) {
	var mainTab=dijit.byId("TabCoverage");
	var subTab=dijit.byId("TabPatGraph");
	mainTab.selectChild(subTab);

	var arraySerie=[];
	for (var i = 0; i < 4; i++){
		var serie;
		if (i==0) serie= {x:2,y:parseFloat(TB2xGroups.toString())}
		if (i==1) serie= {x:10,y:parseFloat(TB10xGroups.toString())}
		if (i==2) serie= {x:20,y:parseFloat(TB20xGroups.toString())}
		if (i==3) serie= {x:30,y:parseFloat(TB30xGroups.toString())}
		arraySerie[i]=serie;
	}

	var xlabelArray=new Array();
	for (var i = 0; i < 4; i++){
		var xlabel;
		if (i==0) xlabel= {value:2,text:"2x"}
		if (i==1) xlabel= {value:10,text:"10x"}
		if (i==2) xlabel= {value:20,text:"20x"}
		if (i==3) xlabel= {value:30,text:"30x"}
		xlabelArray[i]=xlabel;
	}
	var myLabelFuncX = function(text, value, precision){
			if(text=="2"){return "2x";}
			else if(text=="10"){return "10x";}
			else if(text=="20"){return "20x";}
			else if(text=="30"){return "30x";}
			else {return " ";}
	};
//	if (!c) {
	var c = new dojox.charting.Chart("chartRaw"+ind,{
      		titlePos: "top",
		titleFont: "normal normal bold 10pt Arial",
		titleGap: 5,
		titleFontColor: "orange"
	});
	c.title=patStatGroups.toString();
	c.addPlot("default", {type: "Lines",markers: true});
	c.addAxis("y",{ vertical: true,
			title:'% Target',
			titleFont: "normal normal bold 8pt Arial",
			titleFontColor:"#2D495D",
			stroke:{color:"#60A1EA"},
			minorTick:{color:"#60A1EA",length:0},
			majorTick:{color:"#60A1EA"},
//			min:0.6,max:1.0
			min:60,max:100
	});
	c.addAxis('x',{
			title:'Fold',
			titleFont: "normal normal bold 8pt Arial",
			titleFontColor:"#2D495D",
			titleOrientation:'away',
			stroke:{color:"#60A1EA"},
			minorTick:{color:"#60A1EA",length:0},
			majorTick:{color:"#60A1EA"},
			natural:true,
			dropLabels:false,
			min:0, max:31,
			fixLower: "major",
			labelFunc: myLabelFuncX,
//			labels:xlabelArray
	});
c.addSeries("<b>&nbsp;"+ patStatGroups.toString()+"</b>&nbsp;&nbsp;&nbsp;Project <b>"+ projStatGroups.toString()+"</b>&nbsp;&nbsp;&nbsp;Run <b>"+runStatGroups+"</b><P>", arraySerie);
		var cT = new dojox.charting.action2d.Tooltip(c, 'default',{
			text:function(o) {
			return(o.y);
			}
		})
	c.render();
	var patlibleg='Legend'+ind;
	var patlegend = dijit.byId(patlibleg); 
	if (patlegend != undefined) {
 		patlegend.destroyRecursive(true); 
	} 
	var patlegend = new dojox.charting.widget.Legend({chart: c, horizontal: true,style:"color:#2D495D;"}, patlibleg);
}

function drawPatStatNormMulti(ind,runStatGroups,projStatGroups,patStatGroups,TB2xGroups,TB10xGroups,TB20xGroups,TB30xGroups,meanTCovGroups) {
	var mainTab=dijit.byId("TabCoverage");
	var subTab=dijit.byId("TabPatGraph");
	mainTab.selectChild(subTab);
	var arraySerie=[];
	for (var i = 0; i < 4; i++){
		var serie;
		if (i==0) 
serie= {x:(2/parseFloat(meanTCovGroups.toString())).toFixed(2),y:(parseFloat(TB2xGroups.toString())).toFixed(3)}
		if (i==1) 
serie= {x:(10/parseFloat(meanTCovGroups.toString())).toFixed(2),y:(parseFloat(TB10xGroups.toString())).toFixed(3)}
		if (i==2) 
serie= {x:(20/parseFloat(meanTCovGroups.toString())).toFixed(2),y:(parseFloat(TB20xGroups.toString())).toFixed(3)}
		if (i==3) 
serie= {x:(30/parseFloat(meanTCovGroups.toString())).toFixed(2),y:(parseFloat(TB30xGroups.toString())).toFixed(3)}
		arraySerie[i]=serie;
	}

	var xlabelArray=new Array();
	for (var i = 0; i < 4; i++){
		var xlabel;
if (i==0) xlabel= {value:(2/parseFloat(meanTCovGroups.toString())).toFixed(2),text:"2x:"+ (2/parseFloat(meanTCovGroups.toString())).toFixed(2)}
if (i==1) xlabel= {value:(10/parseFloat(meanTCovGroups.toString())).toFixed(2),text:"10x:"+ (10/parseFloat(meanTCovGroups.toString())).toFixed(2)}
if (i==2) xlabel= {value:(20/parseFloat(meanTCovGroups.toString())).toFixed(2),text:"20x:"+(20/parseFloat(meanTCovGroups.toString())).toFixed(2)}
if (i==3) xlabel= {value:(30/parseFloat(meanTCovGroups.toString())).toFixed(2),text:"30x:"+(30/parseFloat(meanTCovGroups.toString())).toFixed(2)}
		xlabelArray[i]=xlabel;
	}

	// Ne marche pas
	var myLabelFuncX = function(text, value, precision){
		if( parseFloat(value).toFixed(2)==(2/parseFloat(meanTCovGroups.toString())).toFixed(2)) 
			{return "N2x";}
//			{return (2/parseFloat(meanTCovGroups[0])).toFixed(1);}
		else if( parseFloat(value).toFixed(2)==(10/parseFloat(meanTCovGroups.toString())).toFixed(2))
			{return "N10x";}
 		else if( parseFloat(value).toFixed(2)==(20/parseFloat(meanTCovGroups.toString())).toFixed(2))
			{return "N20x";}
 		else if( parseFloat(value).toFixed(2)==(30/parseFloat(meanTCovGroups.toString())).toFixed(2))
			{return "N30x";}
		else if(parseFloat(value).toFixed(2)==0.93)
			{return "1";}
		else {return " ";}
	}

// Normalization 
	var cn = new dojox.charting.Chart("chartNorm"+ind,{
     		titlePos: "top",
		titleFont: "normal normal bold 10pt Arial",
		titleGap: 5,
		titleFontColor: "orange"
	});
	cn.title=patStatGroups.toString();
	cn.addPlot("default", {type: "Lines",markers: true, precision:2,labels:true});
	cn.addAxis("y",{ vertical: true,
			title:'% Target',
			titleFont: "normal normal bold 8pt Arial",
			titleFontColor:"#2D495D",
//			min:0.6,max:1,
			min:60,max:100,
			natural:false,
			stroke:{color:"#60A1EA"},
			minorTick:{color:"#60A1EA",length:0},
			majorTick:{color:"#60A1EA"},
			fixed:true,
	});
	cn.addAxis('x',{
			title:'Fold Normalized',
			titleFont: "normal normal bold 8pt Arial",
			titleFontColor:"#2D495D",
			titleOrientation:'away',
//			natural:true,
			natural:false,
			fixed:true,				
			dropLabels:false,
			stroke:{color:"#60A1EA"},
			minorTick:{color:"#60A1EA"},
			majorTick:{color:"#60A1EA"},
//			min:0, max:(30/parseFloat(meanTCovGroups[0]))+0.05,
			min:0, max:1,
//			min:0, max:0.93,
//			maxLabelChartCount:1,
			maxLabelSize:25,
			font: "normal normal normal 7pt Arial",	
//			labelFunc: myLabelFuncX,
			labels:xlabelArray
	});
	cn.addSeries("Series A", arraySerie);
	var cT = new dojox.charting.action2d.Tooltip(cn, 'default',{
		text:function(o) {
			var xinfo=xlabelArray[o.index].text;
			return("%Target:" + o.y + "<br>Norm "+ xinfo);
		}
	})
	cn.setTheme(dojox.charting.themes.PlotKit.blue);
	cn.render();
}

// red ==> #FF0000 Level for child=> tree grid
//	var colorfill=["#80B0FF","#FE7000","#FF0000"];
//H:174 S:127 V:255 R
function colorCov(value,idx,level,cell,row) {
	if (cell.field == "nbpatient" & value==0) {
		cell.customStyles.push("background: red");
	} else if (cell.field == "patient" & level==0) {
		cell.customStyles.push();	
	} else if (cell.field == "project" & level==0) {
		cell.customStyles.push();	
	} else if (cell.field == "patient" & level>0) {
		cell.customStyles.push("background: #E7E9FF;");	
	} else if (cell.field == "project" & level>0) {
		cell.customStyles.push("background: #E7E9FF;");	
	} else if (cell.field == "cov99") {
		cell.customStyles.push("background: #B8B8B8;");
	} else if (value>95) {	
		cell.customStyles.push("background: #80B0FF;");	
	} else if (value>90) {
		cell.customStyles.push("background: #80C0FF;");	
	} else if (value>85) {
		cell.customStyles.push("background: #80D0FF;");	
	} else if (value>80) {
		cell.customStyles.push("background: #80E0FF;");	
	} else if (value>75) {
		cell.customStyles.push("background: #FDCB98;");	
	} else if (value>=70) {
		cell.customStyles.push("background: #FEC182;");
	} else if (value<70) {
		cell.customStyles.push("background: #FF0000;");	
	} 
	return value;
}

function colormCov(value,idx,cell,row) {
	if (value>80) {	
		cell.customStyles.push("background: #80B0FF;");	
	} else if (value> 50 && value<80) {
		cell.customStyles.push("background: #FE7000;");	
	} else {
		cell.customStyles.push("background: #FF0000;");	
	} 
	if (value == undefined) {
		value=""
	}
	return value;
}

function colorpatCov(value,idx,cell,row) {
	var img1 = "<center><img src='icons/ledblue.png'></center>";
	var img2 = "<center><img src='icons/ledorange.png'></center>";
	var img3 = "<center><img src='icons/ledred.png'></center>";
	if (value==0) {	
		value=img1;
	} else if (value==1) {
		value=img2;
	} else if (value==2){
		value=img3;
	} 
	return value;
}

function bulletStat(value,idx,cell,row) {
	var img1 = "<img src='icons/ledblue.png'>";
	var img2 = "<img src='icons/ledorange.png'>";
	var img3 = "<img src='icons/ledred.png'>";
	if (value==0) {	
		value=img1;
	} else if (value==1) {
		value="";
	} else {
		value="";
	} 
	return value;
}
function colorstatCov(value,idx,cell,row) {
	var img1 = "<center><img src='icons/ledred.png'></center>";
	if (value==1) {	
		value=img1;
	} else {
		value="";
	} 
	return value;
}


function colorStat(value,idx,cell,row) {
	if (value>40) {
		cell.customStyles.push("background: red");
/*		var item = gridStat.getItem(idx);
		var store = gridStat.store;
		store.setValue(item, 'ctrlstat', '1');
		gridStat.update();*/
	}
	return value;
}

function Empty(value) {
	if(value == 0) {
		value="";
	} 
	return value;
}

function expandCovSelected(){
	var itemA = gridCov.selection.getSelected();
	dojo.forEach(itemA, function(selectedItem) {
		gridCov.expand(gridCov.store.getIdentity(selectedItem));
	});
}

function collapseCovSelected(){
	var itemA = gridCov.selection.getSelected();
	dojo.forEach(itemA, function(selectedItem) {
		gridCov.collapse(gridCov.store.getIdentity(selectedItem));
	});
}

function expandStatSelected(){
	var itemA = gridStat.selection.getSelected();
	dojo.forEach(itemA, function(selectedItem) {
		gridStat.expand(gridStat.store.getIdentity(selectedItem));
	});
}

function collapseStatSelected(){
	var itemA = gridStat.selection.getSelected();
	dojo.forEach(itemA, function(selectedItem) {
		gridStat.collapse(gridStat.store.getIdentity(selectedItem));
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
		var regSep=new RegExp(',',"g");
		str=str.replace(reg,'');
		str=str.replace(reg1,'');
		str=str.replace(reg2,'');
		str=str.replace(reg3,'');
		str=str.replace(reg4,'');
		str=str.replace(reg5,'');
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
}

function exportSelected(grid){
	dijit.byId(grid).exportSelected("csv",{writerArgs: {separator: ";"}}, function(str){
		var reg=new RegExp('"',"g");
		var reg1=new RegExp("'","g");
		var reg2=new RegExp("<br>","g");
		var reg3=new RegExp("NaN","g");
		var reg4=new RegExp("<img .*.png>","g");
		var reg5=new RegExp("<center></center>","g");
		var regSep=new RegExp(',',"g");
		str=str.replace(reg,'');
		str=str.replace(reg1,'');
		str=str.replace(reg2,'');
		str=str.replace(reg3,'');
		str=str.replace(reg4,'');
		str=str.replace(reg5,'');
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
}
