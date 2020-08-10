

function pre_treatment()


% Arduino object initialization
%if(isempty(a))
    a = arduino();
%end

% Set intial PWM duty cycle
writePWMDutyCycle(a,'D11',0);

disp 'Connected to Arduino (PWM laser)'

for i = 1:1:5
    writePWMDutyCycle(a,'D11',.18);
    disp .18;
    pause(60);
    writePWMDutyCycle(a,'D11',.13);
    disp .13;
    pause(30);
end

fclose(serial(a.Port));
fclose('all');
clear all;

end