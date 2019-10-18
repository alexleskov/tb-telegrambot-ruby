require 'active_record'
require './models/api_token'
require './lib/tbclient/client'

module Teachbase
  module Bot
    class User < ActiveRecord::Base
      has_many :api_tokens, dependent: :destroy
      attr_reader :tb_api

      def api_auth(version, oauth_params = {})
        @tb_api = Teachbase::API::Client.new(version, oauth_params)
      end

      def load_profile
        tb_api.request(:profile).response.answer
      end
    end
  end
end
