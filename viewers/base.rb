module Teachbase
  module Bot
    module Viewers
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

        def prepeare_open_url_button(url, text = "")
          InlineUrlButton.to_open(url, text)
        end

        def menu_show_content(content, open_button = nil)
          cs = content.course_session
          section = content.section
          buttons = InlineCallbackButton.g(buttons_sign: [ I18n.t('back').to_s ],
                                           callback_data: [ "/sec#{section.position}_cs#{cs.tb_id}" ],
                                           emoji: [ :arrow_left ])
          buttons = open_button ? buttons + open_button : buttons
          menu.create(buttons: buttons, type: :menu_inline,
                      text: "#{content.position}. #{attach_emoji(content.content_type.to_sym)} <b>#{content.name}</b>")
        rescue Telegram::Bot::Exceptions::ResponseError => e
          answer.send_out("#{I18n.t('unexpected_error')}")
          @logger.debug "Telegram::Bot::Exceptions::ResponseError: #{e}"
        end

        def show_breadcrumbs(level, stage_names, params = {})
          raise "'stage_names' is a #{stage_names.class}. Must be an Array." unless stage_names.is_a?(Array)

          breadcrumbs = init_breadcrumbs(params)
          raise "Can't find breadcrumbs." unless breadcrumbs

          delimeter = "\n"
          result = []
          stage_names.each do |stage_name|
            result << breadcrumbs[level.to_sym][stage_name]
          end
          to_bolder(result.last)
          result.join(delimeter)
        end

      end
    end
  end
end
