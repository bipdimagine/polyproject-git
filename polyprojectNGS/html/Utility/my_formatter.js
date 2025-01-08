/**
 * @author pnitschk
 */
 dojo.require("dojo.parser");
  dojo.require("dijit.Tooltip"); 
/* 
 var formatters = new Array();
 formatters["formatMethods"] = formatMethods;
 formatters["formatReferenceGene"] = formatReferenceGene;
 formatters["formatSnp"] = formatSnp;
  formatters["formatCnv"] = formatCnv;
 formatters["formatFilter"] = formatFilter;
 formatters["formatValidWithFilter"] = formatValidWithFilter;
 formatters["formatValid"] = formatValid;
 formatters["formatPolyphen1"] = formatPolyphen1;
 formatters["formatAlign"] = formatAlign;
 formatters["formatHapmap"] = formatHapmap;
 formatters["formatHomozygote"] = formatHomozygote;
 formatters["formatPolyphen"] = formatPolyphen;
 formatters["formatCachePolyPhen"] = formatCachePolyPhen;
 formatters["formatPolyphenUrl"] = formatPolyphenUrl;
 formatters["formatSimple"] = formatSimple;
 formatters["formatProteinName"] = formatProteinName;
 formatters["formatTranscriptName"] = formatTranscriptName;
  formatters["formatDgv"] = formatDgv;       
		
//fonction pour connaitre le numéro de la ligne
		function getRow(inRowIndex){
			return ' ' + (inRowIndex+1);
		}
		

			
function formatMethods(value){
	if (!value) value =0 ;
	switch(value){
		case 0:
			return "<img src='/icons/Polyicons/bullet_red.png'>";
	}
		return "<img src='/icons/Polyicons/bullet_green.png'>("+value+")";
}              


function formatReferenceGene(value){
	
	 if (!value) return "-";
	
	return '<a href="http://ncbi36.ensembl.org/Homo_sapiens/geneview?gene='
			  + value
			  + '" target="_blank">'
			  + value + '</a>';
} 

function formatCnv(value){
	if (value.indexOf("Var") == -1) {
		return value;
	}
	
	return '<a href="http://projects.tcag.ca/cgi-bin/variation/xview?source=hg18&view=variation&id='
			  + value
			  + '" target="_blank">'
			  + value + '</a>';
} 

function formatDgv(value){
	if (!value) return "";

var ref = "<a href='http://projects.tcag.ca/cgi-bin/variation/xview?source=hg18&view=variation&id="+value+"' target=_blank>";
	ref += "<img  width=8 height=8 src='/icons/Polyicons/8-em-check.png'></a>";
	
	 return ref;

} 

function formatSnp(value){
	
	if (value.indexOf("rs") == -1) {
		return value;
	}
	
	return '<a href="http://www.ncbi.nlm.nih.gov/snp/?term='
			  + value
			  + '" target="_blank">'
			  + value + '</a>';
} 

function formatFilter(value){
	var img = "<img width=10 height=10 src='/icons/Polyicons/services.png'>";
	if (value == "medium") value = 2;
	else if (value == "strong") value = 3;
	else if (value == "weak") value = 1;
	
	switch(value){
		case 1:
			return img;
		case 2:
			return img+img;	
		case 3:
			return img+""+img+""+img;
	}
	
}

function formatValidWithFilter (tvalue) {
	if (tab_id_patientFilter >= 0) {
		value = tvalue[tab_id_patientFilter];
	}
	else {
	 value = tvalue;	
	}
	if (!value) value =0;
	console.log(value);
	return formatValid(value);
}

 function formatValid(value){
 
	if (value == 0)return "<img src='/icons/Polyicons//bullet_black.png'>";
	if (value == -1) return "<img src='/icons/Polyicons/bullet_red.png'>";	
	if (value == -2) return "<img src='/icons/Polyicons/bullet_purple.png'>";
	if (value == 1) return "<img src='/icons/Polyicons/bullet_green.png'>";
	if (value == 2) return "<img src='/icons/Polyicons/bullet_green.png'>(ho)";
	if (value == 3) return "<img src='/icons/Polyicons/bullet_green.png'>(he)";
	if (value == -8) return "<img src='/icons/Polyicons/bullet_orange.png'>";
	if (value == -99) return "<img src='/icons/Polyicons/System-Security-Question-icon-16.png'>";
	return "-";
}



function formatPolyphen1(value){
	//value= parseInt(value);
	
	if ( value == 6 ) return "<img src='/icons/Polyicons/bullet_orange_grey.png'>"+"<img src='http://mendel.necker.fr/icons/myicons2/bullet_orange.png'>"+"<img src='http://mendel.necker.fr/icons/myicons2/bullet_orange_grey.png'>";
	if ( value == 7 ) return "<img src='/icons/Polyicons/bullet_red_grey.png'>"+"<img src='http://mendel.necker.fr/icons/myicons2/bullet_red_grey.png'>"+"<img src='http://mendel.necker.fr/icons/myicons2/bullet_red.png'>";;
	if ( value == 5 ) return "<img src='/icons/Polyicons/bullet_green.png'>"+"<img src='http://mendel.necker.fr/icons/myicons2/bullet_green_grey.png'>"+"<img src='http://mendel.necker.fr/icons/myicons2/bullet_green_grey.png'>";;
	if ( value == 3 ) return "<img src='/icons/Polyicons/bullet_grey.png'>"+"<img src='http://mendel.necker.fr/icons/myicons2/bullet_grey.png'>"+"<img src='http://mendel.necker.fr/icons/myicons2/bullet_grey.png'>";
	if ( value == 9 )  return "<img  width=16 height=16 src='/icons/Polyicons//stop_hunabkuc_software.png'>";
	if ( value == 0 )  return "<img  width=16 height=16 src='/icons/Polyicons/cancel.png'>";
	return "-";
}

function formatAlign (value){
	if (value == -1 ) return "<img src='/icons/Polyicons/bullet_red.png'>";
	return "<img src='/icons/Polyicons/bullet_green.png'>";
}


function formatHomozygote (value){
	
	if ( value <0 ) return "<img src='/icons/Polyicons//bullet_grey.png'>"+"<img src='/icons/Polyicons/bullet_grey.png'>";
	if ( value == 1 ) return "<img src='/icons/Polyicons//bullet_green.png'>"+"<img src='/icons/Polyicons//bullet_green.png'>";
	if ( value == 2 ) return "<img src='/icons/Polyicons//bullet_red.png'>"+"<img src='/icons/Polyicons//bullet_green.png'>";
	if ( value == 3 ) return "<img src='/icons/Polyicons//bullet_purple.png'>"+"<img src='/icons/Polyicons//bullet_purple.png'>";
    return  "<img src='/icons/Polyicons//bullet_grey.png'>"+"<img src='/icons/Polyicons//bullet_grey.png'>";
	
}

function formatHapmap (value){
	if ( value == 0 ) return "";
	
	var ref = "<a href='http://hapmap.ncbi.nlm.nih.gov/cgi-perl/gbrowse/hapmap27_B36/?name=SNP:"+value+"' target=_blank>";
	ref += "<img  width=8 height=8 src='/icons/Polyicons//8-em-check.png'></a>";
	
	 return ref;
}

function formatPolyphen(value){
	//value= parseInt(value);
	
	if ( value == 6 ) return "<img  width=16 height=16 src='/icons/Polyicons/difficulty_1.png'>";
	if ( value == 7 ) return "<img  width=16 height=16 src='/icons/Polyicons/difficulty_2_1.png'>";
	if ( value == 5 ) return "<img  width=16 height=16 src='/icons/Polyicons/difficulty_0.png'>";	
	if ( value == 3 )   return "<img  width=16 height=16 src='/icons/Polyicons/difficulty_3_b.png'>";
	if ( value == 9 )  return "<img  width=16 height=16 src='/icons/Polyicons/stop_hunabkuc_software.png'>";
	
	if ( value == 0 )  return "<img  width=16 height=16 src='/icons/myicons/warning.png'>";
	return "-";//"<img src='/icons/myicons/bullet_black.png'>";
}

function formatCachePolyPhen (value){
	if (value == "-") return value;
	if (value == "") return value;
	return "<a href='"+url_query+"?"+value+"' target='_blank'>view</a>";
}
 
function formatPolyphenUrl (value){
	
	
	if (value == "-") return value;
	var reg=new RegExp("&lt;", "g");
	var g=value.replace(reg,"<");
	return "-";
	return '<form method="post" id ="harvard" action="http://genetics.bwh.harvard.edu/cgi-bin/ggi/ggi.cgi" target="_blank" enctype="application/x-www-form-urlencoded">'+g+'</form>';
}

function formatSimple (value){

	return value;
}

function formatProteinName (value){
	var tab = value.split("+");
	var eurl = '<a href="http://www.ensembl.org/Homo_sapiens/Transcript/ProteinSummary?db=core;p='
			  + tab[0]
			  + '" target="_blank">'
			  + tab[0] + '</a>';
	
	 
	return eurl+"<br>("+tab[1]+")";
}

function formatTranscriptName (value){
	var tab = value.split("+");
	var eurl = '<a href="http://www.ensembl.org/Homo_sapiens/Transcript/TranscriptSummary?db=core;t='
			  + tab[0]
			  + '" target="_blank">'
			  + tab[0] + '</a>';
	
	 
	return eurl+"<br>("+tab[1]+")";
}
function formathe(val) {
		
		if (val == 0)  return "<img src='/icons/Polyicons/12-em-cross.png'>";
		
		return "<img src='/icons/Polyicons/12-em-check.png'>";
		
	}
	
	function formatho(val) {
		
		if (val == 1) return "<img src='/icons/Polyicons/12-em-cross.png'>";;	
		return "<img src='/icons/Polyicons/12-em-check.png'>";	
	}
	
						
function formatInclude(value){
	value= value*1.0;
	if (!value) value =0 ;
	switch(value){
		case -1:{
		
			
			return "<img src='/icons/Polyicons//delete.png'>";
		}
		case 0:
		 	
			
			return "<img src='/icons/Polyicons/add.png'>";	
			
	}
	return "<img src='/icons/Polyicons/bullet_grey.png'>";
}   


function icon_server(value) {
	if (value == "dev"){
		return "<img src='/icons/Polyicons/bullet_purple.png'>";
		
	}
	return "<img src='/icons/Polyicons/bullet_green.png'>";
	
}
*/
/* function icon_follow(value) {
	if (value == 1){
		//return "<img src='/icons/Polyicons/bullet_green.png'>";
		return "<img src='/icons/myicons5/green_rectangle.png'>";
		
	} else {
//		return "<img src='/icons/myicons5/red_rectangle.png'>";
	}
	return value;
}


function icon_follow2(value) {
	if (value == 1){
		//return "<img src='/icons/Polyicons/bullet_green.png'>";
		return "<img align='top' src='/icons/myicons5/green_rectangle.png'>";
		
	} else {
		return "<img align='top' src='/icons/myicons5/red_rectangle.png'>";
	}
	return value;
}

*/

function icon_follow(value) {
	if (value == 1){
		return "<img align='top' src='/icons/Polyicons/green_rectangle.png'>";
		
	} else {
		return "<img align='top' src='/icons/Polyicons/red_rectangle.png'>";
	}
	return value;
}

function icon_progress(value) {
	var tab = value.split(":");
	var img1 = "<img src='/icons/Polyicons/green_rectangle.png'>";
	var img2 = "<img src='/icons/Polyicons/red_rectangle.png'>";
	for (var i = 0; i < tab.length; i++) {
		var elem = tab[i];
				if (elem == 1){
					tab[i]= img1;
				} 
				else {
					tab[i]= img2;
				}
	}
	value='<table border=1 bordercolor=black cellpadding=0 cellspacing =0 width=100%><th>'+tab.join('')+'</th></table>';
	return value;
}

function icon_progressRow(value) {
	var row = value.split("-");
	var tab = row[1].split(":");
/*	var img1 = "<img src='/icons/Polyicons/green_rectangle.png'>";
	var img2 = "<img src='/icons/Polyicons/red_rectangle.png'>";
	for (var i = 0; i < tab.length; i++) {
		var elem = tab[i];
				if (elem == 1){
					tab[i]= img1;
				} 
				else {
					tab[i]= img2;
				}
	}
*/
	value='<table border=1 bordercolor=black cellpadding=0 cellspacing =0 width=100%><th>'+tab.join('')+'</th></table>';
	return value;
}

function icon_progressTip(value) {
//	var row = value.split("-");
//	var tab = row[1].split(":");
	var tab = value.split(":");
	var img1 = "<img src='/icons/Polyicons/green_rectangle.png'>";
	var img2 = "<img src='/icons/Polyicons/red_rectangle.png'>";
	var tipD="";
	var tipF="</span>";
	var tipC="";
	var tabjoin;
	for (var i = 0; i < tab.length; i++) {
		var elem = tab[i];
		
		if (i==0) {
				new dijit.Tooltip({connectId: ["bar0"],label: "<b>Raw sequence</b>",position:['above']});
				tipD="<span id='bar0'>";
		}
		if (i==1) {	new dijit.Tooltip({connectId: ["bar1"],label: "<b>Alignment</b>",position:['above']});
				tipD="<span id='bar1'>";
		}
		if (i==2) {	new dijit.Tooltip({connectId: ["bar2"],label: "<b>Calling variation</b>",position:['above']});
				tipD="<span id='bar2'>";
		}
		if (i==3) {	new dijit.Tooltip({connectId: ["bar3"],label: "<b>Calling indel</b>",position:['above']});
				tipD="<span id='bar3'>";
		}
		if (i==4) {	new dijit.Tooltip({connectId: ["bar4"],label: "<b>Insert variation</b>",position:['above']});
				tipD="<span id='bar4'>";
		}
		if (i==5) {	new dijit.Tooltip({connectId: ["bar5"],label: "<b>Insert insertion</b>",position:['above']});
				tipD="<span id='bar5'>";
		}
		if (i==6) {	new dijit.Tooltip({connectId: ["bar6"],label: "<b>Insert deletion</b>",position:['above']});
				tipD="<span id='bar6'>";
		}
		if (i==7) {	new dijit.Tooltip({connectId: ["bar7"],label: "<b>Cache gene</b>",position:['above']});
				tipD="<span id='bar7'>";
		}
		if (i==8) {	new dijit.Tooltip({connectId: ["bar8"],label: "<b>Cache variation</b>",position:['above']});
				tipD="<span id='bar8'>";
		}
		if (elem == 1){
			tab[i]= tipD+img1+tipF+tipC+tipF;
//			tab[i]= tipC+tipF+tipD+img1+tipF;
		} 
		else {
//			tab[i]= tipC+tipF+tipD+img2+tipF;
			tab[i]= tipD+img2+tipF+tipC+tipF;
		}
	}
	tabjoin=tab.join('');
//	console.log(tabjoin);
	value='<table border=1 bordercolor=black cellpadding=0 cellspacing =0 width=100%><th>'+tabjoin+'</th></table>';
	return value;
}
function icon_progressTipBis(value) {
	var rowl = value.split("-");
	var tab = rowl[1].split(":");
	var img1 = "<img src='/icons/Polyicons/green_rectangle.png'>";
	var img2 = "<img src='/icons/Polyicons/red_rectangle.png'>";
	var tipD="";
	var tipF="</span>";
	var tipA="</a>";
	var tipC="";
	var tabjoin;
	var row=rowl[0];
	var tipFF="</div>"
	var arlev=new Array();		
	for (var i = 0; i < tab.length; i++) {
		var elem = tab[i];
		if (i==0) {
//function searchLevel(items){
//        var arlev=new Array();
//        for (var i = 0; i < items.length; i++){
//                var numSel=level(items[i].lev);
//                arlev[i]=numSel;
//        }
//        return unique(arlev);
//}

				var bar0="bar"+row+"0";
				arlev[i]=bar0;
//				var bar0="bar"+"0";
				tipD="<span id="+bar0+">";
//				tipD='<span id="bar0">';
//				tipD='<a id="bar0">';
				//tipC="<span id='"+bar0+"' data-dojo-type='dijit.Tooltip' data-dojo-props='connectId:'"+bar0+"',label:'Raw sequence'>";
				//tipC="<span id='"+bar0+"_tooltip' data-dojo-type='dijit.Tooltip' data-dojo-props=\"connectId:['"+bar0+"'],label:'Raw sequence'\">";

//				tipC="<span id='bar0_l' dojoType='dijit.Tooltip' connectId='bar0' label='ttt'>";
//				tipC='<span dojoType="dijit.Tooltip" connectId="bar0">fff</span>';
//				tipC="<span  id='bar0_l 'dojoType='dijit.Tooltip' connectId='bar0' label='ttt'></span>";
//				dijit.byId('bar0_l').attr('label','This is the changed tooltip for id1');
//			new dijit.Tooltip({connectId: "'"+bar0+"'",label: "<b>Raw sequence</b>",position:['above']});

//			new dijit.Tooltip({connectId: "bar420",label: "<b>Raw sequence</b>",position:['above']});
//			new dijit.Tooltip({connectId: bar0,label: "<b>Raw sequence</b>",position:['above']});
//			var barr=dojo.query("span[id='bar0']")[0];
//			console.log(arlev);
//			new dijit.Tooltip({connectId: 'arlev',label: "<b>Raw sequence</b>",position:['above']});




		}
			new dijit.Tooltip({connectId: arlev[0],label: "<b>Raw sequence</b>",position:['above']});
//		console.log(arlev[0]);
			//tab[i]= tipC+tipD+img1+tipF;
			tab[i]=tipD+ img1+tipF;
		if (elem == 1){
//			tab[i]= tipD+img1+tipA+tipC+tipF;
//			tab[i]= tipC+tipD;
		} 
		else {
//			tab[i]= tipC+tipD
//			tab[i]= tipD+img2+tipF+tipC+tipF;
		}
	}
//	tabjoin=tab.join('');
	tabjoin=tab[0];
	console.log(tabjoin);
//	value='<table border=1 bordercolor=black cellpadding=0 cellspacing =0 width=100%><th>'+tab.join('')+'</th></table>';
//	value='<table border=1 bordercolor=black cellpadding=0 cellspacing =0 width=100%><th>'+tabjoin+'</th></table>';
	value=tabjoin;
	return value;
}
function icon_progressTipBis2(value) {
	var rowl = value.split("-");
	var tab = rowl[1].split(":");
	var img1 = "<img src='/icons/Polyicons/green_rectangle.png'>";
	var img2 = "<img src='/icons/Polyicons/red_rectangle.png'>";
	var tipD="";
	var tipF="</span>";
	var tipC="";
	var tabjoin;
	var row=rowl[0];
	var tipFF="</div>"
	for (var i = 0; i < tab.length; i++) {
		var elem = tab[i];
		
		if (i==0) {
//				var bar0="bar"+row+"0";
				var bar0="bar"+"0";
//				tipD="<span id='"+bar0+"'>";
				tipD='<span id="bar0">';
				//tipC="<span id='"+bar0+"' data-dojo-type='dijit.Tooltip' data-dojo-props='connectId:'"+bar0+"',label:'Raw sequence'>";
				//tipC="<span id='"+bar0+"_tooltip' data-dojo-type='dijit.Tooltip' data-dojo-props=\"connectId:['"+bar0+"'],label:'Raw sequence'\">";

//				tipC="<span id='bar0_l' dojoType='dijit.Tooltip' connectId='bar0' label='ttt'>";
//				tipC='<span dojoType="dijit.Tooltip" connectId="bar0" label="ttt">';
				tipC="<div dojoType='dijit.Tooltip' connectId='bar0' label='ttt'></div>";

//			new dijit.Tooltip({connectId: "'"+bar0+"'",label: "<b>Raw sequence</b>",position:['above']});

//			new dijit.Tooltip({connectId: "bar420",label: "<b>Raw sequence</b>",position:['above']});
//			new dijit.Tooltip({connectId: bar0,label: "<b>Raw sequence</b>",position:['above']});





		}
		if (i==1) {
				//var bar1="bar"+row+"1";
				//tipD="<span id='"+bar1+"'>";
				//tipC="<span dojoType='tooltip' label='Alignment'  connectId=['"+bar1+"']>";
				//tipC="<div dojoType='tooltip' label='Alignment'  connectId=['"+bar1+"']>";
				tipD="<span id='bar1'>";
	new dijit.Tooltip({connectId: "bar1",label: "<b>Alignment</b>",position:['above']});
		}
		if (i==2) {
				var bar2="bar"+row+"2";
	new dijit.Tooltip({connectId: "bar2",label: "<b>Calling variation</b>",position:['above']});
				tipD="<span id='bar2'>";
		}
		if (i==3) {
				var bar3="bar"+row+"3";
	new dijit.Tooltip({connectId: ["bar3"],label: "<b>Calling indel</b>",position:['above']});
				tipD="<span id='bar3'>";
		}
		if (i==4) {
				var bar4="bar"+row+"4";
	new dijit.Tooltip({connectId: ["bar4"],label: "<b>Insert variation</b>",position:['above']});
				tipD="<span id='bar4'>";
		}
		if (i==5) {
				var bar5="bar"+row+"5";
	new dijit.Tooltip({connectId: ["bar5"],label: "<b>Insert insertion</b>",position:['above']});
				tipD="<span id='bar5'>";
		}
		if (i==6) {
				var bar6="bar"+row+"6";
	new dijit.Tooltip({connectId: ["bar6"],label: "<b>Insert deletion</b>",position:['above']});
				tipD="<span id='bar6'>";
		}
		if (i==7) {
				var bar7="bar"+row+"7";
	new dijit.Tooltip({connectId: ["bar7"],label: "<b>Cache gene</b>",position:['above']});
				tipD="<span id='bar7'>";
		}
		if (i==8) {
				var bar8="bar"+row+"8";
	new dijit.Tooltip({connectId: ["bar8"],label: "<b>Cache variation</b>",position:['above']});
				tipD="<span id='bar8'>";
		}
		if (elem == 1){
			tab[i]= tipD+img1+tipF+tipC+tipF;
//			tab[i]= tipC+tipF+tipD+img1+tipF;
		} 
		else {
//			tab[i]= tipC+tipF+tipD+img2+tipF;
			tab[i]= tipD+img2+tipF+tipC+tipF;
		}
	}
	tabjoin=tab.join('');
	console.log(tabjoin);
//	value='<table border=1 bordercolor=black cellpadding=0 cellspacing =0 width=100%><th>'+tab.join('')+'</th></table>';
	value='<table border=1 bordercolor=black cellpadding=0 cellspacing =0 width=100%><th>'+tabjoin+'</th></table>';
	return value;
}

function format_line(value) {
	var tabs = value.split(" ");
	var img2 = "<img src='/icons/Polyicons/bullet_red.png'>";
	var ncol=0;
	if (tabs.length> 1){
		//if (tabs.length> 2){
		for (var i = 0; i < tabs.length; i++) {
			//if(i>0) tabs[i]=img2 + tabs[i];
			if(i>0) {
				if(ncol>5){
					tabs[i]=img2 + tabs[i]+ "<BR>";
					//					ncol=-1
					ncol=0;
				} else {
					//					tabs[i]=img2 + tabs[i];
					if(tabs[i]!="") tabs[i]=img2 + tabs[i];
				}
			}
			ncol++;
		}
	}
	return tabs.join(' ');
}

function format_patient(value) {
	if (!value) value =":0";
	var tab = value.split(" ");
	var img1 = "<img src='/icons/Polyicons/bullet_green.png'>";
	var img2 = "<img src='/icons/Polyicons/bullet_red.png'>";
	var ncol=0;
	var total=0;
	for (var i = 0; i < tab.length; i++) {
		var elem = tab[i];
		var tab2= elem.split(":");
		if(tab2[1] > 0){
			// forcing numeric value
			tab2[1]-=0;
			tab[i]="";
			total+=tab2[1];
		} else {
			tab[i]= img2 + tab2[0];
		}
	}
	return total + tab.join(' ');
	//	return value;
}

/*

function format_patient_sav(value) {
	var tab = value.split(" ");
	var img1 = "<img src='/icons/Polyicons/bullet_green.png'>";
	var img2 = "<img src='/icons/Polyicons/bullet_red.png'>";
	var ncol=0;
	for (var i = 0; i < tab.length; i++) {
		var elem = tab[i];
		var tab2= elem.split(":");
		if(tab2[1] > 0){
			if(ncol>1){
				tab[i]= img1 + tab[i] + "<BR>";
				ncol=-1;
			} else {
				tab[i]= img1 + tab[i] ;
			}
		} else {
			if(ncol>1){
				tab[i]= img2 + tab[i] + "<BR>";
				ncol=-1;
			} else {
				tab[i]= img2 + tab[i] ;
			}
		}
		ncol++;
	}
	return tab.join(' ');
	//	return value;
}


function format_seq(value) {
	var tabs = value.split(" ");
	var img2 = "<img src='/icons/Polyicons/bullet_red.png'>";
	var ncol=0;
	if (tabs.length> 1){
		//if (tabs.length> 2){
		for (var i = 0; i < tabs.length; i++) {
			//if(i>0) tabs[i]=img2 + tabs[i];
			if(i>0) {
				if(ncol>5){
					tabs[i]=img2 + tabs[i]+ "<BR>";
					//					ncol=-1
					ncol=0;
				} else {
					//					tabs[i]=img2 + tabs[i];
					if(tabs[i]!="") tabs[i]=img2 + tabs[i];
				}
			}
			ncol++;
		}
	}
	return tabs.join(' ');
}
*/

function changeHtml(value){
	var l = value.length;
	var s = value.indexOf(";");
	var res1 = value.substring(s+1,l);
			
	return"<"+res1;
}
