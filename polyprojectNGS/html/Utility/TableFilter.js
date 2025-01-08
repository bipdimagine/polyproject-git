/**
 * @author pnitschk table filter 
 */


 selectFilter = function(idDiv,queryFilter,url,el){
 		
		var z = new Array();
		 for (var i in TableFilter[idDiv]) {
		 	var qf = TableFilter[idDiv][i];
	
		 	var sel = dojo.byId("sel_" + qf+idDiv);
			var lab = dojo.byId("lab_" + qf+idDiv);
			var td1 = dojo.byId("td_lab_" + qf+idDiv);
			var td2 = dojo.byId("td_sel_" + qf+idDiv);
			
		 	if (sel.value != "all") {
				td1.className="tdActif";
			
		 		z[qf] = "*" + sel.value + "*";
				lab.className="filterLabelActif";
		 	}
			else {
				td1.className="";
				td2.className="";
					lab.className="filterLabel";
			}
		 
		 }
		
		refreshTableWithQuery(url,TableGrid[url],{query:z, clientSort:true});
 }
 
 var TableFilter = new Array();	
 var TableGrid = new Array();
 /*
  * 	createFilter("/cgi-bin/linkage-report/pm-report/queryProject.pl?type=project",["unite","chips","origin"],grid,"filterTable",{name:"code",responsable:"responsable",allemail:"email"});
  *    createFilter (url, array for list, tableau, id de la div ou inserer, code pour le filtre text {nom:"filtre sur les données"})
  */
 
function createFilter(url, arrayFilter,grid,idDiv,arrayText){
	TableGrid[url]= grid;
	//
	 if (dijit.byId('waiting')){
		dijit.byId('waiting').show();
	}
	var store11 = readStore(url);
	dojo.connect(store11, "onSet", function () {
			refreshGrid(grid,store11);
	
			 if (dijit.byId('waiting')){
		dijit.byId('waiting').hide();
			}
	});
	TableFilter[idDiv]= arrayFilter;
	
	 var table = dojo.byId(idDiv);
	 var  tr = table.appendChild(document.createElement('tr'));
	 for (var i = 0; i < arrayFilter.length; i++) {
	 	initFilter(url,arrayFilter[i],tr,idDiv,grid);
	 }
	 
	  var  td0 = tr.appendChild(document.createElement('td'));
	  
	 td0.innerHTML = "<label class='filterLabel' >Text Search </label>";
	  var  td = tr.appendChild(document.createElement('td'));
	   var  td2 = tr.appendChild(document.createElement('td'));
	  var text =  document.createElement('input');
	  text.setAttribute('dojoType','dijit.form.TextBox');
	   text.setAttribute('type','text');
	    text.setAttribute('id','textfilter'+url);
	   td.appendChild(text);
	 
	 
	    var  select = td2.appendChild(document.createElement('select'));
		select.setAttribute('id','selectTextFilter'+url);
		 for (var i in arrayText) {
		 		var elOptNew = document.createElement('option');				
				 elOptNew.text = arrayText[i];
    			elOptNew.value = i;							
				select.appendChild(elOptNew);
		}
		
		   var t = "filterText('"+url+"',this,'selectTextFilter"+url+"');";
	   text.setAttribute('onChange',t );
	 
	 

		refreshGrid(grid,store11);
		 
}

function filterText(url,text,seln){
	
	
	var z = new Array();
	var sel = dojo.byId(seln);

	var reg=new RegExp("[_]+", "g");
	
	var tableau=sel.value.split(reg);
	for (var i = 0; i < tableau.length; i++) {	
		z[tableau[i]] = "*" + text.value + "*";
	}
	refreshTableWithQuery(url,TableGrid[url],{query:z, clientSort:true,queryOptions: {ignoreCase: true}});
	//var table = dojo.byId(idDiv);
	
}


function initFilter(url,queryFilter,tr,idDiv,grid){
	
	 var store11 = readStore(url);
	
	
	
	
	//  var tr = dojo.byId('filterTableTr');//table.appendChild(document.createElement('tr'));
	

	  var  td = tr.appendChild(document.createElement('td'));
	 	td.setAttribute('id', 'td_lab_'+queryFilter+idDiv);
	 td.innerHTML = "<label class='filterLabel' id='lab_"+queryFilter+idDiv+"'>"+queryFilter+"</label>";
	  var  td2 = tr.appendChild(document.createElement('td'));
	 var  select = td2.appendChild(document.createElement('select'));
	 td2.setAttribute('id', 'td_sel_'+queryFilter+idDiv);
	 select.setAttribute('id', "sel_"+queryFilter+idDiv);
	 select.setAttribute('jsId', "sel_"+queryFilter+idDiv);
	 var z = {chips:'*'};
	 var t = "selectFilter('"+idDiv+"','"+queryFilter+"','"+url+"',this);";
	select.setAttribute('onChange', t);

	
	 store11.fetch({ query: { name: "*" },
                        onComplete: function(items, request){
						
					if (dijit.byId('waiting')){
						dijit.byId('waiting').hide();
							}
	
   						var itemsList = "";
						var dejavu = new Array();
						dejavu["all"] =1;
    				dojo.forEach(items, function(i){
					
      				 itemsList = store11.getValue(i, queryFilter);
					 dejavu[itemsList] = "toto";
					 	
   								 });
					 for(var i in dejavu){
					
					 	var elOptNew = document.createElement('option');
						
						  elOptNew.text =i;
    						elOptNew.value = i;							
							select.appendChild(elOptNew);
						}				
		
							},
                scope: this,
                });
				
			
	
}