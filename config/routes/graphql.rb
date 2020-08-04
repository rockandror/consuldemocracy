path = ""
path << (ENV['CONSUL_RELATIVE_URL'].nil? || ENV['CONSUL_RELATIVE_URL'].empty? ? "" : ENV['CONSUL_RELATIVE_URL'])
path << '/graphql'

get '/graphql', to: 'graphql#query'
post '/graphql', to: 'graphql#query'
mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: path
