require 'active_record'
require './lib/tbclient/client'

class User < ActiveRecord::Base
  attr_reader :tb_api

  def api_auth(version, oauth_params = {})
    @tb_api = Teachbase::API::Client.new(version, oauth_params)
  end

  def load_profile
    tb_api.request(:profile).response.answer
  end
end
