# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      include Viewers::Helper

      module Base
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods; end

        def print_on_enter(account_name)
          answer.send_out "#{Emoji.t(:rocket)}<b>#{I18n.t('enter')} #{I18n.t('in')} #{I18n.t(account_name)}</b>"
        end

        def print_greetings(account_name)
          menu.hide("<b>#{answer.user_fullname(:string)}!</b> #{I18n.t('greetings')} #{I18n.t('in')} #{I18n.t(account_name)}!")
        end

        def print_on_farewell
          answer.send_out "#{Emoji.t(:door)}<b>#{I18n.t('sign_out')}</b>"
        end

        def print_farewell
          menu.hide("<b>#{answer.user_fullname(:string)}!</b> #{I18n.t('farewell_message')} #{Emoji.t(:crying_cat_face)}")
        end

        def print_on_save(param, status)
          answer.send_out "#{Emoji.t(:floppy_disk)} #{I18n.t('editted')}. #{I18n.t(param.to_s)}: <b>#{I18n.t(status.to_s)}</b>"
        end

        def print_update_status(status)
          answer.send_out(create_update_status_msg_by(status))
        end

        def ask_enter_the_number(object)
          sign = case object
                 when :section
                   I18n.t('section2')
                 else
                   raise "Can't ask number object: '#{object}'"
                 end
          answer.send_out "#{Emoji.t(:pencil2)} <b>#{I18n.t('enter_the_number')} #{sign}:</b>"
        end

        def print_is_empty_by(params = {})
          answer.send_out "\n#{create_title(params)}
                           \n#{create_empty_msg}"
        end

        def menu_empty_msg(text, buttons, mode = :none)
          menu.create(buttons: buttons,
                      text: "#{text}\n#{create_empty_msg}",
                      type: :menu_inline,
                      mode: mode)
        end

        def menu_confirm_answer(object)
          cs_tb_id = object.course_session.tb_id
          menu.confirmation(command_prefix: "confirm_csid:#{cs_tb_id}_objid:#{object.tb_id}_t:#{object_type(object)}_p:")
        end

        private

        def object_type(object)
          case object
          when Teachbase::Bot::Task
            :tasks
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

      end
    end
  end
end
