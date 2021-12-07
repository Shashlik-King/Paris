function [thk_eff] = thicknessEffective_DNV(thk,L_t)
% Function "thicknessEffective_DNV" gives the effective thickness related
% to the DNV correction. 
%
% [thk_eff] = thicknessEffective_DNV(thk,L_t)
% Input: 
%   - thk:  Thickness
%   - L_t:  Length of weld (see DNV for clarifying this length) 
%
% Output:
%   - thk_eff:  Effective thickness to replace the original thickness, thk

thk_eff = thk;
thk_ref = 0.025;

thk_eff_L_t = 0.014 + 0.66*L_t;

if thk_eff_L_t < thk
    thk_eff = thk_eff_L_t;
end

if thk_eff < thk_ref
    thk_eff = thk_ref;
end
end