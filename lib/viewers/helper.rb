module Viewers
  module Helper
    def create_title(params)
      raise "Params is '#{params.class}'. Must be a Hash" unless params.is_a?(Hash)

      if params.keys.include?(:text)
        params[:text]
      else
        Breadcrumb.g(params[:object], params[:stages], params[:params])
      end
    end
  end
end