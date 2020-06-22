using IRTools, Test
using IRTools: IR, @dynamo

function f(x)
    N = 4
    for i1 in 1:3    # single loop works without issue
        for i2 in 1:N   # needs to be a variable `1:4` works fine
        end
    end
    0.0 # same error with `x`
end

@test @code_ir(f(1)) isa IR

function f(a, b)
    u = 1
    while true
        if true
        end
    end
    f(u)
end

@test @code_ir(f(1, 2)) isa IR

# issue 30
@dynamo function foo(a...)
    ir = IR(a...)
    return ir
end

mylog2(x) = ccall((:log2, Base.Math.libm), Float64, (Float64,), x)

@test foo(mylog2, 3.3) === mylog2(3.3)

bar(a, b) = a > b ? a : b

function foo(a, b)
  bar(a, b)
end

let
  ir1 = @code_ir foo(1, 2)
  ir2 = @code_ir bar(1, 2)
  ir = IRTools.inline(ir1, IRTools.var(4), ir2)
  f = IRTools.func(ir)
  @test f(nothing, 2, 3) == 3
  @test f(nothing, 3, 2) == 3
end
