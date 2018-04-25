function bfitcreatelegend(axesH,remove,removedataH,fighandle,legH)
% BFITCREATELEGEND Create or update legend on figure for Data Stats 
%    and Basic Fitting GUIs.

%   Copyright 1984-2016 The MathWorks, Inc.

% Ignore axes whose Tags are 'PrintUI'. (They are temporary axes for
% printing.)
if strcmpi(get(axesH, 'Tag'), 'PrintUI')
    return;
end

% The legend handle is optional
if nargin < 5 || isempty(legH)
    legH = [];
end

% We can't always get the figure from the axes parent because the axes
% may be orphaned in MCOS graphics if the axes was deleted
if nargin < 4 || isempty(fighandle)
    fighandle = ancestor(axesH,'figure');
end

% The first time this function is called, create a legend and set
% app data to indicate that we have been called at least once for this 
% axes.
% After the first time, check to see whether or not a legend exists and
% do not create (a new) legend if none exists (we assume the user has
% turned it off).

if nargin < 3
    % These are when we need to update the legend after a RemoveLine listener fires:
    %   the line is still in the HG hierarchy, so we have to take it out directly.
    remove = 0;
    removedataH = [];
end

datahandles = double(getappdata(fighandle,'Basic_Fit_Data_All'));
axeshandles = double(getappdata(fighandle,'Basic_Fit_Axes_All'));

% Remove data that is gone from the figure but still in the HG hierarchy.
% Leave axes list alone in case axes still there even though data deleted so
% legend will be deleted.

if remove
    if ~isempty(removedataH)
        datahandles(removedataH==datahandles) = [];
    end
end

% For all potential data, get the parent axes and turn into an array
dataaxescell = ancestor(datahandles,'axes');
if iscell(dataaxescell)
    dataaxes = [dataaxescell{:}];
else
    dataaxes = dataaxescell;
end

% For each unique axis handle, call legend on that axis with 
% all the data handles in that axis
if isempty(axeshandles)
    createaxislegend(axesH,[],legH);
end

for i=1:length(axeshandles)
    if ~isequal(handle(axeshandles(i)),handle(axesH))
        continue;
    end
    
    ah = handle(axeshandles(i));
    if ~isappdata(ah, 'Basic_Fit_Data_Stats_first_time_legend_flag')
        setappdata(ah, 'Basic_Fit_Data_Stats_first_time_legend_flag', false);
    elseif ~ishghandle(handle(ah)) || (isempty(legend('-find',ah)) && (isempty(legH) || (~isempty(legH) && axesH~=axeshandles(i))))
        continue;
    end
    if ~isempty(datahandles)
        axesdata = datahandles(dataaxes == axeshandles(i));
    else
        axesdata = [];
    end
    % If this was the last data in the axis, the legend will go away; If a 
    % legend exists, we want to remove the first_time flag so  that the 
    % legend will return when data is added. 
    if remove && isempty(axesdata) && ...
         isappdata(ah, 'Basic_Fit_Data_Stats_first_time_legend_flag') && ...
        ~isempty(legend('-find',ah))
        rmappdata(ah, 'Basic_Fit_Data_Stats_first_time_legend_flag');
    end 
    createaxislegend(ah,axesdata,legH);
end


%-------------------------------------------------------------------------------------
function legendH = createaxislegend(axesH,datahandles,legH)

allH = []; allM = [];

% get legend info
if isempty(legH)
    l = legend('-find',handle(axesH));
else
    l = legH;
end
legh=[];
oldhandles=[];
oldstrings=[];
if ~isempty(l)
    legh=l;
    % Using _I properties to avoid triggering an update traversal here
    % since BasicFitting is doing a version of legend AutoUpdate.
    oldhandles = l.PlotChildren_I;
    oldstrings = l.String_I;
end
if ~isempty(legh)
	% for each handle in legend put in legend entry
	% If it's a datahandle, create a legend for it.
    bfit = zeros(length(oldhandles),1);
	for i=1:length(oldhandles)
		if ishghandle(oldhandles(i)) % could be a deleted handle
			appdata = getappdata(double(oldhandles(i)),'bfit');
			bfit(i) = ~isempty(appdata);
			if bfit(i)
				% if datahandle, then create legend for it.
				% otherwise, it was created by basic fit, so ignore:
				% it will get recreated with it's datahandle legend.
				if ~isempty(datahandles) && any(oldhandles(i) == datahandles)
					[tmpH, tmpM] = createdatalegend(oldhandles(i));
					allH = [allH, tmpH]; %#ok<AGROW>
					allM = strvcat(allM,tmpM);
				end
			else % not bfit
				allH = [allH, oldhandles(i)];
				allM = strvcat(allM,oldstrings{i});
			end
		end
	end
end

% Check for any data not in a legend
for i=1:length(datahandles)
	if isempty(oldhandles) || all(oldhandles ~= datahandles(i))
		[tmpH, tmpM] = createdatalegend(datahandles(i));
		allH = [allH, tmpH]; %#ok<AGROW>
		allM = strvcat(allM,tmpM);
	end
end
if length(oldstrings) > length(oldhandles)
	allM = strvcat(allM, oldstrings{(length(oldhandles)+1):end});
end

if ~isempty(allH)
    fig = ancestor(axesH,'figure');
    if isempty(legh)
        bfitlistenoff(fig);
        legh = legend(axesH, allH, allM);
        bfitlistenon(fig);
        bfitlisten(legh);
    else
        bfitlistenoff(fig);
%         legh = legend(axesH, allH);
        legh.PlotChildren = allH;
        legh.PlotChildrenSpecified = allH;
        if ~iscell(allM)
          allM = cellstr(allM);
        end
        legh.String = allM;
%         legh.doMethod('clearEntries');
        bfitlistenon(fig);
    end
    legendH = legh;
else
    legend(axesH,'off');
    legendH = [];
end

%------------------------------------------------------------------------
function [H, M] = createdatalegend(dataH)

numdata = 1;
dataname = getappdata(double(dataH),'bfit_dataname');
% Get the length of the longest legend entry:
maxLegendLength = bfitgetmaxlegendlength();
% add 3 spaces for the indent
maxstringlength = max(maxLegendLength + 3, length(dataname));  

bfitappdata = getappdata(double(dataH),'bfit');
if ~isempty(bfitappdata) && ~isequal(bfitappdata.type,'data')
    H = double(dataH);
    M = char(repmat(32,1,maxstringlength)); 
    if ~isempty(dataH) % data
        M(1,1:length(dataname)) = dataname;
    end
else
    % get bfit info
    evalresults = getappdata(double(dataH), 'Basic_Fit_EvalResults');
    
    % pasted bfit line could have an invalid handle
    evalresultsH = [];
    if ~isempty(evalresults) ... 
      && ~isempty(evalresults.handle) ...
      && ishghandle(evalresults.handle)
        evalresultsH = evalresults.handle;
    end
    
    fitshandles = double(getappdata(double(dataH),'Basic_Fit_Handles'));
    fitsvalid = find(isfinite(fitshandles) & ishghandle(fitshandles));
    
    % get datastat info
    xstathandles = double(getappdata(double(dataH),'Data_Stats_X_Handles'));
    xstatvalid = find(isfinite(xstathandles) & ishghandle(xstathandles));
    ystathandles = double(getappdata(double(dataH),'Data_Stats_Y_Handles'));
    ystatvalid = find(isfinite(ystathandles) & ishghandle(ystathandles));
    Hstat = [xstathandles(xstatvalid), ystathandles(ystatvalid)];
    H = [double(dataH), double(fitshandles(fitsvalid)), double(evalresultsH), double(Hstat)];
    
    numfits = length(fitsvalid);
    numxstats = length(xstatvalid);
    numystats = length(ystatvalid);
    if isempty(evalresultsH)
        numevalresults = 0;
    else
        numevalresults = 1;
    end
    
    n = numdata + numfits + numevalresults + numxstats + numystats;
    M = char(repmat(32,n,maxstringlength)); 
    if ~isempty(dataH) % data
        M(1,1:length(dataname)) = dataname;
    end
    for i = 1:numfits
        % get fit type
        fittype = fitsvalid(i)-1;
        % add string to matrix
        M(numdata+i,:) = bfitgetlegendstring('fit',fittype,maxstringlength);
    end
    if numevalresults
        M(numdata+numfits+numevalresults,:) = bfitgetlegendstring('eval results',0,maxstringlength);
    end
    for i = 1:numxstats
        % add string to matrix
        M(numdata+numfits+numevalresults+i,:) = bfitgetlegendstring('xstat',xstatvalid(i),maxstringlength, dataH);
    end
    for i = 1:numystats
        % add string to matrix
        M(numdata+numfits+numevalresults+numxstats+i,:) = bfitgetlegendstring('ystat',ystatvalid(i),maxstringlength, dataH);
    end
end

H = handle(H);