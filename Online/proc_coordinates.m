function coordinates = proc_coordinates(ChannelLocations, HeadSize, NeighDistance, SelectedChannels)
% coordinates = proc_coordinates(ChannelLocations, HeadSize, NeighDistance, SelectedChannels)
%
% ChannelLocations          -- Path to txt file with channels info. The 
%                              file must have the first column with the 
%                              channel number, the second column with the 
%                              channel name, third column with inclination 
%                              and fourth one with azimut. Others columns 
%                              are ignored.
% HeadSize                  -- Head size (from cap)
% NeighDistance             -- Distance of the neighbours for the laplacian
% SelectedChannels          -- List of selected channels. If empty it takes
%                              all channels in the ChannelLocations file
%
% Read the spherical coordinates from text file. Convert them in cartesian coordinates
% and return struct with size equal to the number of channel and the
% following fields:
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
%
% SEE ALSO: proc_getchannel, proc_getneightbours

    fid = fopen(ChannelLocations);     
    Reading = textscan(fid, '%d %s %f %f %*[^\n]'); 
    fclose(fid);
    
    ChannelsId    = Reading{1};
    ChannelsName  = Reading{2};
    Inclination   = Reading{3};
    Azimut        = Reading{4};
    
    
    
    coordinates = struct('Name', [], 'Id', [], 'Head', [], 'Incl', [], 'Azim', [], 'IdNb', [], 'X', [], 'Y', [], 'Z', []);
    
    if nargin < 3
        NumChannels = length(ChannelsName);
        SelectedChannels = 1:NumChannels;
    end
    
    Radius      = HeadSize/(2*pi);
    
    neighbours  = get_neighbours(ChannelLocations);
    
    
    for ChId = SelectedChannels
        
        coordinates(ChId).Name  = ChannelsName{ChId};
        coordinates(ChId).Id    = ChannelsId(ChId);
        coordinates(ChId).Head  = HeadSize;
        coordinates(ChId).Incl  = Inclination(ChId);
        coordinates(ChId).Azim  = Azimut(ChId);
        coordinates(ChId).IdNb2  = sort(neighbours(ChId).IdNb);
    
        % Adding cartesian coordinates
        
        coordinates(ChId).X    = Radius * sin(Inclination(ChId)*pi/180) * sin(Azimut(ChId)*pi/180);
        coordinates(ChId).Y    = Radius * sin(Inclination(ChId)*pi/180) * cos(Azimut(ChId)*pi/180);
        coordinates(ChId).Z    = Radius * cos(Inclination(ChId)*pi/180);
    
        
    end
    
    for ChId = SelectedChannels
        coordinates(ChId).IdNb = proc_getneightbours(coordinates(ChId).Name, NeighDistance, coordinates);
    end
    %keyboard

    
%     for i =1:64
%         a = [];
%         a = setdiff(coordinates(i).IdNb, coordinates(i).IdNb2);
%         if isempty(a)  == false
%             disp(['Diff for channel  : ' coordinates(i).Name ' (' num2str(coordinates(i).Id) ')']);
%             proc_getchannel(a, ChannelLocations)
%         end
%         
%     end
end

function distance = get_distance(ch1, ch2)

    distance = sqrt( (ch1.X - ch2.X)^2 + (ch1.Y - ch2.Y)^2 + (ch1.Z - ch2.Z)^2);

end

function neighbours = get_neighbours2(ref, others, maxdist)

    NumChannels = length(others);
    neighbours = [];
    
    for chId = 1:NumChannels
       
        c_dist = get_distance(ref, others(chId));
        
        if c_dist <= maxdist && strcmpi(ref.Name, others(chId).Name) == 0
           neighbours = cat(1, neighbours, others(chId).Id);
        end
        
    end
end


function neighbours = get_neighbours(channellocation)

    % TO DO BETTER
    
%     'Fp1'
       neighbours(1).IdNb  = proc_getchannel({'AF7'; 'AF3'; 'AFz'; 'FPz'}, channellocation);
%     'AF7'
       neighbours(2).IdNb  = proc_getchannel({'F7'; 'F5'; 'F3'; 'AF3'; 'FP1'}, channellocation);
%     'AF3'
       neighbours(3).IdNb  = proc_getchannel({'F5'; 'F3'; 'F1'; 'AFz'; 'FPz'; 'FP1'; 'AF7'}, channellocation);
%     'F1'
       neighbours(4).IdNb  = proc_getchannel({'F3'; 'FC3'; 'FC1'; 'FCz'; 'Fz'; 'AFz'; 'AF3'}, channellocation);
%     'F3'
       neighbours(5).IdNb  = proc_getchannel({'FC3'; 'FC1'; 'F1'; 'AF3'; 'AF7'; 'F5'; 'FC5'}, channellocation);
%     'F5'
       neighbours(6).IdNb  = proc_getchannel({'FC5'; 'FC3'; 'F3'; 'AF3'; 'AF7'; 'F7'; 'FT7'}, channellocation);
%     'F7'
       neighbours(7).IdNb  = proc_getchannel({'FT7'; 'FC5'; 'F5'; 'AF3'; 'AF7'}, channellocation);
%     'FT7'
       neighbours(8).IdNb  = proc_getchannel({'T7'; 'C5'; 'FC5'; 'F5'; 'F7'}, channellocation);
%     'FC5'
       neighbours(9).IdNb  = proc_getchannel({'C5'; 'C3'; 'FC3'; 'F3'; 'F5'; 'F7'; 'FT7'; 'T7'}, channellocation);
%     'FC3'
       neighbours(10).IdNb  = proc_getchannel({'C3'; 'C1'; 'FC1'; 'F1'; 'F3'; 'F5'; 'FC5'; 'C5'}, channellocation);
%     'FC1'
       neighbours(11).IdNb  = proc_getchannel({'C1'; 'Cz'; 'FCZ'; 'FZ'; 'F1'; 'F3'; 'FC3'; 'C3'}, channellocation);
%     'C1'
       neighbours(12).IdNb  = proc_getchannel({'CP1'; 'CPZ'; 'CZ'; 'FCZ'; 'FC1'; 'FC3'; 'C3'; 'CP3'}, channellocation);
%     'C3'
       neighbours(13).IdNb  = proc_getchannel({'CP3'; 'CP1'; 'C1'; 'FC1'; 'FC3'; 'FC5'; 'C5'; 'CP5'}, channellocation);
%     'C5'
       neighbours(14).IdNb  = proc_getchannel({'CP5'; 'CP3'; 'C3'; 'FC3'; 'FC5'; 'FT7'; 'T7'; 'TP7'}, channellocation);
%     'T7'
       neighbours(15).IdNb  = proc_getchannel({'TP7'; 'CP5'; 'C5'; 'FC5'; 'FT7'}, channellocation);
%     'TP7'
       neighbours(16).IdNb  = proc_getchannel({'P7'; 'P5'; 'CP5'; 'C5'; 'T7'; 'P9'}, channellocation);
%     'CP5'
       neighbours(17).IdNb  = proc_getchannel({'P5'; 'P3'; 'CP3'; 'C3'; 'C5'; 'T7'; 'TP7'; 'P7'}, channellocation);
%     'CP3'
       neighbours(18).IdNb  = proc_getchannel({'P3'; 'P1'; 'CP1'; 'C1'; 'C3'; 'C5'; 'CP5'; 'P5'}, channellocation);
%     'CP1'
       neighbours(19).IdNb  = proc_getchannel({'P1'; 'PZ'; 'CPZ'; 'CZ'; 'C1'; 'C3'; 'CP3'; 'P3'}, channellocation);
%     'P1'
       neighbours(20).IdNb  = proc_getchannel({'PZ'; 'CPZ'; 'CP1'; 'CP3'; 'P3'; 'PO3'; 'POZ'}, channellocation);
%     'P3'
       neighbours(21).IdNb  = proc_getchannel({'P1'; 'CP1'; 'CP3'; 'CP5'; 'P5'; 'PO7'; 'PO3'}, channellocation);
%     'P5'
       neighbours(22).IdNb  = proc_getchannel({'P3'; 'CP3'; 'CP5'; 'TP7'; 'P7'; 'PO7'; 'PO3'}, channellocation);
%     'P7'
       neighbours(23).IdNb  = proc_getchannel({'P5'; 'CP5'; 'TP7'; 'P9'; 'PO7'}, channellocation);
%     'P9'
       neighbours(24).IdNb  = proc_getchannel({'PO7'; 'P7'; 'TP7'}, channellocation);
%     'PO7'
       neighbours(25).IdNb  = proc_getchannel({'O1'; 'PO3'; 'P3'; 'P5'; 'P7'; 'P9'}, channellocation);
%     'PO3'
       neighbours(26).IdNb  = proc_getchannel({'POZ'; 'PZ'; 'P1'; 'P3'; 'P5'; 'PO7'; 'O1'; 'OZ'}, channellocation);
%     'O1'
       neighbours(27).IdNb  = proc_getchannel({'OZ'; 'POZ'; 'PO3'; 'PO7'; 'IZ'}, channellocation);
%     'Iz'
       neighbours(28).IdNb  = proc_getchannel({'O1'; 'OZ'; 'O2'}, channellocation);
%     'Oz'
       neighbours(29).IdNb  = proc_getchannel({'O2'; 'PO4'; 'POZ'; 'PO3'; 'O1'; 'IZ'}, channellocation);
%     'POz'
       neighbours(30).IdNb  = proc_getchannel({'PO4'; 'P2'; 'PZ'; 'P1'; 'PO3'; 'O1'; 'OZ'; 'O2'}, channellocation);
%     'Pz'
       neighbours(31).IdNb  = proc_getchannel({'P2'; 'CP2'; 'CPZ'; 'CP1'; 'P1'; 'PO3'; 'POZ'; 'PO4'}, channellocation);
%     'CPz'
       neighbours(32).IdNb  = proc_getchannel({'CP2'; 'C2'; 'CZ'; 'C1'; 'CP1'; 'P1'; 'PZ'; 'P2'}, channellocation);
%     'Fpz'
       neighbours(33).IdNb  = proc_getchannel({'FP1'; 'AF3'; 'AFZ'; 'AF4'; 'FP2'}, channellocation);
%     'Fp2'
       neighbours(34).IdNb  = proc_getchannel({'FPZ'; 'AFZ'; 'AF4'; 'AF8'}, channellocation);
%     'AF8'
       neighbours(35).IdNb  = proc_getchannel({'FP2';  'AF4'; 'F4'; 'F6'; 'F8'}, channellocation);
%     'AF4'
       neighbours(36).IdNb  = proc_getchannel({'AFZ'; 'F2'; 'F4'; 'F6'; 'F8'; 'AF8'; 'FP2'}, channellocation);
%     'AFz'
       neighbours(37).IdNb  = proc_getchannel({'AF3'; 'F1'; 'FZ'; 'F2'; 'AF4'; 'FP2'; 'FPZ'; 'FP1'}, channellocation);
%     'Fz'
       neighbours(38).IdNb  = proc_getchannel({'F1'; 'FC1'; 'FCZ'; 'FC2'; 'F2'; 'AF4'; 'AFZ'; 'AF3'}, channellocation);
%     'F2'
       neighbours(39).IdNb  = proc_getchannel({'FZ'; 'FCZ'; 'FC2'; 'FC4'; 'F4'; 'AF4'; 'AFZ'}, channellocation);
%     'F4'
       neighbours(40).IdNb  = proc_getchannel({'F2'; 'FC2'; 'FC4'; 'FC6'; 'F6'; 'AF8'; 'AF4'}, channellocation);
%     'F6'
       neighbours(41).IdNb  = proc_getchannel({'AF4'; 'F4'; 'FC4'; 'FC6'; 'FT8'; 'F8'; 'AF8'}, channellocation);
%     'F8'
       neighbours(42).IdNb  = proc_getchannel({'FT8'; 'FC6'; 'F6'; 'AF4'; 'AF8'}, channellocation);
%     'FT8'
       neighbours(43).IdNb  = proc_getchannel({'F8'; 'F6'; 'FC6'; 'C6'; 'T8'}, channellocation);
%     'FC6'
       neighbours(44).IdNb  = proc_getchannel({'F6'; 'F4'; 'FC4'; 'C4'; 'C6'; 'T8'; 'FT8'; 'F8'}, channellocation);
%     'FC4'
       neighbours(45).IdNb  = proc_getchannel({'F4'; 'F2'; 'FC2'; 'C2'; 'C4'; 'C6'; 'FC6'; 'F6'}, channellocation);
%     'FC2'
       neighbours(46).IdNb  = proc_getchannel({'F2'; 'FZ'; 'FCZ'; 'CZ'; 'C2'; 'C4'; 'FC4'; 'F4'}, channellocation);
%     'FCz'
       neighbours(47).IdNb  = proc_getchannel({'FC1'; 'C1'; 'CZ'; 'C2'; 'FC2'; 'F2'; 'FZ'; 'F1'}, channellocation);
%     'Cz'
       neighbours(48).IdNb  = proc_getchannel({'C1'; 'CP1'; 'CPZ'; 'CP2'; 'C2'; 'FC2'; 'FCZ'; 'FC1'}, channellocation);
%     'C2'
       neighbours(49).IdNb  = proc_getchannel({'CZ'; 'CPZ'; 'CP2'; 'CP4'; 'C4'; 'FC4'; 'FC2'; 'FCZ'}, channellocation);
%     'C4'
       neighbours(50).IdNb  = proc_getchannel({'C2'; 'CP2'; 'CP4'; 'CP6'; 'C6'; 'FC6'; 'FC4'; 'FC2'}, channellocation);
%     'C6'
       neighbours(51).IdNb  = proc_getchannel({'FC6'; 'FC4'; 'C4'; 'CP4'; 'CP6'; 'TP8'; 'T8'; 'FT8'}, channellocation);
%     'T8'
       neighbours(52).IdNb  = proc_getchannel({'FT8'; 'FC6'; 'C6'; 'CP6'; 'TP8'}, channellocation);
%     'TP8'
       neighbours(53).IdNb  = proc_getchannel({'T8'; 'C6'; 'CP6'; 'P6'; 'P8'; 'P10'}, channellocation);
%     'CP6'
       neighbours(54).IdNb  = proc_getchannel({'C6'; 'C4'; 'CP4'; 'P4'; 'P6'; 'P8'; 'TP8'; 'T8'}, channellocation);
%     'CP4'
       neighbours(55).IdNb  = proc_getchannel({'C4'; 'C2'; 'CP2'; 'P2'; 'P4'; 'P6'; 'CP6'; 'C6'}, channellocation);
%     'CP2'
       neighbours(56).IdNb  = proc_getchannel({'C2'; 'CZ'; 'CPZ'; 'PZ'; 'P2'; 'P4'; 'CP4'; 'C4'}, channellocation);
%     'P2'
       neighbours(57).IdNb  = proc_getchannel({'P4'; 'CP4'; 'CP2'; 'CPZ'; 'PZ'; 'POZ'; 'PO4'}, channellocation);
%     'P4'
       neighbours(58).IdNb  = proc_getchannel({'CP4'; 'CP2'; 'P2'; 'PO4'; 'PO8'; 'P6'; 'CP6'}, channellocation);
%     'P6'
       neighbours(59).IdNb  = proc_getchannel({'CP6'; 'CP4'; 'P4'; 'PO4'; 'PO8'; 'P8'; 'TP8'}, channellocation);
%     'P8'
       neighbours(60).IdNb  = proc_getchannel({'TP8'; 'CP6'; 'P6'; 'PO8'; 'P10'}, channellocation);
%     'P10'
       neighbours(61).IdNb  = proc_getchannel({'TP8'; 'P8'; 'PO8'}, channellocation);
%     'PO8'
       neighbours(62).IdNb  = proc_getchannel({'P8'; 'P6'; 'P4'; 'PO4'; 'O2'; 'P10'}, channellocation);
%     'PO4'
       neighbours(63).IdNb  = proc_getchannel({'P6'; 'P4'; 'P2'; 'PZ'; 'POZ'; 'OZ'; 'O2'; 'PO8'}, channellocation);
%     'O2'
       neighbours(64).IdNb  = proc_getchannel({'PO8'; 'PO4'; 'POZ'; 'OZ'; 'IZ';}, channellocation);
end