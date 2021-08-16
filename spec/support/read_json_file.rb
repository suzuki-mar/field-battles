# frozen_string_literal: true

class ReadJsonFile
  def self.read(file_path, mode = nil)
    path = Rails.root.join(file_path)
    json = File.open(path).read

    if mode == :not_symbolize
      JSON.parse(json)
    else
      JSON.parse(json, { symbolize_names: true })
    end
  end
end
