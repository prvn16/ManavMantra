(function(){
var _1=[];
var _2=function(){
};
function _3(_4,_5){
parent.postMessage(_4+";"+_5||"","*");
};
function _6(id,_7){
var _8=id+";success;"+_7;
_3("sendMessageResponse",_8);
};
function _9(id,_a){
var _b=id+";fault;"+_a;
_3("sendMessageResponse",_b);
};
function _c(_d){
var _e,_f,id,_10,_11,_12,i,_13,_14;
var xhr,_15,_16;
if(_d.source===parent){
var _17=_d.data.indexOf(";");
var _18=_d.data.substring(0,_17);
if(!_18){
throw new Error("Unable to parse message, no action specified: "+_d.data);
}
switch(_18){
case "sendMessage":
_e=_d.data.indexOf(";",_17+1);
_f=_d.data.indexOf(";",_e+1);
_13=_d.data.indexOf(";",_f+1);
id=_d.data.substring(_17+1,_e);
_10=_d.data.substring(_e+1,_f);
_14=JSON.parse(_d.data.substring(_f+1,_13));
_11=_d.data.substring(_13+1,_d.data.length);
if(id&&_10&&_11){
try{
xhr=new XMLHttpRequest();
_15=false;
xhr.onreadystatechange=function(){
var _19;
if(xhr.readyState===0){
_15=true;
_9(id,"XHR readyState 0");
}else{
if(xhr.readyState===4&&!_15){
_15=true;
_19=xhr.status||0;
if((_19>=200&&_19<300)||_19===304){
_6(id,xhr.responseText);
}else{
_9(id,xhr.responseText);
}
}
}
if(_15&&xhr){
xhr.onreadystatechange=_2;
xhr=null;
}
};
xhr.open("POST",_10,true);
xhr.setRequestHeader("Content-Type",_14.contentType?_14.contentType:"application/json");
xhr.setRequestHeader("X-Requested-With","XMLHttpRequest");
if(_14.headers){
for(_16 in _14.headers){
if(_14.headers.hasOwnProperty(_16)){
xhr.setRequestHeader(_16,_14.headers[_16]);
}
}
}
xhr.send(_11);
}
catch(e){
_9(id,"Unable to send data: "+e.toString());
}
}else{
throw new Error("Invalid message to send: "+_d.data);
}
break;
case "createUploadIframe":
id=_d.data.substring(_17+1,_d.data.length);
if(!document.getElementById(id)){
_12=document.createElement("iframe");
_12.id=id;
_12.name=id;
_12.src="about:blank";
_12.width=0;
_12.height=0;
_12.style="visibility: hidden; display: none;";
_1.push(_12);
document.body.appendChild(_12);
}
break;
case "cancelUpload":
id=_d.data.substring(_17+1,_d.data.length);
var _1a=document.getElementById(id);
if(_1a){
if(navigator.appVersion.indexOf("MSIE")!==-1){
_1a.contentWindow.document.execCommand("Stop");
}else{
_1a.contentWindow.stop();
}
}
break;
default:
throw new Error("Unknown action: "+_18);
}
}else{
for(i=0;i<_1.length;i+=1){
if(_d.source===_1[i].contentWindow){
_3("uploadIframeMessage",_1[i].id+";"+_d.data);
}
}
}
};
addEventListener("message",function(_1b){
_c(_1b);
});
_3("ready","");
if(window.console){
console.log("iframe "+location+" ready at "+new Date());
}
}());

