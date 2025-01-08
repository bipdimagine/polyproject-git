/**
 * @author pnitschk
 */
function refreshTable(url1,grid){
	
	if (!allstore[url1]) {
		 LoadDataForGrid(url1,grid);
	}
	else {
		
		refreshGrid(grid,allstore[url1]);
	}
	
	return 1;
}

function LoadDataForGrid(url1,grid) {
    
		dojo.xhrGet({ // ➂
		// The following URL must match that used to test the server.
		url: url1,
		handleAs: "json",
		
		timeout: 50000, // Time in milliseconds
		// The LOAD function will be called on a successful response.
		
		load: function(responseObject, ioArgs,evt){
		
			// Now you can just use the object
			//dataRef = responseObject;
			//dojo.byId('wait1').src="/icons/myicons/png-24/16-circle-green.png";
			
			updateGrid(responseObject,grid,url1);
			
			if (dijit.byId('waiting')){
						dijit.byId('waiting').hide();
							}
			return;
			
		},
		
		// The ERROR function will be called in an error case.
		error: function(response, ioArgs){ // ➃
			dojo.byId('wait1').src="/icons/myicons/png-24/16-circle-red.png";
			console.error("HTTP status code:  _--> ", ioArgs.xhr.status); // ➆
			return response; // ➅
		}
		
		
	});
	
	
}//End of retrieve_data()

function refreshGrid(grid,store){
		
	var gridDetailModel = new dojox.grid.data.DojoData(null, store, {query:{name: '*'}, clientSort:true});

	grid.setModel(gridDetailModel);   
	grid.refresh();
	
}
function updateGrid(myData,grid,url1)
{   

	var jsonStore = new dojo.data.ItemFileReadStore({ jsId: 'jsonStore',data: myData });		 
	
	allstore[url1] =jsonStore;
	refreshGrid(grid,jsonStore);
    return    1;        
}//End of updateGrid




function forceRefreshTable(url1,grid){
 //refreshGrid(grid,store11);
 LoadDataForGrid(url1,grid);	
	
return 1;
}


function refreshTableWithQuery(url1,grid,a){
	

	
	var store = readStore(url1);

	var gridDetailModel = new dojox.grid.data.DojoData(null,store, a);
	
	grid.setModel(gridDetailModel);
	 
	grid.refresh();
	
	return gridDetailModel;
}

var allstore =[];
function readStore(url1){
	if (!allstore[url1]) {
		allstore[url1] = new dojo.data.ItemFileReadStore({
			url: url1
		});
		
		
	}
	return  allstore[url1];
	
}