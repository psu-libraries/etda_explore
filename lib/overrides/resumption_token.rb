module BlacklightOaiProvider
  class ResumptionToken < ::OAI::Provider::ResumptionToken
    # Override encode conditions to allow for parsing date / datetime objects
    # https://github.com/code4lib/ruby-oai/pull/97 
    def encode_conditions
      encoded_token = @prefix.to_s.dup
      encoded_token << ".s(#{set})" if set
      if self.from
        if self.from.respond_to?(:utc)
          encoded_token << ".f(#{self.from.utc.xmlschema})"
        else
          encoded_token << ".f(#{self.from.xmlschema})"
        end
      end
      if self.until
        if self.until.respond_to?(:utc)
          encoded_token << ".u(#{self.until.utc.xmlschema})" 
        else
          encoded_token << ".u(#{self.until.xmlschema})" 
        end
      end
      encoded_token << ".t(#{total})" if total
      encoded_token << ":#{last}"
    end
  end
end