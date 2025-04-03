require 'rake'

# Загружаем все задачи из директории lib/tasks
Dir.glob('lib/tasks/**/*.rake').each { |r| load r }

task default: :help

desc 'Show available tasks'
task :help do
  puts "Available tasks:"
  puts "  rake services:download_logos    - Download high-quality logos from service URLs"
  puts "  rake services:process_logos     - Download and process logos for services"
end