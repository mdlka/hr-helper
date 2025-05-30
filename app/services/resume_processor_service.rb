require 'ollama_adapter'
require 'ollama_adapter/ollama_client'
require 'ollama_adapter/extractor'
require 'ollama_adapter/prompt_builder'

class ResumeProcessorService
  def initialize
    @client = OllamaAdapter::OllamaClient.new("http://localhost:11434", "qwen2.5:7b")
    @extractor = OllamaAdapter::Extractor.new(@client)
  end

  def process(text)
    schema = {
      type: "object",
      properties: {
        name: { type: "string" },
        email: { type: "string" },
        phone: { type: "string" },
        location: { type: "string" },
        current_position: { type: "string" },
        experience_years: { type: "integer" },
        skills: {
          type: "array",
          items: { type: "string" }
        },
        education: {
          type: "array",
          items: {
            type: "object",
            properties: {
              degree: { type: "string" },
              institution: { type: "string" },
              year: { type: "integer" }
            }
          }
        },
        work_experience: {
          type: "array",
          items: {
            type: "object",
            properties: {
              company: { type: "string" },
              position: { type: "string" },
              duration: { type: "string" }
            }
          }
        }
      },
      required: ["name", "skills"]
    }

    begin
      result = @extractor.extract(text, schema)

      parsed_result = case result
      when String
        JSON.parse(result) rescue nil
      when Hash
        result
      else
        nil
      end
      
      if parsed_result.nil?
        return ["Failed to process resume", []]
      end
      
      data = parsed_result.dig("properties") || parsed_result
      skills = data["skills"]

      unless skills.is_a?(Array)
        return ["Failed to process resume: invalid skills format", []]
      end
      
      tags = skills.map do |skill|
        Tag.find_or_create_by!(name: skill.strip)
      end

      [JSON.pretty_generate(data), tags]
    rescue OllamaAdapter::Error => e
      ["Failed to process resume", []]
    rescue StandardError => e
      ["Failed to process resume", []]
    end
  end
end 