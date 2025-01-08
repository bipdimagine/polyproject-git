/**
 * @author pnitschk
 */

  function resizeDiv(div1,div2,min) 
{
		var sz = document.getElementById(div1).style.width.split('px')[0];
		if (min > 0 && sz<min ){
			sz = min;
			document.getElementById(div1).style.width = sz+"px";
				sz *= 1.0;
			sz +=14;
			
		}
		sz *= 1.0;
		sz +=14;
		
		document.getElementById(div2).style.width = sz+"px";
	
		
	}     
                     
function refreshTable(url1,grid){
	if (!allstore[url1]) {
		var store = readStore(url1);
	
		grid.setStore(store);	
	}
	else {
		grid.setStore(allstore[url1]);
		//refreshGrid(grid,allstore[url1]);
	}
	
	return 1;
}

function refreshGrid(grid,store){
	//var gridDetailModel = new dojox.grid.data.DojoData(null, store, {query:{name: '*'}, clientSort:true});

//JM	grid.setQuery({name:'*'});
	
//JM	grid.setStore(store);
//JM
	//grid.setModel(gridDetailModel);   
	grid.refresh();
	
}
/*function updateGrid(myData,grid,url1)
{   
	
	var jsonStore = new dojo.data.ItemFileWriteStore({ jsId: 'jsonStore',data: myData });	
	allstore[url1] =jsonStore;
	refreshGrid(grid,jsonStore);
	
    return    1;        
}//End of updateGrid
*/

function forceRefreshTable(url1,grid){
allstore[url1] = new dojo.data.ItemFileWriteStore({
			url: url1
		});
	
 grid.setStore(allstore[url1]);

return 1;
}

function refreshPatient(items,tt) {

	if  (patient_name_filter=="") return;
	 gridselected.filter({"allpatients": "*" + patient_name_filter + "*"});	
	 gridselected = undefined;
}

var gridselected;
function forceRefreshTableVariation(gridBig){
	//if (patient_name_filter == "all") patient_name_filter ="*";
gridselected = gridBig;

var url1 = gridBig.store._jsonFileUrl;
allstore[url1] = new dojo.data.ItemFileWriteStore({
			url: url1,

		});
 gridBig.setStore(allstore[url1]);
 if (patient_name_filter) {
 	gridBig.store.fetch({
 		onComplete: refreshPatient
 	});
 }
return 1;
}

function refreshTableWithQuery(url1,grid,a){
	grid.setQuery({name:'*65*'});
	
	var store = readStore(url1);

	var gridDetailModel = new dojox.grid.data.DojoData(null,store, a);
	//grid.setQuery(a);
	//grid.setModel(gridDetailModel);
	 
	//grid.refresh();
	
	return gridDetailModel;
}

var allstore =[];
function readStore(url1){
	if (!allstore[url1]) {
		allstore[url1] = new dojo.data.ItemFileWriteStore({
			url: url1
		});
		
		
	}

	return  allstore[url1];
	
}

function excel(file){
	var el = document.getElementById("filename");
   	el.value = file;
   	var fo = document.getElementById("formexport");
	fo.action=url_auth;
	fo.submit();
}





