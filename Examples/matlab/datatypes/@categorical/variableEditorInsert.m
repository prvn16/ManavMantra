function out = variableEditorInsert(this,orientation,row,col,data)
% These functions are for internal use only and will change in a
% future release.  Do not use this function.

% Performs a insert operation on data from the clipboard.

%   Copyright 2013-2015 The MathWorks, Inc.

% Get the inserted data as a nominal
if isa(data,'categorical')
    varData = data;
else
    varData = categorical(data);
end

if strcmp('columns',orientation)
    if col<=size(this,2)
        %this = [this(:,1:col-1) varData this(:,col:end)];
        this =  horzcat(subsref(this,struct('type',{'()'},'subs',{{':',1:col-1}})),...
            varData,subsref(this,struct('type',{'()'},'subs',{{':',col:size(this,2)}})));        
    else
        %this = [this(:,1:size(this,2)) varData];
        this =  horzcat(subsref(this,struct('type',{'()'},'subs',{{':',1:size(this,2)}})),varData); 
    end
else
    if row<=size(this,1)
        %this = [this(1:row-1,:); varData; this(row:end,:)];
        this =  vertcat(subsref(this,struct('type',{'()'},'subs',{{1:row-1,':'}})),...
            varData,subsref(this,struct('type',{'()'},'subs',{{row:size(this,1),':'}}))); 
    else
        %this = [this(1:row,:); varData];
        this =  vertcat(subsref(this,struct('type',{'()'},'subs',{{1:size(this,1),':'}})),varData); 
    end
end

out = this;
