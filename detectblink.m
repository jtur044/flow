function detectblinkv (V, fps)


p = inputParser ();
p.addOptional ('blink_duration', 0.5);
p.addOptional ('blink_threshold', 1);
p.parse(varargin{:});
res = p.Results;


T = blink_duration;


%% time constant 
t = ((1:length(f))-1) / fps;

%% detect Blink Like features 
sigma = T/5;  %% 5 standard 
t0  = linspace(-T/2,T/2,T*fps); 
f   = wavepacket (t0,T,sigma);

%% correction information
[c0, lags] = xcorr (V, f);
i  = (lags >= 0);
c  = c0(i);

%% These maximum time points indicate the start of a blink


end