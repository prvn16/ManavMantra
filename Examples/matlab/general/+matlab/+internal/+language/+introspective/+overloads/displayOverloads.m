function output = displayOverloads(topic, shouldHotlink, command)

    narginchk(1,3);

    if nargin < 2
        shouldHotlink = matlab.internal.display.isHot;
    end
    
    if nargin < 3
        command = 'help'; 
    end
        
    text = getOverloadTextToDisplay(topic, shouldHotlink, command);
    
    if nargout > 0
        output = text;
    else
        disp(text);
    end
end

function overloadMessage = getOverloadTextToDisplay(topic, shouldHotlink, command)
    
    overloadList = matlab.internal.language.introspective.overloads.getOverloads(topic, false, shouldHotlink);

    if ~isempty(overloadList) 
        overloadMessage = matlab.internal.language.introspective.overloads.formatOverloads(overloadList);
        overloadMessage = hotlinkOverloads(overloadMessage, shouldHotlink, command);
    else
        overloadMessage = ['    ' getString(message('MATLAB:introspective:help:NoOverloadedMethods', topic))];
    end
end

function text = hotlinkOverloads(text, shouldHotlink, command)
    if shouldHotlink
        text = regexprep(text,'(\S*)',['${helpUtils.createMatlabLink(''' command ''',$0,$0)}']);
    end
end