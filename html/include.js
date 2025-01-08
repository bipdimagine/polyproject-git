/**
 * @author plaza
 */
	
dojo.require("dojo.io.iframe");
dojo.require("dijit.ProgressBar");
dojo.require("dijit.form.Button");
dojo.require("dojo.parser");


var href = window.location.href;

var url_path = "/cgi-bin/polyprojectNGS";

if (href.indexOf("plaza", 1) > -1) {
	url_path = "/cgi-bin/plaza/polyprojectNGS";
}


function param( name )
{
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );

  if( results == null )
    return "";
  else
    return results[1];
}
var href = window.location.href;




	
function sendDataMulti(url){
	dojo.io.iframe.send({
        	url: url,
        	method: "get",
        	handleAs: "text",
        	load: function(rep, ioArgs){
			alert("OK!!!");
 			return 1;
        	}, 
        	error: function(rep, ioArgs){
			alert("Not created!!!");
			return -1;
        	}     
	}); 
}

function sendData2(url){
	dojo.io.iframe.send({
        url: url,
        method: "get",
        handleAs: "text",
        load: function(data, ioArgs){
            var foo = dojo.fromJson(data);
//console.dir(foo.status);
            if (foo.status == "OK") {
				alert(foo.message);
				return 1;                
            }
            else {
//				textError.setContent(foo.message);
//				myError.show();
				 return -1;
            }          
        }     
    }); 
}

function sendData6(url){
	dojo.xhrGet({
        	url: url,
        	method: "get",
		handleAs: "json",
        	load: function(data, ioArgs){
			if (data["status"] == "OK"){
//				alert(data["message"]);
				textMessage.setContent(data["message"]);
				myMessage.show();

			} else {
				textError.setContent(data["message"]);
				myError.show();
			}            
        	},
	}); 
}

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


//fonction pour connaitre le numéro de la ligne
function getRow(inRowIndex){
	return ' ' + (inRowIndex+1);
}

//function getRowProgress(inRowIndex,inValue, inFieldIndex){
//function getRowProgress(inRowIndex,inItem){
function getRowProgress(inRowIndex,items){
	console.log(items);
	console.log(items.progress);

//	return ' ' + (inRowIndex+1)  + '-' + items.progress;
	return ' ' + (inRowIndex+1)  + '-' ;
}
//	var selProjId = patGrid.getItem(0).ProjectId;

function getRowName(inRowIndex,items){

//var itemsList = "";
//  dojo.forEach(items, function(i){
//    itemsList += pantryStore.getValue(i, "name") + " ";
//  });
//  console.debug("All items are: " + itemsList);


//getAttributes(selectedItem)
//	var itemProj =grid.store.getAttributes(items);
//	var itemProj = grid.selection.getSelected();
//	console.log(items[0].name.length);
//	function viewAnnex(items, request){

	console.log(items.length);
//	console.log(grid.rows.length);
//	console.log(item.getAttributes("name"));
//	console.log(name);
//	var item  = this.getItem(inRowIndex); 
//	var champ = inCell.field;
//	console.log(item);
//	return ' ' + (inRowIndex+1)  + '-' + items.progress;
	return ' ' + (inRowIndex+1)  + '-' ;
}


