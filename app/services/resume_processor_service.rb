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
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "email": { "type": "string" },
        "phone": { "type": "string" },
        "location": { "type": "string" },
        "current_position": { "type": "string" },
        "experience_years": { "type": "string" },
        "education": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "degree": { "type": "string" },
              "institution": { "type": "string" },
              "year": { "type": "string" }
            }
          }
        },
        "work_experience": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "position": { "type": "string" },
              "company": { "type": "string" },
              "duration": { "type": "string" }
            }
          }
        },
        "skills": {
          "type": "array",
          "items": { "type": "string" }
        }
      }
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
        return [nil, [], I18n.t('resumes.flash.processing_error', reason: "Failed to process resume")]
      end
      
      data = parsed_result.dig("properties") || parsed_result

      if (data["email"].blank? && data["phone"].blank?)
        return [nil, [], I18n.t('resumes.flash.missing_contacts')]
      end
      
      skills = data["skills"]

      unless skills.is_a?(Array)
        return [nil, [], I18n.t('resumes.flash.processing_error', reason: "invalid skills format")]
      end
      
      unique_skills = skills.compact.map(&:strip).uniq.reject(&:empty?)
      data["skills"] = unique_skills
      
      tags = unique_skills.map do |skill|
        Tag.find_or_create_by!(name: skill)
      end

      [JSON.pretty_generate(data), tags, nil]
    rescue OllamaAdapter::Error => e
      [nil, [], I18n.t('resumes.flash.processing_error', reason: e.message)]
    rescue StandardError => e
      [nil, [], I18n.t('resumes.flash.processing_error', reason: e.message)]
    end
  end
end 