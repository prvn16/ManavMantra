classdef helpParts < handle
    %HELPPARTS parses help command into its various parts, including:
    % - The See Also section
    % - The note following the See Also section
    % - Overloaded methods
    % - Examples
    % - Links to published demos
    
    % Copyright 2009 The MathWorks, Inc.
    properties (Access=private)
        allParts = []; % array of matlab.internal.language.introspective.atomicHelpParts
    end
    
    properties (GetAccess = private, Constant)
        Raw               = 0; % Unclassified text
        SeeAlso           = 1; % See Also section.
        Note              = 2; % Note section under See Also section
        OverloadedMethods = 3; % Overloaded Methods
        Example           = 4; % Examples
        Demo              = 5; % Demos
        Invalid           = -1; % invalid help part
    end
    
    
    methods
        function this = helpParts(fullHelpText, fcnName)
            %Constructor takes help comments and extracts specific parts
            
            if ~ischar(fullHelpText)
                error(message('MATLAB:introspective:helpParts:InvalidInput'));
            end
            
            this.allParts = matlab.internal.language.introspective.atomicHelpPart('', fullHelpText, matlab.internal.language.introspective.helpParts.Raw);
            
            % First look for the see also section.
            found = this.addHelpPart('MATLAB:introspective:helpParts:SeeAlso', 'MATLAB:introspective:helpParts:SeeAlsoEnglish');
            
            % Only look for a note if there is a see also!
            if found
                this.addHelpPart('MATLAB:introspective:helpParts:Note', 'MATLAB:introspective:helpParts:NoteEnglish');
            end
            
            if nargin < 2
                fcnName = '\w+';
            end
            % Add overloaded methods help part (if any)
            overloadPattern = getString(message('MATLAB:introspective:help:OverloadedMethods', fcnName));
            overloadEnum = getString(message('MATLAB:introspective:helpParts:OverloadedMethodsEnglish'));
            this.searchAndAppendHelpPart(overloadPattern, overloadEnum, '\n');
            
            % Add demo help part (if any).
            demoPattern = getString(message('MATLAB:introspective:displayHelp:PublishedOutputInTheHelpBrowser'));
            demoEnum = getString(message('MATLAB:introspective:helpParts:PublishedOutputEnglish'));
            this.searchAndAppendHelpPart(demoPattern, demoEnum);

            % Extract examples (if any)
            this.addExampleParts;
        end
        
        
        function allHelpText = getFullHelpText(this)
            % GETFULLHELPTEXT - returns full help stored by all the help parts
            allHelpText = '';
            for i = 1:length(this.allParts)
                allHelpText = [allHelpText this.allParts(i).getTitle this.allParts(i).getText]; %#ok<AGROW>
            end
        end
        
        function atomicHelpPart = getPart(this, partName)
            % GETPART - retrieves specific help part if found in MATLAB file
            enumType = getEnumeration(partName);
            
            if enumType ~= matlab.internal.language.introspective.helpParts.Invalid
                atomicHelpPart = this.allParts([this.allParts.enumType] == enumType);
            else
                atomicHelpPart = matlab.internal.language.introspective.atomicHelpPart;
                atomicHelpPart(end) = [];
            end
        end
    end
    
    methods (Access = private)
        function found = addHelpPart(this, localizedID, nonLocalizedID)
            % ADDHELPPART - appends help part regardless of the language the part name is in
            
            localizedName = getString(message(localizedID));
            nonLocalizedName = getString(message(nonLocalizedID));
            
            found = this.searchAndAppendHelpPart(regexptranslate('escape', localizedName), nonLocalizedName);
            
            if ~found && ~strcmp(nonLocalizedName, localizedName)
                found = this.searchAndAppendHelpPart(nonLocalizedName);
            end
        end
        
        function found = searchAndAppendHelpPart(this, titlePattern, nonLocalizedName, doNotCapture)
            % SEARCHANDAPPENDHELPPART - helper method that searches and appends a help
            % part if found. The algorithm is as follows:
            % 1. Take the last part
            % 2. Extract the part titled TITLEPATTERN from this last part
            % 3. Replace the previous part with the newly extracted
            %    part.
            % 4. Save remainder as the last part.
            
            if nargin < 4
                doNotCapture = '';
            end
            
            found = false;
            parts = regexpi(this.allParts(end).getText, ['(.*^\s*)(' titlePattern '\>:?)' doNotCapture '(.*)'], 'tokens', 'once','lineanchors');
            if ~isempty(parts)
                whiteLine = regexp(parts{3}, '\n\s*\n', 'once');
                if isempty(whiteLine)
                    rawRemainderHelpPart = [];
                else
                    rawRemainderHelpPart = matlab.internal.language.introspective.atomicHelpPart('',  parts{3}(whiteLine:end), matlab.internal.language.introspective.helpParts.Raw);
                    parts{3} = parts{3}(1:whiteLine-1);
                end
                
                if nargin > 2
                    % title pattern is localized
                    enumType = getEnumeration(nonLocalizedName);
                else
                    enumType = getEnumeration(titlePattern);
                end
                
                newAtomicHelpPart = matlab.internal.language.introspective.atomicHelpPart(parts{2}, parts{3}, enumType);
                
                this.allParts(end).replaceText(parts{1});
                this.allParts = [this.allParts, newAtomicHelpPart, rawRemainderHelpPart];
                found = true;
            end
        end
        
        function addExampleParts(this)
            % ADDEXAMPLEPARTS - helper method that extracts examples from
            % the raw help preceding the "See Also" section.
            
            rawHelpPart = this.allParts(1);
            
            [examples, raw] = regexpi(rawHelpPart.getText, ...
                '^(?<indent> *)(?<header>(Examples?):?.*)(?<body>(\k<indent> +.*| *)\n*)*',...
                'names', 'lineanchors', 'dotexceptnewline', 'split');
            
            if ~isempty(examples)
                newParts(length(examples)*2) = matlab.internal.language.introspective.atomicHelpPart;
                
                for i = 1:length(examples)
                    % Need to concatenate spaces preceding the example header.
                    rawWithIndent = [raw{i} examples(i).indent];
                    
                    newParts(2*i-1) = matlab.internal.language.introspective.atomicHelpPart('', rawWithIndent, matlab.internal.language.introspective.helpParts.Raw);
                    
                    newParts(2*i) = matlab.internal.language.introspective.atomicHelpPart(examples(i).header, examples(i).body, matlab.internal.language.introspective.helpParts.Example);
                end
                
                lastRawPart = matlab.internal.language.introspective.atomicHelpPart('', raw{end}, matlab.internal.language.introspective.helpParts.Raw);
                
                this.allParts = [newParts, lastRawPart, this.allParts(2:end)];
            end
        end
        
    end
end

%% ------------------------
function enumType = getEnumeration(partName)
    % GETENUMERATION - returns enumeration corresponding to input part name
    switch lower(partName)
    case {'seealso', 'see also'}
        enumType = matlab.internal.language.introspective.helpParts.SeeAlso;
    case 'note'
        enumType = matlab.internal.language.introspective.helpParts.Note;
    case 'raw'
        enumType = matlab.internal.language.introspective.helpParts.Raw;
    case {'overloaded methods:', 'overloaded'}
        enumType = matlab.internal.language.introspective.helpParts.OverloadedMethods;
    case {'example', 'examples'}
        enumType = matlab.internal.language.introspective.helpParts.Example;
    case {'published output in the help browser', 'demo'}
        enumType = matlab.internal.language.introspective.helpParts.Demo;
    otherwise
        % partName is invalid.
        enumType = matlab.internal.language.introspective.helpParts.Invalid;
    end
end