function show_flowalyzer_result (dataTable, r, c, varargin)

% SHOW_FLOWALYZER_RESULT Show result of FLOWALYZER 
%
%       show_flowalyzer_result (dataTable, varargin)
%
% where 
%       
%

p = inputParser ();
p.addOptional ('Component', 'Vy');
p.parse(varargin{:});
res = p.Results;


% (r,c) pair 

if (ischar(dataTable))
    dataTable = readtable (dataTable);
end    
    
i = (dataTable.row == r) & (dataTable.col == c);    
dataTable = dataTable(i, :);        
t = dataTable.CurrentTime;

Vx = dataTable.Vx;
X  = dataTable.X;
Vy = dataTable.Vy;
Y  = dataTable.Y;

h(1) = subplot(3,1,2);

yyaxis right;
plot (t, Vx);
ylabel ('Velocity (px/s)');
  
yyaxis left;
plot (t, X);
ylabel ('Displacement (px)');

grid on;

title ('Horizontal');



h(2) = subplot(3,1,1);

yyaxis right;
plot (t, Vy);
ylabel ('Velocity (px/s)');

yyaxis left;
plot (t, Y);
ylabel ('Displacement (px)');

grid on;

title ('Vertical');


%% if the blink field is present 
i = ismember('isblink', dataTable.Properties.VariableNames);
if (i)
    h(3) = subplot(3,1,3);
    b = dataTable.isblink;
    stem (t, b, 'r-');
    ylim([-0.2, 1.2]);
end


linkaxes(h);

%ylim([-10.0 +10.0]);

