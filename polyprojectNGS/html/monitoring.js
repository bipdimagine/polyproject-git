/**
 * @author plaza
 */

/*
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

var xhrArgsMonit;
var deferredMonit;

var monitoringStore;
var monitoringGrid;

function initMonitoring(){

}
dojo.addOnLoad(initMonitoring);


function runMonitoring() {
	dijit.byId('Monit_1').set('title', "<span style='width:90%'><B>RNAseq Monitoring</span></B>");
	var layoutMonitoring = [
		{ field: 'name',name: 'Project',width: '30em',styles:"text-align:left;white-space:nowrap;", formatter:analyseColor},
		{ field: 'statAnalyse',name: 'A',width: '1.5',styles:"text-align:center;white-space:nowrap;",formatter:ifledbullet},
		{ field: 'g1NSanalyse',name: 'NS',width: '1.5',styles:"text-align:center;white-space:nowrap;",formatter:ifbulletground},
		{ field: 'nbg1NSanalyse',name: '#NS',width: '2',styles:"text-align:center;white-space:nowrap;"},
		{ field: 'g1analyse',name: 'S',width: '1.5',styles:"text-align:center;white-space:nowrap;",formatter:ifbulletground},
		{ field: 'nbg1analyse',name: '#S',width: '1.5',styles:"text-align:center;white-space:nowrap;"},
		{ field: 'g2analyse',name: 'P',width: '1.5',styles:"text-align:center;white-space:nowrap;",formatter:ifbulletground},
		{ field: 'nbTanalyse',name: '#T',width: '1.5',styles:"text-align:center;white-space:nowrap;"},
		{ field: 'featurecounts',name: 'FC',width: '1.5',styles:"text-align:center;white-space:nowrap;",formatter:ifbullet},
		{ field: 'nbPat',name: '#Pat',width: '2.5',styles:"text-align:left;white-space:nowrap;"},
		{ field: 'nbBam',name: '#Bam',width: '2.5',styles:"text-align:left;white-space:nowrap;"},
		{ field: 'diffPatBam',name: 'PB',width: '1.5',styles:"text-align:center;white-space:nowrap;",formatter:bullet},
		{ field: 'Bam',name: 'Bam',width: '4',styles:"text-align:left;white-space:nowrap;"},
		{ field: 'diffBamBai',name: 'BB',width: '1.5',styles:"text-align:center;white-space:nowrap;",formatter:bullet},
		{ field: "runId",name: "Run",width: '4'},
		{ field: 'Rel',name: 'Rel',width: '7'},
		{ field: "MethSnp",name: "Calling",width: '8'},
		{ field: "MethAln", name: "Alignment", width: '8'},
		{ field: 'capName',name: 'Capture',width: '10'},
		{ field: "macName",name: "Machine",width: '8'},
		{ field: "cDate", name: "Date", datatype:"date", width: '7'},
		
	];
 	showProgressDlg("Loading Monitoring... ",true,"idMonitoringDiv","MO");
	xhrArgsMonit={
  		url: url_path + "/manageRnaProject.pl?option=info",
		handleAs: "json",
		handle: function(response,args) {
			showProgressDlg("Loading Monitoring... ",false,"idMonitoringDiv","MO");
			},
              	timeout: 0, // infinite no time out

		load: function (res) {
			monitoringStore = new dojox.data.AndOrWriteStore({data: res});
			var ModelMonitoring = new dijit.tree.ForestStoreModel({
				store: monitoringStore,deferItemLoadingUntilExpand: true,
				childrenAttrs: ['children','childrenb']
			});

			function fetchFailedMonit(error, request) {
					alert("lookup failed Monitoring.");
					alert(error);
			}

			function clearOldMonitList(size, request) {
				var listMonit = dojo.byId("idMonitoringDiv");
 				if (listMonit) {
					while (listMonit.firstChild) {
						listMonit.removeChild(listMonit.firstChild);
					}
				}
			}

			var gotMonitoringItems = function(items,request){
				monitoringGrid = new dojox.grid.TreeGrid({
	        			treeModel: ModelMonitoring,
	        			structure: layoutMonitoring,

				}, document.createElement('div'));
				dojo.byId("idMonitoringDiv").appendChild(monitoringGrid.domNode);
				monitoringGrid.startup();
				dijit.byId(monitoringGrid)._refresh();
				dojo.connect(monitoringGrid, "onMouseOver", showMonitTooltip);
				dojo.connect(monitoringGrid, "onMouseOut", hideMonitTooltip); 
				dojo.connect(monitoringGrid, "onCellMouseOver", showRowTooltip);
				dojo.connect(monitoringGrid, "onCellMouseOut", hideRowTooltip); 
			}
	
			monitoringStore.fetch({
				onBegin: clearOldMonitList,
				onError: fetchFailedMonit,
				onComplete:gotMonitoringItems
			});
		},
		error: function(error,ioargs) {
			console.log("Error Monitoring");
			return;
		}
	};
	deferredMonit = dojo.xhrGet(xhrArgsMonit);
};


function creatoreStore(store,csvData) {
	var store = new dojox.data.CsvStore({data: csvData});
};

var showMonitTooltip = function(e) {
	var msg;
	var msgfield;
	if (e.rowIndex < 0) { // header grid
		msg = e.cell.name;
		msgfield = e.cell.field;
	};
	if (msg) {
		var classmsg = "<i class='tooltip'>";
		if(msg=="Project") {
			dijit.showTooltip(classmsg + 
			"<B>Project Name</B> with <B>repository Name Analysis</B> when +" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="A") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/ledred.png'>" +
			"<B>Not Complete Analyse</B>" + "<br>" +
			"<img src='icons/bullet_green.png'>" +
			"<B>Complete Analyse</B>" + "<br>" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="NS") {
			dijit.showTooltip(classmsg + 
			"<B>None Supervised Analysis</B> from G1 group" + "<br>" +
			"<img src='icons/bullet_red.png'>" +
			"<B>No Zip files in None Supervised Analysis</B> from G1 group" + "<br>" +
			"<img src='icons/bullet_green.png'>" +
			"<B>Zip files in None Supervised Analysis</B> from G1 group" + "<br>" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="S") {
			dijit.showTooltip(classmsg + 
			"<B>Supervised Analysis</B> from G1 group" + "<br>" +
			"<img src='icons/bullet_red.png'>" +
			"<B>No Zip files in Supervised Analysis</B> from G1 group" + "<br>" +
			"<img src='icons/bullet_green.png'>" +
			"<B>Zip files in Supervised Analysis</B> from G1 group" + "<br>" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="P") {
			dijit.showTooltip(classmsg + 
			"<B>Analysis</B> from G2 group" + "<br>" +
			"<img src='icons/bullet_green.png'>" +
			"<B>Complete Analysis</B> from G2 group" + "<br>" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="FC") {
			dijit.showTooltip(classmsg + 
			"<B>FeatureCounts Calling Method:</B> exons.txt, exons.txt.summary, genes.txt, genes.txt.summary" + "<br>" +
			"<img src='icons/bullet_red.png'>" +
			"<B>One or more Count files Not Found in FeatureCounts</B>" + "<br>" +
			"<img src='icons/bullet_green.png'>" +
			"<B>All Count files found in FeatureCounts</B>" + "<br>" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="Bam") {
			dijit.showTooltip(classmsg + 
			"<B>List of Bam files</B>" +
			 "</i>", e.cellNode,['above']);		
		} 
		if(msg=="BB") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_red.png'>" +
			"<B>Number of Bai files</B> different from <B>Number of Bam Files</B>" + "<br>" +
			"<img src='icons/bullet_green.png'>" +
			"<B>All Bam and Bai Files found</B>" + "<br>" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="PB") {
			dijit.showTooltip(classmsg + 
			"<img src='icons/bullet_red.png'>" +
			"<B>Number of Bam files</B> different from <B>Number of Patients</B>" + "<br>" +
			"<img src='icons/bullet_green.png'>" +
			"<B>All Patient and Bam files found</B>" + "<br>" +
			"</i>", e.cellNode,['above']);		
		} 

		if(msg=="#NS") {
			dijit.showTooltip(classmsg + 
			"<B>Number of None Supervised Analysis</B> from G1 group" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="#S") {
			dijit.showTooltip(classmsg + 
			"<B>Number of Supervised Analysis</B> from G1 group" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="#P") {
			dijit.showTooltip(classmsg + 
			"<B>Number of Analysis</B> from G2 group" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="#T") {
			dijit.showTooltip(classmsg + 
			"<B>Total Number of Analysis</B> from G1 and G2 group" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="#Pat") {
			dijit.showTooltip(classmsg + 
			"<B>Number of Patient</B>" +
			"</i>", e.cellNode,['above']);		
		} 
		if(msg=="#Bam") {
			dijit.showTooltip(classmsg + 
			"<B>Number of Bam files</B>" +
			"</i>", e.cellNode,['above']);		
		} 
	}
}; 

var hideMonitTooltip = function(e) {
	dijit.hideTooltip(e.cellNode);
};

function analyseColor(val, rowIdx, cell){
	var name=this.name,field=this.field;
	var value_sp;
	if (val){
		if (field == "name") {
			if (val.indexOf(":")>0) {
				value_sp=val.split(":");
				var concat_value; 
				if (value_sp[1]=="NS") {
					concat_value = value_sp[0]+ "<span style='border:1px solid #004B8D;background-color:#81D4FA;color:#004B8D;padding:0 2px 0 2px;'>" + value_sp[1] +"</span>";
				}
				if (value_sp[1]=="S") {
					concat_value = value_sp[0]+ "<span style='border:1px solid #004B8D;background-color:#64B5F6;color:#004B8D;padding:0 6px 0 6px;'>" + value_sp[1] +"</span>";
				}
				if (value_sp[1]=="P") {
					concat_value = value_sp[0]+ "<span style='border:1px solid #006400;background-color:#BDFCC9;color:#006400;padding:0 6px 0 6px;'>" + value_sp[1] +"</span>";
				}
				val=concat_value;
			}
		}		
	}
	return val;
}

function ifbulletground(value, rowIndex, cell){
	var name=this.name,field=this.field;
	if (field == "g1NSanalyse") {
		this.customStyles.push("background: #81D4FA");
	}
	if (field == "g1analyse") {
		this.customStyles.push("background: #64B5F6");
	
	}
	if (field == "g2analyse") {
		this.customStyles.push("background: #BDFCC9");
	}

	if(value == "3") {
		return "<img align='top' src='icons/bullet_blue.png'>";
	} 
	if(value == "2") {
		return "<img align='top' src='icons/bullet_orange.png'>";
	} 
	if(value == "1") {
		return "<img align='top' src='icons/bullet_red.png'>";
	} 
	if(value == "0") {
		return "<img align='top' src='icons/bullet_green.png'>";
	} 
	else { 
		return "";
	}
}

function ifledbullet(value) {
	if(value == "1") {
		return "<img align='top' src='icons/ledred.png'>";
	} 
	if(value == "0") {
		return "<img align='top' src='icons/bullet_green.png'>";
	} 
	else { 
		return "";
	}
}
















