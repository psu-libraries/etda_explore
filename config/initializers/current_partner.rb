# frozen_string_literal: true

# A global method to return the current partner
def current_partner
  EtdaUtilities::Partner.current
end
