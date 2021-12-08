# frozen_string_literal: true

class JsonParserSupport
  class << self
    def file(file_path, mode = nil)
      path = Rails.root.join(file_path)
      json = File.open(path).read

      if mode == :not_symbolize
        JSON.parse(json)
      else
        JSON.parse(json, { symbolize_names: true })
      end
    end

    def response_body(response)
      JSON.parse(response.body, { symbolize_names: true })
    end
  end
end
