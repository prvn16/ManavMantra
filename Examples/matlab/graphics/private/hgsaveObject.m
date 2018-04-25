function Obj = hgsaveObject(h)
%hgsaveObject Save object handles natively.
%
%  hgsaveObject prepares handles for saving using MATLAB class system's
%  saving system.

%   Copyright 2009-2012 The MathWorks, Inc.

if ~isempty(h)
    % Filter out non-serializable objects
    hasSer = isprop(h, 'Serializable');
    IsSer = get(h(hasSer), {'Serializable'});
    
    DoSer = ~hasSer;
    DoSer(hasSer) = strcmp(IsSer, 'on');
    Obj = h(DoSer);
else
    Obj = h;
end
Obj = Obj(:).';
