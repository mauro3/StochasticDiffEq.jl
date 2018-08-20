DiffEqBase.@def iipnlcachefields begin
  nlcache = alg.nlsolve.cache
  @unpack κ,tol,max_iter,min_iter,new_W = nlcache
  z = similar(u,axes(u))
  dz = similar(u,axes(u)); tmp = similar(u,axes(u)); b = similar(u,axes(u))
  fsalfirst = zero(rate_prototype)
  k = zero(rate_prototype)
  uToltype = real(uEltypeNoUnits)
  ηold = one(uToltype)

  if typeof(alg.nlsolve) <: NLNewton
    if DiffEqBase.has_jac(f) && !DiffEqBase.has_invW(f) && f.jac_prototype != nothing
      W = WOperator(f, zero(t))
      J = nothing # is J = W.J better?
    else
      J = fill(zero(uEltypeNoUnits),length(u),length(u)) # uEltype?
      W = similar(J)
    end
    du1 = zero(rate_prototype)
    uf = DiffEqDiffTools.UJacobianWrapper(f,t,p)
    jac_config = build_jac_config(alg,f,uf,du1,uprev,u,tmp,dz)
    linsolve = alg.linsolve(Val{:init},uf,u)
    z₊ = z
  elseif typeof(alg.nlsolve) <: NLFunctional
    J = nothing
    W = nothing
    du1 = rate_prototype
    uf = nothing
    jac_config = nothing
    linsolve = nothing
    z₊ = similar(z)
  end

  if κ != nothing
    κ = uToltype(nlcache.κ)
  else
    κ = uToltype(1//100)
  end
  if tol != nothing
    tol = uToltype(nlcache.tol)
  else
    reltol = 1e-1 # TODO: generalize
    tol = uToltype(min(0.03,first(reltol)^(0.5)))
  end
  _nlsolve = alg.nlsolve
end

DiffEqBase.@def oopnlcachefields begin
  nlcache = alg.nlsolve.cache
  @unpack κ,tol,max_iter,min_iter,new_W = nlcache
  z = uprev
  uf = alg.nlsolve isa NLNewton ? DiffEqDiffTools.UDerivativeWrapper(f,t,p) : nothing
  uToltype = real(uEltypeNoUnits)
  ηold = one(uToltype)
  if DiffEqBase.has_jac(f) && alg.nlsolve isa NLNewton
    J = f.jac(uprev, p, t)
    if !isa(J, DiffEqBase.AbstractDiffEqLinearOperator)
      J = DiffEqArrayOperator(J)
    end
    W = WOperator(f.mass_matrix, zero(t), J)
  else
    W = typeof(u) <: Number ? u : Matrix{uEltypeNoUnits}(undef, 0, 0) # uEltype?
  end

  if κ != nothing
    κ = uToltype(κ)
  else
    κ = uToltype(1//100)
  end
  if tol == nothing
    reltol = 1e-1 # TODO: generalize
    tol = uToltype(min(0.03,first(reltol)^(0.5)))
  end
  z₊,dz,tmp,b,k = z,z,z,z,rate_prototype
  _nlsolve = oop_nlsolver(alg.nlsolve)
end

mutable struct ImplicitEMCache{uType,rateType,J,W,JC,UF,N,noiseRateType,F,dWType} <: StochasticDiffEqMutableCache
  u::uType
  uprev::uType
  du1::rateType
  fsalfirst::rateType
  k::rateType
  z::uType
  dz::uType
  tmp::uType
  gtmp::noiseRateType
  gtmp2::rateType
  J::J
  W::W
  jac_config::JC
  linsolve::F
  uf::UF
  dW_cache::dWType
  nlsolve::N
end

u_cache(c::ImplicitEMCache)    = (c.uprev2,c.z,c.dz)
du_cache(c::ImplicitEMCache)   = (c.k,c.fsalfirst)

function alg_cache(alg::ImplicitEM,prob,u,ΔW,ΔZ,p,rate_prototype,noise_rate_prototype,
                   uEltypeNoUnits,uBottomEltype,tTypeNoUnits,uprev,f,t,::Type{Val{true}})
  @iipnlcachefields

  gtmp = zero(noise_rate_prototype)
  if is_diagonal_noise(prob)
    gtmp2 = gtmp
    dW_cache = nothing
  else
    gtmp2 = zero(rate_prototype)
    dW_cache = zero(ΔW)
  end

  nlsolve = typeof(_nlsolve)(NLSolverCache(κ,tol,min_iter,max_iter,100000,new_W,z,W,alg.theta,zero(t),ηold,z₊,dz,tmp,b,k))
  ImplicitEMCache(u,uprev,du1,fsalfirst,k,z,dz,tmp,gtmp,gtmp2,J,W,jac_config,linsolve,uf,
                  dW_cache,nlsolve)
end

mutable struct ImplicitEMConstantCache{F,N} <: StochasticDiffEqConstantCache
  uf::F
  nlsolve::N
end

function alg_cache(alg::ImplicitEM,prob,u,ΔW,ΔZ,p,rate_prototype,noise_rate_prototype,
                   uEltypeNoUnits,uBottomEltype,tTypeNoUnits,uprev,f,t,::Type{Val{false}})
  @oopnlcachefields
  nlsolve = typeof(_nlsolve)(NLSolverCache(κ,tol,min_iter,max_iter,100000,new_W,z,W,alg.theta,zero(t),ηold,z₊,dz,tmp,b,k))
  ImplicitEMConstantCache(uf,nlsolve)
end

mutable struct ImplicitEulerHeunCache{uType,rateType,J,W,JC,UF,N,noiseRateType,F,dWType} <: StochasticDiffEqMutableCache
  u::uType
  uprev::uType
  du1::rateType
  fsalfirst::rateType
  k::rateType
  z::uType
  dz::uType
  tmp::uType
  gtmp::noiseRateType
  gtmp2::rateType
  gtmp3::noiseRateType
  J::J
  W::W
  jac_config::JC
  linsolve::F
  uf::UF
  nlsolve::N
  dW_cache::dWType
end

u_cache(c::ImplicitEulerHeunCache)    = (c.uprev2,c.z,c.dz)
du_cache(c::ImplicitEulerHeunCache)   = (c.k,c.fsalfirst)

function alg_cache(alg::ImplicitEulerHeun,prob,u,ΔW,ΔZ,p,rate_prototype,noise_rate_prototype,
                   uEltypeNoUnits,uBottomEltype,tTypeNoUnits,uprev,f,t,::Type{Val{true}})
  @iipnlcachefields
  gtmp = zero(noise_rate_prototype)
  gtmp2 = zero(rate_prototype)

  if is_diagonal_noise(prob)
      gtmp3 = gtmp2
      dW_cache = nothing
  else
      gtmp3 = zero(noise_rate_prototype)
      dW_cache = zero(ΔW)
  end

  nlsolve = typeof(_nlsolve)(NLSolverCache(κ,tol,min_iter,max_iter,100000,new_W,z,W,alg.theta,zero(t),ηold,z₊,dz,tmp,b,k))
  ImplicitEulerHeunCache(u,uprev,du1,fsalfirst,k,z,dz,tmp,gtmp,gtmp2,gtmp3,
                         J,W,jac_config,linsolve,uf,nlsolve,dW_cache)
end

mutable struct ImplicitEulerHeunConstantCache{F,N} <: StochasticDiffEqConstantCache
  uf::F
  nlsolve::N
end

function alg_cache(alg::ImplicitEulerHeun,prob,u,ΔW,ΔZ,p,rate_prototype,noise_rate_prototype,
                   uEltypeNoUnits,uBottomEltype,tTypeNoUnits,uprev,f,t,::Type{Val{false}})
  @oopnlcachefields
  nlsolve = typeof(_nlsolve)(NLSolverCache(κ,tol,min_iter,max_iter,100000,new_W,z,W,alg.theta,zero(t),ηold,z₊,dz,tmp,b,k))
  ImplicitEulerHeunConstantCache(uf,nlsolve)
end

mutable struct ImplicitRKMilCache{uType,rateType,J,W,JC,UF,N,noiseRateType,F} <: StochasticDiffEqMutableCache
  u::uType
  uprev::uType
  du1::rateType
  fsalfirst::rateType
  k::rateType
  z::uType
  dz::uType
  tmp::uType
  gtmp::noiseRateType
  gtmp2::noiseRateType
  gtmp3::noiseRateType
  J::J
  W::W
  jac_config::JC
  linsolve::F
  uf::UF
  nlsolve::N
end

u_cache(c::ImplicitRKMilCache)    = (c.uprev2,c.z,c.dz)
du_cache(c::ImplicitRKMilCache)   = (c.k,c.fsalfirst)

function alg_cache(alg::ImplicitRKMil,prob,u,ΔW,ΔZ,p,rate_prototype,noise_rate_prototype,
                   uEltypeNoUnits,uBottomEltype,tTypeNoUnits,uprev,f,t,::Type{Val{true}})
  @iipnlcachefields
  gtmp = zero(noise_rate_prototype)
  gtmp2 = zero(rate_prototype)
  gtmp3 = zero(rate_prototype)

  nlsolve = typeof(_nlsolve)(NLSolverCache(κ,tol,min_iter,max_iter,100000,new_W,z,W,alg.theta,zero(t),ηold,z₊,dz,tmp,b,k))
  ImplicitRKMilCache(u,uprev,du1,fsalfirst,k,z,dz,tmp,gtmp,gtmp2,gtmp3,
                   J,W,jac_config,linsolve,uf,nlsolve)
end

mutable struct ImplicitRKMilConstantCache{F,N} <: StochasticDiffEqConstantCache
  uf::F
  nlsolve::N
end

function alg_cache(alg::ImplicitRKMil,prob,u,ΔW,ΔZ,p,rate_prototype,noise_rate_prototype,
                   uEltypeNoUnits,uBottomEltype,tTypeNoUnits,uprev,f,t,::Type{Val{false}})
  @oopnlcachefields
  nlsolve = typeof(_nlsolve)(NLSolverCache(κ,tol,min_iter,max_iter,100000,new_W,z,W,alg.theta,zero(t),ηold,z₊,dz,tmp,b,k))
  ImplicitRKMilConstantCache(uf,nlsolve)
end
