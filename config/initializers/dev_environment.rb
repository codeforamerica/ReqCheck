unless Rails.env.production?
  ENV['EXTRACTOR_NAME'] = 'test'
  ENV['EXTRACTOR_PASSWORD'] = 'test'
end
