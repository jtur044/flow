function show_flowalyzer_result (dataTable, name, varargin)

% SHOW_FLOWALYZER_RESULT Show result of FLOWALYZER 
%
%       show_flowalyzer_result (dataTable, name, varargin)
%
% where 
%       dataTable is a filename or a table 
%       name      is the name of the desired selectROI column (the tile name)
%
% EXAMPLE 
%
%   % Example 1
%   filename = './data/j_kau_3/clip0.result.csv';
%   dataTable = load_flowalyzer_result (filename);
%   show_flowalyzer (dataTable, 'global');

p = inputParser ();
p.addOptional ('Component', 'Vy');
p.parse(varargin{:});
res = p.Results;


% (r,c) pair 

if (ischar(dataTable))
    dataTable = readtable (dataTable);
end

%% name was named 
if (nargin >= 2)
    i = cellfun( @(x) strcmp (x, name),  dataTable.selectROI); % (dataTable.row == r) & (dataTable.col == c);    
    dataTable = dataTable(i, :);                   
end    
    
t = dataTable.CurrentTime;


i = ismember('Vx_updated', dataTable.Properties.VariableNames);
if (i)
    Vx = dataTable.Vx_updated;
    Vy = dataTable.Vy_updated;
else
    Vx = dataTable.Vx;
    Vy = dataTable.Vy;    
end

X  = dataTable.X;
Y  = dataTable.Y;

h(1) = subplot(2,1,2);

yyaxis right;
plot (t, Vx);
ylabel ('Velocity (px/s)');
ylim([-5 5]);  

yyaxis left;
plot (t, X);
ylabel ('Displacement (px)');
ylim([-0.4 0.4]);  

grid on;

title ('Horizontal');

h(2) = subplot(3,1,1);

yyaxis right;
plot (t, Vy);
ylabel ('Velocity (px/s)');
ylim([-5 5]);  

yyaxis left;
plot (t, Y);
ylabel ('Displacement (px)');
ylim([-0.4 0.4]);  

grid on;

title ('Vertical');


%% if the blink field is present 
i = ismember('isblink', dataTable.Properties.VariableNames);
if (i)
    h(3) = subplot(3,1,3);
    
    yyaxis left;
    b = dataTable.isblink;
    stem (t, b, 'r-');
    ylim([-0.2, 1.2]);

    yyaxis right;

    
    title ('Blink Detection');
end


linkaxes(h);

%ylim([-10.0 +10.0]);

