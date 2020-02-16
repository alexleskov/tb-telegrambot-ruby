require './lib/tbclient/request'

module RequestDefaultParam
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def set_default_request_params(parametr, value)
      @default_request_params[parametr.to_sym] = value
    end

    def default_request_params
      @default_request_params = { page: 1, per_page: 100 }
    end
  end

  protected

  def check_and_apply_default_req_params
    parameters = self.class.default_request_params
    return if parameters.empty?

    parameters.each_key do |parametr|
      request.request_params[parametr] = parameters[parametr] unless request.request_params.key?(parametr)
    end
  end
end
