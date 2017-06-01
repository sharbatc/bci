function [weights, sphere] = ICA(channels, mac)
% calls binica() the fastest stable ICA algorithm from eeglab toolbox
% note: binica() runs only on linux! -> runica() for mac... sorry guys!

% see more on ICA: https://sccn.ucsd.edu/wiki/Chapter_09:_Decomposing_Data_Using_ICA
% and here: http://www.mat.ucm.es/~vmakarov/Supplementary/wICAexample/TestExample.html

% source code binica: https://sccn.ucsd.edu/svn/software/eeglab/functions/sigprocfunc/binica.m
% source code runica: https://sccn.ucsd.edu/svn/software/eeglab/functions/sigprocfunc/runica.m

% return weights -> decomposed_channels = weights*sphere*channels

if mac == 1  % call runica()
    [weights, sphere] = runica(channels,'pca',63,'stop',1e-6,'maxsteps',256,'verbose','off'); 
    
elseif mac == 0  % use binica() on linux
    [weights, sphere] = binica(channels,'pca',63,'stop',1e-6,'maxsteps',256,'verbose','off'); 
end

end