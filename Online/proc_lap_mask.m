function [mask, layout] = proc_lap_mask(coordinates)
% [mask, layout] = proc_lap_mask(coordinates)
%
% Compute the Channel x Channel matrix of weights for each channel. Weights
% are based on the inverse of the distances of the neightbours. Neighbours
% for each electrode are provided by the input coordinates. Coordinates 
% is a structure with length equal to the number of channel and the following
% fields:
%
% coordinates.Name          -- Channel name
% coordinates.Id            -- Channel Id
% coordinates.Head          -- Head size
% coordinates.Incl          -- Channel inclination
% coordinates.Azim          -- Channel azimut
% coordinates.IdNb          -- Neighbours id
% coordinates.X             -- Channel X coordinate
% coordinates.Y             -- Channel Y coordinate
% coordinates.Z             -- Channel Z coordinate
% coordinates.IdNb          -- Neithbours id
% coordinates.DNb           -- Neithbours distances
% coordinates.WNb           -- Neithbours weights
%
% The function returns mask that can be multipicated directly with the
% data: datalap = data*mask 
% data must be a points x channel matrix;
% It returns also layout, the coordinates structure populated with
% neightbours distances and weights
% 
% SEE ALSO: proc_lap, proc_coordinates


    % Copy coordinates structure
    layout = coordinates;

    % Computing distance and weights of the neightbours
    
    for ChId = 1:length(layout)
        
        layout(ChId).DNb = get_channeldistance(layout(ChId).Id, layout(ChId).IdNb, coordinates); 
        
        weights = 1./layout(ChId).DNb;
        
        normWeights = weights./sum(weights);
        
        layout(ChId).WNb = -normWeights;
    end


    % Computing mask
    NumChannels = length(layout);
    mask        = zeros(NumChannels, NumChannels);
    
    
    for ChId = 1:NumChannels
        
        IdNb = layout(ChId).IdNb;
        WNb  = layout(ChId).WNb;
        
        W = zeros(NumChannels, 1);
                
        W(IdNb) = WNb;
        W(ChId) = 1;
        mask(:, ChId) = W;
        
    end
    
end

function Distances = get_channeldistance(RefChanId, OthChanId, coordinates)

    
    RefX = coordinates(RefChanId).X;
    RefY = coordinates(RefChanId).Y;
    RefZ = coordinates(RefChanId).Z;
    
    NumOthChannels = length(OthChanId);
    Distances = zeros(NumOthChannels, 1);
    
    for c = 1:NumOthChannels
       
        CurrX = coordinates(OthChanId(c)).X;
        CurrY = coordinates(OthChanId(c)).Y;
        CurrZ = coordinates(OthChanId(c)).Z;
        
        Distances(c) = sqrt( (RefX - CurrX)^2 + (RefY - CurrY)^2 + (RefZ - CurrZ)^2);
        
    end


end
