

role :app, "ext-rails-r3.apeelapp.com"
role :web, "ext-rails-r3.apeelapp.com"
#role :db,  "ext-postgres-rails.apeelapp.com", :primary => true
role :db,  "ext-rails-r3.apeelapp.com", :primary => true
role :backgroundrb, "ext-backgroundrb-r3.apeelapp.com"
#role :backgroundrb, "ext-phocoder-worker.apeelapp.com"

set :deploy_to, "/mnt/rails/#{application}"

