
function noisemask = gen_noisemask(exptP,screenP)


%%% noise mask

for ii = 1:exptP.mask.durTimes
    noisemask_tmp(:,:,ii) = CreateFilteredNoise_gaussian...
        (screenP, exptP.mask.size, exptP.mask.fre_u, exptP.mask.fre_std, exptP.mask.ori_u, exptP.mask.ori_std, ...
        exptP.mask.cont, 1);
    noisemask_scaled(:,:,ii) = noisemask_tmp(:,:,ii)*0.4;
end

%%% make aperture

[x,y]=meshgrid(1:size(noisemask_scaled,1), 1:size(noisemask_scaled,2)); % in pixels
x = x-mean(x(:));
y = y-mean(y(:));
sizedeg = [size(noisemask_scaled,1) size(noisemask_scaled,2)]/screenP.pixels_per_deg_width; % in degrees
x = Scale(x)*sizedeg(2)-sizedeg(2)/2; % in degrees
y = Scale(y)*sizedeg(1)-sizedeg(1)/2; % in degrees
[th,r] = cart2pol(x,y);

patch = double(r <= exptP.stim.size/2); % in degrees
patch = patch & (r > exptP.stim.innerSize/2); % in degrees

sinFilter = sin(linspace(0,pi,exptP.modulator.sinSize*screenP.pixels_per_deg_width)).^4; % in pixels
sinFilter = sinFilter'*sinFilter;
sinFilter = sinFilter/sum(sinFilter(:));

patch = conv2(patch, sinFilter,'same');


%%% final noisemask

for ii = 1:exptP.mask.durTimes
    noisemask(:,:,ii)=noisemask_scaled(:,:,ii).*patch+0.5;
end



return