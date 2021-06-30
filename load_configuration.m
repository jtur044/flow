function protocol = load_configuration (protocolfile)

% LOAD_PROTOCOL load protocol file with comments 

    temp_protocolfile = tempname();        
    stripcomments(protocolfile, temp_protocolfile);        
    protocol = loadjson (temp_protocolfile);

end