require './models/user'
require './models/api_token'
require './models/profile'
require './models/course_session'
require './models/section'
require './models/material'
require './models/quiz'
require './models/scorm_package'
require './models/task'

module Teachbase
  module Bot
    class DataLoader
      MAX_RETRIES = 3
      CS_STATES = %i[active archived].freeze
      SECTION_OBJECTS = [ :materials, :scorm_packages, :quizzes, :tasks ].freeze
      SECTION_OBJECTS_CUSTOM_PARAMS = { materials: { "type" => :content_type },
                                        scorm_packages: { "title" => :name } }.freeze
      MAIN_OBJECTS_CUSTOM_PARAMS = { users: { "name" => :first_name },
                                     course_sessions: { "updated_at" => :changed_at } }.freeze
      SECTION_OBJECT_TYPES = { materials: :material,
                       scorm_packages: :scorm_package,
                       quizzes: :quiz,
                       tasks: :task}

      attr_reader :apitoken, :user, :appshell, :authsession

      def initialize(appshell)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @appshell = appshell
        @tg_user = appshell.controller.respond.incoming_data.tg_user
        @encrypt_key = AppConfigurator.new.get_encrypt_key
        @logger = AppConfigurator.new.get_logger
        @retries = 0
      end

      def get_cs_info(cs_id)
        get_data { user.course_sessions.find_by(tb_id: cs_id) }
      end

      def get_user_profile
        get_data { user.profile }
      end

      def get_cs_list(state, limit_count, offset_num)
        get_data { user.course_sessions.order(name: :asc).limit(limit_count).offset(offset_num).where(complete_status: state.to_s,
                                                     scenario_mode: appshell.settings.scenario) }
      end

      def get_cs_sec_list(cs_id)
        get_data { get_cs_info(cs_id).sections.order(position: :asc) }
      end

      def get_cs_sec(section_position, cs_id)
        get_data do
          user.course_sessions.find_by(tb_id: cs_id).sections.find_by(position: section_position)
        end
      end

      def get_cs_sec_content(section_bd)
        return unless section_bd

        section_objects = {}
        get_data do
          SECTION_OBJECTS.each do |content_type|
            section_objects[content_type] = section_bd.public_send(content_type).order(position: :asc)
          end
        end
        section_objects
      end

      def call_profile
        call_data do
          lms_info = authsession.load_profile
          raise "Profile is not loaded" unless lms_info

          profile = Teachbase::Bot::Profile.find_or_create_by!(user_id: user.id)
          user_params = create_attributes(Teachbase::Bot::User.attribute_names, lms_info, MAIN_OBJECTS_CUSTOM_PARAMS[:users])
          user_params[:tb_id] = lms_info["id"]
          profile_params = create_attributes(Teachbase::Bot::Profile.attribute_names, lms_info)
          user.update!(user_params)
          profile.update!(profile_params)
        end
      end

      def call_cs_list(state, mode = :normal)
        raise "No such option for update course sessions list" unless CS_STATES.include?(state.to_sym)
        
        user.course_sessions.where(complete_status: state.to_s).destroy_all if mode == :with_reload

        call_data do
          lms_info = authsession.load_course_sessions(state)
          #@logger.debug "lms_info: #{lms_info}"

          lms_info.each do |course_session_lms|
            cs = user.course_sessions.find_or_create_by!(tb_id: course_session_lms["id"])
            course_session_params = create_attributes(Teachbase::Bot::CourseSession.attribute_names,
                                                      course_session_lms,
                                                      MAIN_OBJECTS_CUSTOM_PARAMS[:course_sessions])
            course_session_params[:complete_status] = state.to_s
            cs.update!(course_session_params)
          end
        end
      end

      def call_cs_info(cs_id)
        call_data do
          authsession.load_cs_info(cs_id)
        end
      end

      def call_cs_sections(cs_id)
        call_data do
          return if course_session_last_version?(cs_id) && !course_session_last_version?(cs_id).sections.empty?

          cs = user.course_sessions.find_by!(tb_id: cs_id)
          user_id = user.id
          cs.sections.destroy_all if cs

          custom_params = { materials: { content_type: "type" },
                            scorm_packages: { name: "title" } }

          #@request_loader = Async do |task|
            authsession.load_cs_info(cs_id)["sections"].each_with_index do |section_lms, ind|
              section_bd = cs.sections.find_or_create_by!(position: ind + 1)
              SECTION_OBJECTS.each do |type|
                fetch_section_objects(type, section_lms, section_bd)
              end
              section_params = create_attributes(Teachbase::Bot::Section.attribute_names, section_lms)
              section_bd.update!(section_params)
            end
          #end
        end
      end

      def fetch_section_objects(conten_type, section_lms, section_bd)
        raise "No such content type: #{conten_type}." unless section_bd.respond_to?(conten_type)

        content_params = to_constantize(SECTION_OBJECT_TYPES[conten_type], "Teachbase::Bot").public_send(:attribute_names)        
        section_lms[conten_type.to_s].each do |content_type_hash|
          attributes = create_attributes(content_params, content_type_hash, SECTION_OBJECTS_CUSTOM_PARAMS[conten_type])
          section_bd.public_send(conten_type)
                    .find_or_create_by!(position: content_type_hash["position"], tb_id: content_type_hash["id"])
                    .update!(attributes)
        end
      end  

      def load_models
        auth_checker unless authsession?
        @apitoken = Teachbase::Bot::ApiToken.find_by(auth_session_id: authsession.id, active: true)
        raise unless apitoken
        
        authsession.api_auth(:mobile, 2, access_token: apitoken.value)
        @user = authsession.user
      rescue RuntimeError
        auth_checker
        retry
      end

      def unauthorize
        return unless authsession?

        authsession.update!(active: false)
      end

      def auth_checker
        authsession?(:with_create)
        @apitoken = Teachbase::Bot::ApiToken.find_or_create_by!(auth_session_id: authsession.id)
        if apitoken.avaliable?
          authsession.api_auth(:mobile, 2, access_token: apitoken.value)
        else
          authsession.update!(active: false)
          login_by_user_data
        end
        return unless authsession.active?
        @user = authsession.user
      end

      private

      def authsession?(option = {})
        @authsession = case option
                       when :with_create
                         @tg_user.auth_sessions.find_or_create_by!(active: true)
                       else
                         @tg_user.auth_sessions.find_by(active: true)
                       end
      end

      def get_data
        load_models
        yield
      end

      def call_data
        load_models
        yield
      rescue RuntimeError => e
        if e.http_code == 401 || e.http_code == 403
          auth_checker
          retry
        elsif (@retries += 1) <= MAX_RETRIES
          @logger.debug "#{e}\n#{I18n.t('retry')} №#{@retries}.."
          sleep(@retries)
          retry
        else
          @logger.debug "Unexpected error after retries: #{e}. code: #{e.http_code}"
          appshell.controller.answer.send_out "#{I18n.t('unexpected_error')}: #{e}"
        end
      end

      def course_session_last_version?(cs_id)
        user.course_sessions.find_by(tb_id: cs_id, changed_at: call_cs_info(cs_id)["updated_at"])
      end

      def login_by_user_data
        user_auth_data = appshell.request_user_data
        raise if user_auth_data.empty?

        authsession.api_auth(:mobile, 2, user_login: user_auth_data[:login], password: user_auth_data[:crypted_password].decrypt)
        raise "Can't authorize authsession id: #{authsession.id}. User auth data: #{user_auth_data}" unless authsession.tb_api.token.value

        token = authsession.tb_api.token
        apitoken.update!(version: token.api_version,
                         api_type: token.api_type,
                         grant_type: token.grant_type,
                         expired_at: token.expired_at,
                         value: token.value,
                         active: true)
        raise "Can't load API Token" unless apitoken

        @user = Teachbase::Bot::User.find_or_create_by!(user_auth_data[:login_type] => user_auth_data[:login])

        user.update!(password: user_auth_data[:crypted_password])
        authsession.update!(auth_at: Time.now.utc,
                            active: true,
                            api_token_id: apitoken.id,
                            user_id: user.id)
      rescue RuntimeError => e
        @logger.debug e.to_s
        authsession.update!(active: false)
      end

      def create_attributes(params, object_type_hash, custom_params = {})
        raise "Params must be an Array. Your params: #{params} is #{params.class}." unless params.is_a?(Array)

        attributes = {}
        replace_key_names(custom_params, object_type_hash) if custom_params && !custom_params.empty?

        @logger.debug "object_type_hash: #{object_type_hash}"

        params.each do |param|
          unless object_type_hash[param.to_s].nil? && [:id, :position].include?(param.to_sym)
            attributes[param.to_sym] = object_type_hash[param.to_s]
          end
        end
        attributes
      end

      def replace_key_names(mapping, initial_hash)
        mapping.each do |old_key, new_key|
          initial_hash[new_key.to_s] = initial_hash.delete(old_key)
        end
      end

      def to_camelize(string)
        string.to_s.split("_").collect(&:capitalize).join
      end

      def to_constantize(data, prefix = "")
        Kernel.const_get("#{prefix}::#{to_camelize(data)}")
      end

    end
  end
end


