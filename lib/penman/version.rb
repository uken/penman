module Penman
  MAJOR = 0     # api
  MINOR = 2     # features
  PATCH = 7     # bug fixes
  BUILD = nil   # beta, rc1, etc

  VERSION = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
end
