function varargout = setquantizer(q,varargin)
%SETQUANTIZER Set QUANTIZER properties
%
%   To support backward compatibility of the QUANTIZER constructor.
%
%   If there are any inputs, parse them to allow constructions without
%   parameter-value pairs, like:
%       q = quantizer('fixed','convergent','wrap',[4 3]);
%
%   After determining what kind of input it is, then rely on the builtin
%   property-setting methods to do the work.

%   Copyright 1999-2011 The MathWorks, Inc.

modes = {'fixed', 'ufixed', 'float', 'double', 'single', 'none','boolean',...
        'scaleddouble', 'unsignedscaleddouble'};
roundmodes = {'ceil', 'convergent', 'fix', 'floor', 'nearest', 'round', 'ceiling', 'zero'};
overflowmodes = {'saturate', 'wrap'};
stringvalues = {modes{:},roundmodes{:},overflowmodes{:}};
properties = {'mode','datamode','roundmode','overflowmode', ...
              'format','max','min','noverflows', 'nunderflows', 'noperations', ...
              'quantizer',...
              'tag'};  
names = {overflowmodes{:},roundmodes{:},modes{:},properties{:}};
property='';

loopcounter = 1;
while loopcounter <= length(varargin)
  value = varargin{loopcounter};
  
  if ischar(value)
    ind = strmatch(lower(value),names);
    if length(ind)==1
      value = names{ind};
    end
    switch lower(value)
      case properties
        % quantizer(q, property)
        % quantizer(q, property, value)
        % quantizer(q, property1, value1, ...)
        property=lower(value);
        switch length(varargin)
          case 1
            % quantizer(q, property)
            % This syntax doesn't do anything, because no value is
            % being set.  Leave it for backward compatibility.
            return  % early out of the function
          otherwise
            % quantizer(q, property, value)
            % quantizer(q, property1, value1, ...)
            % Get the value associated with the property
            loopcounter=loopcounter+1;
            if loopcounter>length(varargin)
              error(message('fixed:quantizer:invalidPVPairs'));
            end
            value=varargin{loopcounter};
        end
      case stringvalues
        switch lower(value)
          case modes
            property = 'mode';
          case roundmodes
            property = 'roundmode';
          case overflowmodes
            property = 'overflowmode';
        end
    end

    set(q,property,value);
  elseif ~isjava(value) & isnumeric(value)
    q.format = value(:)';  % Make it a row
  elseif isa(value,'struct')
    % quantizer(q, ..., a, ...) where a is a struct.
    set(q,value);
  elseif isa(value,'cell')
    % quantizer(q, ..., pn,pv, ...)
    % Cells are only valid as pn,pv cells
    % Check that the next entry is a cell and that they are the same size
    pn = value; % Property name cell
    loopcounter=loopcounter+1;  
    if loopcounter>length(varargin)
      error(message('fixed:quantizer:invalidPVPairs'));
    end
    pv=varargin{loopcounter}; % Property value cell
    set(q,pn,pv);
  elseif isa(value,'embedded.quantizer')
    set(q,'roundmode',    value.roundmode,...
          'overflowmode', value.overflowmode,...
          'format',       value.format,...
          'mode',         value.mode);
  else
    error(message('fixed:quantizer:setquantizer_invalidValueClass', class(value)));
  end
  loopcounter = loopcounter + 1;
end % while loopcounter <= length(varargin)

if nargout>0
  % q1 = set(q,...)
  % [q1,q2,...] = set(q,...)
  for k=1:nargout
    varargout{k} = copyobj(q);
  end
end
