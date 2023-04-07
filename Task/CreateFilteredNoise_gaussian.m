function [filterednoise, fFilter, oFilter] = CreateFilteredNoise_gaussian(scr, noisesiz, fre_u, fre_std, ori_u, ori_std, contrast, fixcontrast)

%%
% Create the noise pattern filtered in frequency and orientation domain.
% There are two possible way to create filter in frequency domain. Check
% the code below: Method 1 and Method 2.
% If fixcontrast is at 1, The noise is centered at 0 and scaled to have the assigned contrast (RMS
% contrast (The std of the noise; to compute final contrast: devided by the bg luminance) 
% If it is 0, there will be random fluctuation.
% Let ori_low be empty [] if you dont need filter at orientation domain.
% scr: screen parameters
% noisesize: size of the image in dvg
% fre_u: center of frequency filter
% fre_std: width of frequency filter in log unit



%%
% noisepsiz = angle2pix(scr, noisesiz);
% %fNyquist  = angle2pix(scr,1)*.5;
% nyquist  = 1/pix2angle(scr,1)*.5;

% adapted so that the pix size is the same for my stim in expt
noisepsiz = round(scr.pixels_per_deg_width*noisesiz);
nyquist  = 1/scr.pixWidth*.5;


freq     = linspace(0,nyquist,floor(noisepsiz/2)+1);
faxis    = [ freq  fliplr(freq(2:ceil(noisepsiz/2))) ];
faxis    = fftshift(faxis);
%faxis             = linspace(-fNyquist,fNyquist,noisepsiz);
[fgrid_x,fgrid_y] = meshgrid(faxis,faxis);
[ogrid, fgrid]    = cart2pol(fgrid_x,fgrid_y);

%% Draw filter for frequency domain
log_fgrid = log10(fgrid);
log_fre_u = log10(fre_u);
%log_fre_std = 2^fre_std/10; %here let the unit be octave; if fre_std=1, the std of the frequency filter will be one octave
log_fre_std = fre_std;

fFilter = exp(-(log_fgrid-log_fre_u).^2/(2*log_fre_std^2));

%fFilter = exp(-(fgrid-fre_u).^2/(2*fre_std^2));

%% Draw filter in orientation domain
oFilter = ones(noisepsiz,noisepsiz);
% oFilter = exp(-(ogrid-ori_u).^2/(2*ori_std^2));
%save noiseFilter fFilter oFilter

%% Generate Gaussian noise and apply the filters
noise = randn(noisepsiz, noisepsiz);
fn    = fftshift(fft2(noise));
filterednoise = real(ifft2(ifftshift(oFilter.*fFilter.*fn)));

if fixcontrast ==0
%Use this line if allowing more energy fluctuation across trials
filterednoise = filterednoise*contrast - mean(filterednoise(:));
elseif fixcontrast == 1
%Use this if wanting the rmsContrast of the noise to be fixed across trials
filterednoise = filterednoise/std(filterednoise(:))*contrast - mean(filterednoise(:)); 
end
%disp(std(filterednoise(:)))

return

% %% Parameter for Test
% noisesiz = 11;
% fre_u    = 1;
% fre_std  = 0.25;
% contrast = .8;
% fixcontrast =1;
% 
% % ori_u = 0;
% % ori_std = pi/15;
% ori_u = [];
% ori_std = [];
% 
% load('screenP.mat'); 
%     % -this is in apocalypse/behavioral room
%     % -made the matrix size the same as the WM stim, but the stim
%     % parameters are not based off of the screen parameters in the scanning
%     % room
%     % see ver3/stim/makeExptStim.m for more info
% 
% % scr.pixWidth = ;
% % scr.pixels_per_deg_width = ;
% 
% [filterednoise, fFilter, oFilter] = CreateFilteredNoise_gaussian(screenP, noisesiz, fre_u, fre_std, ori_u, ori_std, contrast, fixcontrast);
% %cpsFigure(.5,.5);
% imagesc(filterednoise);colormap(gray);
% axis off;
% axis square;
% %cpsFigure(.5,.5);imagesc(fFilter);colormap(gray);
