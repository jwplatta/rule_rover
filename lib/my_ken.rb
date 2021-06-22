# frozen_string_literal: true

require_relative "./my_ken/version"
require_relative "./my_ken/boolean_monkey_patch"
require_relative "./my_ken/knowledge_base"
require_relative "./my_ken/statements"
# require_relative "./my_ken/model_checker"
# require_relative "./my_ken/conjunctive_normal_form"
# require_relative "./my_ken/resolver"

module MyKen
  class Error < StandardError; end
  # Your code goes here...
end
