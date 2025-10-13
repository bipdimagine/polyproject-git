/**
 * @author plaza
 */
	
require(["dojo/io/iframe","dijit/ProgressBar","dijit/form/Button","dojo/parser",
"dojo/request/xhr"
]);

var href = window.location.href;

var url_path = "/cgi-bin/polyusers";
var url_path_poly = "/cgi-bin/polyprojectNGS";

if (href.indexOf("plaza", 1) > -1) {
	url_path = "/cgi-bin/plaza/polyusers";
	url_path_poly =  "/cgi-bin/plaza/polyprojectNGS";
}

var url_passwd = url_path_poly + "/user_app.pl";

function sendData(url){
	var xhrArgs = {
       		url: url,
 		handleAs: "json",
       		load: function(data, ioargs){
			if (data["status"] == "OK"){
				textMessage.setContent(data["message"]);
				myMessage.show();
			} else {
				textError.setContent(data["message"]);
				myError.show();
			}            
		}
		
	}
	var deferred = dojo.xhrGet(xhrArgs);
	return deferred;
}

var showTooltipField = function(e) {
	var msgfield;
	if (e.rowIndex < 0) { // header grid
		msgfield = e.cell.field;
	};
	if (msgfield) {
		var classmsg = "<i class='tooltip'>";
		if(msgfield=="hgmd") {
			dijit.showTooltip(classmsg + 
			"When <b>Toggled</b>, view on <b>The Human Gene Mutation Database</b> permitted"+"</i>", e.cellNode,['above']);		
		} 
		if(msgfield=="active") {
			dijit.showTooltip(classmsg + 
			"When <b>Toggled</b>, The User Account is active"+"</i>", e.cellNode,['above']);		
		} 
		if(msgfield=="ukey") {
			dijit.showTooltip(classmsg + 
			"When <b>Toggled</b>, The Dual Authentication is activated "+"</i>", e.cellNode,['above']);		
		} 
	}
}; 

var hideTooltipField = function(e) {
	dijit.hideTooltip(e.cellNode);
};

function userColorGroup(value,idx,cell,row) {
	var value_sp;
	if( value == null ) {value=""}
	if (value){
		if (cell.field == "group") {
			value_sp=value.split(" ");
			if (value_sp.length>= 1) {
				var concat_value="";
				for (var i=0; i<value_sp.length; i++) {
					concat_value += "<span style='border:1px solid #00BFFF;background-color:#B0E0E6;color:#000fb3;'>" + value_sp[i] +"</span>" + " ";
				}
				value=concat_value;
			}
		}		
	}
	return value;
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
				usersInGroupStore = new dojo.data.ItemFileWriteStore({
					url: url_path + "/polyusers_up.pl?option=usersInGroup"+"&GrpSel="+ sp_val[0].toString()
				});
				usersInGroupGrid.setStore(usersInGroupStore);
				usersInGroupGrid.store.close();
				dojo.style(dojo.byId('gusergroup'), "padding", "0 1px 0 1px");
				var j_ug = dojo.byId("gusergroup");
				j_ug.innerHTML= sp_val[1].toString();
			} 
		});
	}
	return Cbutton;
}








