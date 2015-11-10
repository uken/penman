module Penman
  MAJOR = 0     # api
  MINOR = 2     # features
  PATCH = 9     # bug fixes
  BUILD = nil   # beta, rc1, etc

  VERSION = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
end
