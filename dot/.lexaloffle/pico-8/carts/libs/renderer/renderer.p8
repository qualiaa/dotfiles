pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
printh("----------------------")

eps = 0.000001

ticks = 0

occ_cull = false

function lerp(a1,a2,r)
 return a1 * (1 - r) + a2 * r
end

-- take verts from
-- [-1,1] to [0,128]
function ndc_to_screen(poly)
 -- p8 display: 128*128
 local res = {}
 for p in all(poly) do
  local q = {}
  q[1] = flr(63.5*(p[1]+1))
  q[2] = flr(63.5*(1 - p[2]))
  q[3] = p[3]
  add(res, q)
 end
 return res
end

--[[
 matrices and vectors
--]]

--vector functions

-- vector constructor
function v4(x,y,z,w)
 return {x or 0,y or 0,z or 0,w or 1}
end

-- string conversion
function v2s(v)
 return ""..v[1]..","..v[2]
end
function v3s(v)
 return v2s(v)..","..v[3]
end
function v4s(v)
 return v3s(v)..","..v[4]
end

-- mag
function mag2(v) return sqrt(dot2(v,v)) end
function mag3(v) return sqrt(dot3(v,v)) end
-- dot product
function dot2(v1,v2) return v1[1]*v2[1] + v1[2]*v2[2] end
function dot3(v1,v2) return dot2(v1,v2) + v1[3]*v2[3] end
--function dot4(v1,v2) return dot3(v1,v2) + v1[4]*v2[4] end
-- cross product
function cross2(v1,v2) return -v1[2]*v2[1] + v1[1]*v2[2] end
function cross3(v1,v2) return {v1[2]*v2[3]-v1[3]*v2[2],v1[3]*v2[1]-v1[1]*v2[3],v1[1]*v2[2]-v1[2]*v2[1]} end
-- distance
function dis3(u,v) return mag3(sub3(u,v)) end
-- addition
function add2(v1,v2) return {v1[1]+v2[1],v1[2]+v2[2]} end
function add3(v1,v2) return {v1[1]+v2[1],v1[2]+v2[2],v1[3]+v2[3]} end
function add4(v1,v2) return {v1[1]+v2[1],v1[2]+v2[2],v1[3]+v2[3],v1[4]+v2[4]} end
-- subtraction
function sub2(v1,v2) return {v1[1]-v2[1],v1[2]-v2[2]} end
function sub3(v1,v2) return {v1[1]-v2[1],v1[2]-v2[2],v1[3]-v2[3]} end
function sub4(v1,v2) return {v1[1]-v2[1],v1[2]-v2[2],v1[3]-v2[3],v1[4]-v2[4]} end

--[[
 matrix functions
]]--

function mulmat4mat4(l,r)
 return mat4({
  l[1]*r[1]+l[2]*r[5]+l[3]*r[9]+l[4]*r[13],
  l[1]*r[2]+l[2]*r[6]+l[3]*r[10]+l[4]*r[14],
  l[1]*r[3]+l[2]*r[7]+l[3]*r[11]+l[4]*r[15],
  l[1]*r[4]+l[2]*r[8]+l[3]*r[12]+l[4]*r[16],
  l[5]*r[1]+l[6]*r[5]+l[7]*r[9]+l[8]*r[13],
  l[5]*r[2]+l[6]*r[6]+l[7]*r[10]+l[8]*r[14],
  l[5]*r[3]+l[6]*r[7]+l[7]*r[11]+l[8]*r[15],
  l[5]*r[4]+l[6]*r[8]+l[7]*r[12]+l[8]*r[16],
  l[9]*r[1]+l[10]*r[5]+l[11]*r[9]+l[12]*r[13],
  l[9]*r[2]+l[10]*r[6]+l[11]*r[10]+l[12]*r[14],
  l[9]*r[3]+l[10]*r[7]+l[11]*r[11]+l[12]*r[15],
  l[9]*r[4]+l[10]*r[8]+l[11]*r[12]+l[12]*r[16],
  l[13]*r[1]+l[14]*r[5]+l[15]*r[9]+l[16]*r[13],
  l[13]*r[2]+l[14]*r[6]+l[15]*r[10]+l[16]*r[14],
  l[13]*r[3]+l[14]*r[7]+l[15]*r[11]+l[16]*r[15],
  l[13]*r[4]+l[14]*r[8]+l[15]*r[12]+l[16]*r[16]
 })
end

function mulmat4vec4(l,r)
 if #r==4 then return { l[1]*r[1]+l[2]*r[2]+l[3]*r[3]+l[4]*r[4], l[5]*r[1]+l[6]*r[2]+l[7]*r[3]+l[8]*r[4], l[9]*r[1]+l[10]*r[2]+l[11]*r[3]+l[12]*r[4], l[13]*r[1]+l[14]*r[2]+l[15]*r[3]+l[16]*r[4] }
 else return { l[1]*r[1]+l[5]*r[2]+l[9]*r[3]+l[13]*r[4], l[2]*r[1]+l[6]*r[2]+l[10]*r[3]+l[14]*r[4], l[3]*r[1]+l[7]*r[2]+l[11]*r[3]+l[15]*r[4], l[4]*r[1]+l[8]*r[2]+l[12]*r[3]+l[16]*r[4] }
 end
end

function mulmat4scalar(l,r)
 if type(r) == "number" then r, l = l, r end
 return mat4({r[1]*l,r[2]*l,r[3]*l,r[4]*l,r[5]*l,r[6]*l,r[7]*l,r[8]*l,r[9]*l,r[10]*l,r[11]*l,r[12]*l,r[13]*l,r[14]*l,r[15]*l,r[16]*l})
end

function addmat4scalar(l,r)
 if type(r) == "number" then r, l = l, r end
 return mat4({r[1]+l,r[2]+l,r[3]+l,r[4]+l,r[5]+l,r[6]+l,r[7]+l,r[8]+l,r[9]+l,r[10]+l,r[11]+l,r[12]+l,r[13]+l,r[14]+l,r[15]+l,r[16]+l})
end

function submat4scalar(l,r)
 if type(r) == "number" then r, l = l, r end
 return addmat4scalar(l,-r)
end

-- matrix constructor
-- overloads +,- and * for
-- matrices and scalars
function mat4(t)
 local t = t or 1
 if type(t) == "number" then t = {t,t,t,t} end
 if #t == 4 then
  t = {t[1],0,0,0,0,t[2],0,0,0,0,t[3],0,0,0,0,t[4]}
 end
 setmetatable(t,{
  __add=function(l,r)
   if type(l) == "number" or type(r) == "number" then
    return addmat4scalar(l,r)
   else return mat4({l[1]+r[1],l[2]+r[2],l[3]+r[3],l[4]+r[4],l[5]+r[5],l[6]+r[6],l[7]+r[7],l[8]+r[8],l[9]+r[9],l[10]+r[10],l[11]+r[11],l[12]+r[12],l[13]+r[13],l[14]+r[14],l[15]+r[15],l[16]+r[16]}) end end,
  __sub=function(l,r)
   if type(l) == "number" or type(r) == "number" then
    return submat4scalar(l,r)
   else return mat4({l[1]-r[1],l[2]-r[2],l[3]-r[3],l[4]-r[4],l[5]-r[5],l[6]-r[6],l[7]-r[7],l[8]-r[8],l[9]-r[9],l[10]-r[10],l[11]-r[11],l[12]-r[12],l[13]-r[13],l[14]-r[14],l[15]-r[15],l[16]-r[16]}) end end,
  __mul=function(l,r)
   if type(l) == "number" or type(r) == "number" then
    return mulmat4scalar(l,r)
   elseif #l == 4 or #r == 4 then
    return mulmat4vec4(l,r)
   elseif #l == 16 and #r == 16 then
    return mulmat4mat4(l,r)
   else
    printh("error: invalid operands to matrix multiplication")
    return {}
   end
  end
  })
 return t
end

function det3(v1,v2,v3)
 return v1[1]*(v2[2]*v3[3]-v2[3]*v3[2])+
        v2[1]*(v3[2]*v1[3]-v3[3]*v1[2])+
        v3[1]*(v1[2]*v2[3]-v1[3]*v2[2])
end

function printh_matrix(m)
 for i=0,3 do
  str = ""
  for j=1,4 do
   str = str..m[j+4*i]..", "
  end
  printh(str)
 end
end


--[[
new scanline stuff
--]]

s_buffer={}

function find_end(x1,x2,y,z,head)
 if not head.next then
  rectfill(x1,y,x2,y)
  return {x1,x2,z}
 end

 head = head.next
 local base_entry = {x1,x2,z}
 local last_entry = base_entry
 local last = nil
 while head and head[1] < x2 do
  --add(intersections,head)
  if head[3] <= z then
   rectfill(x1,y,head[1],y)
   last_entry[2]=head[1]
   x1=min(x2,head[2])
   last_entry.next={head[1],head[2],head[3],next={x1,x2,z}}
   last_entry = last_entry.next.next
  end

  last = head
  head = head.next
 end

 if not last or last[2] < x2 then
  rectfill(x1,y,x2,y)
 end
 if head then
  last_entry.next = head
 end

 return base_entry
end

--s_buffer format: x1,x2,z
function s_draw(x1,x2,y,z)
 if x2 < x1 then x1,x2 = x2,x1 end
 if s_buffer[y] then
  local head = s_buffer[y]
  local last = nil
  while head do
   if x1 < head[1] then
    local entry
    if x2 <= head[1] then
     -- ##########
     --           ========
     rectfill(x1,y,x2,y)
     entry = {x1,x2,z,next=head}
     if last then
      last.next=entry
     else
      s_buffer[y]=entry
     end
    else -- x2 > head[1]
     if x2 < head[2] then
      -- ##########
      --      ========
      if z < head[3] then
       rectfill(x1,y,x2,y)
       head[1]=x2
       entry={x1,x2,z,next=head}
      else
       rectfill(x1,y,head[1],y)
       entry = {x1,head[1],z,next=head}
      end
      if last then
       last.next=entry
      else
       s_buffer[y]=entry
      end
     elseif x2==head[2] then
      -- #############
      --      ========
      if z < head[3] then
       rectfill(x1,y,x2,y)
       head[1] = x1
       head[2] = x2
       head[3] = z
      else
       rectfill(x1,y,head[1],y)
       local entry={x1,head[1],z,next=head}
       if last then
        last.next=entry
       else
        s_buffer[y]=entry
       end
      end
     else -- x2 > head[2]
      -- ###################
      --      ========   ?????
      local entry
      if z < head[3] then
       entry = find_end(x1,x2,y,z,head)
       if last then
        last.next=entry
       else 
        s_buffer[y]=entry
       end
      else
       rectfill(x1,y,head[1],y)
       entry = {x1,head[1],z,next=head}
       head.next=find_end(head[1],x2,y,z,head)
      end
      if last then
       last.next=entry
      else 
       s_buffer[y]=entry
      end
     end
    end
    break
   elseif x1==head[1] then
    if x2==head[2] then
     -- ########
     -- ========
     if z < head[3] then
      rectfill(x1,y,x2,y)
      head[3]=z
  -- else no entry
     end
    elseif x2 < head[2] then
     -- #####
     -- ========
     if z < head[3] then
      rectfill(x1,y,x2,y)
      head[1]=x2
      local entry={x1,x2,z,next=head}
  -- else no entry
     end
    else -- x2 > head[2]
     -- ##########
     -- ======  ???
     if z < head[3] then
      local entry = find_end(x1,x2,y,z,head)
      if last then
       last.next=entry
      else 
       s_buffer[y]=entry
      end
     else
      head.next = find_end(head[2],x2,y,z,head)
     end
    end
    break
   else -- x1 > head[1]
    if x1 > head[2] then
     --        ######
     -- ======     ?????
     if head.next then
      last = head
      head = head.next
     else
      rectfill(x1,y,x2,y)
      head.next={x1,x2,z}
      break
     end
    else -- x1 <= head[2]
     if x2 < head[2] then
      --   #####
      -- ==========
      if z < head[3] then
       rectfill(x1,y,x2,y)
       local entry={x1,x2,z,next={x2,head[2],head[3],next=head.next}}
       head[2] = x1
       head.next=entry 
   -- else no entry
      end
     elseif x2 == head[2] then
      --   #####
      -- =======
      if z < head[3] then
       rectfill(x1,y,x2,y)
       local entry={x1,x2,z,next=head.next}
       head[2]=x1
       head.next=entry
   -- else no entry
      end
     else -- x2 > head[2]
      --   ############
      -- =======    ??????
      if z < head[3] then
       head[2] = x1
       head.next=find_end(x1,x2,y,z,head)
      else
       head.next=find_end(head[2],x2,y,z,head)
      end
     end
     break
    end
   end
  end
 else
  rectfill(x1,y,x2,y)
  s_buffer[y]={x1,x2,z}
 end
end

function scan_flat_tri(a,b,c)
 local dy=sgn(a[2]-c[2])
 local dx1dy = dy*(a[1]-c[1])/(a[2]-c[2])
 local dx2dy = dy*(b[1]-c[1])/(a[2]-c[2])
 local dz1dy = dy*(a[3]-c[3])/(a[2]-c[2])
 local dz2dy = dy*(b[3]-c[3])/(a[2]-c[2])

 local x1,x2=c[1],c[1]
 local z1,z2=c[3],c[3]
 for y=c[2],a[2],dy do
  --if y == 70 then
   --s_draw(flr(x1),flr(x2),y,(z1+z2)*0.5)
  --end
  
  if occ_cull then
   s_draw(flr(x1),flr(x2),y,(z1+z2)*0.5)
  else
   rectfill(flr(x1),y,flr(x2),y)
  end
  x1+=dx1dy
  x2+=dx2dy
 end
end

function scan_tri(a,b,c)
 --printh(".."..c[1]..", "..c[2])
 if a[1]==b[1]==c[1] or a[2]==b[2]==c[2] then
  -- skip
  printh("degenerate tri")
 else
  -- sort triangles so a.y>=b.y>c.y
  if a[2]< b[2] then a,b=b,a end
  if a[2]< c[2] then a,c=c,a end
  if b[2]< c[2] then b,c=c,b end
  if b[2]==c[2] then a,c=c,a end
 
  if a[2]==b[2] then
   scan_flat_tri(a,b,c)
  else
   local d = {a[1] + (b[2]-a[2]) * (c[1]-a[1])/(c[2]-a[2]),
              b[2],
              a[3] + (b[2]-a[2]) * (c[3]-a[3])/(c[2]-a[2])}
   scan_flat_tri(b,d,a)
   scan_flat_tri(b,d,c)
  end
 end
end

function tri_strip_to_tris(strip)
 local tris = {}
 for i=1,#strip-2 do
  -- need to swap even tris
  -- to maintain ccw orientation
  local m = i % 2
  tris[i] = {strip[i+1-m],strip[i+m],strip[i+2]}
 end
 return tris
end

function backface_cull(tris)
 local res,n={},1
 for i=1,#tris do
  local det = det3(tris[i][1],tris[i][2],tris[i][3])
  if det >= 0 then
   res[n] = tris[i]
   n += 1
  end
 end
 return res
end


function outline_strip(strip)
 local tris=tri_strip_to_tris(strip)
 for t in all(tris) do
  local det = det3(t[1],t[2],t[3])
  local ccw = det >= 0
  local s = ndc_to_screen(t)
  color(11)
  if not ccw then color(8) end
  line(s[1][1],s[1][2],s[2][1],s[2][2])
  line(s[1][1],s[1][2],s[3][1],s[3][2])
  line(s[2][1],s[2][2],s[3][1],s[3][2])
 end
end

--[[
 transformation matrices
--]]

function persp(w,h,n,f)
 local t = 1/(n-f)
 return mat4({2*n/w,0, 0,0,
             0,2*n/h,  0,0,
             0,0,(f+n)*t,2*f*n*t,
             0,0, -1,    0})
end

function trans_t(x,y,z)
 local t = mat4()
 t[4],t[8],t[12]=x,y,z
 return t
end

function scale_t(x,y,z)
 local s = mat4()
 s[1] = x; s[6] = y; s[11] = z
 return s
end

function rotx(a)
 local rx = mat4()
 rx[6]  =  cos(a) -- y
 rx[7]  = -sin(a) -- yz
 rx[10] =  sin(a) -- zy
 rx[11] =  cos(a) -- z
 return rx
end

function roty(a)
 local ry = mat4()
 ry[1]  =  cos(a) -- x
 ry[3]  =  sin(a) -- xz
 ry[9]  = -sin(a) -- zx
 ry[11] =  cos(a) -- z
 return ry
end

function rotz(a)
 local rz = mat4()
 rz[1] =  cos(a) -- x
 rz[2] = -sin(a) -- xy
 rz[5] =  sin(a) -- yx
 rz[6] =  cos(a) -- y
 return rz
end



--[[
 rendering
--]]

function apply_transform(poly, t)
 local res = {}
 for v in all(poly) do
  add(res,t*v)
 end
 return res
end

function proj_to_ndc(poly)
 local res = {}
 for v in all(poly) do
  add(res,{v[1]/v[4],v[2]/v[4],v[3]/v[4]})
 end
 return res
end

clip_planes = {
 { 0, 0, 1},
 { 0, 0,-1},
 { 1, 0, 0},
 { 0, 1, 0},
 {-1, 0, 0},
 { 0,-1, 0}
}

function clip_tri(poly)
 local poly_next = {}
 --[[
 printh("  input poly")
 for v in all(poly) do
  printh("    "..v4s(v))
 end
 ]]--
 -- hacky pre-w clipping
 for i=1,#poly do
  local v = poly[i]
  if v[4] >= 0.1 then
   add(poly_next,v)
  else
   local v_prev = poly[((i-2)%#poly)+1]
   local v_next = poly[((i)%#poly)+1]
   for u in all({v_prev,v_next}) do
    if u[4] >= 0 then
     ratio = (0.1 - v[4]) / (u[4] - v[4])
     local dx = u[1] - v[1]
     local dy = u[2] - v[2]
     local dz = u[3] - v[3]
     local dw = u[4] - v[4]
     if 0 <= ratio and ratio <= 1 then
      add(poly_next,v4(v[1] + ratio*dx, v[2] + ratio*dy, v[3] + ratio*dz, v[4] + ratio*dw))
     end
    end
   end
  end
 end

 poly = poly_next
 poly_next = {}

 --[[
 printh("  output poly")
 for v in all(poly) do
  printh("    "..v4s(v))
 end
 ]]--
 for plane in all(clip_planes) do
  for i=1,#poly do
   local v = poly[i]
   local w_v = v[4]

   local p_v = {plane[1]*w_v,plane[2]*w_v,plane[3]*w_v}
            
   if dot3(p_v,v) <= dot3(p_v,p_v) then
    -- v is inside current plane and should not be clipped
    add(poly_next,v)
   else
    -- edges of v should be clipped 
    local v_prev = poly[((i-2)%#poly)+1]
    local v_next = poly[((i)%#poly)+1]
    for u in all({v_prev, v_next}) do
     local w_u = u[4]
     local p_u = {plane[1]*w_u,plane[2]*w_u,plane[3]*w_u}

     if dot3(p_u,u) <= dot3(p_u,p_u) then
      -- todo - could just do w division here

      local dx = u[1] - v[1]
      local dy = u[2] - v[2]
      local dz = u[3] - v[3]
      local dw = u[4] - v[4]

      local a = dot3(plane, v)
      local b = dot3(plane, u)

      local ratio = (a - v[4]) / (u[4] - v[4] - b + a)
                
      if 0 <= ratio and ratio <= 1 then
       add(poly_next,v4(v[1] + ratio*dx, v[2] + ratio*dy, v[3] + ratio*dz, v[4] + ratio*dw))
      end -- if
     end -- if
    end -- for
   end -- else
  end -- for
  poly = poly_next
  poly_next = {}
 end -- for
 
 return poly
end

function w_divide(verts)
 local res = {}
 for i=1,#verts do
  local w = verts[i][4]
  res[i] = {verts[i][1]/w,verts[i][2]/w,verts[i][3]/w}
 end
 return res
end

function render_strip(strip, viewproject, cull)
 if cull == nil then cull = true end
 strip = apply_transform(strip, viewproject)
 local tris = tri_strip_to_tris(strip)
 if cull then
  tris = backface_cull(tris)
 end
 
 for i=1,#tris do
  local clip_res = clip_tri(tris[i])
  local w_div = w_divide(clip_res)
  local ndc = ndc_to_screen(w_div)
  for j=1,#ndc-2 do  
   --color(col)
   scan_tri(ndc[1],ndc[j+1],ndc[j+2])
   --color(1)
   --line(ndc[1][1],ndc[1][2],ndc[j+1][1],ndc[j+1][2])
   --line(ndc[1][1],ndc[1][2],ndc[j+2][1],ndc[j+2][2])
   --line(ndc[j+1][1],ndc[j+1][2],ndc[j+2][1],ndc[j+2][2])
  end
  --[[
  for j=1,#ndc do
   circfill(ndc[j][1], ndc[j][2],3,j)
  end
  --]]
 end
end

function clip_point(pos)
 local w = pos[4]
 if w < 0 or
    pos[1] > w or pos[1] < -w or
    pos[2] > w or pos[2] < -w or
    pos[3] > w or pos[3] < -w then
    return false
 end
 return true 
end

function billboard(p,sz,sprite, projview, sw,sh)
 sw = sw or 8
 sh = sh or 8
 p = projview*p
 if clip_point(p) then
  local w = 32*sz[1]/p[4]
  local h = 32*sz[2]/p[4]
  p = ndc_to_screen(w_divide({p}))[1]
  -- occlusion cull
  head = s_buffer[p[2]]
  occluded = false
  while head do
   if head[1] < p[1] and p[1] < head[2] then
    occluded = true
    break
   end
   head = head.next
  end
  if not occluded then
   --spr(sprite,p[1],p[2])
   local sx = (sprite%16)*8
   local sy = flr(sprite/16)*8
   sspr(sx,sy,sw,sh,p[1]-w,p[2]-h,w*2,h*2)
  end
 end
end
bb = billboard

--[[
 "engine"
--]]

proj = persp(1,1,0.5,10)
ry, rx = 0, 0

-- mouse support
--[[
poke(0x5f2d,1) -- initiate mouse
last_mx, last_my = 0, 0
--]]

projview = proj

px = 0
pz = 0


reproject = false

function display_debug_info()
 print("cpu: "..100*stat(1).." %", 4,4,7)
 print("mem: "..stat(0).." kb",4,12,7)
 print("px: "..px, 84, 4, 7)
 print("pz: "..pz, 84, 12,7)
 --print("mx: "..last_mx, 100, 4, 7)
 --print("my: "..last_my, 100, 12,7)
 --circfill(last_mx,last_my,1,9)
end

function calc_aabb(model)
 --xxx this doesn't consider w
 local minx= 0x7ff0
 local maxx=-0x7ff0
 local miny,minz,maxy,maxz=minx,minx,maxx,maxx
 for i=1,#model do
  minx=min(minx,model[i][1])
  maxx=max(maxx,model[i][1])
  miny=min(miny,model[i][2])
  maxy=max(maxy,model[i][2])
  minz=min(minz,model[i][3])
  maxz=max(maxz,model[i][3])
 end
 return {
  {minx,maxx},
  {miny,maxy},
  {minz,maxz}
 }
end

function printh_aabb(aabb)
 printh("x: "..v2s(aabb[1])..", y: "..v2s(aabb[2])..", z: "..v2s(aabb[3]))
end

objects = {}
billboards = {}
obj_remove = {}
bb_remove  = {}

function create_obj(model, solid, col, pos, rot, scale, backface_cull)
 col   = col or 7 
 if solid == nil then solid = false end
 pos   = pos   or {0,0,0}
 scale = scale or {1,1,1}
 rot   = rot   or {0,0,0}
 if backface_cull == nil then backface_cull = true end 

 local o = {
 	base_model=model,
 	dirty=true,
  solid=solid,
 	pos=pos,
 	rot=rot,
 	scale=scale,
 	col=col,
 	backface_cull=backface_cull
 }
 reproject_obj(o)
 add(objects,o)
 return o
end

function create_bb(pos, size, sprite, solid)
 if solid == nil then solid = false end
 if solid and size[1] and size[2] and not size[3] then
  size[3] = 1
 end
 local b = {
  pos=pos,
  size=size,
  sprite=sprite,
  solid=solid
 }
 add(billboards, b)
 return b
end

function draw_obj(obj,projview)
 if obj.dirty then
  reproject_obj(obj)
 end
 color(obj.col)
 render_strip(obj.model,projview,obj.backface_cull) 
end

function test_aabb_aabb(a,b)
 return not (a[1][2] < b[1][1] or a[1][1] > b[1][2] or
             a[2][2] < b[2][1] or a[2][1] > b[2][2] or
             a[3][2] < b[3][1] or a[3][1] > b[3][2])
end

function test_aabb_point(aabb,p)
 return aabb[1][1] < p[1] and aabb[1][2] > p[1] and
        aabb[2][1] < p[2] and aabb[2][2] > p[2] and
        aabb[3][1] < p[3] and aabb[3][2] > p[3]
end

function reproject_obj(obj) 
 local s = obj.scale
 local p = obj.pos
 local r = obj.rot
 obj.model=apply_transform(obj.base_model,trans_t(p[1],p[2],p[3])*rotx(r[1])*roty(r[2])*rotz(r[3])*scale_t(s[1],s[2],s[3]))
 if obj.solid then
  obj.aabb=calc_aabb(obj.model)
 end
 obj.dirty = false
end

--[[
 begin actual game code
--]]
gm_menu    = 1
gm_playing = 2
gm_end     = 3
gm_text    = 4
gamemode = gm_menu

wall_strip = {
 v4(0,-1,-1),
 v4(0,-1, 0),
 v4(0, 1,-1),
 v4(0, 1, 0)
}

diamond_strip = {
 v4(-1, 0, 0),
 v4( 0, 0,-1),
 v4( 0, 1, 0),
 v4( 1, 0, 0),
 v4( 0, 0, 1),
 v4( 0, 1, 0),
 v4(-1, 0, 0),
 --v4(),
 --v4(),
}

diamond_ticks = 0

function add_wall(pos,length,rot,col,bf,solid)
 if solid == nil then solid = true end
 col = col or 8
 if bf == nil then bf=false end
 create_obj(wall_strip, solid, col, pos, {0,rot,0},{1,1,length}, bf) 
end

function wall_pp(start_p,end_p,col,bf,solid)
 local l = sub2(start_p,end_p)
 local angle = atan2(l[2],l[1])
 add_wall({start_p[1],0,start_p[2]},mag2(l),angle,col,bf,solid)
end

function disapparate(callback)
 sfx(32)
 if callback then callback() end
end

function centre_text(str,y,c)
 local w = 0
 local last = 1
 local split = false
 for i=1,#str do
  if sub(str,i,i) == "\n" then
   w = max(i - last,w)
   last = i
   split = true
  end
 end
 w = max(#str - last,w)

 print(str,64 - 4*flr(w/2),y,c) 
end

function say(str)
 gamemode=gm_text 
 palt(0,false)
 rectfill(20,20,108,108,1)
 palt(0,true)
  
 centre_text(str,40,2) 
 print("press x to continue",24,100,13)
end

function make_ghost(pos,lines)
 pos[2] = -0.25
 pos[4] = 1
 local b = create_bb(pos,{1,1},2)
 b.pre = function() palt(0,false); palt(1,1) end
 b.post = function() palt(0,true); palt(1,0) end
 b.lines = lines or {}
 b.lno   = 1
 b.update = function(self)
 if gamemode==gm_text then return end
 if dis3(self.pos,{px,0,pz}) < 2 then
   if self.lno <= #self.lines then
    disapparate(function()say(self.lines[self.lno][2]);if self.lines[self.lno][3] then self.lines[self.lno][3]() end end)
    self.pos=self.lines[self.lno][1]
    self.pos[4]=1
    self.lno+=1
   end
   if self.lno > #self.lines then
    add(bb_remove,self)
   end
  end
 end
 return b
end

function make_diamond(pos)
 local d1 = create_obj(diamond_strip, false, 7, pos,{0.25,0,0},{1,1,1},false)
 local d2 = create_obj(diamond_strip, false, 6, pos,{0.25,0,0},{1,-1,1},false)

 diamond_update = function(self)
  local player_distance = dis3(self.pos,{px,0,pz})
  self.rot[3] += 0.1/(2*player_distance)
  self.scale[3] = 1 + 0.1*sin(ticks/30)
  self.scale[1] = 1 + 0.1*cos(ticks/30)
  self.dirty=true

  if player_distance < 1 then
   self.col = 10
   diamond_ticks += 1
   if diamond_ticks > 30 then
    sfx(33)
    diamond_ticks = 0
    next_level=true
   end
  else
   self.col = self.oldcol 
   diamond_ticks = 0
  end
  
  local d = 21/player_distance
  d = min(flr(d),6)
  sfx(1,3,d*4)
 end
 d1.oldcol = d1.col
 d2.oldcol = d2.col
 d1.update=diamond_update
 d2.update=diamond_update
end
next_level = false
level = 0
levels = {
 {-- level 1
  init=
  function(l)
   --add_wall({-2,0,0},5,0)
   --add_wall({2,0,0},3,0)
   --add_wall({-2,0,-5},5,0.25)
   local wc = 8
   make_diamond({-3,0,5})
   wall_pp({-2, 3},{ 2, 3},wc,true)
   wall_pp({-2,-5},{-2, 3},wc,true)
   wall_pp({ 2, 3},{ 2,-7},wc,true)
   wall_pp({ 2,-7},{-7,-7},wc,true)
   wall_pp({-7,-5},{-2,-5},wc,true)
   
   make_ghost({-4,0,-6},{
    {{2,0,-6},"who are you?...\n\nhow did you get here?"},
    {{2,0,-6},"you don't belong here"}
   })
--   wall_pp({ 2,-7},{-7,-7})
   --]]
  end
 },
 {-- level 2
  init=
  function(l)
   local wc = 8
   local wd = 15
   add_wall({-2,0,0},1,0)
   add_wall({ 2,0,0},2,0.5)
   wall_pp({-wd, wd},{ wd, wd},wc,true)
   wall_pp({ wd,-wd},{-wd,-wd},wc,true)
   wall_pp({ wd,  1},{ wd,-wd},wc,true)
   wall_pp({ wd, wd},{ wd, 3},wc,true)
   wall_pp({-wd,-wd},{-wd, wd},wc,true)
   wall_pp({ wd+11,  1},{ wd,  1},wc,true)
   wall_pp({ wd,  3},{ wd+13,  3},wc,true)
   wall_pp({ wd+11,  1},{ wd+11, -5})
   wall_pp({ wd+13,  3},{ wd+13,  -5})
   make_diamond({wd+17,0,-7})
   make_ghost({0,0,3},{
    {{1,1,4},"why did you do that?!"},
    {{wd+5,0,2},"did you come here just\nto break things?",function()occ_cull=true end},
    {{wd+10,0,2},"you need to leave"},
    {{wd+12,0,2},"now!"}
   })
  end
 },
 {-- level 3
  init=
  function(l)
   local wc = 8
   occ_cull = true
   wall_pp({ 2,  2},{-2, 2},wc,true)
   wall_pp({-10, 2},{-2,2},wc,true)
   wall_pp({-2,-10},{-2, 2},wc)
   wall_pp({ 2,  2},{ 2,-10},wc)
   wall_pp({ 3, -4},{-6,-4},wc,true,false)
   for z = -10,-2,1.05 do
	   wall_pp({-2, z},{-6,z},wc,true,false)
	  end
   for z = -4,-2,0.4 do
	   wall_pp({-2, z},{-6,z},wc,true,false)
	  end
   make_diamond({-3,0,1})
   make_ghost({0,0,-6},{
    {{0,0,-6},"you're ruining everything!"},
    {{0,0,-6},"i hate you!"},
    {{0,0,-6},"get out get out get out!!!"},
   })
  end
 }
}

function gameover()
 gamemode=gm_end
 ticks=0
 cls(0)
end

function switch_level()
 rx,ry,px,pz=0,0,0,0
 level += 1
 objects = {}
 billboards = {}
 local l = levels[level]
 if l then l.init(l)
 else gameover() end
end

function _init()
 cls(2)
 local c1=8
 local c2=1
 
 print("rotation", 20,30,c1)
 print("e",34,40,c1) print("up",40,40,c2)
 print("s",30,46,c1) print("left",36,46,c2)
 print("right",16,52,c2) print("f",38,52,c1)
 print("down",16,58,c2)  print("d",34,58,c1)
 
 print("movement", 75,30,c1) 
 print("\x94",75,40,c1) print("forward",83,40,c2)
 print("\x8b",71,46,c1) print("left",79,46,c2)
 print("right",81,52,c2) print("\x91",101,52,c1)
 print("backward",65,58,c2)  print("\x83",97,58,c1)
 
 centre_text("press   to ruin everything",100,c2)
 centre_text("      x                   ",100,c1)
 --switch_level()
end

function handle_input()
 if gamemode == gm_playing then
  local vx = 0
  local vz = 0
  if btn(0,1) then ry += 0.01 end
  if btn(1,1) then ry -= 0.01 end
  if btn(2,1) then rx += 0.01 end
  if btn(3,1) then rx -= 0.01 end
  if btn(1) then vx =  0.1 end
  if btn(0) then vx = -0.1 end
  if btn(2) then vz = -0.1 end
  if btn(3) then vz =  0.1 end
  if btn(0,1) or btn(1,1) or btn(2,1) or btn(3,1) then
   reproject = true
  end
  if btn(1) or btn(0) or btn(2) or btn(3) then
   local dx = vx*cos(ry) - vz*sin(ry)
   local dz = vz*cos(ry) + vx*sin(ry)
   px += dx
   pz += dz
   local collision = false
   for i=1,#objects do
    local o = objects[i]
    if o.solid then
     if test_aabb_aabb(o.aabb,{{px-0.75,px+0.75},{-0.5,0.5},{pz-0.75,pz+0.75}}) then
      --printh_aabb(o.aabb)
      collision = true
      break
     end
    end
   end
 
   if collision then
    px -= dx
    pz -= dz
   else
    reproject = true
   end
  end
 elseif gamemode==gm_text then
  if btnp(5) then
   gamemode = gm_playing
  end
 end
end

function _update()
 -- reset fading sfx channel
 if ticks % 16 == 0 then
  sfx(-1,3)
 end
 
 if gamemode == gm_menu then
  if btn(5) then
   gamemode=gm_playing
   switch_level()
  end
 elseif gamemode == gm_playing
     or gamemode == gm_text then

  handle_input()

  local l = levels[level]
  if l.update then
   l.update(l)
  end
  
  for i=1,#objects do
   local o = objects[i]
   if o.update then o.update(o) end
  end
  for i=1,#billboards do
   local o = billboards[i]
   if o.update then o.update(o) end
  end
  
  for i=1,#obj_remove do
   del(objects,obj_remove[i])
  end
  for i=1,#bb_remove do
   del(billboards,bb_remove[i])
  end
 
  if next_level then
  	switch_level()
  	next_level = false
  end
  --[[
  local mx,my = stat(32), stat(33)
  if mx ~= last_mx or my ~= last_my then
   local dx,dy
   dx = last_mx - mx
   dy = last_my - my
   rx -= dy/100
   ry -= dx/100
   print(rx)
   reproject=true
  end
  last_mx = mx
  last_my = my
  --]]
 elseif gamemode == gm_end then
  if ticks == 120 then
   centre_text("made by qualia",40,7)
   sfx(34)   
  elseif ticks == 180 then
   centre_text("for ludum dare 38",50,7)
   sfx(34)
  elseif ticks == 240 then
   cls()
   sfx(34)
   centre_text("fin",50,7)
   --music(0)
  end
 end
 ticks+=1
end

function _draw()
 if gamemode == gm_playing then
	 if reproject then
	  projview = proj*rotx(rx)*roty(ry)*trans_t(-px,0,-pz)
	 end
	 cls(2)
	 s_buffer={}
 
	 -- draw objects
	 for i=1,#objects do
   --local disp = sub3(objects[i].pos,{px,0,pz})
   --if dot3(disp,disp) < 200 then
 	  draw_obj(objects[i], projview)
 	 --end
	 end

	 -- draw billboards
	 for i=1,#billboards do
	  local b = billboards[i]
	  if b.pre then b.pre() end
	  bb(b.pos,b.size,b.sprite,projview)
	  if b.post then b.post() end
 	end

 	--display_debug_info()

	 --[[
	 printh("s-buffer:")
	 head = s_buffer[70]
	 while head do
	  printh("\t"..head[1].."\t"..head[2].."\t"..head[3])
	  head = head.next
	 end
	 pset(1,70,10)
	 --]]
	--elseif gamemode=say
	 
	end
end
__gfx__
00000000000000001100001100444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000090000001104401104343340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700009900001104401103939300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000099000110cc01103933d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000000990011cddc110555ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000000090011cddc110d5dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000901cdccdc10dddd0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001dddddd100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0110000034653346531b643336731a6531b653326731a6543265431653316530d653316733164531653316033165331653316531067510675316730d6631a6543265431653316533261532673326011a60532603
002000002d6002c6002f6002d60002610026100261002610056200562005620056200a6300a6300a6300b63010640106401064010640156501665016650156501c6601d6601d6601d66022670236702367023670
011000002535114351073510030119351163513f3513f3513f3512a3512b3513f3512935117351063510635125301193010d3010e3010d301013011e301383013f3013f3013f3012e3012e3013f3011f3010e301
011000080f6530000000000000000f603000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000700007000070000700007000070026750237502375024750327703877024750247502473023720227101b7201b7301e750267503177038770007000070000700007000070000700007000070000700
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000066400a6300f62014610196101c6102061027620286301e64024650296602a66026640256302463022630206301f6201e6201d6101b6101b610006000060000600006000060000600006000060000600
000600000a3040f304123741d37425374273742d37431374313743137431374023040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304
011000000c65300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 03424344
01 00024344
00 00424344
00 00024344
02 00424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

