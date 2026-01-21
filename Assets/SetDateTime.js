// --- Set and update DateTime_Start and ClientTimeZone ---
var DateTime_Start = null;
var ClientTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
function UpdateDateTime() {
	var JsonPost = {
        type: "POST",
        url: './Assets/GetDateTime.php',
        dataType: 'json',
        data: {FunctionCall: 'GetDateTime', Args: {DoYouFeelMe: true}},
        success: function (Obj,Textstatus) {
            if( !('error' in Obj) ) {
                  return Obj.result;
              }
        }
    }
	Data = jQuery.ajax(JsonPost);
	return new Promise(resolve => {resolve(Data)});
}
UpdateDateTime().then(function(P1) {
    DateTime_Start = P1.DateTime;
    
	// If TaskIO has been set above, add vars in here!
	if (typeof(TaskIO)=="object") {
	    TaskIO.DateTime_Start = DateTime_Start;
	    TaskIO.ClientTimeZone = ClientTimeZone;
	}
});