function setdisp(obj)

% Error if invalid object(s) are given.
if ~all(isvalid(obj))
    error(message('MATLAB:timer:invalid'));
end

% calling builtin set function
out = set(obj.getJobjects);
fields = fieldnames(out); % get settable property names
for lcv=1:length(fields) % foreach property, print line in std. 'set' output
    field = out.(fields{lcv});
    fprintf([blanks(4) fields{lcv}]); % print the prop. name
    if ~isempty(strfind(fields{lcv}, 'Fcn'))
        % We have an '...Fcn' property.
        fprintf(': string -or- function handle -or- cell array\n');
    elseif (isempty(field)) % if field enum values is [], must not be enum; end line here.
        fprintf('\n');
    else
        % list enum values in format [ {default} option2 option3... ]
        fprintf([': ' formatEnum(field) '\n']);
    end
end


function out = formatEnum(field)
out = ['[ {' field{1} '}' ];
for lcv2=2:length(field)
    out = [out ' | ' field{lcv2} ]; %#ok<AGROW>
end
out = [out ' ]'];