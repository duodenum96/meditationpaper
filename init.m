%% Initialize the project (paths and variables)
clear, clc, close all
%% Path
projectfolder = 'C:\Users\user\Desktop\brain_stuff\Bianca\meditationpaper';
cd(projectfolder)
restoredefaultpath
addpath(genpath(projectfolder))

datafold = [projectfolder,  '\data'];
%% Chaudhuri Default Parameters
p = [];

p.tau_E = 20;         % Intrinsic time constant(ms)
p.tau_I = 10;
p.beta_E = 0.066;     % Slope of firing rate (Hz / pA)
p.beta_I = 0.351;
p.w_EE = 24.3;        % Excitatory to excitatory coupling (pA / Hz)
p.w_EI = 19.7;        % Inhibitory to excitatory
p.w_IE = 12.2;
p.w_II = 12.5;
p.mu_EE = 33.7;       % Fixed parameter that control excitatory input (pA / Hz)
p.mu_IE = 25.3;
p.eta = 0.68;         % Scaling parameter for hierarchy
p.dt = 1;           % Time steps (ms)
p.tspan = 300;

timevector = 0:p.dt:p.tspan/p.dt*1000;
ntime = length(timevector);
% Load pkl file for hierarchy
fid = py.open([datafold, '\subgraph_data.pkl'],'rb');
h = py.pickle.load(fid,pyargs('encoding', 'latin1'));
h = struct(h); h = double(h.hier_vals); p.h = h' / max(h);


% Input noise to V1
noise = randn([1 ntime]);
p.I_ext_E  = zeros([29 ntime]);
p.I_ext_E(1,:) = noise;

% SC matrix and ROIs
scpath = [datafold, '/SC.xlsx'];
opts = detectImportOptions(scpath);
opts.VariableTypes = [{'char'}, {'char'}, {'double'}, {'double'}];
SC_raw = readtable(scpath, opts);

rois = {'V1', 'V2', 'V4', 'DP', 'MT', '8m', '5', '8l', 'TEO', '2', 'F1', 'STPc', '7A', '46d', '10', '9/46v','9/46d', 'F5', 'TEpd', 'PBr', '7m', '7B', 'F2', ...
    'STPi', 'ProM', 'F7', '8B', 'STPr', '24c'};
nrois = length(rois);
J = zeros(nrois);

for i = 1:29
    for j = 1:29
        index = find(strcmp(SC_raw{:,1}, rois{i}) & strcmp(SC_raw{:,2}, rois{j}));
        if isempty(index) == 0
            J(i,j) = SC_raw{index,3};
        end
    end
end
p.J = J;
[v_E, time] = chaudhuri(p);