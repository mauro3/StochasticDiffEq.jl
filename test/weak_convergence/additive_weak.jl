using StochasticDiffEq, DiffEqDevTools, Test
using Random
using DiffEqProblemLibrary.SDEProblemLibrary: importsdeproblems
importsdeproblems()
using DiffEqProblemLibrary.SDEProblemLibrary: prob_sde_linear, prob_sde_2Dlinear, prob_sde_additive
Random.seed!(100)

dts = 1 .//2 .^(10:-1:2) #14->7 good plot

prob = prob_sde_additive
println("EM")
sim  = test_convergence(dts,prob,EM(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim.𝒪est[:weak_final]-1) < 0.3
@test abs(sim.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim.𝒪est[:weak_l∞]-1) < 0.3
println("SimplifiedEM")
sim  = test_convergence(dts,prob,SimplifiedEM(),trajectories=Int(1e5),
                        weak_timeseries_errors=true)
@test abs(sim.𝒪est[:weak_final]-1) < 0.3
@test abs(sim.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim.𝒪est[:weak_l∞]-1) < 0.35
println("RKMil")
sim2 = test_convergence(dts,prob,RKMil(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("RKMil_General")
sim2 = test_convergence(dts,prob,RKMil_General(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("SROCK1")
sim2 = test_convergence(dts,prob,SROCK1(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("SROCK2")
sim2 = test_convergence(dts,prob,SROCK2(),trajectories=Int(1e5),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-2) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-2) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-2) < 0.3
println("SROCKEM")
sim2 = test_convergence(dts,prob,SROCKEM(strong_order_1=false),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("SROCKEM")
sim2 = test_convergence(dts,prob,SROCKEM(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("SKSROCK")
sim2 = test_convergence(dts,prob,SKSROCK(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("SROCKC2")
sim2 = test_convergence(dts,prob,SROCKC2(),trajectories=Int(1e5),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-2) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-2) < 0.3

#omitting tests for incomplete methods
# sim2 = test_convergence(dts,prob,TangXiaoSROCK2(version_num=1),trajectories=Int(1e5),
#                    weak_timeseries_errors=true)
# @test abs(sim2.𝒪est[:weak_final]-2) < 0.3
# @test abs(sim2.𝒪est[:weak_l2]-2) < 0.3
# @test abs(sim2.𝒪est[:weak_l∞]-2) < 0.3
# sim2 = test_convergence(dts,prob,TangXiaoSROCK2(version_num=2),trajectories=Int(1e5),
#                    weak_timeseries_errors=true)
# @test abs(sim2.𝒪est[:weak_final]-2) < 0.3
# @test abs(sim2.𝒪est[:weak_l2]-2) < 0.3
# @test abs(sim2.𝒪est[:weak_l∞]-2) < 0.3
# sim2 = test_convergence(dts,prob,TangXiaoSROCK2(version_num=3),trajectories=Int(1e5),
#                    weak_timeseries_errors=true)
# @test abs(sim2.𝒪est[:weak_final]-2) < 0.3
# @test abs(sim2.𝒪est[:weak_l2]-2) < 0.3
# @test abs(sim2.𝒪est[:weak_l∞]-2) < 0.3
# sim2 = test_convergence(dts,prob,TangXiaoSROCK2(version_num=4),trajectories=Int(1e5),
#                    weak_timeseries_errors=true)
# @test abs(sim2.𝒪est[:weak_final]-2) < 0.3
# @test abs(sim2.𝒪est[:weak_l2]-2) < 0.3
# @test abs(sim2.𝒪est[:weak_l∞]-2) < 0.3
# sim2 = test_convergence(dts,prob,TangXiaoSROCK2(version_num=5),trajectories=Int(1e5),
#                    weak_timeseries_errors=true)
# @test abs(sim2.𝒪est[:weak_final]-2) < 0.3
# @test abs(sim2.𝒪est[:weak_l2]-2) < 0.3
# @test abs(sim2.𝒪est[:weak_l∞]-2) < 0.3

println("WangLi3SMil_A")
sim2 = test_convergence(dts,prob,WangLi3SMil_A(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("WangLi3SMil_B")
sim2 = test_convergence(dts,prob,WangLi3SMil_B(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("WangLi3SMil_C")
sim2 = test_convergence(dts,prob,WangLi3SMil_C(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("WangLi3SMil_D")
sim2 = test_convergence(dts,prob,WangLi3SMil_D(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("WangLi3SMil_E")
sim2 = test_convergence(dts,prob,WangLi3SMil_E(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("WangLi3SMil_F")
sim2 = test_convergence(dts,prob,WangLi3SMil_F(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim2.𝒪est[:weak_final]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l2]-1) < 0.3
@test abs(sim2.𝒪est[:weak_l∞]-1) < 0.3
println("SRI")
sim3 = test_convergence(dts,prob,SRI(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim3.𝒪est[:weak_final]-2) < 0.3
@test abs(sim3.𝒪est[:weak_l2]-2) < 0.3
@test abs(sim3.𝒪est[:weak_l∞]-2) < 0.3
println("SRIW1")
sim4 = test_convergence(dts,prob,SRIW1(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim4.𝒪est[:weak_final]-2) < 0.3
@test abs(sim4.𝒪est[:weak_l2]-2) < 0.3
@test abs(sim4.𝒪est[:weak_l∞]-2) < 0.35
println("SRA")
sim5 = test_convergence(dts,prob,SRA(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim5.𝒪est[:weak_final]-2) < 0.3
@test abs(sim5.𝒪est[:weak_l2]-2) < 0.3
@test abs(sim5.𝒪est[:weak_l∞]-2) < 0.3
println("SRA1")
sim6 = test_convergence(dts,prob,SRA1(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim6.𝒪est[:weak_final]-2) < 0.3
@test abs(sim6.𝒪est[:weak_l2]-2) < 0.3
@test abs(sim6.𝒪est[:weak_l∞]-2) < 0.3
println("SRA2")
sim6 = test_convergence(dts,prob,SRA2(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim6.𝒪est[:weak_final]-2) < 0.3
@test abs(sim6.𝒪est[:weak_l2]-2) < 0.3
@test abs(sim6.𝒪est[:weak_l∞]-2) < 0.3
println("SRA3")
sim6 = test_convergence(dts,prob,SRA3(),trajectories=Int(1e4),
                        weak_timeseries_errors=true)
@test abs(sim6.𝒪est[:weak_final]-3) < 0.3
@test abs(sim6.𝒪est[:weak_l2]-3) < 0.3
@test abs(sim6.𝒪est[:weak_l∞]-3) < 0.3
