function protocol = load_commented_json (protocolfile)

% LOAD_COMMENTED_JSON load protocol file with comments 

    temp_protocolfile = tempname();        
    stripcomments(protocolfile, temp_protocolfile);        
    protocol = loadjson (temp_protocolfile);

end