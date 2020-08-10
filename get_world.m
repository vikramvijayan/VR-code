% 0.19 PWM causes rapid death

function space_map = get_world(numb, world_size)

switch numb
    
    case 1
        space_map = ones(world_size,world_size)*.0;
    case 2
        space_map = ones(world_size,world_size)*.01;
    case 3
        space_map = ones(world_size,world_size)*.02;
    case 4
        space_map = ones(world_size,world_size)*.03;
    case 5
        space_map = ones(world_size,world_size)*.04;
    case 6
        space_map = ones(world_size,world_size)*.05;
    case 7
        space_map = ones(world_size,world_size)*.06;
    case 8
        space_map = ones(world_size,world_size)*.07;
    case 9
        space_map = ones(world_size,world_size)*.08;
    case 10
        space_map = ones(world_size,world_size)*.09;
    case 11
        space_map = ones(world_size,world_size)*.1;
    case 12
        space_map = ones(world_size,world_size)*.115;
    case 13
        space_map = ones(world_size,world_size)*.12;
    case 14
        space_map = ones(world_size,world_size)*.125;
    case 15
        space_map = ones(world_size,world_size)*.13;
    case 16
        space_map = ones(world_size,world_size)*.135;
    case 17
        space_map = ones(world_size,world_size)*.14;
    case 18
        space_map = ones(world_size,world_size)*.145;
    case 19
        space_map = ones(world_size,world_size)*.15;
    case 20
        space_map = ones(world_size,world_size)*.155;
    case 21
        space_map = ones(world_size,world_size)*.16;
    case 22
        space_map = ones(world_size,world_size)*.165;
    case 23
        space_map = ones(world_size,world_size)*.17;
    case 24
        space_map = ones(world_size,world_size)*.175;
    case 25
        space_map = ones(world_size,world_size)*.18;
    case 26
        space_map = ones(world_size,world_size)*.185;
    case 27
        space_map = ones(world_size,world_size)*.19;
    case 28
        space_map = ones(world_size,world_size)*.195;
    case 29
        space_map = ones(world_size,world_size)*.2;
    case 30
        space_map = ones(world_size,world_size)*.205;
    case 31
        space_map = ones(world_size,world_size)*.21;
    case 32
        space_map = ones(world_size,world_size)*.215;
    case 33
        space_map = ones(world_size,world_size)*.22;
    case 34
        space_map = ones(world_size,world_size)*.225;
    case 35
        space_map = zeros(100,100);
        temp0 = .13.*ones(1,1);
        temp1 = .16.*ones(1,1);
        temp2 = .185.*ones(1,1);
        temp3 = [
            temp1, temp2, temp0, temp2, temp1, temp2, temp0, temp2;
            temp1, temp2, temp0, temp2, temp1, temp2, temp0, temp2;
            temp1, temp2, temp0, temp2, temp1, temp2, temp0, temp2;
            temp1, temp2, temp0, temp2, temp1, temp2, temp0, temp2;
            temp1, temp2, temp0, temp2, temp1, temp2, temp0, temp2;
            temp1, temp2, temp0, temp2, temp1, temp2, temp0, temp2;
            temp1, temp2, temp0, temp2, temp1, temp2, temp0, temp2;
            temp1, temp2, temp0, temp2, temp1, temp2, temp0, temp2;
            ];
        space_map = repmat(temp3,20);
    case 36
        space_map = zeros(100,100);
        temp0 = .13.*ones(1,1);
        temp1 = .13.*ones(1,1);
        temp2 = .18.*ones(1,1);
        temp3 = [
            temp1, temp2, temp2, temp0, temp2, temp2;
            temp1, temp2, temp2, temp0, temp2, temp2;
            temp1, temp2, temp2, temp0, temp2, temp2;
            temp1, temp2, temp2, temp0, temp2, temp2;
            temp1, temp2, temp2, temp0, temp2, temp2;
            temp1, temp2, temp2, temp0, temp2, temp2;
            ];
        space_map = repmat(temp3,20);
    case 37
        space_map = zeros(100,100);
        temp0 = .155.*ones(1,1);
        temp1 = .155.*ones(1,1);
        temp2 = .18.*ones(1,1);
        temp3 = [
            temp1, temp2, temp2, temp0, temp2, temp2;
            temp1, temp2, temp2, temp0, temp2, temp2;
            temp1, temp2, temp2, temp0, temp2, temp2;
            temp1, temp2, temp2, temp0, temp2, temp2;
            temp1, temp2, temp2, temp0, temp2, temp2;
            temp1, temp2, temp2, temp0, temp2, temp2;
            ];
        space_map = repmat(temp3,20);
    case 38
        space_map = zeros(100,100);
        temp0 = .13.*ones(1,1);
        temp1 = .13.*ones(1,1);
        temp2 = .18.*ones(1,1);
        temp3 = [
            temp1, temp2, temp2, temp2;
            temp1, temp2, temp2, temp2;
            temp1, temp2, temp2, temp2;
            temp1, temp2, temp2, temp2;
            ];
        space_map = repmat(temp3,35);
        
    case 39
        space_map = zeros(100,100);
        temp0 = .125.*ones(1,1);
        temp1 = .125.*ones(1,1);
        temp2 = .185.*ones(1,1);
        temp3 = [
            temp1, temp2, temp2, temp2;
            temp1, temp2, temp2, temp2;
            temp1, temp2, temp2, temp2;
            temp1, temp2, temp2, temp2;
            ];
        space_map = repmat(temp3,35);
        
    case 40
        space_map = zeros(100,100);
        temp3 = 32.*ones(16,16);
        temp3(:,3) = 28;
        temp3(:,4) = 28;
        temp3(:,5) = 28;
        temp3(:,6) = 28;
        space_map = repmat(temp3,34);
    case 41
        space_map = zeros(100,100);
        temp3 = 32.*ones(16,16);
        space_map = repmat(temp3,34);
    case 42
        space_map = zeros(100,100);
        temp3 = 33.*ones(10,10);
        space_map = repmat(temp3,35);
    case 43
        space_map = zeros(100,100);
        temp3 = 34.*ones(10,10);
        space_map = repmat(temp3,35);
    case 44
        space_map = zeros(100,100);
        temp3 = 32.*ones(10,10);
        space_map = repmat(temp3,35);
    case 45
        space_map = ones(3600,1).*30;
        space_map(1:450) = 30;
        space_map(3150:3600) = 30;
    case 46
        space_map = ones(3600,1).*30;
        %   space_map(1:450) = 25;
        %    space_map(3150:3600) = 25;
        
        space_map(1:300) = 30;
        space_map(3300:3600) = 30;
        
        
        
    case 47
        space_map = ones(3600,1).*30;
        space_map(1:450) = 30;
        space_map(3150:3600) = 30;
    case 48
        space_map = ones(3600,1).*34;
        space_map(1:450) = 34;
        space_map(3150:3600) = 34;
    case 49
        space_map = ones(3600,1).*36;
        space_map(1:450) = 36;
        space_map(3150:3600) = 36;
        
    case 50
        space_map = ones(3600,1).*.05;
        
    case 51
        space_map = ones(3600,1).*.075;
        
    case 52
        space_map = ones(3600,1).*.085;
        
    case 53
        space_map = ones(3600,1).*.1;
    case 54
        space_map = ones(3600,1).*.12;
    case 55
        space_map = ones(3600,1).*.16;
    case 56
        space_map = ones(3600,1).*.2;
    case 57
        space_map = ones(3600,1).*.25;
    case 58
        space_map = ones(3600,1).*.3;
    case 59
        space_map = ones(3600,1).*.35;
    case 60
        space_map = ones(3600,1).*.4;
    case 61
        space_map = ones(3600,1).*.5;
    case 62
        space_map = ones(3600,1).*.6;
    case 63
        space_map = ones(3600,1).*.7;
    case 64
        space_map = ones(3600,1).*.8;
    case 65
        space_map = ones(3600,1).*.9;
    case 66
        space_map = ones(3600,1).*.95;
    case 67
        space_map = ones(3600,1).*0;
end
end

%     otherwise
%         space_map = zeros(100,100);
%
% end

%end

