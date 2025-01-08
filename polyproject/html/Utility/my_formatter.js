/**
 * @author pnitschk
 */
 
 
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

function icon_follow(value) {
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



function icon_progress(value) {
	var tab = value.split(":");
	//	var img1 = "<img width=10 height=10 src='/icons/myicons5/green_rectangle.png'>";
	//var img2 = "<img width=10 height=10 src='/icons/myicons5/red_rectangle.png'>";
	var img1 = "<img src='/icons/myicons5/green_rectangle.png'>";
	var img2 = "<img src='/icons/myicons5/red_rectangle.png'>";
	//	console.log(tab[0]);
	//	console.log(tab[1]);
	//console.log(tab);
	for (var i = 0; i < tab.length; i++) {
		var elem = tab[i];
				if (elem == 1){
					tab[i]= img1;
				} 
				else {
					tab[i]= img2;
				}
	}
	//	console.log(tab.join(''));
//	value="<div style="border:solid 1px black;">tab.join('')</div>;
	//	value='<table border=2><th>'+tab.join('')+'</th></table>';
	value='<table border=1 bordercolor=black cellpadding=0 cellspacing =0 width=100%><th>'+tab.join('')+'</th></table>';

	//	value="<table border=1><th><img width=10 height=10 src='/icons/myicons5/015-05_red_rectangle.png'><img width=10 height=10 src='/icons/myicons5/015-05_red_rectangle.png'></th></table>";
	return value;
	
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
