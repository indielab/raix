# frozen_string_literal: true

RSpec.describe Raix::CompletionContext do
  let(:chat_completion_class) do
    Class.new do
      include Raix::ChatCompletion

      def initialize
        self.model = "test-model"
        transcript << { user: "Hello" }
      end
    end
  end

  let(:chat_completion) { chat_completion_class.new }
  let(:messages) { [{ role: "user", content: "Hello" }] }
  let(:params) { { temperature: 0.7, max_tokens: 100 } }

  subject do
    described_class.new(
      chat_completion:,
      messages:,
      params:
    )
  end

  describe "#chat_completion" do
    it "returns the chat completion instance" do
      expect(subject.chat_completion).to eq(chat_completion)
    end
  end

  describe "#messages" do
    it "returns the messages array" do
      expect(subject.messages).to eq(messages)
    end

    it "allows mutation of messages for content filtering" do
      subject.messages << { role: "system", content: "Added by hook" }
      expect(subject.messages.length).to eq(2)
    end

    it "allows modification of message content for PII redaction" do
      subject.messages.first[:content] = "[REDACTED]"
      expect(subject.messages.first[:content]).to eq("[REDACTED]")
    end
  end

  describe "#params" do
    it "returns the params hash" do
      expect(subject.params).to eq(params)
    end

    it "allows mutation of params" do
      subject.params[:temperature] = 0.9
      expect(subject.params[:temperature]).to eq(0.9)
    end
  end

  describe "#transcript" do
    it "returns the chat completion transcript" do
      expect(subject.transcript).to eq(chat_completion.transcript)
    end
  end

  describe "#current_model" do
    context "when chat completion has a model set" do
      it "returns the instance model" do
        expect(subject.current_model).to eq("test-model")
      end
    end

    context "when chat completion model is nil" do
      before { chat_completion.model = nil }

      it "falls back to configuration model" do
        expect(subject.current_model).to eq(chat_completion.configuration.model)
      end
    end
  end

  describe "#chat_completion_class" do
    it "returns the class that includes ChatCompletion" do
      expect(subject.chat_completion_class).to eq(chat_completion_class)
    end
  end

  describe "#configuration" do
    it "returns the chat completion configuration" do
      expect(subject.configuration).to eq(chat_completion.configuration)
    end
  end
end
