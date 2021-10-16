function protocol = load_configuration (protocolfile)

% LOAD_PROTOCOL load protocol file with comments 

    if (~exist(protocolfile,'file'))
        error (sprintf('The configuration file "%s" - was not found.', protocolfile));
    end
    
   
    temp_protocolfile = tempname();        
    stripcomments(protocolfile, temp_protocolfile);        
    try 
    protocol = loadjson (temp_protocolfile);
    catch ME     
        error (sprintf('There was an error in file "%s"', protocolfile));
    end 
end