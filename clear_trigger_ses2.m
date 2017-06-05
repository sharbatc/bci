function [cleared_trigger_ses2] = clear_trigger_ses2(trigger)
% finds 15 start and stop points in trigger channel to slice the data
% + finds 16, 32 for missing and passing points. 128 is for changed
% waypoint

cleared_trigger_ses2 = zeros(1, size(trigger, 2));
trigger = trigger - mode(trigger); % substract the most common value
start = find(trigger == 1);  % 1 for "start" trial
missed = find(trigger == 16);  % 16 for changing the waypoint (without passing it)
passed = find(trigger == 48);  % 48 for passing the waypoint (16+32 = new + prev.passed succesfully)
stop = find(trigger == 255);  % 255 for "end" trial
change_missed = find(trigger == 144); % 144 = 16+128 = new + change in waypoint
change_passed = find(trigger == 176); % 176 = 16+32+128 = new + prev. missed + change in waypoint


% eliminate consecutive values ... this is a bit hacky but works fast
start_tmp = start(diff(start)~=1);
missed_tmp = missed(diff(missed)~=1);
passed_tmp = passed(diff(passed)~=1);
stop_tmp = stop(diff(stop)~=1);
change_missed_tmp = change_missed(diff(change_missed)~=1);
change_passed_tmp = change_passed(diff(change_passed)~=1);

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

change_missed_idx = change_missed_tmp(1);
for m = change_missed_tmp
	id = find(change_missed == m) + 1;
	change_missed_idx = [change_missed_idx, change_missed(id)];
end

change_passed_idx = change_passed_tmp(1);
for n = change_passed_tmp
    id = find(change_passed == n) + 1;
    change_passed_idx = [change_passed_idx, change_passed(id)];
end

   
% eliminate until here...

% put trigger values back to the right place
cleared_trigger_ses2(start_idx) = 1;
cleared_trigger_ses2(missed_idx) = 16;
cleared_trigger_ses2(passed_idx) = 48;
cleared_trigger_ses2(stop_idx) = 255;
cleared_trigger_ses2(change_missed_idx) = 144;
cleared_trigger_ses2(change_passed_idx) = 176;

end