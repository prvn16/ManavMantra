function CodeMetrics() {
	 this.metricsArray = {};
	 this.metricsArray.var = new Array();
	 this.metricsArray.fcn = new Array();
	 this.metricsArray.var["rtDWork"] = {file: "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\ecoder\\GenerateAMainProgramForDeploymentToBareBoardTargetExample\\rtwdemo_examplemain_ert_rtw\\rtwdemo_examplemain.c",
	size: 24};
	 this.metricsArray.var["rtM_"] = {file: "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\ecoder\\GenerateAMainProgramForDeploymentToBareBoardTargetExample\\rtwdemo_examplemain_ert_rtw\\rtwdemo_examplemain.c",
	size: 9};
	 this.metricsArray.var["rtU"] = {file: "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\ecoder\\GenerateAMainProgramForDeploymentToBareBoardTargetExample\\rtwdemo_examplemain_ert_rtw\\rtwdemo_examplemain.c",
	size: 16};
	 this.metricsArray.var["rtY"] = {file: "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\ecoder\\GenerateAMainProgramForDeploymentToBareBoardTargetExample\\rtwdemo_examplemain_ert_rtw\\rtwdemo_examplemain.c",
	size: 16};
	 this.metricsArray.fcn["rtwdemo_examplemain_initialize"] = {file: "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\ecoder\\GenerateAMainProgramForDeploymentToBareBoardTargetExample\\rtwdemo_examplemain_ert_rtw\\rtwdemo_examplemain.c",
	stack: 0,
	stackTotal: 0};
	 this.metricsArray.fcn["rtwdemo_examplemain_step0"] = {file: "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\ecoder\\GenerateAMainProgramForDeploymentToBareBoardTargetExample\\rtwdemo_examplemain_ert_rtw\\rtwdemo_examplemain.c",
	stack: 0,
	stackTotal: 0};
	 this.metricsArray.fcn["rtwdemo_examplemain_step1"] = {file: "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\ecoder\\GenerateAMainProgramForDeploymentToBareBoardTargetExample\\rtwdemo_examplemain_ert_rtw\\rtwdemo_examplemain.c",
	stack: 0,
	stackTotal: 0};
	 this.getMetrics = function(token) { 
		 var data;
		 data = this.metricsArray.var[token];
		 if (!data) {
			 data = this.metricsArray.fcn[token];
			 if (data) data.type = "fcn";
		 } else { 
			 data.type = "var";
		 }
	 return data; }; 
	 this.codeMetricsSummary = '<a href="rtwdemo_examplemain_metrics.html">Global Memory: 65(bytes) Maximum Stack: 0(bytes)</a>';
	}
CodeMetrics.instance = new CodeMetrics();
