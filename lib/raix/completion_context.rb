# frozen_string_literal: true

module Raix
  # Context object passed to before_completion hooks.
  # Provides access to the chat completion instance, messages, and request parameters.
  # Messages can be mutated for content filtering, PII redaction, etc.
  class CompletionContext
    attr_reader :chat_completion, :messages, :params

    def initialize(chat_completion:, messages:, params:)
      @chat_completion = chat_completion
      @messages = messages # mutable - hooks can modify for filtering, redaction, etc.
      @params = params # mutable - hooks can modify parameters
    end

    # Convenience accessor for the transcript
    def transcript
      chat_completion.transcript
    end

    # Get the currently configured model
    def current_model
      chat_completion.model || chat_completion.configuration.model
    end

    # Get the class that includes ChatCompletion
    def chat_completion_class
      chat_completion.class
    end

    # Get the current configuration
    def configuration
      chat_completion.configuration
    end
  end
end
