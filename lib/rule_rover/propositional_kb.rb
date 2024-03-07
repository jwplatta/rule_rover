module RuleRover
  class PropositionalKB
    attr_reader :clauses

    class << self
      def build(*prop_strings)
        self.new.then do |prop_kb|
          prop_strings.map do |prop_s|
            prop_kb.assert(prop_s)
          end
          prop_kb
        end
      end
    end

    def initialize
      @clauses = []
    end

    def size
      clauses.count
    end

    def to_statement
      clauses[1..].reduce(clauses[0]) { |stmt, cls| stmt.and(cls) }
    end

    def assert(statement)
      prop = if statement.is_a? String
        RuleRover::Statements::Proposition.parse(statement).to_cnf
      elsif statement.is_a? RuleRover::Statements::Proposition
        statement.to_cnf
      end

      # NOTE: return if conjuncts.select { |cnj| clauses.include? cnj }.any?
      prop.to_conjuncts.each do |cnj|
        @clauses << cnj unless clauses.include? cnj
      end
      clauses
    end

    def deny(statement)
      prop = if statement.is_a? String
        RuleRover::Statements::Proposition.parse(statement).to_cnf
      elsif statement.is_a? RuleRover::Statements::Proposition
        statement.to_cnf
      end

      cnjs = prop.to_conjuncts
      @clauses = clauses.reject { |cls| cnjs.include? cls }
      clauses
    end

    def query(proposition, add_to_kb: false, algorithm: 'model_checking')
      # TODO: should be using resolution or model checking here.
      case algorithm
      when 'model_checking'
        model_checking(proposition)
      else
        model_checking(proposition)
      end
    end

    private

    def model_checking(query)
      RuleRover::ModelChecker.entail?(self, query)
    end

    def backtracking(query); end
    def resolution(query); end
    def forward_chaining(query); end
  end
end
