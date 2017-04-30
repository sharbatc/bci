function print_trigger_info(cleared_trigger)

starts = find(cleared_trigger==1);
missed = find(cleared_trigger==16);
passed = find(cleared_trigger==48);
stops = find(cleared_trigger==255);

for i = 1:15
    start = starts(i);
    stop = stops(i);
    time = (stop - start)/2048; % sampling at 2048 Hz;
    miss = size(find(start < missed & missed < stop),2);
    pass = size(find(start < passed & passed < stop),2);
    fprintf('trial: %i, time: %f2 (s), missed: %i, passed: %i, #{waypoints}: %i \n',i, time, miss, pass, miss+pass);
end

end