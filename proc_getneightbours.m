function neighbours = proc_getneightbours(ChanName, MaxDist, Coordinates)
% neighbours = proc_getneightbours(ChanName, MaxDist, Coordinates)
%
% Given a channel name and the structure with the coordinates of all
% channels, it returns the ids of those channel far no more than the
% maximum distance.
%
% ChanName                  -- Name of the reference channel (no case
%                              sensitive)
% MaxDist                   -- Maximum distance to get neighbours (cm)
% Coordinates               -- Structure with all channels information
%
% Coordinates.Name          -- Channel name
% Coordinates.Id            -- Channel Id
% Coordinates.Head          -- Head size
% Coordinates.Incl          -- Channel inclination
% Coordinates.Azim          -- Channel azimut
% Coordinates.X             -- Channel X coordinate
% Coordinates.Y             -- Channel Y coordinate
% Coordinates.Z             -- Channel Z coordinate
%
% SEE ALSO: proc_getchannel

    
    NumChannels = length(Coordinates);
    
    SelChan = [];
    for ChId = 1:NumChannels
        if strcmpi(Coordinates(ChId).Name, ChanName) == 1
            SelChan = cat(1, SelChan, Coordinates(ChId).Id);
        end
    end
    
    if length(SelChan) > 1
        error('chk:sel', 'More the one channel in the list with this name');
    end
    
    if isempty(SelChan) == 1
        error('chk:sel', 'No channel in the list with this name');
    end
    
    
    RefChan = Coordinates(SelChan);
    
    neighbours = [];
    
    for ChId = setdiff(1:NumChannels, SelChan)
       
        cChan = Coordinates(ChId);  
        dist = sqrt( (RefChan.X - cChan.X)^2 + (RefChan.Y - cChan.Y)^2 + (RefChan.Z - cChan.Z)^2);
        
        if dist <= MaxDist
           neighbours = cat(1, neighbours, cChan.Id);
        end
        
    end
    
    neighbours = sort(neighbours);

end