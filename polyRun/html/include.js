/**
 * @author plaza
 */
	
require(["dojo/io/iframe","dijit/ProgressBar","dijit/form/Button","dojo/parser",
"dojo/request/xhr"
]);

var href = window.location.href;

var url_path = "/cgi-bin/polyRun";
if (href.indexOf("plaza", 1) > -1) {
	url_path = "/cgi-bin/plaza/polyRun";
}
//var url_statfile = url_path + "/uploadFile.pl";



//fonction pour connaitre le numéro de la ligne
function getRow(inRowIndex){
        return ' ' + (inRowIndex+1);
}

var showTooltip = function(e) {
	var msg;
	var msgname;
	if (e.rowIndex < 0) { // header grid
		msg = e.cell.field;
	};
	if (msg) {
		var classmsg = "<i class='tooltip'>";
		if(msg=="ctrl") {
			dijit.showTooltip(classmsg + 
			"<span style='color:red;'>Warning Patient Coverage</span>" + "<br>" +
			"<img src='icons/bullet_blue.png'>" +
			"Patient with cov15 > 85%" + "<br>" +
			"<img src='icons/bullet_orange.png'>" +
			"Patient with cov15 in 85-80%" + "<br>" +
			"<img src='icons/bullet_red.png'>" + 
			"Patient with cov15 < 80%"+"</i>", e.cellNode);		
		}
		if(msg=="ctrlstat") {
			dijit.showTooltip(classmsg + 
			"<span style='color:red;'>Warning Patient Statistics</span>" + "<br>" +
			"<img src='icons/bullet_red.png'>" + 
			"Patient with % Off Bait > 40%"+"</i>", e.cellNode);		
		}
                if(msg=="cov5" || msg=="cov15" || msg=="cov30" || msg=="cov99") {
			if(msg=="cov99") {
				msg="covMoy";
			}
			dijit.showTooltip(classmsg +
			"<img src='icons/bullet_blue.png'>" +
			"Average patient coverage with " + msg + " > 80%" + "<br>" +
			"<img src='icons/bullet_orange.png'>" +
			"Average patient coverage with " + msg + " in 80-50%" + "<br>" +
			"<img src='icons/bullet_red.png'>" + 
			"Average patient coverage with " + msg + " < 50%"+"</i>", e.cellNode);		
		}
		if(msg=="pltRun") {
		dijit.showTooltip(classmsg +
		"Plateform Run Name" + "</i>", e.cellNode);		
		}
	}	
}; 

var hideTooltip = function(e) {
	dijit.hideTooltip(e.cellNode);
};

var showTooltipByName = function(e) {
	var msgname;
	if (e.rowIndex < 0) { // header grid
		msgname = e.cell.name;
	};
	if (msgname) {
		var classmsg = "<i class='tooltip'>";
                if(msgname=="%cov5" || msgname=="%cov15" || msgname=="%cov30") {
			var lines=msgname.split("%");
			dijit.showTooltip(classmsg +
			"<img src='icons/bullet_blue.png'>" +
			"Patient with " + lines[1] + " > 80%" + "<br>" +
			"<img src='icons/bullet_orange.png'>" +
			"Patient with " + lines[1] + " in 80-50%" + "<br>" +
			"<img src='icons/bullet_red.png'>" + 
			"Patient with " + lines[1] + " < 50%"+"</i>", e.cellNode);		
		}
	}	
	if(msgname=="Stat") {
		dijit.showTooltip(classmsg +
		"<img src='icons/bullet_blue.png'> " +
		"Patient with Statistics Informations"+"</i>", e.cellNode);		
	}
}; 

var hideTooltipByName = function(e) {
	dijit.hideTooltip(e.cellNode);
};

var showTooltipRow = function(e) {
	var msg;
	if (e.rowIndex >= 0) { // Row
		var selectedItem = gmacGrid.getItem(e.rowIndex);
		msg=gmacGrid.store.getValue(selectedItem, "plt");
	};
	if (msg) {
		dijit.showTooltip(msg, e.cellNode);
	}
}; 

var hideTooltipRow = function(e) {
	dijit.hideTooltip(e.cellNode);
};


var showTooltipCell = function(e) {
	var msg;
	if (e.rowIndex >= 0) {
		var selectedItem = runGrid.getItem(e.rowIndex);
		var pltRun = runGrid.store.getValue(selectedItem, "pltRun");
		var vdes=runGrid.store.getValue(selectedItem, "description");
		if(vdes) {vdes="Description: " + vdes + ", "}
		if(pltRun) {pltRun="Plateform Run: " + pltRun + ", "}

		msg = pltRun + vdes + " Plateform: " + runGrid.store.getValue(selectedItem, "plateform") + ", ";
		msg = msg + " Machine: " + runGrid.store.getValue(selectedItem, "machine");
		if(runGrid.store.getValue(selectedItem, "gMachine")) {
			msg = msg + ", " + runGrid.store.getValue(selectedItem, "gMachine") + ", RUN "
			+ runGrid.store.getValue(selectedItem, "gRun");
		}
	};
	if (msg) {
		dijit.showTooltip(msg, e.cellNode);
	}
}; 

var hideTooltipCell = function(e) {
	dijit.hideTooltip(e.cellNode);
};

