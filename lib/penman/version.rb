module Penman
  MAJOR = 0     # api
  MINOR = 1     # features
  PATCH = 6     # bug fixes
  BUILD = nil   # beta, rc1, etc

  VERSION = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
end
