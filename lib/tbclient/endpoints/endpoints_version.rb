require './lib/tbclient/client'
require './lib/tbclient/endpoints/load_checker'
require './lib/tbclient/endpoints/load_helper'
require './lib/tbclient/endpoints/versions/endpoint_v1'
require './lib/tbclient/endpoints/versions/mobile_v1'
require './lib/tbclient/endpoints/versions/mobile_v2'

module Teachbase
  module API
    module EndpointsVersion
      LIST = { "users" => "User",
               "course-sessions" => "CourseSession",
               "documents" => "Document",
               "news" => "New",
               "oauth" => "Oauth",
               "offline-events" => "OfflineEvent",
               "profile" => "Profile",
               "user-accounts" => "UserAccount",
               "programs" => "Program",
               "tokens" => "Token",
               "user-activity" => "UserActivity" }.freeze # TODO: "clickmeeting-meetings" => "ClickmeetingMeeting"
    end
  end
end
