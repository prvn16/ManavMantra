function eqntxtH = bfitcreateeqntxt(digits,axesh,dataH,fitsshowing)
% BFITCREATEEQNTXT Create text equations for Basic Fitting GUI.

%   Copyright 1984-2011 The MathWorks, Inc.

eqntxtH = [];
coeffcell = getappdata(double(dataH),'Basic_Fit_Coeff');
guistate = getappdata(double(dataH),'Basic_Fit_Gui_State');
normalized = guistate.normalize;

% If normalized, we will use "z" instead of "x" in the equation text except
% if the only fits showing are the interpolants.
if ~any(fitsshowing>2)
    normalized = false;
end

n = length(fitsshowing);
if normalized
    eqns = cell(n+2,1);
else
    eqns = cell(n+1,1);
end
eqns{1,:} = ' ';
for i = 1:n
    % get fit type
    currentInd = fitsshowing(i);
    fittype = currentInd - 1;
    % add string to matrix
    eqns{i+1,:} = eqntxtstring(fittype,coeffcell{currentInd},digits,axesh,normalized);
end
if normalized
    normalizers = getappdata(double(dataH),'Basic_Fit_Normalizers');
    % normalizers(1) = mean; normalizers(2) = std
    format = ['where z = (x - %0.', num2str(digits), 'g)/%0.', num2str(digits), 'g'];
    eqns{n+2,:} = sprintf(format, normalizers);
end
if ~isempty(eqns) && n > 0 
    eqntxtH = text(.05, .95, eqns,'parent',axesh, ...
        'tag', 'equations', ...
        'verticalalignment','top', ...);
        'units', 'normalized');
    %handle code generation for this text object in bfitMCodeConstructor.m
    b = hggetbehavior(eqntxtH,'MCodeGeneration');
    set(b, 'MCodeIgnoreHandleFcn', 'true');
end
%-------------------------------------------------------

function s = eqntxtstring(fitnum,pp,digits,axesh,normalized)

op = '+-';
if normalized
    format1 = ['%s %0.',num2str(digits),'g*z^{%s} %s'];
else
    format1 = ['%s %0.',num2str(digits),'g*x^{%s} %s'];
end
format2 = ['%s %0.',num2str(digits),'g'];

xl = get(axesh,'xlim');
if isequal(fitnum,0)
  s = getString(message('MATLAB:graph2d:bfit:CubicSplineInterpolant'));
elseif isequal(fitnum,1)
  s = getString(message('MATLAB:graph2d:bfit:ShapePreservingInterpolant'));
else
  fit = fitnum - 1;
  s = sprintf('y =');
  th = text(xl*[.95;.05],1,s,'parent',axesh, 'vis','off');
  if abs(pp(1) < 0), s = [s ' -']; end
  for i = 1:fit
    sl = length(s);
    if ~isequal(pp(i),0) % if exactly zero, skip it
      s = sprintf(format1,s,abs(pp(i)),num2str(fit+1-i), op((pp(i+1)<0)+1));
    end    
    if (i==fit) && ~isequal(pp(i),0), s(end-5:end-2) = []; end % change x^1 to x.
    set(th,'string',s);
    et = get(th,'extent');
    if et(1)+et(3) > xl(2)
      s = [s(1:sl) sprintf('\n     ') s(sl+1:end)];
    end
  end
  if ~isequal(pp(fit+1),0)
    sl = length(s);
    s = sprintf(format2,s,abs(pp(fit+1)));
    set(th,'string',s);
    et = get(th,'extent');
    if et(1)+et(3) > xl(2)
      s = [s(1:sl) sprintf('\n     ') s(sl+1:end)];
    end
  end
  delete(th);
end

% delete last '+' if one is left hanging on the end
if isequal(s(end),'+')
    s(end-1:end) = []; % there is always a space before the +.
end

if length(s) == 3
    s = sprintf(format2,s,0);
end

