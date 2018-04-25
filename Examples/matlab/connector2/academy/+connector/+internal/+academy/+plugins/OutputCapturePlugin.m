classdef OutputCapturePlugin < connector.internal.academy.plugins.TestIndexPlugin
    
    properties
        Details
        Figures
        MaxFigureCount = 10
    end
    
    methods(Access=protected)
        
        function runTestMethod(plugin, pluginData)
            runTestMethod@TestIndexPlugin(plugin, pluginData)

            % Capture figures for every test 
            captureFigures(plugin);
        end
    
        function runTestSuite(plugin, pluginData)
            plugin.Figures = cell2mat(mls.internal.figure.getFigures([], [], 'maxFigures', plugin.MaxFigureCount).figures);
            structElement = struct('Output', '', 'Figures', '');            
            plugin.Details = repmat(structElement, size(pluginData.TestSuite));          
            runTestSuite@TestIndexPlugin(plugin, pluginData);        
        end

        function evaluateMethod(plugin, pluginData) %#ok<INUSD>
            
            oldLog = plugin.Details(plugin.CurrentIndex).Output;
            log = evalc('evaluateMethod@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData)');
            output = sprintf('%s%s', oldLog, log);
            plugin.Details(plugin.CurrentIndex).Output = cleanOutput(output);
        end
    end
    
    methods(Access=private)
               
        function captureFigures(plugin)
            try              
               % Figures already open
                previousTestfiguresData = plugin.Figures; 

                % Getting new figures
                figures = mls.internal.figure.getFigures(previousTestfiguresData, [], 'maxFigures', plugin.MaxFigureCount).figures;
                figuresData = cell2mat(figures);
                figuresData(arrayfun(@(x)isempty(x.imageUrl), figuresData)) = [];

                % Adding new figures to already opened
                plugin.Figures = [figuresData; plugin.Figures];             
            catch exception
                figuresData = [];
                disp(exception)
            end
            
            plugin.Details(plugin.CurrentIndex).Figures = figuresData;
        end
    end
end

function cleanOutput = cleanOutput(output)
    %CLEANCODE Cleans output to avoid anomolies when displaying as HTML.


    % Normalize line endings to Unix-style.
    code = regexprep(output,'\r\n?','\n');
    newLine = sprintf('\n');

    % Trim leading whitespace.
    code = regexprep(code,'^[ \t\n]*','\n');

    % Trim trailing whitespace.
    code = regexprep(code,'[ \t\n]*(\n|$)','\n');

    % Remove MATLAB-specific HTML markup.
    code = regexprep(code,'<a href="matlab:.*?>(.*?)</a>','$1');

    % Remove illegal ASCII character 8
    % ASCII 8 was surrounding a warning in one result. I'm not sure why,
    % but it caused the XSLT processing to fail.
    code = regexprep(code,char(8),'');

    % Exactly one newline at the end of the file.
    code = regexprep(code,'\n*$','');
    code(end+1) = newLine;

    % Truncate code if necessary
    charCountLimit = 10000;
    if length(code) > charCountLimit
        code = [code(1:charCountLimit) '...'];
    end

    cleanOutput = code;
end        
