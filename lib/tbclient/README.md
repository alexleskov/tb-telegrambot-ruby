# tb-apiclient-ruby
API client for Teachbase LMS

## Usage
Avaliable endpoints for usage: 
`endpoint_v1, mobile_v1, mobile_v2`

### Running the client

Endpoint v1:

```ruby
Teachbase::API::Client.new :endpoint_v1, client_id: "", client_secret: ""
```

Mobile v1:

```ruby
Teachbase::API::Client.new :mobile_v1, user_login: "", password: ""
```

Mobile v2:

```ruby
Teachbase::API::Client.new :mobile_v2, user_login: "", password: ""
```

On mobile API user_login it's email or phone number.
For success authorization in Teachbase API if you are using mobile endpoints must have set up 'account_id':

```ruby
Teachbase::API::Client.new :mobile_v2, user_login: "", password: "", account_id: ""
```

Avaliable options for Client:
```ruby
:client_id, :client_secret, :account_id, :token_time_limit
```

Or you can set 'client_id', 'client_secret', 'account_id' in config/secrets.yml

'token_time_limit' = 7200 seconds

### Sending Request

Note: Replace `_` on `-` in method with name like: "course_session", "notification_settings" and etc. Beacause `_` - default delimiter for methods.

Examples:

```ruby
api = Teachbase::API::Client.new :endpoint_v1, client_id: "", client_secret: ""
api.request "users_sections", id:666

# where 'users_sections' is users/{user_id}/sections, and 'id:666' is user id
# https://go.teachbase.ru/api-docs/index.html#/competences/get_users__id__sections

api = Teachbase::API::Client.new :mobile_v2, account_id: "", user_login: "", password: ""
api.request "course-sessions_materials", cs_id:111, m_id:222

# where 'course-sessions_materials' is /course_sessions/{session_id}/materials/{id}, and 'cs_id:111' is session_id, m_id:222 is material's id
# https://go.teachbase.ru/api-docs/index.html?urls.primaryName=Mobile#/materials/get_course_sessions__session_id__materials__id_

api = Teachbase::API::Client.new :mobile_v2, account_id: "", user_login: "", password: ""
api.request "profile_notification-settings", method: :get # for get http method
api.request "profile_notification-settings", body: {"courses": true, "news": true, "tasks": true,
                                                    "quizzes": true, "programs": true, "webinars": false},
                                             method: :patch #for patch http method

# where 'profile_notification-settings' is /profile/notification_settings
# https://go.teachbase.ru/api-docs/index.html?urls.primaryName=Mobile#/notification%20settings/get_profile_notification_settings
# https://go.teachbase.ru/api-docs/index.html?urls.primaryName=Mobile#/notification%20settings/patch_profile_notification_settings
```

See more about other methods in API docs: https://go.teachbase.ru/api-docs/

Every Request can has several params:
```ruby
:response, :client, :method_name, :request_url, :request_params, :url_ids, :account_id, :http_method, :payload
```

### Getting Response

```ruby
api = Teachbase::API::Client.new :endpoint_v1, client_id: "", client_secret: ""
api.request "users_sections", id:666
api.response.answer.raw #return json
api.response.answer.object #return object with methods
```

## Available methods

Looking for available methods in 'endpoints/versions' folder.
