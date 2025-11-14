# frozen_string_literal: true

module Raix
  # Adapter to convert between Raix's transcript array format and RubyLLM's Message objects
  class TranscriptAdapter
    attr_reader :ruby_llm_chat

    def initialize(ruby_llm_chat)
      @ruby_llm_chat = ruby_llm_chat
      @pending_messages = []
    end

    # Add a message in Raix format (hash) to the transcript
    def <<(message_hash)
      case message_hash
      when Array
        # Handle nested arrays (from function dispatch)
        message_hash.each { |msg| self << msg }
      when Hash
        add_message_from_hash(message_hash)
      end
      self
    end

    # Return all messages in Raix-compatible format
    def flatten
      (@ruby_llm_chat.messages.map { |msg| message_to_raix_format(msg) } + @pending_messages).flatten
    end

    # Get all messages including pending ones
    def to_a
      flatten
    end

    # Allow iteration
    def compact
      flatten.compact
    end

    # Clear all messages
    def clear
      @ruby_llm_chat.reset_messages!
      @pending_messages.clear
      self
    end

    private

    def add_message_from_hash(hash)
      # Raix abbreviated format: { system: "text" }, { user: "text" }, { assistant: "text" }
      if hash.key?(:system) || hash.key?("system")
        content = hash[:system] || hash["system"]
        @ruby_llm_chat.with_instructions(content)
        @pending_messages << { role: "system", content: }
      elsif hash.key?(:user) || hash.key?("user")
        content = hash[:user] || hash["user"]
        # Don't add to ruby_llm_chat yet - wait for chat_completion call
        @pending_messages << { role: "user", content: }
      elsif hash.key?(:assistant) || hash.key?("assistant")
        content = hash[:assistant] || hash["assistant"]
        @pending_messages << { role: "assistant", content: }
      elsif hash[:role] == "tool" || hash["role"] == "tool"
        # Tool result message
        @pending_messages << hash.with_indifferent_access
      elsif hash[:role] == "assistant" && (hash[:tool_calls] || hash["tool_calls"])
        # Assistant message with tool calls
        @pending_messages << hash.with_indifferent_access
      elsif hash[:role] || hash["role"]
        # Standard OpenAI format
        @pending_messages << hash.with_indifferent_access
      end
    end

    def message_to_raix_format(message)
      result = {
        role: message.role.to_s,
        content: message.content
      }

      result[:tool_calls] = message.tool_calls if message.tool_call?
      result[:tool_call_id] = message.tool_call_id if message.tool_result?

      result
    end
  end
end
