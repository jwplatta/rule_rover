module MyKen
  class KnowledgeBase
    def initialize(statements:)
      @statements = statements
    end

    attr_reader :statements

    def true?(model)
      statements.call(*model)
    end
  end
end
