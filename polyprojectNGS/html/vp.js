/**
 * @author pnitschk
 */
 
dojo.require("dojo.cookie");
var url_passwd;
var permitStore;
var username;
var passwd;

function checkPassword(okf){
	username = dojo.cookie("username");
	passwd = dojo.cookie("passwd");
	urlpasswd =url_passwd +"?&pwd="+passwd+"&login="+username;
	permitStore = new dojo.data.ItemFileWriteStore({
		url: urlpasswd
	});
	permitStore.fetch({
		onComplete: okf,
		onError: error,		
	});
	if (initl) {console.log(username)};	
}

function error (items, request){
 	console.dir(items);
	console.dir(request);
	console.error("error in vp.js");
}

