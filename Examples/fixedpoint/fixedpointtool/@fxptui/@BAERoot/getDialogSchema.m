function dlgstruct = getDialogSchema(~, ~)
%GETDIALOGSCHEMA Get the dialog information.
%   OUT = GETDIALOGSCHEMA(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

r = 1;

%========= useShortcut ===========%
txt1 = ModelAdvisor.Text(fxptui.message('labelBatchEdit'),{'bold'});

txt2 = ModelAdvisor.Text(fxptui.message('txtUseSE'));

txt3 = ModelAdvisor.Text(fxptui.message('labelUseSE'),{'bold'});

list = ModelAdvisor.List;
list.addItem(ModelAdvisor.Text(fxptui.message('txtSECanDo1')));
list.addItem(ModelAdvisor.Text(fxptui.message('txtSECanDo2')));
list.addItem(ModelAdvisor.Text(fxptui.message('txtSECanDo3')));
list.addItem([ModelAdvisor.Text(fxptui.message('txtSECanDo4')), ModelAdvisor.LineBreak]);

txt4 = ModelAdvisor.Text(fxptui.message('labelUseSEManageRun'),{'bold'});

list2 = ModelAdvisor.List;
list2.addItem(ModelAdvisor.Text(fxptui.message('txtSEOptions1')));
list2.addItem([ModelAdvisor.Text(fxptui.message('txtSEOptions2')), ModelAdvisor.LineBreak]);

table=ModelAdvisor.Table(6,1);
table.setBorder(0);
table.setEntry(1,1,[txt1, ModelAdvisor.LineBreak]);
table.setEntry(2,1,[txt2,ModelAdvisor.LineBreak]);
table.setEntry(3,1,[txt4,ModelAdvisor.LineBreak]);
table.setEntry(4,1,list2);
table.setEntry(5,1,[txt3,ModelAdvisor.LineBreak]);
table.setEntry(6,1,list);
doc=ModelAdvisor.Document;
doc.addItem({table});

r = r+1;
txtUseSE.Text  = doc.emitHTML;
txtUseSE.Type  = 'textbrowser';
txtUseSE.Tag   = 'textbrowser_SE_Root';
txtUseSE.RowSpan = [r r];
txtUseSE.ColSpan = [1 5];

%=================
% Shortcuts group
%=================
% Main dialog
dlgstruct.DialogTitle = '';
dlgstruct.DialogTag = 'BAE_Root_Dialog';
dlgstruct.LayoutGrid  = [2 2]; 
dlgstruct.ColStretch = [0 1];% 0 0 1];
dlgstruct.Items = {txtUseSE};
dlgstruct.EmbeddedButtonSet = {'Help'};
dlgstruct.HelpMethod = 'helpview';
dlgstruct.HelpArgs = {[docroot '/toolbox/simulink/csh/blocks/fxptui.BAETreeNode.Batch_Action_Editor_Dialog.map'],'shortcut_help_button'};

% [EOF]
