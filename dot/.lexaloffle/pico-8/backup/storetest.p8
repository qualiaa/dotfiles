pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- storage library


cartdata("jamie-test-1")

int_to_char = {[0]="a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
char_to_int = {}
for k,v in pairs(int_to_char) do
 char_to_int[v] = k
end

function str2bytes(str)
 local bytes = {}
 for i=1,#str do
  add(bytes, char_to_int(sub(str,i,i)))
 end
 return bytes
end

function grid2bytes(grid)
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

function bytes2grid(bytes)
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



-->8
-- tests

function test_grid()
 local g = {{1,2,3,4},
            {5,6,7,8},
            {9,10,11,12},
            {13,14,15,0}}

 local b = grid2bytes(g)
 local ng = bytes2grid(b)
 local eq = true
 for j=1,4 do
  for i=1,4 do
   eq = eq and g[j][i] == ng[j][i]
  end
 end
 return eq
end

function print_test(name,result)
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
print_test("grid",test_grid())
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
