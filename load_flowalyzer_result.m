function dataTable = load_flowalyzer_result (filename, name, varargin)

% LOAD_FLOWALYZER_RESULT Show result of FLOWALYZER 
%
%       load_flowalyzer_result (filename, name, varargin)
%
% where 
%
%   filename is the name of the CSV file (or a table)
%   name     is the name of the tile (have a look in the .config file used to
%               generate the data 
%
% EXAMPLE 
%
%   % see demo_flowalyzer.m for information about generating an output 
%   % file. Once this is done you can load the output file using thr 
%   % following ... 
%
%   % Example 1
%   % tile-5 is 6th tile of a 3x3 grid (row = 2, col =2)
%   filename = './data/Saaed/clip0.result.csv';
%   dataTable = load_flowalyzer_result (filename, 'tile-5');
%
%   % Example 2
%   filename = './data/Saaed/clip0.result.csv';
%   dataTable = load_flowalyzer_result (filename);
%

p = inputParser ();
p.parse(varargin{:});
res = p.Results;

% (r,c) pair 
if (ischar(filename))
    dataTable = readtable (filename);
else
    dataTable = filename;
end    
    
%% if the name is specified then filter on it 
if (nargin >= 2)
    i = cellfun( @(x) strcmp (x, name),  dataTable.selectROI); % (dataTable.row == r) & (dataTable.col == c);    
    dataTable = dataTable(i, :);        
end 

return