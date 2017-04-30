function print_trigger_info(cleaned_trigger)

starts = find(cleaned_trigger==1);
missed = find(cleaned_trigger==16);
passed = find(cleaned_trigger==48);
stops = find(cleaned_trigger==255);

for i = 1:15
    start = starts(i);
    stop = stops(i);
    time = (stop - start)/2048; % sampling at 2048 Hz;
    miss = size(find(start < missed & missed < stop),2);
    pass = size(find(start < passed & passed < stop),2);
    fprintf('trial: %i, time: %f2 (s), missed: %i, passed: %i, #{waypoints}: %i \n',i, time, miss, pass, miss+pass);
end

end