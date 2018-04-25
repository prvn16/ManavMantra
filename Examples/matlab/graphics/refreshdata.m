function refreshdata(h,workspace)
%REFRESHDATA Refresh data in plot
%   REFRESHDATA evaluates any data source properties in the
%   plots in the current figure and sets the corresponding data
%   properties of each plot.
%
%   REFRESHDATA(FIG) refreshes the data in figure FIG.
%
%   REFRESHDATA(H) for a vector of handles H refreshes the data of
%   the objects specified in H or the children of those
%   objects. Therefore, H can contain figure, axes, or plot object
%   handles.
%
%   REFRESHDATA(H,WS) evaluates the data source properties in the
%   workspace WS. WS can be 'caller' or 'base'. The default
%   workspace is 'base'.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 1
    workspace = convertStringsToChars(workspace);
end

if nargin == 0
    h = gcf;
end
if nargin < 2
    workspace = 'base';
end
if iscell(h), h = [h{:}]; end
h = unique(h(ishghandle(h)));
h = handle(findall(h));

if isempty(h)
    error(message('MATLAB:refreshdata:InvalidInput'));
end

for k = 1:length(h)
    obj = h(k);
    
    % Create a pvpairs array comprising Data,Value pairs for each 
    % property which corresponds to a data source (e.g. pair 'Ydata',ydata
    % for  YDataSource)
    objfields = fields(obj);
    datasourcefields = cellfun(@(x) strncmpi(fliplr(x),'ecruoSataD',10),objfields);
    
    % ErrorBar uses 'Delta' instead of 'Data' for some data fields.
    deltasourcefields = cellfun(@(x) strncmpi(fliplr(x),'ecruoSatleD',11),objfields);
    
    objfields = objfields(datasourcefields | deltasourcefields);
    pvpairs = {};
    srcStrings = {};
    for j=1:length(objfields)
        srcString = get(obj,objfields{j});
        if ~isempty(srcString)
            prop = objfields{j}(1:end-6); % Remove 'source'
            val = evalin(workspace,srcString);
            pvpairs = [pvpairs {prop,val}]; %#ok<AGROW>
            srcStrings = [srcStrings {srcString}]; %#ok<AGROW>
        end
    end
    
    % Try setting the affected properties in a single set statement. If that fails,
    % set the properties one-by-one until the first assignment fails.
    try
        if ~isempty(pvpairs)
            set(obj,pvpairs{:});
        end
    catch err %#ok<NASGU>
        haderror = false;
        try
            for j = 1:length(pvpairs)/2
                set(obj,pvpairs{2*j-1},pvpairs{2*j});
            end
        catch me %#ok<NASGU>
            haderror = true;
        end
        if haderror
            error(message('MATLAB:refreshdata:InvalidSource',pvpairs{2*j-1},srcStrings{j}));
        end
    end
end
