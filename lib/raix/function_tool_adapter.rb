# frozen_string_literal: true

module Raix
  # Adapter to convert Raix function declarations to RubyLLM::Tool instances
  class FunctionToolAdapter
    def self.create_tool_from_function(function_def, instance)
      tool_class = Class.new(RubyLLM::Tool) do
        description function_def[:description] if function_def[:description]

        # Define parameters based on function definition
        function_def[:parameters][:properties]&.each do |param_name, param_def|
          required = function_def[:parameters][:required]&.include?(param_name)
          param param_name.to_sym, type: param_def[:type], desc: param_def[:description], required:
        end

        # Store reference to the instance and function name
        define_method(:raix_instance) { instance }
        define_method(:raix_function_name) { function_def[:name] }

        # Override execute to call the Raix function
        define_method(:execute) do |**args|
          raix_instance.public_send(raix_function_name, args.with_indifferent_access, nil)
        end
      end

      # Set a meaningful name for the tool class
      tool_class.define_singleton_method(:name) do
        "Raix::GeneratedTool::#{function_def[:name].to_s.camelize}"
      end

      tool_instance = tool_class.new

      # Override the name method to return the original function name
      # This ensures RubyLLM can match the tool call from the AI
      tool_instance.define_singleton_method(:name) do
        function_def[:name].to_s
      end

      tool_instance
    end

    def self.convert_tools_for_ruby_llm(raix_instance)
      return [] unless raix_instance.class.respond_to?(:functions)
      return [] if raix_instance.class.functions.blank?

      raix_instance.class.functions.map do |function_def|
        create_tool_from_function(function_def, raix_instance)
      end
    end
  end
end
