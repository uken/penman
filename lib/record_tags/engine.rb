module Penman
  class Engine < ::Rails::Engine
    initializer :append_migrations do |app|
      unless app.config.paths["db/migrate"].include? root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
