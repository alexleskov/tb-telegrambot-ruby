# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Base
        class Menu < Teachbase::Bot::InterfaceController
          def sign_in_again
            params.merge!(type: :menu_inline, buttons: InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.sign_in]).raw)
            params[:mode] ||= :none
            params[:text] ||= "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
            answer.menu.create(params)
          end

          def starting
            params.merge!(type: :menu, slices_count: 2)
            params[:text] ||= I18n.t('start_menu_message').to_s
            params[:buttons] = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[sign_in settings]).raw
            answer.menu.create(params)
          end

          def is_empty
            params.merge!(type: :menu_inline)
            params[:text] ||= "#{params[:text]}\n#{sing_on_empty}"
            params[:mode] ||= :none
            back_button = InlineCallbackButton.custom_back(params[:back_button][:action])
            params[:buttons] = InlineCallbackKeyboard.collect(buttons: [back_button]).raw
            answer.menu.create(params)
          end

          def custom_back(params)
            answer.menu.custom_back(params)
          end

          def back
            answer.menu.back
          end

          def confirm_answer
            params[:command_prefix] = "confirm_csid:#{cs_tb_id}_secid:#{entity.section.id}_objid:#{entity.tb_id}_t:#{entity.class.type_like_sym}_p:"
            params[:text] ||= "<b>#{I18n.t('send').capitalize} #{I18n.t('answer').downcase}</b>\n<pre>#{params[:user_answer]}</pre>"
            answer.menu.confirmation(params)
          end

          def settings
            params.merge!(slices_count: 1, type: :menu_inline)
            params[:text] ||= "<b>#{Emoji.t(:wrench)}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
                              \n #{Emoji.t(:video_game)} #{I18n.t('scenario')}: #{I18n.t(to_snakecase(params[:scenario]))}
                              \n #{Emoji.t(:ab)} #{I18n.t('localization')}: #{I18n.t(params[:localization])}"
            params[:mode] ||= :none
            params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: ["#{I18n.t('edit')} #{I18n.t('settings').downcase}"],
                                                        command_prefix: "edit_", buttons_actions: %i[settings]).raw
            answer.menu.create(params)
          end

          def edit_settings
            params.merge!(slices_count: 2, type: :menu_inline)
            params[:text] ||= "<b>#{Emoji.t(:wrench)} #{I18n.t('editing_settings')}</b>"
            params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(settings_class::PARAMS),
                                                        command_prefix: "settings:",
                                                        buttons_actions: settings_class::PARAMS,
                                                        back_button: params[:back_button]).raw
            answer.menu.create(params)
          end

          def choosing(type, option_name)
            params[:text] ||= "<b>#{Emoji.t(:wrench)} #{I18n.t("choose_#{option_name.downcase}")}</b>"
            buttons_signs = to_constantize("#{option_name.upcase}_PARAMS", "Teachbase::Bot::#{type.capitalize}::")
            emojis = to_constantize("#{option_name.upcase}_EMOJI", "Teachbase::Bot::#{type.capitalize}::")
            params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs),
                                                        command_prefix: "#{option_name.downcase}_param:",
                                                        buttons_actions: buttons_signs,
                                                        emojis: emojis,
                                                        back_button: params[:back_button]).raw
            params.merge!(type: :menu_inline, slices_count: buttons_signs.size)
            answer.menu.create(params)
          end

          def ready
            params.merge!(type: :menu, slices_count: 1)
            params[:text] ||= "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_next_answer')} #{Emoji.t(:point_down)}"
            params[:buttons] = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[ready]).raw
            answer.menu.create(params)
          end

          def show_more
            answer.menu.show_more(params)
          end

          def links
            raise unless params[:links].is_a?(Array)

            params.merge!(slices_count: 1, type: :menu_inline, mode: :edit_msg)
            params[:text] ||= "#{create_title(params)}<b>#{Emoji.t(:link)} #{I18n.t('attachments')}</b>"
            buttons = []
            params[:links].each do |link_params|
              raise unless link_params.is_a?(Hash)

              buttons << InlineUrlButton.to_open(link_params["source"], link_params["title"])
            end
            params[:buttons] = InlineUrlKeyboard.collect(buttons: buttons, back_button: params[:back_button]).raw
            answer.menu.create(params)
          end

          private

          def init_commands
            answer.menu.command_list
          end

          def settings_class
            Teachbase::Bot::Setting
          end
        end
      end
    end
  end
end
