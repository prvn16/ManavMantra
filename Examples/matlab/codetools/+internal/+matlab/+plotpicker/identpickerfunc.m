function varargout = identpickerfunc(action,fname,inputnames,inputvals)
%PLOTPICKERFUNC  Support function for Plot Picker component.

% Copyright 2009-2012 The MathWorks, Inc.

% Default display functions for MATLAB plots
if strcmp(action,'defaultshow')
    n = length(inputvals);
    toshow = false;
    % A single empty should always return false
    if isempty(inputvals) ||  isempty(inputvals{1})
        varargout{1} = false;
        return
    end
    switch lower(fname)
        case 'n4sid'
            x = inputvals{1};
            % Select either an iddata or idfrd object with at least one input, 
            % a real matrix with at least two columns, or two matrices/column 
            % vectors with the same number of rows.
            if n==1        
                % iddata object with >=1 inputs
                if (isa(x,'iddata') || isa(x,'idfrd')) && size(x,'Nu')>=1
                    toshow = true;
                % 2-column matrix
                elseif isnumeric(x) && isreal(x) && size(x,2)>=2 && size(x,1)>=2
                    toshow = true;
                end
            elseif n==2
                y = x;
                x = inputvals{2};
                % Matrix/vector with same number of rows
                if isnumeric(x) && isnumeric(y) && isreal(x) && isreal(y) && ...
                        size(x,1)==size(y,1) && ismatrix(x) && ismatrix(y)
                    toshow = true;
                % Frequency response matrix/vector with an increasing real
                % freq vector
                elseif isnumeric(x) && isnumeric(y) && ~isreal(y) && ...
                        isreal(x) && isvector(x) &&  size(x,1)==size(y,1) && ...
                        issorted(x)
                    toshow = true;
                end
            end

       case 'oe'
            x = inputvals{1};
            % Select either an iddata or idfrd object with one output and
            % at least one input, a matrix with at least two columns, or a
            % column vector and a matrix with the same number of rows.
            if n==1        
                % iddata object with >=1 inputs
                if (isa(x,'iddata') || isa(x,'idfrd')) && size(x,'Ny')==1 && ...
                        size(x,'Nu')>=1
                    toshow = true;
                % 2-column matrix
                elseif isnumeric(x) && isreal(x) && size(x,2)>=2 && size(x,1)>=2 && ...
                        ismatrix(x)
                    toshow = true;
                end
            elseif n==2
                y = x;
                x = inputvals{2};
                % real column vector and matix/vector with same number of
                % rows
                if isnumeric(x) && isnumeric(y) && isreal(x) && isreal(y) && ...
                        size(x,1)==size(y,1) && isvector(y) && ismatrix(x)
                    toshow = true;
                % Frequency response matrix/vector with an increasing real
                % freq vector
                elseif isnumeric(x) && isnumeric(y) && ~isreal(y) && ...
                        isreal(x) && size(y,2)==1 &&  size(x,1)==size(y,1) && ...
                        ismatrix(y) && issorted(x)
                    toshow = true;
                end
            end
                       
         case 'arx'
            % Select either an iddata object with at least one input, a
            % real matrix with at least two columns, or two matrices/column 
            % vectors with the same number of rows.
            x = inputvals{1};
            if n==1        
                % iddata object with >=1 inputs
                if isa(x,'iddata')  && size(x,'Nu')>=1
                    toshow = true;
                % 2-column matrix
                elseif isnumeric(x) && isreal(x) && ismatrix(x) && ...
                        size(x,2)>=2 && size(x,1)>=2
                    toshow = true;
                end
            elseif n==2
                y = x;
                x = inputvals{2};
                % Matrix/vector with same number of rows
                if isnumeric(x) && isnumeric(y) && isreal(x) && isreal(y) && ...
                         size(x,1)==size(y,1) && ismatrix(x) && ismatrix(y) ==2 
                    toshow = true;
                end
            end
        case 'arxtimeseries'
            x = inputvals{1};
            % Select an iddata object with zero inputs and at least two
            % outputs or a real matrix with at least two columns. 
            if n==1 
                % Vector timeseries iddata or >=2 column numeric matrix
                if isa(x,'iddata') && size(x,'Nu')==0 && size(x,'Ny')>=2
                    toshow = true;
                elseif isnumeric(x) && isreal(x) && size(x,2)>=2 && size(x,1)>=2 && ...
                        ismatrix(x)
                    toshow = true;
                end
            end
        case 'artimeseries'
            % Select  an iddata object with zero inputs and one output or a
            % real column vector.
            x = inputvals{1};
            if n==1 
                % Scalar timeseries iddata or 1 column numeric matrix
                if isa(x,'iddata') && size(x,'Nu')==0 && size(x,'Ny')==1
                    toshow = true;
                elseif isnumeric(x) && isvector(x) && isreal(x) && size(x,1)>=2
                    toshow = true;
                end
            end            
        case 'identspa'  
            % Select an iddata object or a real matrix or column vector
            x = inputvals{1};
            if n==1 
                % An iddata object or a numeric column vector
                if isa(x,'iddata') 
                    toshow = true;
                elseif isnumeric(x) && isreal(x) && size(x,1)>=2 && ismatrix(x)
                    toshow = true;
                end
            end
        case 'identcra'
            x = inputvals{1};
            % Select an iddata object representing data from a SISO system
            % or a vector time series with two outputs. Alternatively, 
            % select a single real numeric two column matrix.
            if n==1 
                if isa(x,'iddata') && ((size(x,'Nu')==1 && ...
                    size(x,'Ny')==1) ||  (size(x,'Nu')==0 && ...
                    size(x,'Ny')==2))
                    toshow = true;
                elseif isnumeric(x) && isreal(x) && size(x,1)>=2 && size(x,2)==2 && ...
                        ismatrix(x)
                    toshow = true;
                end
            end
        case 'iddataplot'
             % Select one or more iddata objects
             toshow = all(cellfun(@(x) isa(x,'iddata'),inputvals)); 
        case 'identbode'
            % One or more idmodel, idfrd, or lti objects
            toshow = all(cellfun(@(x) isa(x,'idmodel') || isa(x,'idfrd') || ...
                (isa(x,'lti') && ~isa(x,'frd')),inputvals));
        case 'identstep'
            % Select one or more idmodel, idnlmodel, idfrd, or lti objects
            toshow = all(cellfun(@(x) isa(x,'idmodel') || isa(x,'idfrd') || ...
                isa(x,'idnlmodel') || (isa(x,'lti') && ~isa(x,'frd')),inputvals));
        case {'identbodeband','identstepband'}
            % Select one or more idmodel, idfrd, or lti objects with
            % non-empty covariance matrix.
            Iidmodel = cellfun(@(x) isa(x,'idmodel'),inputvals);
            Iidfrd = cellfun(@(x) isa(x,'idfrd'),inputvals);
            if all(Iidmodel | Iidfrd | cellfun(@(x) isa(x,'lti'),inputvals))
               if any(Iidmodel) || any(Iidfrd)
                  toshow = any(cellfun(@(x) ~isempty(get(x,'CovarianceMatrix')),...
                      inputvals(Iidmodel))) || any(cellfun(@(x) ~isempty(get(x,'CovarianceData')),...
                      inputvals(Iidfrd)));
               end
            end                
        case 'identpzmap'
            % Select one or more idmodel or lti objects
            toshow = all(cellfun(@(x) isa(x,'idmodel') || ...
                (isa(x,'lti') && ~isa(x,'frd')),inputvals));          
        case 'identpzmapband'
            % Select one or more idmodel or lti objects with non-empty
            % covariance matrix.
            Iident = cellfun(@(x) isa(x,'idmodel'),inputvals);
            if all(Iident | cellfun(@(x) isa(x,'lti') && ~isa(x,'frd'),inputvals)) && any(Iident)
                  toshow = all(cellfun(@(x) ~isempty(x.CovarianceMatrix),...
                      inputvals(Iident)));
            end                     
        case 'idnlarxplot'
            % Select one or more idnlarx objects for which the isestimated
            % method returns true
            toshow = all(cellfun(@(x) isa(x,'idnlarx') && isestimated(x),inputvals));
        case 'idnlhwplot'   
            % Select one or more idnlhw objects for which the isestimated
            % method returns true
            toshow = all(cellfun(@(x) isa(x,'idnlhw') && isestimated(x),inputvals));           
        case 'identsim'   
            % Select an idmodel object with at least one input and an
            % iddata object with matching number of inputs and, for discrete 
            % time systems, equal sample times. For discrete models, the 
            % input may alternatively be specified as a real matrix where 
            % the number of columns matches the number of model inputs. 
            % The selection order does not matter for determining the enabled
            % state of the plot action.
            if n==2 
               idmodelObj = inputvals{1};
               iddataObj = inputvals{2};
               % Switch the order if necessary
               if isa(iddataObj,'idmodel') 
                   idmodelObj = inputvals{2};
                   iddataObj = inputvals{1};
               end
               if isa(idmodelObj,'idmodel') 
                   if isa(iddataObj,'iddata') 
                      toshow = size(idmodelObj,'Nu')>=1 && size(idmodelObj,'Nu')==size(iddataObj,'Nu') && ...
                         (get(idmodelObj,'Ts')==0 || get(idmodelObj,'Ts')==get(iddataObj,'Ts'));
                   elseif isnumeric(iddataObj) && isreal(iddataObj) && ndims(iddataObj)==2  %#ok<ISMAT>
                      toshow = size(idmodelObj,'Nu')>=1 && size(idmodelObj,'Nu')==size(iddataObj,2) && ...
                         get(idmodelObj,'Ts')>0;
                   end
               end
            end    
        case 'identpredict'
            % Select an idmodel or idnlmodel object and an iddata object
            % with matching numbers of inputs and outputs and equal sample
            % times (for discrete time systems).
            if n==2
                model = inputvals{1};
                data = inputvals{2};
                if isa(data,'iddata') && size(data,'Nu')>=1 && ...
                       (isa(model,'idmodel') || isa(model,'idnlmodel'))
                   toshow = size(data,'Nu') == size(model,'Nu') && ...
                       size(data,'Ny') == size(model,'Ny') && ...
                       ( get(model,'Ts')>0 || get(model,'Ts')==get(data,'Ts'));
                end
            end

        case 'identcompare'
            % Select one or more idmodel or idnlmodel objects with at least
            % one input and an iddata or idfrd object. All selections must 
            % have matching number of inputs and equal sample times (for 
            % discrete time systems).
            if length(inputvals)>=2
                models = inputvals(2:end);
                data = inputvals{1};
                if (isa(data,'iddata') || isa(data,'idfrd')) && size(data,'Nu')>=1 && ...
                        all(cellfun(@(x) isa(x,'idmodel') || isa(x,'idnlmodel'),...
                        models))
                    nu = cellfun(@(x) size(x,'Nu'),models);
                    if all(size(data,'Nu')==nu) 
                        Ts = cellfun(@(x) get(x,'Ts'),models);
                        toshow = all(Ts==0 | get(data,'Ts')==Ts );
                    end
                end
            end
    end
    varargout{1} = toshow;
% Default execution strings for ident plots
elseif strcmp(action,'defaultdisplay') 
    n = length(inputnames);
    dispStr = '';
    switch lower(fname)
        case 'n4sid'
           if n==1
               if isa(inputvals{1},'iddata') || isa(inputvals{1},'idfrd')
                   inArgs =  inputnames{1};
               elseif isnumeric(inputvals{1})
                   inArgs =  sprintf('iddata(%s(:,1),%s(:,2:end))',inputnames{1},...
                       inputnames{1});
               end
           elseif n==2
               if ~isreal(inputvals{1})
                   inArgs =  sprintf('idfrd(%s,%s,0)',inputnames{1},...
                       inputnames{2});
               else
                   inArgs = sprintf('iddata(%s,%s)',inputnames{1},inputnames{2});
               end
           end
           dispStr =  sprintf('compare(%s,n4sid(%s));',inArgs,inArgs);
        case {'arx','oe'}
           if n==1
               if isa(inputvals{1},'iddata') || isa(inputvals{1},'idfrd')
                   inArgs =  inputnames{1};
               elseif isnumeric(inputvals{1})
                   inArgs =  sprintf('iddata(%s(:,1),%s(:,2:end))',inputnames{1},...
                       inputnames{1});
               end
           elseif n==2
               if ~isreal(inputvals{1})
                   inArgs =  sprintf('idfrd(%s,%s,0)',inputnames{1},inputnames{2});
               else
                   inArgs =  sprintf('iddata(%s,%s)',inputnames{1},inputnames{2});
               end
           end            
           if isnumeric(inputvals{1})
               numInputs = size(inputvals{1},2)-(n==1);
           else
               numInputs = size(inputvals{1},'Nu');
           end
           orderVecStr = sprintf('[2 2*ones(1,%d) ones(1,%d)]',numInputs,numInputs);
           if strcmpi(fname,'arx')
                dispStr = sprintf('compare(%s,arx(%s,%s));',...
                    inArgs,inArgs,orderVecStr);
           else
                dispStr = sprintf('compare(%s,oe(%s,%s));',...
                    inArgs,inArgs,orderVecStr);
           end   
        case 'arxtimeseries'       
           if n==1
               if isa(inputvals{1},'iddata') 
                   inArgs =  inputnames{1};
                   numOutputs = size(inputvals{1},'Ny');
               elseif isnumeric(inputvals{1})
                   inArgs =  sprintf('iddata(%s)',inputnames{1});
                   numOutputs = size(inputvals{1},2);
               end
           end            
           orderVecStr = sprintf('2*eye(%d)',numOutputs);
           dispStr =  sprintf('compare(%s,arx(%s,%s),1);',inArgs,inArgs,...
               orderVecStr);
        case 'artimeseries'   
           if n==1
               if isa(inputvals{1},'iddata') 
                   inArgs =  inputnames{1};
               elseif isnumeric(inputvals{1})
                   inArgs =  sprintf('iddata(%s)',inputnames{1});
               end
           end            
           dispStr =  sprintf('compare(%s,ar(%s,2),1);',inArgs,inArgs);        
           
        case 'identspa' 
           dispStr =  sprintf('bode(spa(%s));',inputnames{1});
        case 'identbodeband'
           dispStr =  sprintf('bode(%s,''sd'',1,''fill'');',...
               localCreateArgStr(inputnames)); 
        case 'identstep'
               dispStr =  sprintf('step(%s);',localCreateArgStrInclIdfrd(inputnames,inputvals));
        case 'identstepband'
           dispStr =  sprintf('step(%s,''sd'',1,''fill'');',...
                  localCreateArgStrInclIdfrd(inputnames,inputvals));            

        case 'identpzmapband'
           dispStr =  sprintf('pzmap(%s,''sd'',1);',...
               localCreateArgStrInclIdfrd(inputnames,inputvals));
        case {'idnlarxplot','idnlhwplot'}
            dispStr =  sprintf('plot(%s);',localCreateArgStr(inputnames));
    end                   
    varargout{1} = dispStr;
% Custom label for ident plots
elseif strcmp(action,'defaultlabel')
    n = length(inputnames);       
    lblStr = '';
    switch lower(fname)
        case 'identspa'            
            if n>=1
                lblStr = sprintf('bode(spa(%s))',inputnames{1});
            else
                lblStr = '';
            end
        case 'identbodeband'
            if n>=1
               lblStr = sprintf('bode(%s,''sd'',1,''fill'')',...
                   localCreateArgStr(inputnames));
            else
               lblStr = '';
            end
        case 'identstepband'
            if n>=1
                lblStr = sprintf('step(%s,''sd'',1,''fill'')',...
                    localCreateArgStrInclIdfrd(inputnames,inputvals));
            else
                lblStr = '';
            end            
        case 'identpzmapband'
            if n>=1
                lblStr = sprintf('pzmap(%s,''sd'',1)',...
                    localCreateArgStrInclIdfrd(inputnames,inputvals));
            else
                lblStr = '';
            end             
    end
    varargout{1} = lblStr;    
end

% Create a comma separated argument string from the call array of input
% variable names. Wrap idfrd objects in n4sid.
function argStr = localCreateArgStrInclIdfrd(inputnames,inputvals)

if isa(inputvals{1},'idfrd') 
   argStr = sprintf('n4sid(%s)',inputnames{1});
else
   argStr = inputnames{1};
end           
for k=2:length(inputnames)
   if isa(inputvals{1},'idfrd')
       argStr = sprintf('%s,n4sid(%s)',argStr,inputnames{k});
   else
       argStr = sprintf('%s,%s',argStr,inputnames{k});
   end
end

% Create a comma separated argument string from the call array of input
% variable names.
function argStr = localCreateArgStr(inputnames)

argStr = inputnames{1};
for k=2:length(inputnames)
   argStr = sprintf('%s,%s',argStr,inputnames{k});
end
