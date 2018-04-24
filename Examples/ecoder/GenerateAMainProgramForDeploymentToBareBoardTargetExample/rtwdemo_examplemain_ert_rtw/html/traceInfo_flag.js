function TraceInfoFlag() {
    this.traceFlag = new Array();
    this.traceFlag["rtwdemo_examplemain.c:46c42"]=1;
    this.traceFlag["rtwdemo_examplemain.c:57c18"]=1;
    this.traceFlag["rtwdemo_examplemain.c:57c43"]=1;
    this.traceFlag["rtwdemo_examplemain.c:69c19"]=1;
    this.traceFlag["rtwdemo_examplemain.c:69c44"]=1;
    this.traceFlag["rtwdemo_examplemain.c:69c58"]=1;
    this.traceFlag["rtwdemo_examplemain.c:69c64"]=1;
    this.traceFlag["rtwdemo_examplemain.c:83c29"]=1;
    this.traceFlag["rtwdemo_examplemain.c:83c36"]=1;
}
top.TraceInfoFlag.instance = new TraceInfoFlag();
function TraceInfoLineFlag() {
    this.lineTraceFlag = new Array();
    this.lineTraceFlag["rtwdemo_examplemain.c:46"]=1;
    this.lineTraceFlag["rtwdemo_examplemain.c:47"]=1;
    this.lineTraceFlag["rtwdemo_examplemain.c:57"]=1;
    this.lineTraceFlag["rtwdemo_examplemain.c:69"]=1;
    this.lineTraceFlag["rtwdemo_examplemain.c:78"]=1;
    this.lineTraceFlag["rtwdemo_examplemain.c:83"]=1;
}
top.TraceInfoLineFlag.instance = new TraceInfoLineFlag();
