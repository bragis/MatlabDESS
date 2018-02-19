function [ratio] = SC2(SA,SB)
if (min(abs(SB)) > 0)
    ratio = abs(SA)./abs(SB);
else if (min(abs(SA)) == 0)
        ratio = 1;
    else
        ratio = 1e7;
    end
end