function str = datestrnow()
%DATESTRNOW A simple datestr now call with specific format
%   This simple function returns a datetime string using the format
%   'dd-mmm-yyyy_HH-MM-SS_FFF'. This is just to provide a unified way of
%   naming files between MapReduce frameworks.
    str = datestr(now, 'dd-mmm-yyyy_HH-MM-SS_FFF');
end
