function header = getHeader(input, headerLinkAttributes)  
% getHeader returns the header for a given type
% Inputs - 
%       input - the variable for which the header needs to be computed
%          Inputs have to be one of the following types:
%          * struct
%          * function_handle
%          * double
%          * single
%          * int8
%          * uint8
%          * int16
%          * uint16
%          * int32
%          * uint32
%          * int64
%          * uint64
%          * logical
%          * char
%          * matlab.mixin.internal.MatrixDisplay
%          * string
%          * MATLAB enumerations
%       headerLinkAttributes - attributes to be added to the <a> tag 
%       of the header. For example 'class="headerDataType"'. If  second 
%       argument does not exist, default attribute 
%       'style="font-weight:bold"' will be added to the <a> tag which is 
%       used by command window. 
% Output - The header
% Copyright 2016 The MathWorks, Inc.

if nargin == 1
    headerLinkAttributes = 'style="font-weight:bold"';
end

switch (class(input))
    case 'struct'
        header = getStructHeader(input, headerLinkAttributes);
    case 'function_handle'
        header = getFunctionHandleHeader(input, headerLinkAttributes);   
    case 'double'
        header = getDoubleHeader(input, headerLinkAttributes);
    case {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64','single'}
        header = getHeaderForNumericClasses(input, headerLinkAttributes);
    case 'char'
        header = getHeaderForChar(input, headerLinkAttributes);
    case 'string'
        header = getHeaderForString(input, headerLinkAttributes);
    otherwise
      if isa(input,'tabular')
          header = getTabularHeader(input, headerLinkAttributes);
      elseif isenum(input)
          header = getHeaderForEnum(input, headerLinkAttributes);
      else
          header = getHeaderForNonNumericClasses (input, headerLinkAttributes);
      end
end
end

function out = getStructHeader(inp, headerLinkAttributes)
    % Returns the header for a struct
    % Scalar input
    if isscalar(inp)  
        % struct with at least one field
        if  numel(fields(inp)) >= 1
            obj = message('MATLAB:services:printmat:ScalarStructWithFields',getClassnameString(inp, headerLinkAttributes));
            out = [char(32) char(32) obj.getString];
        else
            % struct with no field
            obj = message('MATLAB:services:printmat:ScalarStructWithNoFields',getClassnameString(inp, headerLinkAttributes));
            out = [char(32) char(32) obj.getString];
        end        
    else
    % Non scalar input
    % Empty non-scalar
    if isempty(inp)
        % Empty with at least one field
        if  numel(fields(inp)) >= 1
            obj = message('MATLAB:services:printmat:EmptyStructWithFields',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
            out =  [char(32) char(32)   obj.getString];
        else
            % Empty with no field
            obj = message('MATLAB:services:printmat:EmptyStructVectorWithNoFields',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
            out =  [char(32) char(32)   obj.getString];
        end
    else
        % Non empty non-scalar
        % Non-empty non-scalar with at least one field
        if  numel(fields(inp)) >= 1
            obj = message('MATLAB:services:printmat:StructVectorWithFields',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
            out =  [char(32) char(32)   obj.getString];
        else
            %Non-empty no-scalar with no fields
            obj = message('MATLAB:services:printmat:StructVectorWithNoFields',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
            out =  [char(32) char(32)   obj.getString];
        end
    end        
    end
end

function out = getTabularHeader(inp, headerLinkAttributes)
% Returns the header for a table or timetable

    classname = getClassnameString(inp, headerLinkAttributes);
    
    if isscalar(inp)
        out = [char(32) char(32) classname];
    else
        dims = matlab.internal.display.dimensionString(inp);
        out = [char(32) char(32) dims char(32) classname];
        if isempty(inp)
            % zero case -- message catalog
            obj = message('MATLAB:services:printmat:EmptyTabular',dims, classname);
            out = [char(32) char(32) obj.getString];            
            return
        end
    end
end

function out = getFunctionHandleHeader(inp, headerLinkAttributes)
% Returns the header for a function_handle
    % Scalar function_handle
    if isscalar(inp)
        obj = message('MATLAB:services:printmat:ScalarFunctionHandle',getClassnameString(inp, headerLinkAttributes));
        out = [char(32) char(32) obj.getString];
    else
        % Empty function_handle
        out = getHeaderForNonNumericClasses(inp, headerLinkAttributes);
    end    
end

function out = getDoubleHeader(inp, headerLinkAttributes)
    % Returns the header for a double
    out = '';
    ndims = numel(size(inp));
    rows = size(inp,1);
    cols = size(inp,2); 
    
    if isempty(inp) && ~isreal(inp)
        % Complex empty double
        if issparse(inp)
            % Empty sparse complex double
            if matlab.internal.display.isHot
                if isrow(inp)
                    out = [char(32) char(32) ...
                        message('MATLAB:services:printmat:EmptySparseComplexRowVector', ...
                        matlab.internal.display.dimensionString(inp), ...
                        getClassnameString(inp, headerLinkAttributes)).getString()];
                elseif iscolumn(inp)
                    out = [char(32) char(32) ...
                        message('MATLAB:services:printmat:EmptySparseComplexColumnVector', ...
                        matlab.internal.display.dimensionString(inp), ...
                        getClassnameString(inp, headerLinkAttributes)).getString()];
                else
                    out = [char(32) char(32) ...
                        message('MATLAB:services:printmat:EmptySparseComplexMatrix', ...
                        matlab.internal.display.dimensionString(inp), ...
                        getClassnameString(inp, headerLinkAttributes)).getString()];
                end
            else
                if isrow(inp)
                    out = [char(32) char(32) ...
                        message('MATLAB:services:printmat:EmptySparseComplexRowVectorNoHyperlink', ...
                        matlab.internal.display.dimensionString(inp), ...
                        getClassnameString(inp, headerLinkAttributes)).getString()];
                elseif iscolumn(inp)
                    out = [char(32) char(32) ...
                        message('MATLAB:services:printmat:EmptySparseComplexColumnVectorNoHyperlink', ...
                        matlab.internal.display.dimensionString(inp), ...
                        getClassnameString(inp, headerLinkAttributes)).getString()];
                else
                     out = [char(32) char(32) ...
                        message('MATLAB:services:printmat:EmptySparseComplexMatrixNoHyperlink', ...
                        matlab.internal.display.dimensionString(inp), ...
                        getClassnameString(inp, headerLinkAttributes)).getString()];
                end
            end
        else
            % Empty non-sparse complex double
            out = getHeaderForComplexEmptyNumeric(inp, headerLinkAttributes);
        end
    elseif isempty(inp) && (~(size(inp,1) == 0 && size(inp, 2) == 0 && numel(size(inp)) == 2) || issparse(inp))               
        if issparse(inp)
            % Empty sparse double
            if rows == 1    
                if matlab.internal.display.isHot
                    obj = message('MATLAB:services:printmat:EmptySparseRowVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                else
                    obj = message('MATLAB:services:printmat:EmptySparseRowVectorNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                end                
                out = [char(32) char(32) obj.getString];
            elseif cols == 1
                if matlab.internal.display.isHot
                    obj = message('MATLAB:services:printmat:EmptySparseColumnVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                else
                    obj = message('MATLAB:services:printmat:EmptySparseColumnVectorNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                end                
                out = [char(32) char(32) obj.getString];
            else
                if matlab.internal.display.isHot
                    obj = message('MATLAB:services:printmat:EmptySparseMatrix',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                else
                    obj = message('MATLAB:services:printmat:EmptySparseMatrixNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                end                
                out = [char(32) char(32) obj.getString];
            end
        else
            % Empty double
            if ndims > 2
                obj = message('MATLAB:services:printmat:EmptyArray',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                out = [char(32) char(32) obj.getString];
            else
                if rows == 1
                    obj = message('MATLAB:services:printmat:EmptyRowVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                    out = [char(32) char(32) obj.getString];
                elseif cols == 1
                    obj = message('MATLAB:services:printmat:EmptyColumnVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                    out = [char(32) char(32) obj.getString];
                else
                    obj = message('MATLAB:services:printmat:EmptyMatrix',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                    out = [char(32) char(32) obj.getString];
                end
            end
        end
    end  
end

function out = getHeaderForNumericClasses(inp, headerLinkAttributes)
    % Returns the header for all numeric types except double    
    if isscalar(inp)
        out = [char(32) char(32) getClassnameString(inp, headerLinkAttributes)];     
    else
        ndims = numel(size(inp));
        rows = size(inp,1);
        cols = size(inp,2);
        if isempty(inp)
                % Empty input
                if ~isreal(inp)
                    % Complex empty
                    out = getHeaderForComplexEmptyNumeric(inp, headerLinkAttributes);
                else
                    % Non-complex empty
                    if ndims > 2
                        obj = message('MATLAB:services:printmat:EmptyArray',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                        out = [char(32) char(32) obj.getString];
                    else
                        if rows == 1
                            obj = message('MATLAB:services:printmat:EmptyRowVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                            out = [char(32) char(32) obj.getString];
                        elseif cols == 1
                            obj = message('MATLAB:services:printmat:EmptyColumnVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                            out = [char(32) char(32) obj.getString];
                        else
                            obj = message('MATLAB:services:printmat:EmptyMatrix',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                            out = [char(32) char(32) obj.getString];
                        end
                    end
                end
                
         else
                % Non-empty input
                if ndims > 2
                    obj = message('MATLAB:services:printmat:Array',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                    out = [char(32) char(32) obj.getString];
                else
                    if rows == 1
                        obj = message('MATLAB:services:printmat:RowVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                        out = [char(32) char(32) obj.getString];
                    elseif cols == 1
                        obj = message('MATLAB:services:printmat:ColumnVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                        out = [char(32) char(32) obj.getString];
                    else
                        obj = message('MATLAB:services:printmat:Matrix',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                        out = [char(32) char(32) obj.getString];
                    end
                end
        end
     
    end
end

function out = getHeaderForChar(inp, headerLinkAttributes)
    % Returns the header for char
    out = '';
    
    if isempty(inp)
        % Empty input
        obj = message('MATLAB:services:printmat:EmptyArray',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
        out = [char(32) char(32) obj.getString];
    else
        rows = size(inp,1);
        dims = numel(size(inp));
        if (dims > 2) || (rows > 1)
             % Non-empty input  
             obj = message('MATLAB:services:printmat:Array',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
             out = [char(32) char(32) obj.getString];       
        end
    end
    
end

function out = getHeaderForString(inp, headerLinkAttributes)
    % Returns the header for string
    out = '';
    if isempty(inp)
        % Empty input
        obj = message('MATLAB:services:printmat:EmptyArray',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
        out = [char(32) char(32) obj.getString];
    else        
        if (~isscalar(inp))
             % Non-empty input  
             obj = message('MATLAB:services:printmat:Array',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
             out = [char(32) char(32) obj.getString];       
        end
    end
end

function out = getHeaderForNonNumericClasses(inp, headerLinkAttributes)
    % Returns the header for all non numeric types    
    if isscalar(inp)
        if issparse(inp)
            % Sparse logical scalar
            if matlab.internal.display.isHot
                obj = message('MATLAB:services:printmat:SparseLogicalScalar',getClassnameString(inp, headerLinkAttributes));
            else
                obj = message('MATLAB:services:printmat:SparseLogicalScalarNoHyperlink',getClassnameString(inp, headerLinkAttributes));
            end            
            out = [char(32) char(32) obj.getString];
        elseif isa(inp, 'cell')
            obj = message('MATLAB:services:printmat:Array',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
            out = [char(32) char(32) obj.getString];
        else
            out = [char(32) char(32) getClassnameString(inp, headerLinkAttributes)];
        end        
    else
        if issparse(inp)
            % Input is sparse
            if isempty(inp)
               % Empty sparse logical
               if matlab.internal.display.isHot
                   obj = message('MATLAB:services:printmat:EmptySparseArray',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
               else
                   obj = message('MATLAB:services:printmat:EmptySparseArrayNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
               end               
               out = [char(32) char(32) obj.getString];            
            else
                if matlab.internal.display.isHot
                    obj = message('MATLAB:services:printmat:SparseLogicalVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                else
                    obj = message('MATLAB:services:printmat:SparseLogicalVectorNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                end                    
                out = [char(32) char(32) obj.getString];
            end
        else
            % Input is not sparse
             if isempty(inp)
                % Empty input
                obj = message('MATLAB:services:printmat:EmptyArray',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                out = [char(32) char(32) obj.getString];
            else
                % Non-empty input  
                obj = message('MATLAB:services:printmat:Array',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
                out = [char(32) char(32) obj.getString];
            end        
        end       
    end
end

function header = getHeaderForEnum(inp, headerLinkAttributes)    
    
    if isempty(inp)
        % Empty enumeration
        obj = message('MATLAB:ClassText:DISPLAY_EMPTY_ENUMERATION_LABEL', matlab.internal.display.dimensionString(inp), getClassnameString(inp, headerLinkAttributes));        
    else
        % Non-empty enumeration
        if isscalar(inp)
            % Scalar
            obj = message('MATLAB:ClassText:SCALAR_ENUMERATION_HEADER', getClassnameString(inp, headerLinkAttributes));
        else
            % Non-scalar
            obj = message('MATLAB:ClassText:ENUMERATION_ARRAY_HEADER', matlab.internal.display.dimensionString(inp), getClassnameString(inp, headerLinkAttributes));
        end
    end   
    
    header = [char(32) char(32) obj.getString];
end

function out = getClassNameForEnums(inp)
    %  If input is an enum, strip the package name if any
    out = '';
    if isenum(inp)
        str = class(inp);
        idx = regexp(str, '\.');
        if ~isempty(idx)
            out = str(idx(end)+1:end);
        else
            out = str;
        end
    end
end

function out = getHeaderForComplexEmptyNumeric(inp, headerLinkAttributes)
    if matlab.internal.display.isHot
        if isrow(inp)
        % Empty row vector
            obj = message('MATLAB:services:printmat:EmptyComplexRowVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
        elseif iscolumn(inp)
        % Empty column vector
            obj = message('MATLAB:services:printmat:EmptyComplexColumnVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
        elseif numel(size(inp)) == 2
        % Empty matrix
            obj = message('MATLAB:services:printmat:EmptyComplexMatrix',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
        else
        % Empty array
            obj = message('MATLAB:services:printmat:EmptyComplexArray',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
        end    
    else
        if isrow(inp)
        % Empty row vector
            obj = message('MATLAB:services:printmat:EmptyComplexRowVectorNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
        elseif iscolumn(inp)
        % Empty column vector
            obj = message('MATLAB:services:printmat:EmptyComplexColumnVectorNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
        elseif numel(size(inp)) == 2
        % Empty matrix
            obj = message('MATLAB:services:printmat:EmptyComplexMatrixNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
        else
        % Empty array
            obj = message('MATLAB:services:printmat:EmptyComplexArrayNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp, headerLinkAttributes));
        end        
     end
    
    out = [char(32) char(32) obj.getString];
end

function out = getClassnameString(inp, headerLinkAttributes)
    % Returns the classname string
    if isenum(inp)
        classname = getClassNameForEnums(inp);
    else
        classname = class(inp);
    end
    
    if matlab.internal.display.isHot
        out = ['<a href="matlab:helpPopup ' class(inp) '" ' headerLinkAttributes '>' classname '</a>'];
    else
        out = classname;
    end          
end
