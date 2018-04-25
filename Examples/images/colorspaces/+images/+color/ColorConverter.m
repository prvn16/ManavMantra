classdef (Sealed) ColorConverter < images.color.internal.Callable & matlab.mixin.CustomDisplay
    % ColorConverter Convert color values from one color space to another
    %
    %   A color converter converts color values from one color space to
    %   another based on a user-supplied mathematical function. It
    %   automatically handles different input shapes and input encodings.
    %
    %   ColorConverter methods:
    %       ColorConverter - Creates a color converter
    %       convert        - Convert colors
    %       convertUnencoded - Convert unencoded colors in column form
    %       toHTML           - Create an HTML description of the converter
    %       describe         - Display converter description in browser
    %
    %   ColorConverter properties:
    %       Description - Description of the color converter
    %       InputSpace  - Input color space
    %       OutputSpace - Output color space
    %       NumInputComponents - Number of input color components
    %       NumOutputComponents - Number of output color components
    %       InputEncoder - Color encoder for the input color space
    %       OutputEncoder - Color encoder for the output color space
    %       OutputType - Encoded data type used for output colors
    %       ConversionSteps - Functions that perform the mathematical conversion
    %       ConversionParameters - Parameters associated with the conversion steps
    %
    %   See also rgb2lab, lab2rgb, xyz2lab, lab2xyz, rgb2xyz, xyz2rgb.
    
    %   Copyright 2014 The MathWorks, Inc.

    properties
        % Description - Description of the color converter
        %    String describing the color converter. The string, which can contain HTML, is used by
        %    the color converter's toHTML and describe functions.
        Description = ''
        
        % NumInputComponents - Number of input color components
        %    'any' (default) | positive integer
        NumInputComponents = 'any'
        
        % NumOutputComponents - Number of output color components
        %    'any' (default) | positive integer
        NumOutputComponents = 'any'
        
        % InputEncoder - Object that can decode and encode color values
        %    images.color.GenericColorEncoder (default) | object of type images.color.ColorEncoder
        InputEncoder  = images.color.GenericColorEncoder
        
        % OutputEncoder - Object that can decode and encode color values
        %    images.color.GenericColorEncoder (default) | object of type images.color.ColorEncoder        
        OutputEncoder = images.color.GenericColorEncoder
        
        % OutputType - Data type of the output colors
        %    If OutputType is 'auto', then the output type matches the input type (as long as
        %    the output encoder supports that type). If OutputType is 'float', then the output is
        %    single if the input is single; otherwise the output is double
        %
        %    'auto' (default) | 'float' | the name of a numeric type, such as 'uint8' or 'uint16'
        OutputType = 'auto'
    end
    
    properties (Dependent)
        % ConversionParameters Parameter values (if any) associated with a conversion step
        %    struct (Read-only)
        ConversionParameters
        
        % InputSpace - Input color space family
        %    'generic' (default) | 'RGB' | 'XYZ' | 'Lab' | 'CMYK' | 'CMY' | 'gray'
        InputSpace
        
        % OutputSpace - Output color space family
        %    'generic' (default) | 'RGB' | 'XYZ' | 'Lab' | 'CMYK' | 'CMY' | 'gray'
        OutputSpace
        
        % ConversionSteps - Steps used in the color conversion process
        %    cell array containing function handles and color converter objects
        ConversionSteps
    end
    
    properties (Hidden)
        % BlockSize - Maximum number of colors to be converted at once.
        %    This property controls the size of the blocks used by the convert function. It is used
        %    to reduce the maximum memory usage of the converter by not converting all input colors
        %    to unencoded (floating-point) color values all at once.
        BlockSize     = 1024*1024
        
        InputSpaceImpl = 'generic'
        OutputSpaceImpl = 'generic'
        
        ConversionStepsImpl = {}
    end
    
    methods
        function self = ColorConverter(steps)
            % ColorConverter Create a color converter
            %
            %   converter = images.color.ColorConverter(f)
            %   converter = images.color.ColorConverter(steps)
            %
            %   converter = images.color.ColorConverter(f) creates a color converter from the
            %   function handle f. The function handle must take a single input argument and return
            %   a single output argument. The input and output are unencoded color values stored in
            %   a matrix with one color per row. (For example, this is the format used by MATLAB
            %   color maps.)
            %
            %   converter = images.color.ColorConverter(steps) creates a color converter from a cell
            %   array whose elements are either function handles or color converters.
            %
            %   A color converter is similar to a function handle. Specifically, you can use it
            %   convert colors using function-call syntax.
            %
            %   Example 1
            %   ---------
            %   Create a color converter that swaps the red and green components and complements the
            %   blue component of an RGB image. Use it to convert image colors.
            %
            %       f = @(rgb) [rgb(:,[2 1]), 1-rgb(:,3)];
            %       converter = images.color.ColorConverter(f);
            %       rgb = imread('peppers.png');
            %       rgb2 = converter(rgb);
            %       imshow(rgb2)
            %
            %   Example 2
            %   ---------
            %   Create a color converter from a sequence of two color converters. Use it to convert
            %   image colors.
            %
            %       f = @(rgb) rgb(:,[2 1 3]);
            %       converter1 = images.color.ColorConverter(f);
            %
            %       g = @(rgb) [rgb(:,[1 2]), 1-rgb(:,3)];
            %       converter2 = images.color.ColorConverter(g);
            %
            %       converter = images.color.ColorConverter({converter1 converter2});
            %
            %       rgb = imread('peppers.png');
            %       rgb2 = converter2(rgb);
            %
            %       imshow(rgb2)

            if iscell(steps)
                % ColorConverter(steps)
                [self.NumInputComponents, self.NumOutputComponents] = images.color.internal.checkSequence(steps);
                self.ConversionSteps = steps;
            else
                % ColorTransformFunction(fh)
                self.ConversionSteps = steps;
                self.NumInputComponents = 'any';
                self.NumOutputComponents = 'any';
            end
        end
        
        function p = get.ConversionParameters(self)
            p = images.color.internal.getConversionParameters(self.ConversionSteps);
        end
        
        function converter = set.ConversionSteps(converter,new_steps)
            if iscell(new_steps)
                [num_in,num_out] = images.color.internal.checkSequence(new_steps);
                converter.ConversionStepsImpl = new_steps;
                converter.NumInputComponents = num_in;
                converter.NumOutputComponents = num_out;
            else
                converter.ConversionStepsImpl = new_steps;
            end
        end
        
        function steps = get.ConversionSteps(converter)
            steps = converter.ConversionStepsImpl;
        end
        
        function converter = set.InputSpace(converter,input_space)
            [input_space,num_in] = images.color.internal.checkColorSpaceString(input_space);
            converter.InputSpaceImpl = input_space;
            converter.NumInputComponents = num_in;
        end
        
        function space = get.InputSpace(converter)
            space = converter.InputSpaceImpl;
        end
        
        function converter = set.OutputSpace(converter,output_space)
            [output_space,num_out] = images.color.internal.checkColorSpaceString(output_space);
            converter.OutputSpaceImpl = output_space;
            converter.NumOutputComponents = num_out;
        end
        
        function space = get.OutputSpace(converter)
            space = converter.OutputSpaceImpl;
        end
        
        function out = convert(self,in)
            % convert Convert colors
            %
            %    out = convert(converter,in)
            %
            %    out = convert(converter,in) uses the color converter to convert colors. The input
            %    colors in color matrix form (one color per row), image form (M-by-N-by-Q, where Q
            %    is the number of input color components), or image stack form (M-by-N-by-Q-by-F,
            %    where F is the number of image frames in the stack). The function convert also
            %    handles decoding and encoding of color values automatically.

            if strcmp(self.OutputType, 'auto')
                % In 'auto' mode, the output type is the same as the input type.
                output_type = class(in);
            elseif strcmp(self.OutputType, 'float')
                % This option allows for single-precision workflows. If the input is
                % single-precision, then the output will also be single precision.
                output_type = images.color.internal.floatType(in);
            else
                output_type = self.OutputType;
            end
            
            % Reshape the input to have the canonical shape, M-by-Q-by-P. M is the number of colors,
            % Q is the number of input color components, and P is the number of image frames.
            % output_column_size is used to initialize the output canonical array, while output_size
            % is used at the end of the process to reshape the final output.
            [in, output_column_size, output_size] = images.color.internal.toColumns(in, ...
                self.NumInputComponents, self.NumOutputComponents, ...
                self.InputSpace);
            
            [M,~,P] = size(in);
            out = zeros(output_column_size,output_type);
            % The k-loop is over the image frames.
            for k = 1:P
                num_blocks = ceil(M/self.BlockSize);
                % The b-loop is for processing the colors in each frame in blocks. The purpose is to
                % avoid a high peak memory use caused by converting all the colors to unencoded form
                % (double precision) at once.
                for b = 1:num_blocks
                    first = (b-1)*self.BlockSize + 1;
                    last = min(first + self.BlockSize - 1, M);
                    v = in(first:last,:,k);
                    v = self.InputEncoder.decode(v);
                    v = self.convertUnencoded(v);
                    v = self.OutputEncoder.encode(v,output_type);
                    out(first:last,:,k) = v;
                end
            end
            
            out = reshape(out, output_size);
        end
        
        function out = convertUnencoded(self, in)
            % convertUnencoded Convert encoded colors in row form
            %
            %    out = convertUnencoded(converter,in)
            %
            %    out = convertUnencoded(converter,in) uses the color converter to convert colors
            %    that are unencoded and in row form. That is, the input is an M-by-Q matrix where M
            %    is the number of colors and Q is the number of color components.
            
            seq = self.ConversionSteps;
            out = in;
            
            % Apply the sequence of steps one at a time.
            for k = 1:numel(seq)
                if iscell(seq)
                    f = seq{k};
                else
                    f = seq;
                end
                if isa(f, 'images.color.ColorConverter')
                    out = f.convertUnencoded(out);
                else
                    % f is assumed to be a function handle.
                    out = f(out);
                end
            end
        end
        
        function str = toHTML(self, level, lines)
            % toHTML Create HTML description of color converter
            %
            %    str = toHTML(converter)
            %
            %    str = toHTML(converter) returns a string containing an HTML description of the
            %    converter.
            
            % Note for developers: additional syntax
            %
            %    str = toHTML(converter,level,lines)
            %
            %    This syntax is for internal implementation and is not to be documented. When the
            %    converter contains steps that are themselves converters, then toHTML calls itself
            %    recursively using this syntax. In the recursive calls, the current recursion level
            %    is passed in, as well as a double-ended queue (handle object) that is used to build
            %    up the HTML string. The current recursion level is used to automatically produce
            %    different styles of ordered lists.
            % 

            if nargin < 2
                level = 1;
            end
            if nargin < 3
                lines = images.color.internal.Deque;
            end
            
            if level == 1
                pushBack(lines, '<!doctype html>');
                pushBack(lines, '<html>');
                addHTMLHead(lines);
                pushBack(lines,'<body>');
                pushBack(lines,sprintf('<h1>%s</h1>',...
                    getString(message('images:color:colorConverterHTMLTitle'))));
                
                addSummaryTable(lines,self);
            end
                        
            pushBack(lines, self.Description);
            
            canonical_tform = self.ConversionSteps;
            if isscalar(canonical_tform) && iscell(canonical_tform)
                canonical_tform = canonical_tform{1};
            end
            
            if isa(canonical_tform, 'function_handle')
                pushBack(lines, '<br />');
                pushBack(lines, describeFunctionHandle(canonical_tform));
            elseif isa(canonical_tform, 'images.color.ColorConverter')
                canonical_tform.toHTML(level + 1, lines);
            else
                pushBack(lines, '<p>Steps:</p>');
                pushBack(lines, sprintf('<ol style="list-style-type:%s;">', images.color.internal.listStyleType(level)));
                for k = 1:numel(canonical_tform)
                    f = canonical_tform{k};
                    pushBack(lines, '<li style="padding-bottom:2ex;">');
                    f.toHTML(level + 1, lines);
                    pushBack(lines, '</li>');
                end
                pushBack(lines, '</ol>');
            end
            
            pushBack(lines,'</body>');
            pushBack(lines,'</html>');
            
            if nargout > 0
                % Concatenate all the lines together with newlines in between.
                str = sprintf('%s\n', lines.Items{:});
            end
        end
        
        function describe(self)
            % describe Display converter description in MATLAB Browser
            %
            %    describe(converter)
            %
            %    describe(converter) displays a description of the converter in the MATLAB Browser. 
            
            web(sprintf('text://%s',toHTML(self)));
        end
                
    end
    
    methods (Hidden)
        function out = evaluate(self, in)
            % evaluate Convert colors
            %
            %    out = evaluate(converter,in)
            %
            %    This undocumented method is the implementation of the abstract evaluate method
            %    defined by the superclass images.color.internal.Callable.
            
            out = convert(self, in);
        end
    end
    
    methods (Access = protected)
        function groups = getPropertyGroups(~)
            % Overrides the base implementation provided by matlab.mixin.CustomDisplay.
            %
            % Groups the display of converter properties as follows:
            %
            % GENERAL
            %     Description
            %
            % COLOR SPACES
            %     InputSpace
            %     OutputSpace
            %
            % COMPONENTS
            %     NumInputComponents
            %     NumOutputComponents
            %
            % ENCODING
            %     InputEncoder
            %     OutputEncoder
            %     OutputType
            %
            % CONVERSION
            %     ConversionSteps
            %     ConversionParameters
            %

            general_group = matlab.mixin.util.PropertyGroup({'Description'});
            general_group.Title = 'GENERAL';
            
            spaces_group = matlab.mixin.util.PropertyGroup({'InputSpace', 'OutputSpace'});
            spaces_group.Title = 'COLOR SPACES';
            
            components_group = matlab.mixin.util.PropertyGroup({'NumInputComponents', ...
                'NumOutputComponents'});
            components_group.Title = 'COMPONENTS';
            
            encoding_group = matlab.mixin.util.PropertyGroup({'InputEncoder', 'OutputEncoder', 'OutputType'});
            encoding_group.Title = 'ENCODING';
            
            conversion_props = {'ConversionSteps', 'ConversionParameters'};
            conversion_details_group = matlab.mixin.util.PropertyGroup(conversion_props);
            conversion_details_group.Title = 'CONVERSION';
            
            groups = [general_group spaces_group components_group encoding_group ...
                conversion_details_group];
        end
        
        function s = getFooter(self)
            % Overrides the base implementation provided by matlab.mixin.CustomDisplay
            %
            % Displays a clickable link in the footer of the object display. Clicking on the link
            % displays a description of the converter in the MATLAB Browser.
            
            if feature('hotlinks')
                t = toHTML(self);
                % Replace single quote characters (') with two single quote characters ('')
                t2 = strrep(t,'''','''''');
                
                % The presence of double quote characters confuses the Command Window code that
                % looks for HTML hyperlinks in displayed output. The following work-around replaces
                % a double quote character (") with this concatenation syntax: (, char(34) ,).
                t3 = strrep(t2,'"',''', char(34), ''');
                
                % Replace newlines with spaces.
                t4 = strrep(t3, char(10), ' ');
                
                s = sprintf('<a href="matlab:web([''text://%s''])">%s</a>',t4,...
                    getString(message('images:color:colorConverterFullDescription')));
            else
                s = '';
            end
            
        end

    end
    
end

function str = describeAnonymousFunctionHandle(f)
% describeAnonymousFunctionHandle
%
%    str = describeAnonymousFunctionHandle(f)
%
%    Returns a string containing an HTML description of an anonymous function handle

% Use "out" for function output and "in" for function input
tokens = regexp(func2str(f), '^@\((.*?)\)', 'tokens');
input_argument_name = tokens{1};
str = regexprep(func2str(f), '^@\(.*?\)', 'out = ');
str = regexprep(str, ['\<', input_argument_name, '\>'], 'in');
str = sprintf('<p><code>%s</code></p>', str);
str = ['<p>Code:</p>', str];

% If there are variables in the anonymous function handle's workspace, produce a tabular listing of
% them.
ff = functions(f);
w = ff.workspace{1};
param_names = fieldnames(w);
if ~isempty(param_names)
    t = images.color.internal.Deque;
    pushBack(t,'<div style="margin-top:2ex; margin-left:2ex;">');
    pushBack(t,'<table style="border:1px solid gray; border-collapse:collapse;" >');
    pushBack(t,'<tr style="border:1px solid gray;">');
    pushBack(t,'<th style="border:1px solid gray;">Parameter</th> <th style="border:1px solid gray;">Value</th>');
    pushBack(t,'</tr>');
    for k = 1:length(param_names)
        pushBack(t,'<tr>');
        pushBack(t,sprintf('<td style="border:1px solid gray;"> <code>%s</code> </td>', param_names{k}));
        s = num2str(w.(param_names{k}));
        pushBack(t,'<td style="border:1px solid gray;">');
        for q = 1:size(s,1)
            pushBack(t,sprintf('<code> %s </code> <br/>', s(q,:)));
        end
        pushBack(t,'</td>');
        pushBack(t,'</tr>');
    end
    pushBack(t,'</table>');
    pushBack(t,'</div>');
    t_str = sprintf('%s\n', t.Items{:});
    
    str = [str, t_str];
end
end

function str = describeSimpleFunctionHandle(f)
% describeSimpleFunctionHandle
%
%    str = describeSimpleFunctionHandle(f)
%
%    Returns a string containing an HTML description of a simple function handle

str = '<p>Code:</p>';
str = [str, sprintf('<p><code>out = %s(in)</code></p>', func2str(f))];
end

function str = describeFunctionHandle(f)
% describeFunctionHandle
%
%    str = describeFunctionHandle(f)
%
%    Returns a string containing an HTML description of a simple function handle.

about_f = functions(f);
switch about_f.type
    case 'simple'
        str = describeSimpleFunctionHandle(f);
    case 'anonymous'
        str = describeAnonymousFunctionHandle(f);
    otherwise
        % Unrecognized function handle type
        str = '';
end
end

function str = numComponentsToString(num_components)
% numComponentsToString
%
%    str = numComponentsToString(num_components)
%
%    A color converter's NumInputComponents (or NumOutputComponents) can either be a positive
%    integer or the string 'any'. This function either returns 'any' or converts the integer to a
%    string and returns that.

if ischar(num_components)
    str = num_components;
else
    str = sprintf('%d', num_components);
end
end

function addSummaryTable(lines, converter)
% addSummaryTable
%
%    addSummaryTable(lines, converter)
%
%    Adds a summary on input space, output space, number of input components, and number of output
%    components to the HTML. The input argument lines is a deque containing the HTML, and the input
%    argument converter is a color converter.

pushBack(lines, '<table class="summary-table">');
pushBack(lines, '<thead>');
pushBack(lines, sprintf('<tr> <th scope="col"> </th> <th scope="col"> %s </th> <th scope="col"> %s </th> </tr>',...
    getString(message('images:color:input')), getString(message('images:color:output'))));
pushBack(lines, '</thead>');
pushBack(lines, sprintf('<tr> <td> %s: </td> <td> %s </td> <td> %s </td> </tr>', ...
    getString(message('images:color:colorSpace')), converter.InputSpace, converter.OutputSpace));
pushBack(lines, sprintf('<tr> <td> %s: </td> <td> %s </td> <td> %s </td> </tr>', ...
    getString(message('images:color:components')), ...
    numComponentsToString(converter.NumInputComponents), ...
    numComponentsToString(converter.NumOutputComponents)));
pushBack(lines, '</table>');
end

function addHTMLHead(lines)
% addHTMLHead
%
%    addHTMLHead(lines)
%
%    Adds the <head> ... </head> section to the HTML stored in lines, which is a deque.

pushBack(lines, '<head>');
pushBack(lines,'<style>');
pushBack(lines, '.summary-table');
pushBack(lines, '{');
pushBack(lines, '  border-collapse: collapse;');
pushBack(lines, '  text-align: left;');
pushBack(lines, '  margin-bottom: 2em;');
pushBack(lines, '  border-bottom: 1pt solid #C8C8C8;');
pushBack(lines, '}');

pushBack(lines, '.summary-table th');
pushBack(lines, '{');
pushBack(lines, '  padding: 10px 8px;');
pushBack(lines, '  border-bottom: 2pt solid #C8C8C8;');
pushBack(lines, '}');

pushBack(lines, '.summary-table td');
pushBack(lines, '{');
pushBack(lines, '  padding: 9px 8px 4px 8px;');
pushBack(lines, '}');
pushBack(lines, '</style>');
pushBack(lines, sprintf('<title>%s</title>', ...
    getString(message('images:color:colorConverterHTMLTitle'))));
pushBack(lines,'</head>');
end