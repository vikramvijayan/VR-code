function frame_dump_setup()
%FRAME_DUMP_SETUP switches the panel controller to act in frame dump mode
%
%NOTE:  This function only needs to be called once after turning on the
%Reiser Panel Controller

    fprintf(1, 'Switching the controller to frame dumping mode...\n');
    Panel_com('pc_dumping_mode');
    pause(2);
    fprintf(1, 'Resetting controller for change to take effect...\n');
    Panel_com('ctr_reset');
    fprintf(1, 'Entering PC dumping mode!\n');
    pause(10);
    fprintf(1, 'Controller successfully switched to frame dumping mode.\n');
end