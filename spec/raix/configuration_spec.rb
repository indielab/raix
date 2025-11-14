# frozen_string_literal: true

RSpec.describe Raix::Configuration do
  describe "#client?" do
    context "with RubyLLM configured via OpenRouter API key" do
      it "returns true" do
        configuration = described_class.new(fallback: nil)
        configuration.ruby_llm_config = RubyLLM::Configuration.new
        configuration.ruby_llm_config.openrouter_api_key = "test_key"
        expect(configuration.client?).to eq true
      end
    end

    context "with RubyLLM configured via OpenAI API key" do
      it "returns true" do
        configuration = described_class.new(fallback: nil)
        configuration.ruby_llm_config = RubyLLM::Configuration.new
        configuration.ruby_llm_config.openai_api_key = "test_key"
        expect(configuration.client?).to eq true
      end
    end

    context "without any API configuration" do
      it "returns false" do
        configuration = described_class.new(fallback: nil)
        configuration.ruby_llm_config = RubyLLM::Configuration.new
        # Clear all API keys
        configuration.ruby_llm_config.openai_api_key = nil
        configuration.ruby_llm_config.openrouter_api_key = nil
        configuration.ruby_llm_config.anthropic_api_key = nil
        configuration.ruby_llm_config.gemini_api_key = nil
        expect(configuration.client?).to eq false
      end
    end
  end
end
