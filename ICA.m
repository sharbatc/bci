function [weights, sphere] = ICA(channels)
% calls binica() the fastest stable ICA algorithm from eeglab toolbox
% note! binica() runs only on unix!
% see more on ICA: https://sccn.ucsd.edu/wiki/Chapter_09:_Decomposing_Data_Using_ICA
% source code: https://sccn.ucsd.edu/svn/software/eeglab/functions/sigprocfunc/binica.m
% return weights -> decomposed_channels = weights*channels (and I have no idea what sphere is - András)

% run ICA on short epoch (5% of the whole dataset in the middle of the trial) to get initial weights
tmp = size(channels,2)/20;
[init_weights, sphere_] = binica(channels(:,10*tmp:11*tmp),'stop',1e-6,'maxsteps',256);

% run ICA on the whole trial, using the inital weights calculated before
[weights, sphere] = binica(channels,'weightsin',init_weights,'stop',1e-5,'maxsteps',128); % terminates earlier...

end