function CodeDefine() { 
this.def = new Array();
this.def["rt_OneStep"] = {file: "ert_main_c.html",line:37,type:"fcn"};
this.def["main"] = {file: "ert_main_c.html",line:123,type:"fcn"};
this.def["rtDWork"] = {file: "rtwdemo_examplemain_c.html",line:23,type:"var"};
this.def["rtU"] = {file: "rtwdemo_examplemain_c.html",line:26,type:"var"};
this.def["rtY"] = {file: "rtwdemo_examplemain_c.html",line:29,type:"var"};
this.def["rtM_"] = {file: "rtwdemo_examplemain_c.html",line:32,type:"var"};
this.def["rtM"] = {file: "rtwdemo_examplemain_c.html",line:33,type:"var"};
this.def["rtwdemo_examplemain_step0"] = {file: "rtwdemo_examplemain_c.html",line:36,type:"fcn"};
this.def["rtwdemo_examplemain_step1"] = {file: "rtwdemo_examplemain_c.html",line:75,type:"fcn"};
this.def["rtwdemo_examplemain_initialize"] = {file: "rtwdemo_examplemain_c.html",line:87,type:"fcn"};
this.def["RT_MODEL"] = {file: "rtwdemo_examplemain_h.html",line:37,type:"type"};
this.def["D_Work"] = {file: "rtwdemo_examplemain_h.html",line:44,type:"type"};
this.def["ExternalInputs"] = {file: "rtwdemo_examplemain_h.html",line:50,type:"type"};
this.def["ExternalOutputs"] = {file: "rtwdemo_examplemain_h.html",line:56,type:"type"};
this.def["int8_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:46,type:"type"};
this.def["uint8_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:47,type:"type"};
this.def["int16_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:48,type:"type"};
this.def["uint16_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:49,type:"type"};
this.def["int32_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:50,type:"type"};
this.def["uint32_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:51,type:"type"};
this.def["int64_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:52,type:"type"};
this.def["uint64_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:53,type:"type"};
this.def["real32_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:54,type:"type"};
this.def["real64_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:55,type:"type"};
this.def["real_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:61,type:"type"};
this.def["time_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:62,type:"type"};
this.def["boolean_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:63,type:"type"};
this.def["int_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:64,type:"type"};
this.def["uint_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:65,type:"type"};
this.def["ulong_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:66,type:"type"};
this.def["ulonglong_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:67,type:"type"};
this.def["char_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:68,type:"type"};
this.def["uchar_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:69,type:"type"};
this.def["byte_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:70,type:"type"};
this.def["pointer_T"] = {file: "../../slprj/ert/_sharedutils/html/rtwtypes_h.html",line:91,type:"type"};
}
CodeDefine.instance = new CodeDefine();
var testHarnessInfo = {OwnerFileName: "", HarnessOwner: "", HarnessName: "", IsTestHarness: "0"};
var relPathToBuildDir = "../ert_main.c";
var fileSep = "\\";
var isPC = true;
function Html2SrcLink() {
	this.html2SrcPath = new Array;
	this.html2Root = new Array;
	this.html2SrcPath["ert_main_c.html"] = "../ert_main.c";
	this.html2Root["ert_main_c.html"] = "ert_main_c.html";
	this.html2SrcPath["rtwdemo_examplemain_c.html"] = "../rtwdemo_examplemain.c";
	this.html2Root["rtwdemo_examplemain_c.html"] = "rtwdemo_examplemain_c.html";
	this.html2SrcPath["rtwdemo_examplemain_h.html"] = "../rtwdemo_examplemain.h";
	this.html2Root["rtwdemo_examplemain_h.html"] = "rtwdemo_examplemain_h.html";
	this.html2SrcPath["rtwtypes_h.html"] = "../rtwtypes.h";
	this.html2Root["rtwtypes_h.html"] = "../../slprj/ert/_sharedutils/html/rtwtypes_h.html";
	this.getLink2Src = function (htmlFileName) {
		 if (this.html2SrcPath[htmlFileName])
			 return this.html2SrcPath[htmlFileName];
		 else
			 return null;
	}
	this.getLinkFromRoot = function (htmlFileName) {
		 if (this.html2Root[htmlFileName])
			 return this.html2Root[htmlFileName];
		 else
			 return null;
	}
}
Html2SrcLink.instance = new Html2SrcLink();
var fileList = [
"ert_main_c.html","rtwdemo_examplemain_c.html","rtwdemo_examplemain_h.html","rtwtypes_h.html"];
