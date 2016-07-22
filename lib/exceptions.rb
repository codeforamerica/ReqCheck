module Exceptions
  class ImportError < StandardError; end
  class MissingCVX < ImportError; end
end