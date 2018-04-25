%PYARGS Creates keyword arguments for Python.
%   S = PYARGS('key1', VALUE1, 'key2', VALUE2,...) creates keyword 
%   arguments for Python.
%
%   Example
%     py.dict(pyargs('type',{'big','little'},'color','red','x',{3 4}))
%
%     is the equivalent of the Python command
%
%     >>> dict(type=('big', 'little'), color='red', x=(3., 4.))
%

