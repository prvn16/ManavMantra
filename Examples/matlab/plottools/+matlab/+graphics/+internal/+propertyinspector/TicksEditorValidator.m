classdef TicksEditorValidator < handle
    
    % This function is used in the JavaScript Ticks Editor to evaluate and validate the
    % Ticks values manually entered by the user.
    
    % Copyright 2017 The MathWorks, Inc.
    
    
    methods (Static)
        % Validates datetime values.
        % Recieves a vector of strings and tries to convert each value to
        % datetime using the format of the currently inspected object.
        % Also checks if the values are in increasing order so that they
        % can be used as ticks values in the axes
        function [invalidInd] = validateTickValues(values,propName,hAx)
            
           if nargin == 2 
                hAx = getInspectedAxes();
           end
            
            origValue = hAx.(propName);
            invalidInd = [];      
            
            if isdatetime(origValue)  || isduration(origValue)
                for i = 1:numel(values)
                    
                    if isdatetime(origValue)
                        try
                            datetime(values{i}, ...
                                'InputFormat', origValue.Format);
                        catch
                            % collect the indecies of the elements that cannot
                            % be converted to datetime
                            invalidInd = [invalidInd,i]; %#ok<AGROW>
                        end
                    else
                        iFormat = origValue.Format;
                        if isempty(origValue)
                            firstChar = propName(1);
                            limits = hAx.([firstChar,'Lim']);
                            iFormat = limits.Format;                            
                        end
                        if isempty(internal.matlab.datatoolsservices.VariableConversionUtils.getDurationFromText(char(values{i}),iFormat))
                            invalidInd = [invalidInd,i]; %#ok<AGROW>
                        end
                    end
                    
                end
                
                %check if the values are in increasing order
                if isempty(invalidInd)
                    d = [];
                    if isdatetime(origValue)
                        d =  datetime(values, ...
                            'InputFormat', origValue.Format);
                    else
                        for j = 1:numel(values)
                            d = [d internal.matlab.datatoolsservices.VariableConversionUtils.getDurationFromText(values{j},origValue.Format)]; %#ok<AGROW>
                        end
                    end
                    invalidInd = find(diff(d) > 0 == 0) ;
                end
            end            
            invalidInd = invalidInd - 1; % client side is zero based               
        end    
        
        
        % Recieives an index and returns a tick that can be positioned at that location in the current axes                      
        function [tick,label] = getNewTickAt(index,propName,hAx)
            
            if nargin == 2 
                hAx = getInspectedAxes();
            end            
            origTicks  = hAx.(propName);
            
            % get the limits
            firstChar = propName(1);
            limits = hAx.([firstChar,'Lim']);
                                       
            % if this is the first tick to be added, put it at the lowest
            % limit value
            if isempty(origTicks)
                tick = limits(1); %#ok<NASGU>
                label = getLabelForTick(tick, hAx,firstChar);    
                tick = char(tick);
                return
            end            
            
            index = index + 1; % 1 based index            
            if(index > numel(origTicks)) % append a tick to the end of the array                 
                if numel(origTicks) == 1   
                    % there is only one tick, add another one, 
                    tick = origTicks(1) + diff(limits)/5;
                else
                    % there are two or more ticks
                    tick = origTicks(end) + mean(diff(origTicks));
                end
            else
                % add a tick between two existing values
                tick = mean([origTicks(index - 1),origTicks(index )]);
            end                                            
            label = getLabelForTick(tick, hAx,firstChar);         
            tick = char(tick);                      
        end
                           
        
        % Evaluates the incoming value and retuns the result if and only if the
        % result is a numeric scalar.
        function ret = ticksEditorEval(val)
            ret = [];
            try
                ret =  evalin('base',val);
                if ~isscalar(ret) || isnan(ret) || ~isnumeric(ret)
                    ret = [];
                end
            catch
            end
        end
    end
end


function label = getLabelForTick(tick,hAx,firstChar)

cTick = tick;
ruler = hAx.([firstChar,'Axis']);

% For datetime use the format that th ruler has
if isa(ruler,'matlab.graphics.axis.decorator.DatetimeRuler') || isa(ruler,'matlab.graphics.axis.decorator.DurationRuler')
    cTick.Format = ruler.TickLabelFormat;             
end

if isduration(cTick)    
    % get rid of hr... at the end
    s = string(cTick).split(' ');    
    label = char(s(1));
else
    label = char(cTick);
end

end

%Returns the currently incpected object (Axes)
function hAx = getInspectedAxes()
i   = internal.matlab.inspector.peer.InspectorFactory.createInspector('default','/PropertyInspector');
% TODO: to handle multiple objects
hAx = i.handleVariable;
end


