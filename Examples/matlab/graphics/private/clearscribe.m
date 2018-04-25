function clearscribe(fig)

%   Copyright 2013-2017 The MathWorks, Inc.

  scribeax = findall(fig,'Type','annotationpane');

  if any(ishghandle(scribeax))
    for ix=1:numel(scribeax)
        delete(get(scribeax(ix),'Children'));
    end
  end
  
