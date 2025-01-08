/**
 * @author plaza
 */
require(["dijit/Dialog","dojo/data/ItemFileReadStore","dojo/data/ItemFileWriteStore","dojo/parser", "dijit/layout/BorderContainer", "dijit/layout/ContentPane","dijit/DropDownMenu","dijit/Menu","dijit/MenuItem", "dijit/MenuSeparator", "dijit/PopupMenuItem","dijit/form/ComboBox","dijit/form/CheckBox","dijit/form/Form",
"dijit/TitlePane","dijit/form/TextBox","dijit/form/Textarea",
"dijit/form/Button","dijit/form/FilteringSelect","dijit/form/ValidationTextBox",
"dojo/ready","dojo/store/Memory", "dijit/registry", "dojo/on",
"dijit/Toolbar","dijit/ToolbarSeparator",
"dojox/data/AndOrReadStore","dojox/data/AndOrWriteStore",
"dojo/_base/declare","dojo/aspect","dojo/_base/lang",
"dijit/form/CurrencyTextBox"

]);


function viewLog(){
	console.log("viewLog");
        var onSubmit = function(token) {
          console.log('success!');
        };

        var onloadCallback = function() {
          grecaptcha.render('submit', {
            'sitekey' : '6LfQ_fwZAAAAAGYb7VcAdTKJv25vPXNTda54fXPt',
            'callback' : onSubmit
          });
        };
	divViewLog.show();

}

/*
function submitLog(){
	console.log("submitlog");
	var logFormvalue = dijit.byId("logForm").getValues();
	console.log(logFormvalue);

}
*/



