function [cleared_trigger] = clear_trigger(trigger)
% finds 15 start and stop points in trigger channel to slice the data
% + finds 16, 48 for missing and passing points

cleared_trigger = zeros(1, size(trigger, 2));

trigger = trigger - mode(trigger); % substract the most common value
start = find(trigger == 1);  % 1 for "start" trial
missed = find(trigger == 16);  % 16 for changing the waypoint (without passing it)
passed = find(trigger == 48);  % 48 for passing the waypoint (16+32 = new + prev.passed succesfully)
stop = find(trigger == 255);  % 255 for "end" trial
% eliminate consecutive values ... this is a bit hacky but works fast
start_tmp = start(diff(start)~=1);
missed_tmp = missed(diff(missed)~=1);
passed_tmp = passed(diff(passed)~=1);
stop_tmp = stop(diff(stop)~=1);

start_idx = start_tmp(1);
for i = start_tmp
    id = find(start == i) + 1;
    start_idx = [start_idx, start(id)];
end
missed_idx = missed_tmp(1);
for j = missed_tmp
    id = find(missed == j) + 1;
    missed_idx = [missed_idx, missed(id)];
end
passed_idx = passed_tmp(1);
for k = passed_tmp
    id = find(passed == k) + 1;
    passed_idx = [passed_idx, passed(id)];
end
stop_idx = stop_tmp(1);
for l = stop_tmp
    id = find(stop == l) + 1;
    stop_idx = [stop_idx, stop(id)];
end
% eliminate untill here...

% put trigger values back to the right place
cleared_trigger(start_idx) = 1;
cleared_trigger(missed_idx) = 16;
cleared_trigger(passed_idx) = 48;
cleared_trigger(stop_idx) = 255;

end