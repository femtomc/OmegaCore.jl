using OmegaCore

a = ~ Normal(0, 1)

function f(ω)
  x = ~ Normal(0, 1)(ω)
  y = ~ Normal(0, 1)(ω)
  for i = 1:10
    z += ~ Normal(0, 1)(ω)
  end
  z + a(ω)
end


function samplemodel()
    x = ~ Normal(0, 1)
    y = ~ Normal(0, 1)
    for i = 1:10
        z += ~ Normal(0, 1)
    end
    z(ω) = (x(ω), y(ω), x(ω))
    randsample(z)
  end
  