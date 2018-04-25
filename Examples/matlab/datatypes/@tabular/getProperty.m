function [varargout] = getProperty(t,name,createIfEmpty)
%GETPROPERTY Get a table property.

%   Copyright 2012-2016 The MathWorks, Inc.

import matlab.tabular.Continuity

if nargin < 3, createIfEmpty = false; end

% We may be given a name (when called from get), or a subscript expression
% that starts with a '.name' subscript (when called from subsref).  Get the
% name and validate it in any case.
if isstruct(name)
    s = name;
    if s(1).type == '.'
        name = s(1).subs;
    else
        error(message('MATLAB:table:InvalidSubscript'));
    end
    haveSubscript = true;
else
    haveSubscript = false;
end
% Allow partial match for property names if this is via the get method;
% require exact match if it is via subsref
name = tabular.matchPropertyName(name,t.propertyNames,haveSubscript);

% Get the property out of the table.  Some properties need special handling
% when empty:  create either a non-empty default version or a "canonical" 0x0
% cell array (subscripting can sometimes make them 1x0 or 0x1), depending on
% what the caller asks for.
switch name
case {'RowNames' 'RowTimes'}
    if t.rowDim.hasLabels || ~createIfEmpty
        p = t.rowDim.labels;
    else
        p = t.rowDim.defaultLabels();
    end
case 'VariableNames'
    p = t.varDim.labels;
    % varnames are "always there", so leave them 1x0 when empty
case 'DimensionNames'
    p = t.metaDim.labels;
case 'VariableDescriptions'
    p = t.varDim.descrs;
    if ~t.varDim.hasDescrs && createIfEmpty
        p = repmat({''},1,t.varDim.length);
    end
case 'VariableUnits'
    p = t.varDim.units;
    if ~t.varDim.hasUnits && createIfEmpty
        p = repmat({''},1,t.varDim.length);
    end
case 'VariableContinuity'
    p = t.varDim.continuity;
    if ~t.varDim.hasContinuity && createIfEmpty
        p = repmat(Continuity.unset,1,t.varDim.length);
    end
case 'Description'
    p = t.arrayProps.Description;
case 'UserData'
    p = t.arrayProps.UserData;
end

if haveSubscript && ~isscalar(s)
    % If this is 1-D named parens/braces subscripting, convert labels to 
    % correct indices for properties that support subscripting with labels. 
    % e.g. t.Properties.VariableUnits('SomeVarName')
    if ~ strcmp(name,'UserData')
        if ~strcmp(s(2).type,'.') && isscalar(s(2).subs)
            sub = s(2).subs{1};
            if matlab.internal.datatypes.isCharStrings(sub) % a name, names, or colon
                switch name
                    case {'VariableNames' 'VariableDescriptions' 'VariableUnits' 'VariableContinuity'}
                        % Most subs2inds callers want a colon expanded out, here we don't.
                        if strcmp(sub, ':')
                            inds = sub;
                        else
                            inds = t.varDim.subs2inds(sub);
                        end
                    case 'RowNames'
                        inds = t.rowDim.subs2inds(sub);
                    case 'DimensionNames'
                        inds = t.metaDim.subs2inds(sub);
                end
                % subs2inds returns the indices as row/col/col vectors, but a
                % table's properties aren't "on the grid", and so should follow the usual
                % reshaping rules for subscripting. One (char) name and colon are fine as
                % is, but preserve a cellstr subscript's original shape.
                if iscell(sub), inds = reshape(inds,size(sub)); end
                s(2).subs{1} = inds;
            end
        end
        % If there's cascaded subscripting into the property, let the property's
        % subsasgn handle the reference.  This may return a comma-separated list,
        % so ask for and assign to as many outputs as we're given.  If there's no
        % LHS to the original expression (nargout==0), this only assigns one
        % output and drops everything else in the CSL.
        [varargout{1:nargout}] = subsref(p,s(2:end));
    else %'UserData'
        % If there's a table in the UserData struct, need to be able to access both builtin
        % and overloaded subscripting.
        [varargout{1:nargout}] = matlab.internal.tabular.private.subsrefRecurser(p,s(2:end));
    end

else
    % If there's no cascaded subscripting, only ever assign the property itself.
    varargout{1} = p;
end
