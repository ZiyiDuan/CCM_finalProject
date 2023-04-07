function r_pix = va2pixel(screen, phi)
% created by Mrugank (06/15/2022):
% rho is distance of screen from the subject, and angle is the visual angle
% of the stimulus
rho = screen.screenViewDist;
r_cm = rho * tand(phi/2);
r_pix = round(r_cm*screen.pixels_per_deg_width); % convert cm to pixels
end

