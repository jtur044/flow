% /***********************************************************************
% * Company: TATA ELXSI
% * File: removecomment.m
% * Author :Nitin
% * Version :1.0
% * Date:4-8-2006
% * Operating Environment: 
% * Description: Remove comments in c file 
% ex: checkvariable('e:\nitin','xx.xls')
% * Dependencies : 
% * Customer Bug No./ CMF No. :
% * Brief description of the fix/enhancement :
% ***********************************************************************/
function [flag, outputname] = stripcomments(filename, outputfilename)
 
fid = fopen(filename);

 if (nargin == 1) 
    [fpath, fname, fext] = fileparts (filename);
    outputfilename = fullfile (fpath, strcat(fname, '.stripped', fext));  
 end
 
 % write the file 
 fid_2 = fopen(outputfilename, 'w');
 while (~feof(fid))
 
    tline = fgetl(fid);
    
    %% deal with this odd error
    tline = strrep(tline, '},]' ,'}]');
    
    %% deal with line ending comments  
    start = strfind(tline, '//');    
    if (~isempty(start))
        rline = replaceBetween(tline, start, length(tline), '', 'Boundaries', 'inclusive');
        rline = deblank(rline);
    else
        rline = deblank(tline);
    end
    
    fprintf(fid_2, '%s\n', rline);
        
 end
 
 fclose (fid);
 fclose (fid_2);
 

 
