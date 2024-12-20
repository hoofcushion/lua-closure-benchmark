Clone this project, then use `lua closure.lua` to see benchmark result.

Output:

```
-0.003000000000001
0.73
0.36
0.368
0.387
0.068999999999999
0.058999999999996
1.739
1.525
1.432
1.594
0.784
2.293
```

### Script Overview

The script is designed to measure the performance overhead of different types of function calls in Lua, particularly focusing on closures and their capture of upvalues (variables from the outer scope that are referenced by the inner function).

### Benchmark Results Analysis

1. **Control Group (No Operation)**
   **Result: -0.003**

   - **Explanation**: Gives the error range of the test function it self.

2. **Inter Implicit Capture**

   ```lua
    local x=1
    (function() return x end)() -- *
   ```

   **Result: 0.73**

   - **Explanation**: This measures the overhead of an inner function implicitly capturing a single upvalue. The result is relatively high due to the implicit capture mechanism.

3. **Inter Explicit Capture**

   ```lua
   local x=1
   (function(x) return x end)(x) -- *
   ```

   **Result: 0.36**

   - **Explanation**: This measures the overhead of an inner function explicitly capturing a single upvalue. It's faster than implicit capture because the upvalue is explicitly passed, reducing the lookup time.

4. **Outer Implicit Capture**

   ```lua
   (function() return time end)()
   ```

   **Result: 0.368**

   - **Explanation**: Similar to inter implicit capture but `time` is in outer scope, faster than Inter Implicit Capture group, telling that binding outer upvalue is cheaper than inner one.

5. **Outer Explicit Capture**

   ```lua
   (function(x) return x end)(time)
   ```

   **Result: 0.387**

   - **Explanation**: Similar to outer implicit capture but with explicit passing, showing a minor performance decrease, cause passing arguments still take times.

6. **Outer No Capture**

   ```lua
   u(time)
   ```

   **Result: 0.069**

   - **Explanation**: This test does not capture any upvalues, using a helper function `u` to return the value. It's faster than any capture scenario due to the absence of upvalue handling.

7. **Inter No Capture**

   ```lua
   local x=1
   u(x)
   ```

   **Result: 0.059**

   - **Explanation**: Similar to outer no capture but in an inner scope, showing a slightly higher overhead due to the local variable declaration.

8. **4 Upvalues**

   ```lua
   local a,b,c,d=1,2,3,4
   (function() return a+b+c+d end)()
   ```

   **Result: 1.739**

   - **Explanation**: Capturing four upvalues increases the overhead significantly compared to single upvalue capture due to more memory access and management.

9. **4 Values in 1 Table Upvalue**

   ```lua
   local a,b,c,d=1,2,3,4
   local t={a,b,c,d}
   (function() return t[1]+t[2]+t[3]+t[4] end)()
   ```

   **Result: 1.525**

   - **Explanation**: Using a table to capture multiple values reduces the overhead compared to individual upvalues, likely due to better locality and reduced memory accesses.

10. **3 Upvalues**

    ```lua
    local a,b,c=1,2,3
    (function() return a+b+c end)()
    ```

    **Result: 1.432**

    - **Explanation**: Similar to 4 upvalues but with one less, showing a slight reduction in overhead.

11. **3 Values in 1 Table Upvalue**

    ```lua
    local a,b,c=1,2,3
    local t={a,b,c}
    (function() return t[1]+t[2]+t[3] end)()
    ```

    **Result: 1.594**

    - **Explanation**: Similar to 4 values in 1 table upvalue but with three values, showing a comparable performance, that 4 upvalues is worth to pack in table (and in luajit is 3).

12. **Normal Closure**

    ```lua
    local x=1
    (function() return x end)()
    ```

    **Result: 0.784**

    - **Explanation**: A normal closure with a single upvalue, showing a moderate overhead.

13. **Metatable Closure**

    ```lua
    local x=1
      (setmetatable({x=x},{
       __call=function(ups)
        return ups.x
       end,
      }))()
    ```

    **Result: 2.293**

    - **Explanation**: Using a metatable with a `__call` method to simulate closure behavior introduces significant overhead due to the additional layer of indirection and table lookup, But it prevents any upvalue and created a gc-friendly structure, prevent life-cycle problem for closure.

### Conclusion

The benchmark results clearly show that closures with fewer upvalues or using tables to bundle upvalues have less performance overhead compared to capturing multiple individual upvalues. This insight can guide optimizations in Lua or similar languages to minimize the performance impact of closures.
