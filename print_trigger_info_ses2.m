function print_trigger_info_ses2(cleared_trigger_ses2)

starts = find(cleared_trigger_ses2==1);
missed = find(cleared_trigger_ses2==16);
passed = find(cleared_trigger_ses2==48);
stops = find(cleared_trigger_ses2==255);
change_missed = find(cleared_trigger_ses2==144);
change_passed = find(cleared_trigger_ses2==176)

for i = 1:15
    start = starts(i);
    stop = stops(i);
    time = (stop - start)/2048; % sampling at 2048 Hz;
    miss = size(find(start < missed & missed < stop),2);
    miss_change = size(find(start < change_missed & change_missed < stop),2);
    pass = size(find(start < passed & passed < stop),2);
    miss_pass = size(find(start < change_passed & change_passed < stop),2);
    fprintf('trial: %i, time: %f2 (s), missed: %i, passed: %i,changes: %i, #{waypoints}: %i \n',...
        i, time, miss+miss_change, pass+miss_pass,miss_pass+miss_change, miss+pass+miss_pass+miss_change);
end

end