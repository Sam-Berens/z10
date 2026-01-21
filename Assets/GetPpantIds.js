function GetPoolIds() {
    // Self-contained code to grab ProlificId and/or SubjectId:
	var CurrentUrl = window.location.href;
	var QueryStart = CurrentUrl.indexOf("?") + 1;
	var QueryEnd = CurrentUrl.indexOf("#") + 1 || CurrentUrl.length + 1;
	var Query = CurrentUrl.slice(QueryStart, QueryEnd - 1);
	var Pairs = Query.replace(/\+/g, " ").split("&");
	var UrlParams = {};
	var i, n, v, nv;
	if (!(Query === CurrentUrl || Query === "")) {
	    for (i = 0; i < Pairs.length; i++) {
		    nv = Pairs[i].split("=", 2);
		    n = decodeURIComponent(nv[0]);
		    v = decodeURIComponent(nv[1]);
		    if (!UrlParams.hasOwnProperty(n)) {
		        UrlParams[n] = [];
		    }
		    UrlParams[n].push(nv.length === 2 ? v : null);
	    }
	}
	var IsEmpty = true;
	for(var Key in UrlParams) {
	    if (UrlParams.hasOwnProperty(Key)) {
	        IsEmpty = false;
	    }
	}
	if (!IsEmpty) {
	    if (UrlParams.hasOwnProperty('PROLIFIC_PID')) {
	        PoolId = UrlParams.PROLIFIC_PID[0];
	    }
	    if (UrlParams.hasOwnProperty('PoolId')) {
	        PoolId = UrlParams.PoolId[0];
	    }
	    if (UrlParams.hasOwnProperty('SubjectId')) {
	        SubjectId = UrlParams.SubjectId[0];
	    }
	} else {
	    // Keep PoolId and SubjectId at null
	}
	
	// If TaskIO has been set above, add vars in here!
	if (typeof(TaskIO)=="object") {
	    TaskIO.SubjectId = SubjectId;
	}
}

function Sid2Sin(Sid) {
	// SubjectId (Sid) to SubjectInteger (Sin)
	let dotProd = (a, b) => a.map((x, i) => a[i] * b[i]).reduce((m, n) => m + n);
	let v = Sid.split('').map(function(s){
		s = s.toLowerCase();
		let i = s.charCodeAt(0);
		if (i < 97) {
			i = i - 48;
		} else {
			i = i - 97 + 10;
		}
		return i;
	});
	let w = Array.from(Array(v.length).keys()).reverse().map(function(i){return Math.pow(36,i)});
	let Sin = dotProd(v,w);
	return Sin;
}

var PoolId = null;
var SubjectId = null;
var SubjectInt = null;
GetPoolIds();
if (SubjectId) {
	SubjectInt = Sid2Sin(SubjectId);
}