module Jbr
  # Jobber refusing the grant itself, rather than failing to answer about it. The first is a
  # token that will never work again; the second may be a moment of trouble at their end.
  Refused = Class.new Error
end
