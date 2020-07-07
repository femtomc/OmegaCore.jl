using Test
using OmegaCore
using Distributions
using OmegaTest

function minimal_example()
  xx = 1 ~ Normal(0, 1)
  y(ω) = xx(ω) + 10
  yi = intervene(y, xx => (ω -> 200.0)) 
  yi2 = intervene(yi, xx => (ω -> 300.0))
  @test randsample(yi2) == 200
end

function minimal_example_2()
  xx = 1 ~ Normal(0, 1)
  y(ω) = xx(ω) + 10
  xr = 2 ~ Normal(30, 1)
  yi = intervene(y, xx => xr) 
  yi2 = intervene(yi, xr => (ω -> 300.0))
  @test randsample(yi2) == 310
end

function test_model()
  # Normally distributed random variable with id 1
  x = 1 ~ Normal(0, 1)
    
    # Normally distributed random variable with id 2 and x as mean
    function y(ω)
      xt = x(ω)
      u = Uniform(xt, xt + 1)
      u((2,), ω)
    end
    x_ = 0.1
    y_ = 0.3

    # An omega object -- like a trace
    ω = SimpleΩ(Dict((1,) => x_, (2,) => y_))

    # model -- tuple-valued random variable ω -> (x(ω), y(ω)), becase we want joint pdf
    m(ω) = (x(ω), y(ω))
    (x, y, m)
end

function samplemodel()
  x,y,z = test_model()
  ω = defω()
  y(ω)
end

function test_intervention()
  x, y, m = test_model()
  yⁱ = y |ᵈ (x => (ω -> 100.0))
  @test 100.0 <= randsample(yⁱ) <= 101.0
  @test isinferred(randsample, yⁱ)
end

function test_intervene_diff_parents()
  x = 1 ~ Normal(0, 1)
  function y(ω)
    x_ = x(ω)
    (2 ~ Normal(x_, 1))(ω)
  end
  x2 = 3 ~ Normal(0, 1)
  yi = y |ᵈ (x => ω -> 100.0)
  yi2 = y |ᵈ (x2 => ω -> 100.0)
  yi_, yi2_ = randsample((yi, yi2))
  @test yi_ != yi2_
end

function test_two_interventions()
  x = 1 ~ Normal(0, 1)
  y = 2 ~ Uniform(10.0, 20.0)
  z(ω) = Normal(x(ω), y(ω))((3,), ω)
  (x, y, z)
  zi = z |ᵈ (x => (ω -> 100.0), y => (ω -> 0.1))
  @test 99 <= randsample(zi) <= 101
end

function test_three_interventions()
  x = 1 ~ Normal(0, 1)
  y = 2 ~ Uniform(10.0, 20.0)
  c = 3 ~ Uniform(2.0, 3.0)
  z(ω) = Normal(x(ω)*c(ω), y(ω))((3,), ω)
  (x, y, z)
  zi = z |ᵈ (x => (ω -> 100.0), y => (ω -> 0.1), c => (w -> 1.0))
  @test 99 <= randsample(zi) <= 101
end

function test_intervention_logpdf()
  # Log density of model wrt ω
  l = logpdf(m, ω)

  # Check it is what it should be
  @test l == logpdf(Normal(0, 1), x_) + logpdf(Normal(x_, 1), y_)

  # Intervened model
  v_ = 100.0

  # y had x been v_
  yⁱ = y | had(x => v_)

  # new model with Intervened variables
  mⁱ = rt(x, yⁱ)

  # log pdf of interved model on same ω
  lⁱ = logpdf(mⁱ, ω)
  logpdf(x, ω)

  
  @test lⁱ == logpdf(Normal(0, 1), x_) + logpdf(Normal(v_, 1), y_)
  @test lⁱ < l
end

@testset "intervene" begin
  test_intervention()
  test_intervene_diff_parents()
  test_two_interventions()
  test_three_interventions()
  # test_intervention_logpdf()
end 