server "s3.teachbase.ru", user: "deplo"

set :ssh_options, {
   keys: %w(~/.ssh/tb_s1),
   forward_agent: false,
   auth_methods: %w(publickey)
 }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
