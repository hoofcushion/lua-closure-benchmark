local unpack=unpack or table.unpack
local function empty_f()
end
math.randomseed(os.time())
-- calc the usage of function call
local function get_usage(t,fn)
 collectgarbage("collect")
 local s=os.clock()
 for _=1,t do
  fn()
 end
 local e=os.clock()
 return e-s
end
local function get_real_usage(t,fn)
 return get_usage(t,fn)-get_usage(t,empty_f)
end
-- test how long fn runs t time takes
-- output could be negative, means time function takes shorter than the error range
-- increase test time may fix that
local function test(t,fn,offset)
 return get_real_usage(t,fn)-(offset and get_real_usage(t,offset) or 0)
end
local tests={}
-- push function to test set
local function push(fn,offset)
 table.insert(tests,{fn,offset})
end
-- run test in shuffle order
local function iter(t)
 local e=#tests
 local i=e
 local res={}
 while i>0 do
  local id=math.random(e)
  local v=tests[id]
  if v then
   tests[id]=nil
   i=i-1
   local ret=test(t,unpack(v))
   res[id]=ret
  end
 end
 -- print out the result
 for _,v in ipairs(res) do
  print(v)
 end
end
-- define test times
local time=5000000
-- *
push(
 function()
 end,
 function()
 end
)
-- inter implicit capture
push(
 function()
  local x=1
  (function() return x end)()
 end,
 function() local _=1 end
)
-- inter explicit capture
push(
 function()
  local x=1
  (function(x) return x end)(x)
 end,
 function() local _=1 end
)
-- outer implicit capture
push(function()
 (function() return time end)()
end)
-- outer explicit capture
push(function()
 (function(x) return x end)(time)
end)
local function u(x)
 return x
end
-- outer no capture
push(
 function() u(time) end
)
-- inter no capture
push(
 function()
  local x=1
  u(x)
 end,
 function() local _=1 end
)
-- 4 upvalue
push(
 function()
  local a,b,c,d=1,2,3,4
  (function() return a+b+c+d end)()
 end,
 function()
  local a,b,c,d=1,2,3,4
 end
)
-- 4 value in 1 table upvalue
push(
 function()
  local a,b,c,d=1,2,3,4
  local t={a,b,c,d}
  (function() return t[1]+t[2]+t[3]+t[4] end)()
 end,
 function()
  local a,b,c,d=1,2,3,4
 end
)
-- 3 upvalue
push(
 function()
  local a,b,c=1,2,3
  (function() return a+b+c end)()
 end,
 function()
  local a,b,c=1,2,3
 end
)
-- 3 value in 1 table upvalue
push(
 function()
  local a,b,c=1,2,3
  local t={a,b,c}
  (function() return t[1]+t[2]+t[3] end)()
 end,
 function()
  local a,b,c=1,2,3
 end
)
-- normal closure
push(
 function()
  local x=1
  (function() return x end)()
 end,
 function()
  local _=1
 end
)
-- metatable closure
push(
 function()
  local x=1
  (setmetatable({x=x},{
   __call=function(ups)
    return ups.x
   end,
  }))()
 end,
 function()
  local _=1
 end
)
iter(time)
