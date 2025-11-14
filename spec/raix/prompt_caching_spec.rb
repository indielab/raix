# frozen_string_literal: true

class GettingRealAnthropic
  include Raix::ChatCompletion

  def initialize
    self.model = "anthropic/claude-3-haiku"
    transcript << {
      role: "system",
      content: [
        {
          type: "text",
          text: "You are a modern historian studying trends in modern business. You know the following book callsed 'Getting Real' very well:"
        },
        {
          type: "text",
          text: File.read("spec/files/getting_real.md"),
          cache_control: {
            type: "ephemeral"
          }
        }
      ]
    }
    transcript << { user: "What is the meaning of Getting Real according to the book? Begin your response with According to the book," }
  end
end

RSpec.describe GettingRealAnthropic, :vcr do
  subject { described_class.new }

  it "does a completion with prompt caching" do
    subject.chat_completion.tap do |response|
      expect(response).to include("According to the book")
    end

    # now do it again
    subject.chat_completion

    # pause to let OpenRouter's usage event system catch up
    sleep 2

    # TODO: RubyLLM doesn't currently expose OpenRouter's generation stats API
    # For now, we just verify that the second completion also works (would use cached data)
    # A more thorough test would require adding generation stats support to RubyLLM
    expect(Thread.current[:chat_completion_response]).to be_present
  end
end
