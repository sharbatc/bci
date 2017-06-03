function [activations, W, invW] = ICA(channels, ncomponents, mac)
% calls binica() the fastest stable ICA algorithm from eeglab toolbox
% note: binica() runs only on linux! -> runica() for mac... sorry guys!

% see more on ICA: https://sccn.ucsd.edu/wiki/Chapter_09:_Decomposing_Data_Using_ICA
% and here: http://www.mat.ucm.es/~vmakarov/Supplementary/wICAexample/TestExample.html

% source code binica: https://sccn.ucsd.edu/svn/software/eeglab/functions/sigprocfunc/binica.m
% source code runica: https://sccn.ucsd.edu/svn/software/eeglab/functions/sigprocfunc/runica.m
% source code of posact: https://sccn.ucsd.edu/svn/software/eeglab/functions/sigprocfunc/posact.m

assert(ncomponents <= 64,'max number of components to keep is 64')

if mac == 1  % call runica()
    if ncomponents < 64
        [weights, sphere] = runica(channels,'pca',ncomponents,'stop',1e-6,'maxsteps',256,'verbose','off');
        W = weights * sphere;  % unmixing matrix
        invW = inv(W);  % mixing matrix
        activations = W * channels;
    else
        [weights, sphere] = runica(channels,'stop',1e-6,'maxsteps',256,'verbose','off');
        [activations, invW, W] = posact(channels,weights,sphere);  % might be buggy - by EEGLab people
    end
    
elseif mac == 0  % use precomputed weights and binica() on linux
    if ncomponents < 64
        [weights, sphere] = binica(channels,'pca',ncomponents,'stop',1e-6,'maxsteps',256,'verbose','off');
        [activations, invW, W] = posact(channels,weights,sphere);  % might be buggy - by EEGLab people
    else
        % precompute weights
        tmp = floor(size(channels,2)/20);
        [init_weights, ~] = binica(channels(:,10*tmp:11*tmp),'stop',1e-6,'maxsteps',256,'verbose','off');
    
        [weights, sphere] = binica(channels,'weightsin',init_weights,'stop',1e-6,'maxsteps',256,'verbose','off');
        W = weights * sphere;  % unmixing matrix
        invW = inv(W);  % mixing matrix
        activations = W * channels;
    end
    % delete generated (random) binary files on linux
    delete 'binica*'
    delete 'bias_after_adjust'
    delete 'temp.*'
end

end