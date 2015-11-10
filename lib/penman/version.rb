module Penman
  MAJOR = 0     # api
  MINOR = 3     # features
  PATCH = 0     # bug fixes
  BUILD = nil   # beta, rc1, etc

  VERSION = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
end
