function I = getVarBrushArrayUsingLinkedBehavior(varNames,subsStr,bobj,...
    objH,region,lastregion,extendMode,mfile,fcnname)

% Obtains a logical array the same size as a subreferenced linked variable
% representing data brushed by the specified region for cases where the
% linked variable is represnted by a graphic object with a link behavior object.

%   Copyright 2014-2015 The MathWorks, Inc.

% Get the existing variable brushing array after accounting for subreferences
% for this graphic object
brushMgr = datamanager.BrushManager.getInstance();
if isprop(objH,'LinkDataError') && ~isempty(objH.LinkDataError)
	    % Return empty of there was an error evaluating linked data
	    I = [];
        return
end
I = brushMgr.getBrushingProp(varNames,mfile,fcnname,'I');
if ~isempty(I) && ~isempty(subsStr)
    Isubs = eval(['I' subsStr ';']);
else
    Isubs = I;
end
Iextend =[];
Icontract = [];
% Find logical arrays the same size as the sub-referenced linked variable
% representing expanded/constracted points
if length(region)>2 % ROI brushing
    Icurrent = false(size(Isubs));
    Icurrent(feval(bobj.LinkBrushQueryFcn{1},bobj,region,objH,bobj.LinkBrushQueryFcn{2:end})) = true;
    if ~isempty(lastregion)
        Ilast = false(size(Isubs));
        Ilast(feval(bobj.LinkBrushQueryFcn{1},bobj,...
           lastregion,objH,bobj.LinkBrushQueryFcn{2:end})) = true;                        
        Iextend= Icurrent & ~Ilast;
        Icontract = ~Icurrent & Ilast;
    else
        Iextend = Icurrent;
        Icontract = [];
    end
elseif length(region)==2 % Single click brushing
    Iextend = false(size(Isubs));
    Iextend(feval(bobj.LinkBrushQueryFcn{1},bobj,region,objH,bobj.LinkBrushQueryFcn{2:end})) = true;
    Icontract = [];   
elseif isempty(region)
    Iextend = [];
    Icontract = [];
end

% Set the variable brushing array for the newly selected region
if ~isempty(bobj.LinkBrushUpdateIFcn)
    Isubs = feval(bobj.LinkBrushUpdateIFcn{1},bobj,Isubs,Iextend,Icontract,...
        extendMode,objH,bobj.LinkBrushUpdateIFcn{2:end});
end
if ~extendMode
    Isubs(Iextend) = true;
    Isubs(Icontract) = false;                
else
    Isubs(Iextend) = ~Isubs(Iextend);
    Isubs(Icontract) = ~Isubs(Icontract);
end
if ~isempty(I) && ~isempty(subsStr)
    eval(['I' subsStr ' = Isubs;']);
else
    I = Isubs;
end