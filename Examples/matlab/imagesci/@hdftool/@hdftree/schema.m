function schema
%SCHEMA Define the HDFTREE class.

%   Copyright 2004-2013 The MathWorks, Inc.

    pkg = findpackage('hdftool');
    parent = pkg.findclass('filetree');

    myPkg = findpackage('hdftool');
    cls = schema.class(myPkg,'hdftree', parent);

    prop(1) = schema.prop(cls,'staticGridPanel', 'MATLAB array');
    prop(2) = schema.prop(cls,'staticRasterPanel', 'MATLAB array');
    prop(3) = schema.prop(cls,'staticSdsPanel', 'MATLAB array');
    prop(4) = schema.prop(cls,'staticSwathPanel', 'MATLAB array');
    prop(5) = schema.prop(cls,'staticVdataPanel', 'MATLAB array');
    prop(6) = schema.prop(cls,'staticPointPanel', 'MATLAB array');

    set(prop,'AccessFlags.PrivateGet','on',...
        'AccessFlags.PrivateSet','on',...
        'AccessFlags.PublicGet','off',...
        'AccessFlags.PublicSet','off');

    public_prop(1) = schema.prop(cls,'mainPanel','MATLAB array');
    public_prop(2) = schema.prop(cls,'mainLayout','MATLAB array');
    public_prop(3) = schema.prop(cls,'subsetPanelContainer','MATLAB array');
    public_prop(4) = schema.prop(cls,'splitPane','MATLAB array');
    public_prop(5) = schema.prop(cls,'matlabCmd','MATLAB array');
    public_prop(5).SetFunction = @setMLCmd;
    public_prop(6) = schema.prop(cls,'wsvarname','MATLAB array');
    public_prop(6).SetFunction = @setWSvarName;
    public_prop(6).GetFunction = @getWSvarName;
    public_prop(7) = schema.prop(cls,'hImportMetadata','MATLAB array');
    public_prop(8) = schema.prop(cls,'wsvarnamehandle','MATLAB array');
    public_prop(9) = schema.prop(cls,'matlabCmdhandle','MATLAB array');
    public_prop(10) = schema.prop(cls,'iconPath','MATLAB array');
    public_prop(11) = schema.prop(cls,'bHDFEOS','MATLAB array');
    public_prop(12) = schema.prop(cls,'fullpath','MATLAB array');


    set(public_prop,'AccessFlags.PrivateGet','on',...
        'AccessFlags.PrivateSet','on',...
        'AccessFlags.PublicGet','on',...
        'AccessFlags.PublicSet','on');

    function newvalue = setWSvarName(this,newvalue)
		if isempty(newvalue)
			newvalue = 'X';
		end
        chk = isstrprop(newvalue,'alphanum');
        newvalue(~chk) = '_';
        if ~isstrprop(newvalue(1),'alpha')
            newvalue = ['A',newvalue];
        end
        set(this.wsvarnamehandle,'String',newvalue);
    end

    function out = getWSvarName(this,prop)
        out = get(this.wsvarnamehandle,'String');
    end

    function newvalue = setMLCmd(this,newvalue)
        set(this.matlabCmdhandle,'String',newvalue);
    end
end
