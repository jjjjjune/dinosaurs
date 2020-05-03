-- should out to TheNexusAvenger for this code

local floor = math.floor
local perm = {}

for i = 1,512 do
    perm[i] = math.random(1,256)
end

local function grad( hash, x, y )
    local h = hash%8; -- Convert low 3 bits of hash code
    local u = h<4 and x or y; -- into 8 simple gradient directions,
    local v = h<4 and y or x; -- and compute the dot product with (x,y).
    return ((h%2==1) and -u or u) + ((floor(h/2)%2==1) and -2.0*v or 2.0*v);
end

local function PerlinNoise(x,y)
    local ix0, iy0, ix1, iy1;
    local fx0, fy0, fx1, fy1;
    local s, t, nx0, nx1, n0, n1;
    ix0 = floor(x); -- Integer part of x
    iy0 = floor(y); -- Integer part of y
    fx0 = x - ix0; -- Fractional part of x
    fy0 = y - iy0; -- Fractional part of y
    fx1 = fx0 - 1.0;
    fy1 = fy0 - 1.0;
    ix1 = (ix0 + 1) % 255; -- Wrap to 0..255
    iy1 = (iy0 + 1) % 255;
    ix0 = ix0 % 255;
    iy0 = iy0 % 255;
        t = (fy0*fy0*fy0*(fy0*(fy0*6-15)+10));
        s = (fx0*fx0*fx0*(fx0*(fx0*6-15)+10));
    nx0 = grad(perm[ix0 + perm[iy0+1]+1], fx0, fy0);
    nx1 = grad(perm[ix0 + perm[iy1+1]+1], fx0, fy1);
    n0 = nx0 + t*(nx1-nx0);
    nx0 = grad(perm[ix1 + perm[iy0+1]+1], fx1, fy0);
    nx1 = grad(perm[ix1 + perm[iy1+1]+1], fx1, fy1);
    n1 = nx0 + t*(nx1-nx0);
    return 0.5*(1 + (0.507 * (n0 + s*(n1-n0))))
end

return PerlinNoise