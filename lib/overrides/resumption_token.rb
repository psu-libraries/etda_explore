# frozen_string_literal: true

require 'blacklight_oai_provider/resumption_token'

module Overrides
  module ResumptionToken
    # Override encode conditions to allow parsing date/datetime objects.
    # https://github.com/code4lib/ruby-oai/pull/97
    def encode_conditions
      encoded_token = @prefix.to_s.dup
      encoded_token << ".s(#{set})" if set
      if from
        encoded_token << if from.respond_to?(:utc)
                           ".f(#{from.utc.xmlschema})"
                         else
                           ".f(#{from.xmlschema})"
                         end
      end
      if self.until
        encoded_token << if self.until.respond_to?(:utc)
                           ".u(#{self.until.utc.xmlschema})"
                         else
                           ".u(#{self.until.xmlschema})"
                         end
      end
      encoded_token << ".t(#{total})" if total
      encoded_token << ":#{last}"
    end
  end
end

BlacklightOaiProvider::ResumptionToken.prepend(Overrides::ResumptionToken)
