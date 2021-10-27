

%% define output files 

% The reduced file are reduced FRAME-RATE Files 
%
% !ffmpeg -y -i eye0.mp4 -filter:v fps=30 eye0.reduced.mp4
%
% Only do ONCE!


%% MN_Threshold1_10times_LogMAR-02_08intensity075
inputDataFile   = './data/MN_Threshold1_10times_LogMAR-02_08intensity075/right_video/flowdata.csv';
bestTile        = 'tile-5';

%% show analysis 
dataTable = readtable (inputDataFile);

figure(1); clf;
show_flowalyzer_result (dataTable, bestTile);

%figure(2); clf;
%show_flowalyzer_result (dataTable, 2,2, 'Component', 'Vx');
