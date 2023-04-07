function smod = ShiftMod(n, mode)
%   ShiftMod(n, mode)
%   若N是mode的整倍数则返回mode，其他情况下返回mod(N, mode)
%   2012/04/25      20:51       黄羽商

smod = mod(n, mode);
smod(smod == 0) = mode;