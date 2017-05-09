function [dataout, mask, layout] = proc_lap(datain, coordinates)
% [dataout, mask, layout] = proc_lap(datain, coordinates)
%
% Compute laplacian spatial filter on the datain. datain must be points x
% channels matrix. coordinates is a structure with channel informations.
% The structure must have the following fields:
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
% The function returns the data filtered in the same format (points x
% channels). Optional output arguments are the mask and the layout used.
%
% SEE ALSO: proc_lap_mask, proc_coordinates
    
    [mask, layout] = proc_lap_mask(coordinates);   
    dataout =  datain*mask;

end
