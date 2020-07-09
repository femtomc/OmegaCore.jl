using ..Tagging, ..Traits, ..Var, ..Space
# @inline hasintervene(ω) = hastag(ω, Val{:intervene})
@inline tagintervene(ω, intervention) = tag(ω, (intervene = intervention,), mergetags)
@inline (x::Intervened)(ω) = x.x(tagintervene(ω, x.i))

@inline function passintervene(traits, i::Intervention{X, V}, x::X, ω) where {X, V}
  # If the variable ` x` to be applied to ω is the variable to be replaced
  # then replace it, and apply its replacement to ω instead.
  # Othewise proceed as normally
  if i.x == x
    i.v(ω)
  else
    ctxapply(traits, x, ω)
  end
end

function passintervene(traits,
                       i::Union{MultiIntervention{Tuple{Intervention{X1, V1},
                                                        Intervention{X2, V2}}},
                                MultiIntervention{Tuple{Intervention{X1, V1},
                                                        Intervention{X2, V2},
                                                        Intervention{X3, V3}}},
                                MultiIntervention{Tuple{Intervention{X1, V1},
                                                        Intervention{X2, V2},
                                                        Intervention{X3, V3},
                                                        Intervention{X4, V4}}},
                                MultiIntervention{Tuple{Intervention{X1, V1},
                                                        Intervention{X2, V2},
                                                        Intervention{X3, V3},
                                                        Intervention{X4, V4},
                                                        Intervention{X5, V5}}}},
                       x::Union{X1, X2, X3, X4, X5},
                       ω) where {X1, X2, X3, X4, X5, V1, V2, V3, V4, V5}
  # method 1
  # @show typeof(i.is[1].x)
  # is = filter(i -> x == i.x, [i.is...])
  # if !isempty(is)
  #   first(is).v(ω)
  # else
  #   ctxapply(traits, x, ω)
  # end

  # method 2
  # index = 1;
  # while (index <= length(i.is) && x != i.is[index].x)
  #   index += 1
  # end
  # if (index <= length(i.is))
  #   i.is[index].v(ω)
  # else
  #   ctxapply(traits, x, ω)
  # end

  # method 3
  # if x == i.is[1].x
  #   i.is[1].v(ω)
  # elseif x == i.is[1].x
  #   i.is[2].v(ω)
  # else  
  #   ctxapply(traits, x, ω)
  # end

  # method 4
  helper(i, 1, traits, x, ω)

end

function helper(i::Union{MultiIntervention{Tuple{Intervention{X1, V1},
                            Intervention{X2, V2}}},
                          MultiIntervention{Tuple{Intervention{X1, V1},
                            Intervention{X2, V2},
                            Intervention{X3, V3}}},
                          MultiIntervention{Tuple{Intervention{X1, V1},
                            Intervention{X2, V2},
                            Intervention{X3, V3},
                            Intervention{X4, V4}}},
                          MultiIntervention{Tuple{Intervention{X1, V1},
                            Intervention{X2, V2},
                            Intervention{X3, V3},
                            Intervention{X4, V4},
                            Intervention{X5, V5}}}}, 
                index::Int, 
                traits, 
                x::Union{X1, X2, X3, X4, X5}, 
                ω) where {X1, X2, X3, X4, X5, V1, V2, V3, V4, V5}
  if index <= length(i.is)
    if x == i.is[index].x
      i.is[index].v(ω)
    else
      helper(i, index + 1, traits, x, ω)
    end
  else
    ctxapply(traits, x, ω)
  end
end


# We only consider intervention if the intervention types match
@inline passintervene(traits, i::AbstractIntervention, x, ω) =
  ctxapply(traits, x, ω)

(f::Vari)(traits::trait(Intervene), ω::AbstractΩ) = 
  passintervene(traits, ω.tags.intervene, f, ω)