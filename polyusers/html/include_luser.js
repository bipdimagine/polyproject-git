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
//var url_ftpfile = url_path + "/uploadFile.pl";
var url_luser = url_path + "/luser.pl";
console.log("include_luser.js");
console.log(url_luser);

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
	
