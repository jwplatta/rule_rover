module RuleRover
  class Resolution
    class << self
      def entail?(kb, query)
        query = RuleRover::Statements::Proposition.parse(query) if query.is_a? String
        self.new(kb, query).entail?
      end
    end

    def initialize(kb=nil, query=nil)
      @kb = kb
      @query = query
    end

    attr_reader :kb, :query

    def entail?
      resolve(kb, query)
    end

    private

    def resolve(kb, query)
      all_clauses = kb.clauses + query.to_cnf.to_conjuncts
      while true
        new_clauses = []
        (0...all_clauses.count).to_a.combination(2).to_a.each do |cls1_idx, cls2_idx|
          # STEP: resolve clauses
          cls1_disjuncts = all_clauses[cls1_idx].to_disjuncts
          cls2_disjuncts = all_clauses[cls2_idx].to_disjuncts

          resolvents = []
          cls1_disjuncts.each do |cls1_disj|
            cls2_disjuncts.each do |cls2_disj|
              # STEP: complimentary literals?
              if cls1_disj.not == cls2_disj or cls1_disj == cls2_disj.not
                # STEP: remove the literals
                temp = (cls1_disjuncts.reject { |cls| cls == cls1_disj } + cls2_disjuncts.reject { |cls| cls == cls2_disj }).uniq

                if temp.count > 1
                  resolvents << temp[1..].reduce(temp[0]) { |stmt, cls| stmt.or(cls) }
                elsif temp.count == 1
                  resolvents << temp.first
                elsif temp.empty?
                  return true
                end
              end
            end
          end
          new_clauses = (new_clauses + resolvents).uniq
        end

        # STEP: is subset?
        new_clauses = new_clauses.reject { |nc| all_clauses.include? nc }
        if new_clauses.empty?
          return false
        else
          all_clauses = new_clauses + all_clauses
        end
      end
    end
  end
  # def self.tautology?(statement)
  #   pl_resolve(knowledge_base: RuleRover::PropositionalKB.new, statement: statement)
  # end
end
