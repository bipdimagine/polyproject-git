require(["dijit/Dialog","dojo/data/ItemFileReadStore","dojo/data/ItemFileWriteStore","dojo/parser", "dijit/layout/BorderContainer", "dijit/layout/ContentPane","dijit/DropDownMenu","dijit/Menu","dijit/MenuItem", "dijit/MenuSeparator", "dijit/PopupMenuItem","dijit/form/ComboBox","dijit/form/CheckBox","dijit/form/Form",
"dijit/TitlePane","dijit/form/TextBox","dijit/form/Textarea","dojox/grid/cells/dijit",
"dijit/form/Button","dijit/form/FilteringSelect","dijit/form/ValidationTextBox",
"dojox/grid/enhanced/plugins/Pagination","dojox/grid/EnhancedGrid","dojox/grid/enhanced/plugins/DnD",
"dojox/grid/enhanced/plugins/Menu","dojox/grid/enhanced/plugins/NestedSorting","dojox/grid/enhanced/plugins/IndirectSelection","dojo/ready","dojo/store/Memory", "dijit/form/ComboBox", "dijit/registry",
"dojox/grid/LazyTreeGrid","dijit/tree/ForestStoreModel","dojox/grid/LazyTreeGridStoreModel",
"dojox/grid/TreeGrid","dojo/on"

]);

function cov(value,rowindex) {
	console.log(value);
 	var gridCov = dijit.byId('gridcovDiv');
//	var item = gridCov.getItem(rowIndex); 
//	console.log(item);
 	if (value>80) {value='<div style="background-color:green">'+ value + '</div>'};
	return value;
}
