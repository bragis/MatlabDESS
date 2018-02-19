function [ratio] = SC(SA,SB)
if (abs(SB) > 0)
    ratio = abs(SA)/abs(SB);
else if (abs(SA) == 0)
        ratio = 1;
    else
        ratio = 1e7;
    end
end