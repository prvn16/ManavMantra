function gpucoder_publish_a_demo(demoname)

    set(0,'DefaultFigureWindowStyle' , 'normal');
    try
        disp(['Publishing demo : ' demoname]);
        opts.stylesheet = fullfile(matlabroot,'tools','examples','exampletools','m-file.xsl');
        publish(demoname, opts);
        disp('publish successful');
    catch e
        disp('publish failied');
        disp(e.getReport);
    end

end
