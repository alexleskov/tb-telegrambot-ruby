# frozen_string_literal: true

require './interfaces/object_interface/course_session'
require './interfaces/object_interface/material'
require './interfaces/object_interface/section'
require './interfaces/object_interface/task'
require './interfaces/object_interface/scorm_package'
require './interfaces/object_interface/quiz'

module Teachbase
  module Bot
    module Interfaces
      module Base
        include Viewers::Helper
        include Teachbase::Bot::Interfaces::CourseSession
        include Teachbase::Bot::Interfaces::Material
        include Teachbase::Bot::Interfaces::Section
        include Teachbase::Bot::Interfaces::Task
        include Teachbase::Bot::Interfaces::ScormPackage
        include Teachbase::Bot::Interfaces::Quiz

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods; end

        def print_on_enter(account_name)
          answer.text.send_out "#{Emoji.t(:rocket)}<b>#{I18n.t('enter')} #{I18n.t('in')} #{I18n.t(account_name)}</b>"
        end

        def print_greetings(account_name)
          answer.menu.hide("<b>#{appshell.user_fullname(:string)}!</b> #{I18n.t('greetings')} #{I18n.t('in')} #{I18n.t(account_name)}!")
        end

        def print_on_farewell
          answer.text.send_out "#{Emoji.t(:door)}<b>#{I18n.t('sign_out')}</b>"
        end

        def print_farewell
          answer.menu.hide("<b>#{appshell.user_fullname(:string)}!</b> #{I18n.t('farewell_message')} #{Emoji.t(:crying_cat_face)}")
        end

        def print_on_save(param, status)
          answer.text.send_out "#{Emoji.t(:floppy_disk)} #{I18n.t('editted')}. #{I18n.t(param.to_s)}: <b>#{I18n.t(status.to_s)}</b>"
        end

        def print_update_status(status)
          answer.text.send_out(create_update_status_msg_by(status))
        end

        def ask_enter_the_number(object)
          sign = case object
                 when :section
                   I18n.t('section2')
                 else
                   raise "Can't ask number object: '#{object}'"
                 end
          answer.text.send_out "#{Emoji.t(:pencil2)} <b>#{I18n.t('enter_the_number')} #{sign}:</b>"
        end

        def print_is_empty_by(params = {})
          answer.text.send_out "\n#{create_title(params)}
                           \n#{create_empty_msg}"
        end

        def menu_content_main(params)
          params.merge!(type: :menu_inline, disable_web_page_preview: true, disable_notification: true,
                        slices_count: 2)
          params[:text] ||= I18n.t('start_menu_message')
          params[:mode] ||= :none
          answer.menu.create(params)
        end

        def menu_empty_msg(params)
          params.merge!(type: :menu_inline)
          params[:text] = "#{params[:text]}\n#{create_empty_msg}"
          params[:mode] ||= :none
          back_button = InlineCallbackButton.custom_back(params[:back_button][:action])
          params[:buttons] = InlineCallbackKeyboard.collect(buttons: [back_button]).raw
          answer.menu.create(params)
        end

        def menu_confirm_answer(params)
          raise unless params[:object]

          object = params[:object]
          cs_tb_id = object.course_session.tb_id

          params[:command_prefix] = "confirm_csid:#{cs_tb_id}_secid:#{object.id}_objid:#{object.tb_id}_t:#{object_type(object)}_p:"
          params[:text] = "<b>#{I18n.t('send').capitalize} #{I18n.t('answer').downcase}</b>\n<pre>#{params[:user_answer]}</pre>"
          answer.menu.confirmation(params)
        end

        private

        def object_type(object)
          case object
          when Teachbase::Bot::Task
            :task
          end
        end

        def create_update_status_msg_by(status)
          case status.to_sym
          when :in_progress
            "#{Emoji.t(:arrows_counterclockwise)} <b>#{I18n.t('updating_data')}</b>"
          when :success
            "#{Emoji.t(:thumbsup)} #{I18n.t('updating_success')}"
          else
            "#{Emoji.t(:thumbsdown)} #{I18n.t('error')}"
          end
        end

        def create_empty_msg
          "<b>#{I18n.t('empty')}</b>"
        end
      end
    end
  end
end
