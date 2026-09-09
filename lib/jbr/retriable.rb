module Jbr
  # Jobber refusing a query over what it costs rather than over anything about the query. The
  # bucket it is priced against refills, so the same question asked later is answered; the
  # numbers it was refused with stay in the message.
  Retriable = Class.new Error
end
