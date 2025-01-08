/**
 * @author plaza
 */
dojo.require("dojo.io.iframe");
dojo.require("dijit.ProgressBar");
dojo.require("dijit.form.Button");
dojo.require("dojo.parser");

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

function sendData(url){
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

