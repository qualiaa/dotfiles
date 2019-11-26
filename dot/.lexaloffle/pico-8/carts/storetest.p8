pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- storage library

cartdata("jamie-test-1")

conv = {}
store = {
 addr=0x5e00
}
 -- string storage
 -- ascii codes -32, with gap for lower case
ascii = {
 chr = {[0]=" ","!",[["]],"#","$","%","&","'","(",")","*","+",",","-",".","/","0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?","@","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","[","\\","]","^","_","`",
        [91]="{",[92]="|",[93]="}",[94]="~"},

 -- abc only is more economical
 -- chr = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"},

 ord = {}
}
for k,v in pairs(ascii.chr) do
 ascii.ord[v] = k
end


function conv.str2bytes(str)
 local bytes = {}
 for i=1,#str do
  add(bytes, ascii.ord[sub(str,i,i)])
 end
 return bytes
end

function conv.bytes2str(bytes)
 local str = ""
 for b in all(bytes) do
  str = str .. ascii.chr[b]
 end
 return str
end

-- number conversion
function conv.num2bytes(n)
 local bytes = {}
 add(bytes,band(0xff,shr(n,8)))
 add(bytes,band(0xff,n))
 add(bytes,band(0xff,shl(n,8)))
 add(bytes,band(0xff,shl(n,16)))
 return bytes
end

function conv.bytes2num(bytes)
 local n = 0
 for b in all(bytes) do
  n = shl(n,8)
  n += shr(b,16)
 end
 return n
end

-- example table conversion
-- compress a 4x4 array
function conv.grid2bytes(grid)
 assert(#grid == 4)
 assert(#grid[1] == 4)
 local bytes = {}
 for j=1,#grid do
  for i=1,#grid[1],2 do
   local low  = grid[j][i]
   local high = grid[j][i+1]
   assert(low  <= 0xf)
   assert(high <= 0xf)
   add(bytes, low+shl(high,4))
  end
 end
 return bytes
end

function conv.bytes2grid(bytes)
 local grid = {}
 for j=1,4 do
  add(grid,{})
  for i=1,2 do
   local byte = bytes[(j-1)*2+i]
   add(grid[j],
       band(0xf,byte))
   add(grid[j],
       band(0xf,shr(byte,4)))
  end
 end
 return grid
end

function joinlist(a,b)
 local l = {}
 for v in all(a) do add(l,v) end
 for v in all(b) do add(l,v) end
 return l
end

function store.save_bytes(bytes,start_byte)
 assert(start_byte >= 0 
    and start_byte+#bytes-1 <= 0xff)
 
 for i,b in pairs(bytes) do
  poke(store.addr + start_byte
       + i - 1, b)
 end
end

function store.load_bytes(start_byte,n)
 local bytes = {}
 local last_byte = start_byte+n-1
 assert(start_byte >= 0
    and last_byte <= 0xff)
 for i=start_byte,last_byte do
  add(bytes,peek(store.addr+i))
 end
 return bytes
end 
-->8
-- tests
test = {}

function test.grid()
 return {{1,2,3,4},
         {5,6,7,8},
         {9,10,11,12},
         {13,14,15,0}}
end  

function test.valid_ascii()
 return (ascii.ord["a"] == 65-32 and
         ascii.ord["z"] == 90-32 and
         ascii.ord["0"] == 48-32 and
         ascii.ord["9"] == 57-32 and
         ascii.ord["!"] == 33-32)
end

function test.conv_ascii()
 local s = "{hi there]123,:}| 98 \\!\""
 local b = conv.str2bytes(s)
 local ns = conv.bytes2str(b)
 return s == ns
end

function test.conv_abc()
 local s = "thequickbrownfoxjumpedoverthelazydog"
 local b = conv.str2bytes(s)
 local ns = conv.bytes2str(b)
 return s == ns
end

function test.string()
 local s = "{hello there]123 98 \\!\""
 local b = conv.str2bytes(s)
 local ns = conv.bytes2str(b)
 return s == ns
end


function test.conv_grid()
 local g = test.grid()
 local b = conv.grid2bytes(g)
 local ng = conv.bytes2grid(b)
 local eq = true
 for j=1,4 do
  for i=1,4 do
   eq = eq and g[j][i] == ng[j][i]
  end
 end
 return eq
end

function test.conv_num()
 local n = 0x6e80.f102
 local b = conv.num2bytes(n)
 local nn = conv.bytes2num(b)
 return n == nn
end

function test.store_bytes()
 local g = test.grid()
 local b = conv.grid2bytes(g)
 for i=0,0xfe-#b do
  store.save_bytes(b, i)
  nb = store.load(i, #b)
  ng = conv.bytes2grid(nb)
 end
 return true
end
 

function test.print(name,result)
 color(7)
 print("")
 x,y = peek(0x5f26),peek(0x5f27)-6
 print(name..":",x,y)
 if result then
  print("[success]",x+(#name+2)*4,y,11)
 else
  print("[failed]",x+(#name+2)*4,y,8)
 end
 poke(0x5f26,x); poke(0x5f27,y+6)
end
-->8
print("running test suite")
test.print("conv num",
           test.conv_num())
test.print("conv ascii",
           test.conv_ascii())
test.print("conv abc",
           test.conv_abc())
test.print("conv grid",
           test.conv_grid())
test.print("valid ascii",
           test.valid_ascii())
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
