function speed = calc_speed(x,y,frate,ballcirc)

speed(1) = 0;
for i = 1:1:length(x)-1
    speed(i+1) = ballcirc.*(sqrt((x(i+1)-x(i)).^2+(y(i+1)-y(i)).^2));
end

speed = speed.*frate;