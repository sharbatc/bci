function identifier = proc_getchannel(ChannelKey, ChannelsList)
% identifier = proc_getchannel(ChannelKey, ChannelsList)
%
% Converts channel index from label to channel number and from channel
% number to label. The channel list is provided by text file with
% ChannelList argument. The file must have the first column with the
% channel number and the second column with the channel name. Others
% columns are ignored.
%
% ChannelKey   - Number, numeric vector, char or cell of char
% ChannelsList - Path to the text file
% identifier   - Number, numeric vector, char or cell of char according to
%                the input

    fid = fopen(ChannelsList); 
    List = textscan(fid, '%d %s %*[^\n]'); 
    fclose(fid);
    
    if strcmpi(ChannelKey, 'EEG')
        ChannelKey = 1:64;
    elseif strcmpi(ChannelKey, 'EXG')
        ChannelKey = 65:length(List{2});
    elseif strcmpi(ChannelKey, 'All')
        ChannelKey = 1:length(List{2});
    end
    
    
    if ischar(ChannelKey)
        
        identifier = label2number(ChannelKey, List);
        
    elseif iscell(ChannelKey)
        
        identifier = zeros(length(ChannelKey), 1);
        
        for k = 1:length(ChannelKey)
            identifier(k) = label2number(ChannelKey{k}, List);
        end
        
    elseif isnumeric(ChannelKey)
        
        identifier = cell(length(ChannelKey), 1);
        
        for k = 1:length(ChannelKey)
            identifier{k} = number2label(ChannelKey(k), List);
        end
    end
    

end


function number = label2number(label, list)
    
    label = upper(label);
    
    llist = list{2};
    
    idmatch = [];
    for m = 1:length(llist)
        if strcmpi(char(llist{m}), label)
            idmatch = [idmatch m];
        end
    end
    
    if isempty(idmatch)
        error('chk:label', [label ' is not in the channel list']);
    end
    
    if length(idmatch) > 1
        error('chk:label', ['Multiple entries for label ' label]);
    end
    
    number = idmatch;

end


function label = number2label(number, list)
    label = char(list{2}(number));
end