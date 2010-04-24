Dir[File.join(Rails.root, 'lib', 'security', '**', '*.rb'].each do |f|
  require f
end