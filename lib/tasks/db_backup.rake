namespace :db do
  desc "Backup the production database"
  task :backup => :environment do
    db_to_backup = "development.sqlite3"
    backup_dir = ENV['DIR'] || File.join(Rails.root, 'db', 'backup')
    source = File.join(Rails.root, 'db', db_to_backup)
    dest = File.join(backup_dir, "#{db_to_backup}.backup")
    makedirs backup_dir, :verbose => true
    sh "sqlite3 #{source} .dump > #{dest}"
  end
end