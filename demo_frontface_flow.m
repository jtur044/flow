% DEMO_FRONTFACE_FLOWALYZER Demo the fornt face flow-alyzer
%
% This demo runs the flowalyzer on front-face eye camera videos
%
%


%% define output files 

% The reduced file are reduced FRAME-RATE Files 
%
% !ffmpeg -y -i eye0.mp4 -filter:v fps=30 eye0.reduced.mp4
%
% Only do ONCE!


%% MN_Threshold1_10times_LogMAR-02_08intensity075
inputDataFile   = './data/MN_Threshold1_10times_LogMAR-02_08intensity075/right_video/flowdata.updated.csv';
bestTile        = 'global';

%% show analysis 
dataTable = readtable (inputDataFile);

figure(1); clf;
show_flowalyzer_result (dataTable, bestTile);
subplot(3,1,1);
yyaxis left;
ylim([-0.2 0.2]);
%savefig(gcf);

yyaxis right;
ylim([-12 12]);


%figure(2); clf;
%show_flowalyzer_result (dataTable, 2,2, 'Component', 'Vx');
