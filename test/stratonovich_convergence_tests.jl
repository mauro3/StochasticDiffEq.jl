using StochasticDiffEq, DiffEqProblemLibrary, DiffEqDevTools, Base.Test
srand(100)
dts = 1./2.^(10:-1:2) #14->7 good plot

prob = prob_sde_linear_stratonovich
sim  = test_convergence(dts,prob,EulerHeun(),numMonte=Int(5e2))
@test abs(sim.𝒪est[:l2]-1) < 0.1

sim  = test_convergence(dts,prob,ImplicitEulerHeun(),numMonte=Int(5e2))
@test abs(sim.𝒪est[:l2]-1) < 0.1

sim  = test_convergence(dts,prob,ImplicitEulerHeun(theta=1),numMonte=Int(5e2))
@test abs(sim.𝒪est[:l2]-1) < 0.1

sim  = test_convergence(dts,prob,ImplicitEulerHeun(symplectic=true),numMonte=Int(5e2))
@test abs(sim.𝒪est[:l2]-1) < 0.1

sim2 = test_convergence(dts,prob,RKMil(interpretation=:Stratonovich),numMonte=Int(5e2))
@test abs(sim2.𝒪est[:l2]-1) < 0.2

sim  = test_convergence(dts,prob,ImplicitRKMil(interpretation=:Stratonovich),numMonte=Int(5e2))
@test abs(sim.𝒪est[:l2]-1) < 0.1

prob = prob_sde_2Dlinear_stratonovich

sim  = test_convergence(dts,prob,EulerHeun(),numMonte=Int(5e1))
@test abs(sim.𝒪est[:l2]-1) < 0.1

sim  = test_convergence(dts,prob,ImplicitEulerHeun(),numMonte=Int(5e1))
@test abs(sim.𝒪est[:l2]-1) < 0.1

sim  = test_convergence(dts,prob,ImplicitEulerHeun(theta=1),numMonte=Int(5e1))
@test abs(sim.𝒪est[:l2]-1) < 0.1

sim  = test_convergence(dts,prob,ImplicitEulerHeun(symplectic=true),numMonte=Int(5e1))
@test abs(sim.𝒪est[:l2]-1) < 0.1

sim2 = test_convergence(dts,prob,RKMil(interpretation=:Stratonovich),numMonte=Int(5e2))
@test abs(sim2.𝒪est[:l2]-1) < 0.2

sim  = test_convergence(dts,prob,ImplicitRKMil(interpretation=:Stratonovich),
                        numMonte=Int(5e2))
@test abs(sim.𝒪est[:l2]-1) < 0.1

sim  = test_convergence(dts,prob,ImplicitRKMil(theta=1,interpretation=:Stratonovich),
                        numMonte=Int(5e2))
@test abs(sim.𝒪est[:l2]-1) < 0.1

sim  = test_convergence(dts,prob,ImplicitRKMil(symplectic=true,interpretation=:Stratonovich),
                        numMonte=Int(5e2))
@test abs(sim.𝒪est[:l2]-1) < 0.1

srand(200)
sol = solve(prob,EulerHeun(),dt=1/4)
